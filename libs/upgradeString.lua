local stringMeta = getmetatable"";

local string = string
local type = type
local rep = string.rep
local format = string.format
local reverse = string.reverse
local gmatch = string.gmatch
local gsub = string.gsub
local match = string.match
local sub = string.sub
local unpack = table.unpack
local none = ""

-- pow for cut front or back
stringMeta.__pow = function(self,n)
    if n > 0 then
        return sub(self,1,n)
    else
        return sub(self,n,-1)
    end
end

-- mod for smart formating
stringMeta.__mod = function(self,t)
    if type(t) ~= "table" then error("mod target must be a table") end
    self = format(self,unpack(t))
    for k,v in pairs(t) do
        if type(k) == "string" then
            self = gsub(self,k,v)
        end
    end
    return self
end

-- sub to gsub(s,"")
stringMeta.__sub = function(self,s)
    if type(s) == "number" then
        if s > 0 then
            return sub(self,1,-s-1)
        else
            return sub(self,s+1,-1)
        end
    end
    return gsub(self,s,none)
end

-- div to match
stringMeta.__div = function(self,s)
    return match(self,s)
end

-- Call to format
stringMeta.__call = function(self,...)
    return format(self,...)
end

-- multiplication to repeat
stringMeta.__mul = function(self,n)
    if n < 0 then
        self = reverse(self)
    end
    return rep(self,n)
end

-- -string to reverse
stringMeta.__unm = function(self)
    return reverse(self)
end

-- pairs for chars
stringMeta.__pairs = function(self)
    return gmatch(self,"()(.)")
end

-- add to concat
stringMeta.__add = function(self,s)
    return self .. s
end
