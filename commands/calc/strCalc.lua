local LuaMathFuncs = {
	roundto = function(Num, DecimalsPoints)
		local Mult = 10 ^ (DecimalsPoints or 0)
		return math.round(Num * Mult) / Mult
	end,
	truncate = function(Num, DecimalsPoints)
		local Mult = 10 ^ (DecimalsPoints or 0)
		return (Num < 0 and math.ceil or math.floor)(Num * Mult) / Mult
	end,
	approach = function(Num, Target, Inc)
		Inc = math.abs(Inc)
		if (Num < Target) then
			return math.min(Num + Inc, Target)
		elseif (Num > Target) then
			return math.max(Num - Inc, Target)
		end

		return Target
	end
}

function MapArgs(Nums, Args)
	for k, Num in ipairs(Nums) do
		if type(Num) == "table" then
			MapArgs(Num, Args)
		elseif Args[Num] then
			Nums[k] = Args[Num]
		end
	end

	return Nums
end

function Interpret(Formula, LocalVars, LocalFuncs, Attempt)
	local Nums
	if type(Formula) == "string" then
		Nums = {{}}

		local Var
		for M1, M2 in string.gmatch(Formula, "(%d*%.?%d*)(%D?)") do
			if Var then
				-- Add non-digit M1 to variable
				Var = Var .. M1
			elseif M1 ~= "" then
				-- Add number M! to stack
				Nums[#Nums][#Nums[#Nums] + 1] = tonumber(M1)
			end

			if M2 == "(" then
				-- Open bracket
				if Var then
					-- End collection of variable and add to stack
					Nums[#Nums][#Nums[#Nums] + 1], Var = LocalVars[Var] or math[Var] or LuaMathFuncs[Var] or Var, nil
				end
				-- Add new stack
				local In = {}
				Nums[#Nums][#Nums[#Nums] + 1] = In
				Nums[#Nums + 1] = In
			elseif M2 == ")" then
				-- Close bracket
				if Var then
					-- End collection of variable and add to stack
					Nums[#Nums][#Nums[#Nums] + 1], Var = LocalVars[Var] or math[Var] or LuaMathFuncs[Var] or Var, nil
				end

				-- Unpack comma separated arguments back to start of brackets so that {1, {7, {5*2}}} goes to {1, 7, 10}
				if Nums[#Nums - 1][#Nums[#Nums - 1] - 1] == "," then
					-- Interpret last comma as it hasn't been interpreted yet and then replace the comma with the result and remove the top stack
					local Result = Interpret(Nums[#Nums], LocalVars, LocalFuncs)
					Nums[#Nums - 1][#Nums[#Nums - 1] - 1] = Result
					Nums[#Nums - 1][#Nums[#Nums - 1]] = nil
					Nums[#Nums] = nil
					-- Go back along the stack until the previous stack doesn't end in a comma (AKA the start of the brackets)
					while Nums[#Nums - 1][#Nums[#Nums - 1] - 1] == "," do
						-- Remove the comma and top stack
						Nums[#Nums - 1][#Nums[#Nums - 1]] = nil
						Nums[#Nums - 1][#Nums[#Nums - 1]] = nil
						-- Add current stacks values to previous stack and remove current stack
						for _, Val in ipairs(Nums[#Nums]) do
							Nums[#Nums - 1][#Nums[#Nums - 1] + 1] = Val
						end
						Nums[#Nums] = nil
					end
				end
				-- Remove brackets stack
				Nums[#Nums] = nil
				-- Get the character before the brackets
				local Previous = Nums[#Nums][#Nums[#Nums] - 1]
				if type(Previous) == "function" or LocalFuncs[Previous] then
					-- If it's a function or a locally defined function then
					if type(Previous) == "function" then
						-- Replace the function with the result of running the function with the last item in the current stack (the arguments)
						Nums[#Nums][#Nums[#Nums] - 1] = Previous(unpack(Nums[#Nums][#Nums[#Nums]]))
					elseif type(LocalFuncs[Previous]) == "number" then
						-- Replace the function with the statically computed result of the function
						Nums[#Nums][#Nums[#Nums] - 1] = LocalFuncs[Previous]
					else
						-- Map the args to the named arguments of the local function
						local MappedArgs = {}
						for i, FuncVariable in ipairs(LocalFuncs[Previous][2]) do
							MappedArgs[FuncVariable] = Nums[#Nums][#Nums[#Nums]][i]
						end
						-- Replace the function with the results of interpreting the local function with the arguments mapped to the corresponding values
						Nums[#Nums][#Nums[#Nums] - 1] = Interpret(MapArgs(LocalFuncs[Previous][1], MappedArgs), LocalFuncs, Attempt)
					end
					-- Remove the arguments that were just used from the stack
					Nums[#Nums][#Nums[#Nums]] = nil
				else
					-- If it's not a function
					if type(Previous) == "number" then
						-- If previous is a number then insert an asterisk before current stack to signify the previous number and current brackets should be multiplied aka 5(2+2) = 5*(2+2) = 5*4 = 20
						Nums[#Nums][#Nums[#Nums] + 1] = Nums[#Nums][#Nums[#Nums]]
						Nums[#Nums][#Nums[#Nums] - 1] = "*"
					end
					-- Replace stack with result of interpretting the stack
					Nums[#Nums][#Nums[#Nums]] = Interpret(Nums[#Nums][#Nums[#Nums]], LocalVars, LocalFuncs)
				end
			elseif M2 == "," then
				-- Argument ended, interpret the stack and add a new stack for next argument
				if Var then
					-- End collection of variable and add to stack
					Nums[#Nums][#Nums[#Nums] + 1], Var = LocalVars[Var] or math[Var] or LuaMathFuncs[Var] or Var, nil
				end
				-- Interpret the stack
				local Result = Interpret(Nums[#Nums], LocalVars, LocalFuncs)
				-- Empty the stack as it will be replaced with just the result
				for i in ipairs(Nums[#Nums]) do
					Nums[#Nums][i] = nil
				end
				-- Add the result and the comma to the now empty stack
				Nums[#Nums][1] = Result
				Nums[#Nums][#Nums[#Nums] + 1] = M2
				-- Add the new stack
				local In = {}
				Nums[#Nums][#Nums[#Nums] + 1] = In
				Nums[#Nums + 1] = In
			elseif M2:find("%W") then
				-- Add non-variable character to stack
				if Var then
					-- End collection of variable and add to stack
					Nums[#Nums][#Nums[#Nums] + 1], Var = LocalVars[Var] or math[Var] or LuaMathFuncs[Var] or Var, nil
				end

				Nums[#Nums][#Nums[#Nums] + 1] = M2
			elseif M2 ~= "" then
				-- Add to variable
				Var = Var and (Var .. M2) or M2
			end
		end

		if Var then
			-- Add unfinished variable to the stack
			Nums[#Nums][#Nums[#Nums] + 1] = LocalVars[Var] or math[Var] or LuaMathFuncs[Var] or Var
		end

		if #Nums ~= 1 then
			error("Unclosed bracket  - (" .. table.concat(Nums[#Nums]))
		end

		-- Set Nums to the only remaining stack
		Nums = Nums[1]
	else
		Nums = Formula
	end

	local a = 1
	-- Factorial
	while a <= #Nums do
		if Nums[a] == "!" and type(Nums[a - 1]) == "number" then
			local Total, x = 1, Nums[a - 1]
			while x > 0 do
				Total = Total * x
				x = x - 1
			end

			Nums[a - 1] = Total

			table.remove(Nums, a)
		else
			a = a + 1
		end
	end

	a = #Nums
	-- Exponent
	while a > 1 do
		if Nums[a] == "^" and type(Nums[a - 1]) == "number" then
			if Nums[a + 1] == "-" and type(Nums[a + 2]) == "number" then
				Nums[a + 1] = -Nums[a + 2]

				table.remove(Nums, a + 2)
			end

			if type(Nums[a + 1]) == "number" then
				Nums[a - 1] = Nums[a - 1] ^ Nums[a + 1]

				table.remove(Nums, a)
				table.remove(Nums, a)

				a = a - 2
			end
		else
			a  = a - 1
		end
	end

	a = 1
	-- Unary and modulus
	while a <= #Nums do
		if Nums[a] == "-" and type(Nums[a - 1]) ~= "number" and type(Nums[a + 1]) == "number" then
			Nums[a] = -Nums[a + 1]

			table.remove(Nums, a + 1)

			a = a + 1
		elseif Nums[a] == "%" and type(Nums[a - 1]) == "number" and type(Nums[a + 1]) == "number" then
			Nums[a - 1] = Nums[a - 1] % Nums[a + 1]

			table.remove(Nums, a)
			table.remove(Nums, a)
		else
			a = a + 1
		end
	end

	a = 1
	-- Multiplication and division
	while a <= #Nums do
		if Nums[a] == "*" and type(Nums[a - 1]) == "number" and type(Nums[a + 1]) == "number" then
			Nums[a - 1] = Nums[a - 1] * Nums[a + 1]

			table.remove(Nums, a)
			table.remove(Nums, a)
		elseif Nums[a] == "/" and type(Nums[a - 1]) == "number" and type(Nums[a + 1]) == "number" then
			Nums[a - 1] = Nums[a - 1] / Nums[a + 1]

			table.remove(Nums, a)
			table.remove(Nums, a)
		else
			a = a + 1
		end
	end

	a = 1
	-- Addition and subtraction
	while a <= #Nums do
		if Nums[a] == "+" and type(Nums[a - 1]) == "number" and type(Nums[a + 1]) == "number" then
			Nums[a - 1] = Nums[a - 1] + Nums[a + 1]

			table.remove(Nums, a)
			table.remove(Nums, a)
		elseif Nums[a] == "-" and type(Nums[a - 1]) == "number" and type(Nums[a + 1]) == "number" then
			Nums[a - 1] = Nums[a - 1] - Nums[a + 1]

			table.remove(Nums, a)
			table.remove(Nums, a)
		elseif a ~= 1 and type(Nums[a]) == "number" and Nums[a] < 0 and type(Nums[a - 1]) == "number" then
			Nums[a - 1] = Nums[a - 1] + Nums[a]

			table.remove(Nums, a)
		else
			a = a + 1
		end
	end

	if Attempt then
		return #Nums == 1 and Nums[1] or Nums
	elseif #Nums == 1 then
		return Nums[1]
	else
		local Invalid = ""
		for _, Num in ipairs(Nums) do
			if type(Num) ~= "number" and not Num:find("%W") then
				Invalid = Invalid .. Num .. ", "
			end
		end

		if Invalid ~= "" then
			error("Unknown variable(s)/function(s) - " .. Invalid:sub(1, -3))
		end

		for _, Num in ipairs(Nums)do
			if type(Num) == "string" and Num:find("%W") then
				Invalid = Invalid .. Num .. ", "
			end
		end

		if Invalid ~= "" then
			error("Invalid operator(s) - " .. Invalid:sub(1, -3))
		end

		for i, Num in ipairs(Nums)do
			if type(Num) == "number" and type(Nums[i - 1]) == "number" then
				Invalid = Invalid ..Nums[i - 1] .. " " .. Num .. ", "
			end
		end

		if Invalid ~= "" then
			error("No operators between numbers - " .. Invalid:sub(1, -3))
		end
	end
end

local insert = table.insert
local function split(str,format)
	local result = {}
	for n in string.gmatch(str,"[^"..format.."]+") do
		insert(result,n)
	end
	return result
end

local module = {}
function module.calc(Formula, LocalVars, LocalFuncs)
	if tonumber(Formula) then
		return tonumber(Formula)
	else
		Formula = Formula:gsub("%s+", "")

		local LocalVars, LocalFuncs = LocalVars or {}, LocalFuncs or {}
		if Formula:find("%;") then
			-- Split the string into variables/functions and the actual expression
			local LastSplit = Formula:reverse():find(";")

			local Locals
			Formula, Locals = Formula:sub(-LastSplit + 1), split(Formula:sub(1, -LastSplit - 1), ";")
			-- Iterates through the user defined variables / functions and interpret them
			for _, Local in ipairs(Locals) do
				local Name, Value = Local:match("(.+)=(.+)")
				if Name then
					local FuncName, Args = Name:match("(%w+)(%b())")
					if FuncName then
						local Func = Interpret(Value, LocalVars, LocalFuncs, true)
						LocalFuncs[FuncName] = type(Func) == "number" and Func or {Func, split(Args:sub(2, -2), ",")}
					else
						local Ran, Result = pcall(Interpret, Value, LocalVars, LocalFuncs)
						if not Ran then
							error("Local variable " .. Name .. " could not be calculated\n" .. Result:sub(-Result:reverse():find(":") + 2))
						end

						LocalVars[Name] = Result
					end
				else
					error("Invalid local function/variable - " .. Local)
				end
			end
		end

		local Result = Interpret(Formula, LocalVars, LocalFuncs)
		return type(Result) == "number" and Result or error("Formula could not be calculated")
	end
end

return module
