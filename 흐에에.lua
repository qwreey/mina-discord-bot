
local mem = {}

local parlang = {}
parlang.__index = parlang

local helper = {}
parlang.helper = helper
function helper.makeints(str)
    local result = ""
    for i,v in pairs{string.byte(str,1,-1)} do
        local r = {}
        while true do
            if v % 20 == 0 then
                v = v / 20
                table.insert(r,"흐에에에에흐에에에에에")
            elseif v % 18 == 0 then
                v = v / 18
                table.insert(r,"흐에에에흐에에에흐에에")
            elseif v % 16 == 0 then
                v = v / 16
                table.insert(r,"흐에에에에흐에에에에")
            elseif v % 15 == 0 then
                v = v / 15
                table.insert(r,"흐에에에에에흐에에에")
            elseif v % 14 == 0 then
                v = v / 14
                table.insert(r,"흐에에에에에에에흐에에")
            elseif v % 12 == 0 then
                v = v / 12
                table.insert(r,"흐에에에흐에에에에")
            elseif v % 10 == 0 then
                v = v / 10
                table.insert(r,"흐에에에에에흐에에")
            elseif v % 9 == 0 then
                v = v / 9
                table.insert(r,"흐에에에흐에에에")
            elseif v % 8 == 0 then
                v = v / 8
                table.insert(r,"흐에에에에흐에에")
            elseif v % 6 == 0 then
                v = v / 6
                table.insert(r,"흐에에에흐에에")
            elseif v % 4 == 0 then
                v = v / 4
                table.insert(r,"흐에에에에")
            elseif v % 3 == 0 then
                v = v / 3
                table.insert(r,"흐에에에")
            elseif v % 2 == 0 then
                v = v / 2
                table.insert(r,"흐에에")
            else break
            end
        end
        table.insert(r,"흐")
        table.insert(r,string.rep("에",v))

        result = result .. table.concat(r) .. " "
    end

    return result:sub(1,-2)
end

-- 흐에에흐에에에에 같은 수를 루아 number 로 바꿈 
-- 주어진 문장이
function parlang:_parseint(str)
    if not str then return end
    if (not string.match(str,"^흐")) and (not string.match(str,"^호")) then return end
    local pos,expmode,ints,pointermode = 0,false,{},false
    for char in string.gmatch(str,utf8.charpattern) do
        if char == "흐" then
            pos = pos + 1
            expmode = false
            ints[pos] = 0
        elseif char == "호" then
            pos = pos + 1
            expmode = true
            ints[pos] = 1
        elseif char == "에" then
            if expmode then
                if ints[pos] == 1 then
                    ints[pos] = 2
                else
                    ints[pos] = ints[pos] * 2
                end
            else
                ints[pos] = ints[pos] + 1
            end
        elseif char == "!" then
            pointermode = true
        else error "unsupported int"
        end
    end
    local int = 1
    for _,v in ipairs(ints) do
        int = int * v
    end
    if pointermode then
        return self._mem[int]
    end
    return int
end
function parlang.new()
    return setmetatable({_mem = {},_pointer=1},parlang)
end
function parlang:_setpointer(pos)
    if not pos then error "pos must be int" end
    self._pointer = pos
end
function parlang:_write(bytes)
    for i,v in ipairs(bytes) do
        self._mem[self._pointer+i-1] = v
    end
end
function parlang:_stringify(length)
    local str = {}
    for i = self._pointer,self._pointer+length-1 do
        table.insert(str,string.char(self._mem[i]))
    end
    return table.concat(str)
end
function parlang:_print(str)
    print(str)
end
-- return {ints}, endAt
function parlang:_parseints(splitted,i)
    local ints = {}
    while true do
        local str = splitted[i]
        if str ~= " " and str ~= "\n" and str ~= "\t" and str ~= "\r" then
            local int = self:_parseint(str)
            if not int then
                return ints,i
            end
            table.insert(ints,int)
        end
        i = i + 1
    end
