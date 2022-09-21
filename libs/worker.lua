local bundlePaths = require('luvi').bundle.paths
local uv = require "uv"
local json = require "json"

---@class worker
local worker = {}
worker.__index = worker

---private function, used on creating child thread
function worker.__inner(dumped,bundles,path,cpath,read_fd,write_fd,thread_name,...)

    -- resolve lua require paths
    package.path = path
    package.cpath = cpath

    -- convert bundle paths back to table, and resolve luvi environment
    local paths = {}
    for str in bundles:gmatch("[^;]+") do
        paths[#paths + 1] = str
    end
    local _, mainRequire = require('luvibundle').commonBundle(paths)

    -- inject the global process table
    _G.process = mainRequire('process').globalProcess()

    -- print function
    local luaprint = print
    local print,printerr do
        local pass,module = pcall(require,"logger")
        if not pass then
            pass,module = pcall(require,"logger/init")
        end
        if not pass then
            pass,module = pcall(require,"libs/logger")
        end
        if not pass then
            pass,module = pcall(require,"libs/logger/init")
        end
        if not pass then
            pass,module = pcall(require,"deps/logger")
        end
        if not pass then
            pass,module = pcall(require,"deps/logger/init")
        end

        if pass then
            module.prefix = thread_name
            print = function (...)
                local args = table.pack(...)
                for i=1,args.n do
                    module.info(tostring(args[i]))
                end
            end
            printerr = function (...)
                local args = table.pack(...)
                for i=1,args.n do
                    module.error(tostring(args[i]))
                end
            end
        else
            local function rawprint(head,...)
                local str = {head}
                local args = table.pack(...)
                for i=1,args.n do
                    table.insert(str,tostring(args[i]))
                    if i ~= args.n then
                        table.insert(str,"\t")
                    end
                end
                table.insert(str,"\n")
                local content = table.concat(str)

                local stdout = process and process.stdout
                local write = stdout.write
                local passWrite
                if write then
                    passWrite = pcall(write,stdout,content)
                end
                if (not write) or (not passWrite) then
                    if io then
                        io.write(content)
                    else luaprint(content)
                    end
                end
            end
            local printHead = ("[THREAD %s] "):format(thread_name)
            print = function (...)
                rawprint(printHead,...)
            end
            local errHead = ("*ERROR* [THREAD %s] "):format(thread_name)
            printerr = function (...)
                rawprint(errHead,...)
            end
        end
    end

    -- load dumped function and set environment
    local fn = loadstring(dumped) if not fn then return end
    local fn_env = getfenv(fn)
    fn_env.require = mainRequire
    fn_env.print = print
    fn_env.printerr = printerr

    -- load libs
    local uv = require "uv"
    local json = require "json"

    -- setup read/write pipe
    local read_pipe = uv.new_pipe()
    read_pipe:open(read_fd)
    local write_pipe = uv.new_pipe()
    write_pipe:open(write_fd)

    -- setup handler class
    ---Handleing data receiving/sending on child thread
    ---@class workerChildHandler
    local handler = {__request_ids = 0}
    ---Set callback function on message receive return value is sent to main thread.
    ---@param func function set Callback function, return value is sent into main thread. if alreadly setted, will overwrite last function
    function handler.onRequest(func)
        handler.__func = func
    end
    ---Set this worker thread ready and make handshake with main thread
    ---YOU SHOULD CALL THIS FUNCTION AFTER ALL HANDLER FUNCTION BINDED
    function handler.ready()
        local routine = coroutine.running()
        if not routine then
            error("handler.ready must be called on coroutine")
        end

        if handler.__is_ready then return end
        write_pipe:write('{"id":"READY"}')
        handler.__waiting_ready = routine
        coroutine.yield()
        handler.__is_ready = true
    end
    ---Send request to main thread
    function handler.request(data)
        local routine = coroutine.running()
        if not routine then
            error("handler.request must be called on coroutine")
        end

        local id = handler.__request_ids
        handler[id] = routine
        handler.__request_ids = id+1
        write_pipe:write(json.encode({r=1; d=data; i=id}))
        local hasError,result = coroutine.yield()

        if hasError then error(result) end
        return result
    end
    ---Print error on console, this function not make actual error (not throw thread)
    handler.printerr = printerr
    ---A print function, if logger library exist, use logger library. or using process.stdout or io.write or lua's default print function
    handler.print = print
    ---args from main thread (worker:ready(...))
    handler.args = table.pack(...)
    fn_env.handler = handler

    local READY = '{"id":"READY"}'
    local KILL = '{"id":"KILL"}'
    local killed
    local function onRead(err, chunk)
        if err then
            printerr(("error occurred on reading pipe : %s"):format(tostring(err)))
            uv.close(read_pipe)
            pcall(write_pipe.write,write_pipe,'{"id":"CLOSE"}')
            uv.close(write_pipe)
            return
        end

        -- handshake
        if chunk == READY then
            local waitter = handler.__waiting_ready
            if waitter then
                local pass,resumeErr = coroutine.resume(waitter)
                if not pass then printerr(("error occurred on resume READY routine\n%s"):format(tostring(resumeErr))) end
            else
                printerr("received READY before waitter setted")
            end
            write_pipe:write('{"id":"START"}')
            return
        elseif chunk == KILL then
            read_pipe:read_stop()
            read_pipe:close()
            write_pipe:close()
            pcall(uv.stop)
            return
        end

        if not handler.__is_ready then
            printerr("received data before handler.ready called")
            return
        end

        -- decode data
        local data,_,decodeErr = json.decode(chunk)
        if not data then
            printerr(("error occurred on decoding json.\n%s\nchunk : %s"):format(tostring(decodeErr),tostring(chunk)))
            return
        end

        -- check data
        local id = data.i
        local direction = data.r
        if not id then
            printerr(("job id not got.\nchunk : %s"):format(chunk))
            return
        elseif not direction then
            printerr(("direction not got.\nchunk : %s"):format(chunk))
            return
        end

        -- reverse pipe, request result received (child thread => main thread)
        if direction == 1 then
            local routine = handler[id]
            handler[id] = nil
            if not routine then
                printerr(("got request result from main thread, but callback routine was not found\bchunk : %s"):format(tostring(chunk)))
                return
            end
            local derr = data.e
            local ddata = data.d
            local hasError = derr and true or false
            local pass,errResume = coroutine.resume(routine,hasError,hasError and derr or ddata)
            if not pass then
                printerr(("got request result from main thread, but error occurred on callback routine\n%s\nchunk : %s"):format(tostring(errResume),tostring(chunk)))
            end
            return
        -- main thread => child thread (request from main)
        elseif direction == 0 then
            local func = handler.__func
            if not func then
                printerr(("received data before onRequest called\nchunk : %s"):format(tostring(chunk)))
                return
            end

            local pass,result = pcall(func,data.d)
            if not pass then -- catch error
                printerr(("error occurred on calling onRequest function\n%s\nchunk : %s"):format(tostring(result),tostring(chunk)))
                write_pipe:write(json.encode{
                    i=id; e=tostring(result); r=0
                })
                return
            end

            -- write result
            write_pipe:write(json.encode{
                i=id; d=result; r=0
            })
            return
        else
            printerr(("unknown direction int got (%s)\nchunk : %s"):format(tostring(direction),tostring(chunk)))
            return
        end
    end
    read_pipe:read_start(function (...)
        coroutine.wrap(onRead)(...)
    end)

    -- set error handler
    local function protected()
        xpcall(fn,function (err)
            local traceback = debug.traceback(err)
            printerr(("Uncaught exception:\n %s"):format(tostring(traceback)))
            return traceback
        end,handler)
    end
    coroutine.wrap(protected)()

    uv.run()
end

---Set callback function on message receive return value is sent to child thread.
---@param func function set Callback function, return value is sent into child thread. if alreadly setted, will overwrite last function
function worker:onRequest(func)
    self.__func = func
    return self
end

function worker:request(data)
    local routine = coroutine.running()
    if not routine then
        error("handler.request must be called on coroutine")
    end

    local id = self.__request_ids
    self[id] = routine
    self.__request_ids = id+1

    self.__write_pipe:write(json.encode({r=0; d=data; i=id}))
    local hasError,result = coroutine.yield()

    if hasError then error(result) end
    return result
end

function worker:protectedRequest(data)
    local routine = coroutine.running()
    if not routine then
        error("handler.protectedRequest must be called on coroutine")
    end

    local id = self.__request_ids
    self[id] = routine
    self.__request_ids = id+1

    self.__write_pipe:write(json.encode({r=0; d=data; i=id}))
    local hasError,result = coroutine.yield()
    return not hasError,result
end

local KILL = '{"id":"KILL"}'
function worker:kill()
    self.__write_pipe:write(KILL)
    self.__read_pipe:read_stop()
    self.__read_pipe:close()
    self.__write_pipe:close()
    uv.thread_join(self.__thread)
    self.__thread = nil
    self.__read_pipe = nil
    self.__write_pipe = nil
    self.__pipeOut = nil
    self.__pipeIn = nil
    self.__name = nil
    self.__func = nil
    self.__print = nil
    self.__printerr = nil
    self.__request_ids = nil
    setmetatable(self,nil)
end

---Set this worker thread ready and make handshake with main child
---YOU SHOULD CALL THIS FUNCTION AFTER ALL HANDLER FUNCTION BINDED
function worker:ready(...)
    local dumped = self.__dumped; self.__dumped = nil
    self.__waiting_start = coroutine.running()
    local thread = uv.new_thread(
        worker.__inner,
        dumped,
        table.concat(bundlePaths, ";"),
        package.path,
        package.cpath,
        self.__pipeIn.read,
        self.__pipeOut.write,
        self.__name or "DEFAULT",
        ...
    )
    self.__thread = thread
    coroutine.yield()
    return self
end

---A print function, if logger library exist, use logger library. or using process.stdout or io.write or lua's default print function
function worker:print(...)
    self.__print(...)
end

---Print error on console, this function not make actual error (not throw thread)
function worker:printerr(...)
    self.__printerr(...)
end

---Set child thread work handler function, this function can be called when only ready was not called
function worker:setWorkHandler(workHandler)
    if type(workHandler) ~= "function" then
        error(("worker:setWorkHandler argument #1 'workHandler' must be function, but got %s"):format(workHandler))
    end
    local dumped = type(workHandler)=='function'
        and string.dump(workHandler) or workHandler
    self.__dumped = dumped
end

local START = '{"id":"START"}'
local READY = '{"id":"READY"}'
function worker.new(name,workHandler)
    if type(name) ~= "string" then
        error(("worker.new argument #1 'name' must be string, but got %s"):format(name))
    elseif workHandler ~= nil and type(workHandler) ~= "function" then
        error(("worker.new argument #2 'workHandler' must be function or nil, but got %s"):format(workHandler))
    end

    ---@type worker
    local this = {__request_ids=0,__name = name}

    if workHandler then
        local dumped = type(workHandler)=='function'
            and string.dump(workHandler) or workHandler
        this.__dumped = dumped
    end

    local pipeIn = uv.pipe({nonblock=true}, {nonblock=true})
    local pipeOut = uv.pipe({nonblock=true}, {nonblock=true})

    this.__pipeIn = pipeIn
    this.__pipeOut = pipeOut

    local read_pipe = uv.new_pipe()
    read_pipe:open(pipeOut.read)
    this.__read_pipe = read_pipe

    local write_pipe = uv.new_pipe()
    write_pipe:open(pipeIn.write)
    this.__write_pipe = write_pipe

    -- print function
    local luaprint = print
    local print,printerr do
        local pass,module = pcall(require,"logger")
        if not pass then
            pass,module = pcall(require,"logger/init")
        end
        if not pass then
            pass,module = pcall(require,"libs/logger")
        end
        if not pass then
            pass,module = pcall(require,"libs/logger/init")
        end
        if not pass then
            pass,module = pcall(require,"deps/logger")
        end
        if not pass then
            pass,module = pcall(require,"deps/logger/init")
        end

        if pass then
            print = function (...)
                local args = table.pack(...)
                for i=1,args.n do
                    module.info(("[MAIN THREAD %s] %s"):format(tostring(this.__name),tostring(args[i])))
                end
            end
            printerr = function (...)
                local args = table.pack(...)
                for i=1,args.n do
                    module.error(("*ERROR* [MAIN THREAD %s] %s"):format(tostring(this.__name),tostring(args[i])))
                end
            end
        else
            local function rawprint(head,...)
                local str = {head}
                local args = table.pack(...)
                for i=1,args.n do
                    table.insert(str,tostring(args[i]))
                    if i ~= args.n then
                        table.insert(str,"\t")
                    end
                end
                table.insert(str,"\n")
                local content = table.concat(str)

                local stdout = process and process.stdout
                local write = stdout.write
                local passWrite
                if write then
                    passWrite = pcall(write,stdout,content)
                end
                if (not write) or (not passWrite) then
                    if io then
                        io.write(content)
                    else luaprint(content)
                    end
                end
            end
            local printHead = ("[MAIN THREAD %s] "):format(tostring(this.__name))
            print = function (...)
                rawprint(printHead,...)
            end
            local errHead = ("*ERROR* [MAIN THREAD %s] "):format(tostring(this.__name))
            printerr = function (...)
                rawprint(errHead,...)
            end
        end
    end
    this.__print = print
    this.__printerr = printerr

    setmetatable(this,worker)

    read_pipe:read_start(function(err, chunk)
        if err then
            this:printerr(("error occurred on reading pipe\n%s"):format(tostring(err)))
            return
        end

        -- handshake
        if chunk == READY then
            write_pipe:write(READY)
            return
        elseif chunk == START then
            local waittingStart = this.__waiting_start
            if not waittingStart then
                this:printerr("received START before worker:ready called")
                return
            end
            this.__waiting_start = nil

            local pass,resumeErr = coroutine.resume(waittingStart)
            if not pass then this:printerr(("error occurred on resume READY routine\n%s"):format(tostring(resumeErr))) end
            return
        end

        -- decode data
        local data,_,decodeErr = json.decode(chunk)
        if not data then
            this:printerr(("error occurred on decoding json.\n%s\nchunk : %s"):format(tostring(decodeErr),tostring(chunk)))
            return
        end

        -- check data
        local id = data.i
        local direction = data.r
        if not id then
            this:printerr(("job id not got.\nchunk : %s"):format(chunk))
            return
        elseif not direction then
            this:printerr(("direction not got.\nchunk : %s"):format(chunk))
            return
        end

        -- reverse pipe, request result received (child thread => main thread)
        if direction == 1 then
            local func = this.__func
            if not func then
                this:printerr(("received data before onRequest called\nchunk : %s"):format(tostring(chunk)))
                return
            end

            local pass,result = pcall(func,data.d)
            if not pass then -- catch error
                this:printerr(("error occurred on calling onRequest function\n%s\nchunk : %s"):format(tostring(result),tostring(chunk)))
                write_pipe:write(json.encode{
                    i=id; e=tostring(result); r=1
                })
                return
            end

            -- write result
            write_pipe:write(json.encode{
                i=id; d=result; r=1
            })
            return
        -- main thread => child thread
        elseif direction == 0 then
            local routine = this[id]
            this[id] = nil
            if not routine then
                this:printerr(("got request result from child thread, but callback routine was not found\bchunk : %s"):format(tostring(chunk)))
                return
            end
            local derr = data.e
            local ddata = data.d
            local hasError = derr and true or false
            local pass,errResume = coroutine.resume(routine,hasError,hasError and derr or ddata)
            if not pass then
                this:printerr(("got request result from child thread, but error occurred on callback routine\n%s\nchunk : %s"):format(tostring(errResume),tostring(chunk)))
            end
            return
        else
            this:printerr(("unknown direction int got (%s)\nchunk : %s"):format(tostring(direction),tostring(chunk)))
            return
        end
    end)

    return this
end

-- local work = worker.new("testingThread",
--     ---@param handler workerChildHandler
--     function(handler)
--         handler.onRequest(function(data)
--             -- 대충 복잡도가 미친듯이 큰 무언가
--             print(handler.request())
--             return data + 1
--         end)
--         handler.ready()
--     end
-- )

-- work:onRequest(function(data)
--     -- error("너가 왜 보내냐?")
--     return "wow"
-- end)
-- work:ready()
-- print("준비됨")
-- print(work:request(32))
-- print(work:request(99))
-- print(work:request(123123))
-- work:kill()
-- require"logger".info(work)

return worker
