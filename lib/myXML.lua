local module = {};

local tremove = table.remove
local tinsert = table.insert

local item = {}
item.__index = item;

function item.isItem(thing)
    local ty = type(thing)
    if ty ~= "table" then
        return false,ty
    elseif getmetatable(thing) ~= item then
        return false,ty
    end
    return true,ty
end
local isItem = item.isItem

function item:remove(index)
    local this = self[index]
    if not this then
        error("[ERROR] Xml.Item : cannot removed '%s' because anything match index with '%s' not found from Item")
    end
    this.__parent = nil
    this.__pindex = nil
    tremove(self,index)
end

function item:removeValue(value)
    local pass,ty = isItem(value)
    if not (pass or ty == "string") then
        error(("[ERROR] Xml.Item : removeValue method arg 1 'value' must be an item object or a string, but got %s"):format(type(value)))
    end
    for i,v in pairs(self) do
        if v == value then
            if ty ~= "string" then
                value.__parent = nil;
                value.__pindex = nil;
            end
            tremove(self, i)
            return true;
        end
    end
    return false;
end

function item:insert(index,value)
    local pass,ty = isItem(value)
    if not (pass or ty == "string") then
        error(("[ERROR] Xml.Item : insert method arg 2 'value' must be an item object or a string, but got %s"):format(type(value)))
    end
    tinsert(self,index,value)
    if ty ~= "string" then
        value.__parent = self
        value.__pindex = index
    end
end

function item:append(value)
    local pass,ty = isItem(value)
    if not (pass or ty == "string") then
        error(("[ERROR] Xml.Item : append method arg 1 'value' must be an item object or a string, but got %s"):format(type(value)))
    end
    tinsert(self,value)
    if ty ~= "string" then
        value.__parent = self
        value.__pindex = #self
    end
end

function item:prepend(value)
    local pass,ty = isItem(value)
    if not (pass or ty == "string") then
        error(("[ERROR] Xml.Item : prepend method arg 1 'value' must be an item object or a string, but got %s"):format(type(value)))
    end
    if ty ~= "string" then
        value.__parent = self
        value.__pindex = 1
    end
    tinsert(self,1,value)
end

--[[!autoDoc!
@define class:item
    function item:getFirstChildByTag(tag)
        i: get child object by using tag
        arg1 string tag: tag of child
        return: class:item/nil child item , int index
!autoDoc!]]
function item:getFirstChildByTag(tag)
    if type(tag) ~= "string" then
        error(("[ERROR] Xml.Item : getFirstChildByTag method arg 1 'tag' must be a string, but got %s"):format(type(value)))
    end
    for i,v in ipairs(self) do
        if v.tag == tag then
            return v,i
        end
    end
end

--[[!autoDoc!
@define class:item
    function item:getChildrenByTag(tag)
        i: get child objects by using tag
        arg string tag: tag of children
        return: table of class:item/nil
!autoDoc!]]
function item:getChildrenByTag(tag)
    if type(tag) ~= "string" then
        error(("[ERROR] Xml.Item : getFirstChildByTag method arg 1 'tag' must be a string, but got %s"):format(type(value)))
    end
    local t,c = {},0
    for i,v in ipairs(self) do
        if type(v) == "table" and v.tag == tag then
            t[i] = v
            c = c + 1
        end
    end
    return t,c
end

--[[!autoDoc!
@define class:item
    function item:getParent()
        i: get parent of item
        return: item/nil
!autoDoc!]]
function item:getParent()
    return self.__parent
end

--[[!autoDoc!
@define class:item
    function item:getIndex()
        i: get index of item from parent item
        return: int/nil
!autoDoc!]]
function item:getIndex()
    return self.__pindex
end

--[[!autoDoc!
@define class:item
    function item:destroy()
        i: destroy it self and remove from parent item (if is exist)
!autoDoc!]]
function item:destroy()
    local p = self.__parent
    if p then
        p:removeValue(self)
    end

    self.__parent = nil;
    self.__pindex = nil;

    setmetatable(self,nil)
end

--[[!autoDoc!
@define calss:item
    i: handler of xml items
    string item.tag
        i: tag of itself, it must be string
    table/nil item.option
        i: option of itself, you can make this property to empty with nil
    string/calss:item item[n]
        i: child object, you can modify with table lib and methods of class:item
    function item.new(tag,option,t)
        i: make new item
        arg1 string tag: tag of new item, it means <tag></tag>
        arg2 table/nil: option of new item, it means <a option></a>
        arg3 table/nil t: include child items, you can make empty this
        return: class:item
!autoDoc!]]
function item.new(tag,option,t)
    t = (t == nil and {}) or (type(t) == "table" and t) or {}
    if type(tag) ~= "string" then
        error(("[ERROR] Xml.Item : new function arg 1 'tag' must be a string, but got %s"):format(type(tag)))
    elseif option ~= nil and type(option) ~= "table" then
        error(("[ERROR] Xml.Item : new function arg 2 'option' must be a nil or a table, but got %s"):format(type(option)))
    end

    t.tag = tag
    t.option = option

    t.__pindex = nil
    t.__parent = nil

    setmetatable(t,item)

    return t