end
function parlang:execute(code)
    local splitted = {}
    local length = 1
    for str in string.gmatch(code,utf8.charpattern) do
        if str == " " or str == "\n" or str == "\t" or str == "\r" then
            length = length + 1
        else
            splitted[length] = (splitted[length] or "") .. str
        end
    end

    local pos = 1
    while true do
        local str = splitted[pos]
        if not str then pos = pos + 1 -- pass
        elseif str:sub(1,1) == "#" then pos = pos + 1 -- pass (comment)
        elseif str == "냐" then -- move pointer
            local ints
            ints,pos = self:_parseints(splitted,pos+1)
            self:_setpointer(ints[1])
        elseif str == "냥" then -- write ints at pointer
            local ints
            ints,pos = self:_parseints(splitted,pos+1)
            self:_write(ints)
        elseif str == "냐냥" then -- print out memory with length (at pointer)
            local ints
            ints,pos = self:_parseints(splitted,pos+1)
            self:_print(self:_stringify(ints[1]))
        elseif str == "냐옹" then -- print out number (at pointer)
            local ints
            ints,pos = self:_parseints(splitted,pos+1)
            self:_print(ints[1])
        elseif str == "냥?" then -- get numbers from user input (set to pointer)
            local routine = coroutine.running()
            require"pretty-print".stdin:read_start(coroutine.wrap(function (err, data)
                require"pretty-print".stdin:read_stop()
                coroutine.resume(routine,data)
            end))
            local int = tonumber(coroutine.yield():match("%d+"))
            if not int then
                error "unsupported int from input"
            end
            self:_write{int}
            pos = pos + 1
        elseif str == "기여워" then
            break
        end
    end
end

--[[
parlang.new():execute[[

    냐 흐에 냥 흐에에에흐에에에흐에에흐에에에에흐에 흐에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에 흐에에에흐에에에흐에에흐에에에흐에에흐에 흐에에에흐에에에흐에에흐에에에흐에에흐에 흐에에에흐에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에 흐에에에에흐에에에에흐에에흐에 흐에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에 흐에에에흐에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에에 흐에에에흐에에흐에에에에에에에에에에에에에에에에에에에 흐에에에흐에에에흐에에흐에에에흐에에흐에 흐에에에에흐에에에에에흐에에에에에 냐냥 흐에에에에에에에에에에에 기여워

]]

--[[
        #1번에_12추가
    냐 흐에 냥 호에에흐에에에
    
    #1번메모리_숫자로출력
    냐옹 흐에!
]]

-- coroutine.wrap(xpcall)(function ()
--     parlang.new():execute[[
    
--     냐 흐에에 냥?
--     냐옹 흐에에!
--     냐냥 흐에
    
--     기여워
    
--     ]]
-- end,function(err)
--     print(err)
-- end)


parlang.new():execute(args[2])

-- this = parlang.new()
-- this:_setpointer(1)
-- this:_write{string.byte("Hello world",1,-1)}
-- this:_print(this:_stringify(11))

return parlang
--[[
# 가 붇으면 주석으로 간주하나 띄어쓰기는 허용되지 않으므로 _ 를 이용한다

모든 숫자는 흐에 로 구성되며
흐에 는 1 흐에에 는 2 길이에 따라 수가 늘어난다
흐에에흐에에에 같이 두 수가 붇은 경우는 곱셈으로 간주한다.
흐 대신 호를 이용하면 2의 n 승을 바로 구할 수 있다
맨뒤에 ! 를 넣으면 (e 흐에에!) n 번째 메모리 값을 읽어온다
ㅠ 는 냥? (숫자 읽기) 에서 읽기 실패했을 때 주는 수로 nan 이다

모든 명령문은 '냐' 를 이용하며
냐 : move pointer
냥 : write ints at pointer (can be array of int)
냐냥 : print out memory with length by ascii (at pointer)
냐옹 : print out number (at pointer)
냐아 : toggle int's sign (at pointer)
냐앙 : summing numbers, you should give memory positions two or more. result will saved on pointer
냐아아 : add number (pointer + n)
냐아앙 : multiply numbers (pointer * n)
냐아옹 : divide (pointer / n)
냐오옹 : square (pointer ^ n)
[X] 냥! : if, check pointer's number and input number is same, can be array
[X] 냐냥! : goto. e) 냐냥! 호에
[X] 으에 : goto positions
냥? : get numbers from user input (set to pointer)
[X] 냐냥? : get ascii from user input, length should be given (set to pointer)

기여워 는 프로그램의 끝임. 없다면 컴파일러가 무한 루프에 빠집니다

(1번 메모리에 포인터 놓기) (4*2,2 를 쓰기)
냐 흐에                  냥 흐에에에흐에에 흐에

(포인터 위치로 부터 2 글자 출력)
냐냥 흐에에

기여워 (exit 0)


fun a()
]]


