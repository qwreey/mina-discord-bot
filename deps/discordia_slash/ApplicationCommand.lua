local discordia = require("discordia")
local endpoints = require('./endpoints')
local f = string.format
local Snowflake_m = discordia.class.classes.Snowflake
local AC, ACgetters = discordia.class('ApplicationCommand', Snowflake_m)

local function recursiveOptionsMap(t)
	local map = {}

	for _, v in ipairs(t) do
		local name = string.lower(v.name)
		v.name = name
		map[name] = v

		if v.options then
			v.mapoptions = recursiveOptionsMap(v.options)
		end
	end

	return map
end

function AC:__init(data, parent)
	self._id = data.id
	self._parent = parent
	self._name = data.name
	self._description = data.description
	self._default_permission = data.default_permission or true
	self._version = data.version
	self._callback = data.callback
	self._guild = parent._id and parent

	if not self._options then
		self._options = data.options or {}
	end
end

function AC:publish()
	if self._id then return self:edit() end
	local g = self._guild

	if not g then
		local res, err = self.client._api:request('POST', f(endpoints.COMMANDS, self.client._slashid), {
			type = 1;
			name = self._name,
			description = self._description,
			options = self._options,
			-- default_permission = self._default_permission
		})

		if not res then
			return nil, err
		else
			self._id = res.id

			return self
		end
	else
		local res, err = self.client._api:request('POST', f(endpoints.COMMANDS_GUILD, self.client._slashid, g._id), {
			type = 1;
			name = self._name,
			description = self._description,
			options = self._options,
			-- default_permission = self._default_permission
		})

		if not res then
			return nil, err
		else
			self._id = res.id

			return true
		end
	end
end

function AC:edit()
	local g = self._guild

	if not g then
		local res, err = self.client._api:request('PATCH', f(endpoints.COMMANDS_MODIFY, self.client._slashid, self._id), {
			type = 1;
			name = self._name,
			description = self._description,
			options = self._options,
			default_permission = self._default_permission
		})

		if not res then
			return nil, err
		else
			return true
		end
	else
		local res, err = self.client._api:request('PATCH', f(endpoints.COMMANDS_MODIFY_GUILD, self.client._slashid, g._id, self._id), {
			type = 1;
			name = self._name,
			description = self._description,
			options = self._options,
			default_permission = self._default_permission
		})

		if not res then
			return nil, err
		else
			return true
		end
	end
end

function AC:setName(name)
	self._name = name
end

function AC:setDescription(description)
	self._description = description
end

function AC:setOptions(options)
	self._options = options
end

function AC:setCallback(callback)
	self._callback = callback
end

function AC:delete()
	local g = self._guild

	if not g then
		self.client._api:request('DELETE', f(endpoints.COMMANDS_MODIFY, self.client._slashid, self._id))
		self.client._globalCommands:_delete(self._id)
	else
		self.client._api:request('DELETE', f(endpoints.COMMANDS_MODIFY_GUILD, self.client._slashid, g._id, self._id))
		g._slashCommands:_delete(self._id)
	end
end

function AC:getPermissions(g)
	g = self._guild or g

	if not g then
		error("Guild is required")
	end

	local stat, err = self.client._api:request('GET', f(endpoints.COMMAND_PERMISSIONS_MODIFY, self.client._slashid, g._id, self._id))

	if stat then
		return stat.permissions
	else
		return stat, err
	end
end

function AC:addPermission(perm, g)
	g = self._guild or g

	if not g then
		error("Guild is required")
	end

	if not self._permissions then
		self._permissions = self:getPermissions(g) or {}
	end

	for k, v in ipairs(self._permissions) do
		if v.id == perm.id and v.type == perm.type then
			if v.permission == perm.permission then return end
			self._permissions[k] = perm
			goto found
		end
	end

	do
		self._permissions[#self._permissions + 1] = perm
	end

	::found::

	return self.client._api:request('PUT', f(endpoints.COMMAND_PERMISSIONS_MODIFY, self.client._slashid, g._id, self._id), {
		permissions = self._permissions
	})
end

function AC:removePermission(perm, g)
	g = self._guild or g

	if not g then
		error("Guild is required")
	end

	if not self._permissions then
		self._permissions = self:getPermissions(g) or {}
	end

	for k, v in ipairs(self._permissions) do
		if v.id == perm.id and v.type == perm.type then
			table.remove(self._permissions, k)
			return
		end
	end

	return self.client._api:request('PUT', f(endpoints.COMMAND_PERMISSIONS_MODIFY, self.client._slashid, g._id, self._id), {
		permissions = self._permissions
	})
end

local function table_eq(table1, table2)
	local avoid_loops = {}
	local function recurse(t1, t2)
	   -- compare value types
	   if type(t1) ~= type(t2) then return false end
	   -- Base case: compare simple values
	   if type(t1) ~= "table" then return t1 == t2 end
	   -- Now, on to tables.
	   -- First, let's avoid looping forever.
	   if avoid_loops[t1] then return avoid_loops[t1] == t2 end
	   avoid_loops[t1] = t2
	   -- Copy keys from t2
	   local t2keys = {}
	   local t2tablekeys = {}
	   for k, _ in pairs(t2) do
		  if type(k) == "table" then table.insert(t2tablekeys, k) end
		  t2keys[k] = true
	   end
	   -- Let's iterate keys from t1
	   for k1, v1 in pairs(t1) do
		  local v2 = t2[k1]
		  if type(k1) == "table" then
			 -- if key is a table, we need to find an equivalent one.
			 local ok = false
			 for i, tk in ipairs(t2tablekeys) do
				if table_eq(k1, tk) and recurse(v1, t2[tk]) then
				   table.remove(t2tablekeys, i)
				   t2keys[tk] = nil
				   ok = true
				   break
				end
			 end
			 if not ok then return false end
		  else
			 -- t1 has a key which t2 doesn't have, fail.
			 if v2 == nil then return false end
			 t2keys[k1] = nil
			 if not recurse(v1, v2) then return false end
		  end
	   end
	   -- if t2 has a key which t1 doesn't have, fail.
	   if next(t2keys) then return false end
	   return true
	end
	return recurse(table1, table2)
 end

function AC:_compare(cmd)
	-- p({
	-- 	name = cmd._name;
	-- 	description = cmd._description;
	-- 	default_permission = cmd._default_permission;
	-- 	options = cmd._option;
	-- })
	-- p({
	-- 	name = self._name;
	-- 	description = self._description;
	-- 	default_permission = self._default_permission;
	-- 	options = self._option;
	-- })
	if self._name ~= cmd._name or self._description ~= cmd._description or self._default_permission ~= cmd._default_permission then
		return false
	end
	if not self._options and cmd._options then
		return false
	end
	if not table_eq(self._options, cmd._options) then return false end

	return true
end

function AC:_merge(cmd)
	self._name = cmd._name
	self._description = cmd._description
	self._options = cmd._options
	self._callback = cmd._callback
	self._default_permission = cmd._default_permission
	self:edit()
end

function ACgetters:name()
	return self._name
end

function ACgetters:description()
	return self._description
end

function ACgetters:options()
	return self._options
end

function ACgetters:guild()
	return self._guild
end

function ACgetters:callback()
	return self._callback
end

function ACgetters:version()
	return self._version
end

return AC