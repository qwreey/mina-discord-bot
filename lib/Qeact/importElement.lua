return function(className)
    return function (items)
        local items = items or {};

        items.IsElement = true;
        items.ClassName = className;
        return items;
    end;
end;