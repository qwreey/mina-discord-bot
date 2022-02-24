local module = {};

local find = string.find;
local sub = string.sub;
local insert = table.insert;

-- strs
-- " : 1
-- ' : 2
-- ` : 3
-- [[ : 4

function module.run(str)
  local this = {};
  local obj = {s = ""};
  insert(this,obj);

  -- start,before,after
  local function con(st,b,a) -- concat into str
    obj.s = obj.s .. sub(str,1,st+b);
    str = sub(str,st+a,-1);
  end

  -- mode,start,before,after
  local function push(m,st,b,a) -- set obj status
    con(st,b,a);
    obj = {s = "",m = m};
    insert(this,obj);
  end

  local lstr = str; -- last str that check loop is locked
  while true do
    lstr = str;
    local st = find(str,"[\\\"'`%[%]]");
    if not st then
      obj.s = obj.s .. str;
      break;
    end

    local m = obj.m;
    local fstr = sub(str,st,st); -- found str
    if fstr == "\\" then -- on escape
      con(st,1,2);
    elseif fstr == '"' then -- str mode "
      if not m then -- on
        push(1,st,-1,1);
      elseif m == 1 then -- off
        push(nil,st,-1,1);
      else
        con(st,0,1);
      end
    elseif fstr == "'" then -- str mode '
      if not m then -- on
        push(2,st,-1,1);
      elseif m == 2 then -- off
        push(nil,st,-1,1);
      else
        con(st,0,1);
      end
    elseif fstr == "`" then -- str mode `
      if not m then-- on
        push(3,st,-1,1);
      elseif m == 3 then -- off
        push(nil,st,-1,1);
      else
        con(st,0,1);
      end
    elseif fstr == "[" then
      if (not m) and (sub(str,st+1,st+1) == "[") then -- on str mode [[
        push(4,st,-1,2);
      else
        con(st,0,1);
      end
    elseif fstr == "]" then
      if (m == 4) and (sub(str,st+1,st+1) == "]") then -- off str mode [[
        push(nil,st,-1,2);
      else
        con(st,0,1);
      end
    end
    if lstr == str then
      error "Error : compile locked loop";
    end
  end

  return this;
end

return module;