end

module.item = item

local sgsub = string.gsub
local schar = string.char
local function toLuaStr(str)
    str = sgsub(str,"&#x([%x]+)%;",function(h)
        return sgsub(tonumber(h,16))
    end)
    str = sgsub(str,"&#([0-9]+)%;",function(h)
        return sgsub(tonumber(h,10))
    end)
    str = sgsub(str,"&quot;",'"')
    str = sgsub(str,"&apos;","'")
    str = sgsub(str,"&gt;",">")
    str = sgsub(str,"&lt;","<")
    str = sgsub(str,"&amp;","&")
    return str
end
module.toLuaStr = toLuaStr

local sbyte = string.byte
local sformat = string.format
local function toXmlStr(str)
    str = sgsub(str,"&","&amp;")
    str = sgsub(str,"<","&lt;")
    str = sgsub(str,">","&gt;")
    str = sgsub(str,"\"","&quot;")
   	str = sgsub(str,"([^%w%&%;%p%\t%\32])",function (c)
        return sformat("&#x%X;", sbyte(c))
    end)
	return str
end
module.toXmlStr = toXmlStr

-- <a option1="test" option2="test2"></a>
-- => {option1 = "test", option2 = "test2"}
local sfind = string.find
local ssub = string.sub
local optionFind = "\32-([%w-_]+)\32-="
local function strToOption(str)
    local option = {};
    while true do
        local nameStart,nameEnd,name = sfind(str,optionFind)
        if not nameStart then
            return option;
        end
        local qtStart,_ = sfind(str,"\"",nameEnd+1)
        local qtEnd,_ = sfind(str,"\"",qtStart+1)
        option[name] = toLuaStr(ssub(str,qtStart+1,qtEnd-1))
        str = ssub(str,qtEnd+1,-1);
    end
    return option
end
module.strToOption = strToOption

-- {option1 = "test", option2 = "test2"}
-- => <a option1="test" option2="test2"></a>
local optionFormat = '%s%s="%s" '
local function optionToStr(option)
    local str = ""
    if not option then
        return str
    end
    for i,v in pairs(option) do
        str = optionFormat:format(str,i,toXmlStr(v))
    end
    return ssub(str,1,-2);
end
module.optionToStr = optionToStr

local holderTag = "myXML_Main"
local tagFind = "<([%/%?!]?)\32-([%w:%-_]+)(.-)([%/%?!]?)>"
function module.xmlToItem(xml)
    local main = item.new(holderTag)
    local stack = {}
    local now = main
    while true do
        local posStart,posEnd,prefix,tag,option,suffix = sfind(xml,tagFind);
        if posStart == nil then
            break
        end
        option = strToOption(option)

        -- append string
        local str = ssub(xml,1,posStart-1)
        if sfind(str,"[^\32\n]") then
            now:append(str)
        end

        if suffix and suffix ~= "" then -- self start, self end
            now:append(item.new(tag,option))
        elseif prefix and prefix ~= "" then -- end last tag
            if now.tag ~= tag then
                error(("[ERROR] Xml.xmlToItem : start tag and end tag is not match! startTag: %s; endTag: %s;"):format(now.tag,tag))
            end
            tremove(stack)
            now = stack[#stack] or main
        else
            local this = item.new(tag,option)
            now:append(this)
            now = this
            tinsert(stack,this)
        end

        xml = string.sub(xml,posEnd+1,-1)
    end
    setmetatable(main,nil)
    main.tag = nil;
    main.option = nil;
    return main
end

local function itemToXml(thing)
    local pass,ty = isItem(thing)
    if not pass then
        if ty == "table" then
            local str = ""
            for _,v in ipairs(thing) do
                str = str .. itemToXml(v) .. " "
            end
            return ssub(str,1,-2)
        end
        return thing
    end
    local optStr = optionToStr(thing.option)
    local tag = thing.tag
    if #thing == 0 then
        return ("<%s%s%s/>"):format(tag,optStr == "" and "" or "\32",optStr)
    end
    local str = ("<%s%s%s>%%s</%s>"):format(tag,optStr == "" and "" or "\32",optStr,tag)
    local child = ""
    for i,v in ipairs(thing) do
        child = child .. itemToXml(v)
    end
    return str:format(child)
end

function module.itemToXml(nitem)
    local pass,ty = isItem(nitem);
    if not (pass or ty == "table") then
        error(("[ERROR] Xml.itemToXml : arg 1 'nitem' must be a table or an item, but got %s"):format(ty))
    end
    return itemToXml(nitem)
end

return module