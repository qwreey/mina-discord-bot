local module = {};

function module.getLove(User)
    local UserId = (type(User) == "string") and (User) or (User.id);
    print("try to get " .. UserId .. "'s love");
end;


return module;