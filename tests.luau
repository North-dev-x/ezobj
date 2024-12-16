--!strict
local class = require(script.Parent)

function test(test_name: string, func: () -> any?)
	local success, err = pcall(func)
	if success then
		print("TEST PASSED: "..test_name)
	elseif err and not success then
		error("TEST "..test_name.." FAILED WITH ERROR: ".. err)
	end
end
--- TESTS ---

test("ShouldFail", function()
	local success,err = pcall(function() return class "something" end)
	if success then
		error("Class should not be permitted to initialize with string")
	else
		print(err)
	end
	return 0
end)

-- test inheritance --
test("InheritanceTest", function()
	local SomeClass = class {
		val = 30;
		div = function(self: any?,to_divide_with: number)
			if to_divide_with == 0 then
				return error("Cannot divide by zero")
			end
			return self.val / to_divide_with;
		end,
	}
	type SomeClass = typeof(SomeClass);
	
	local ExtendedClass = SomeClass:extend {
		mul = function(self: any?, ...: number)
			local val = self.val;
			for i,num in pairs({...}) do
				val *= num
			end
			return val
		end,
	}
	
	local newMathObject = ExtendedClass.new {
		val = 20;
	}
	print(newMathObject:div(5))
	print(newMathObject:mul(5))
	print(newMathObject:mul(4,5,6))
	
	-- should fail
	local success,_ = pcall(function() return newMathObject:div(0) end)
	if success then
		return error("Should not be allowed to divide by zero on this class")
	end
	return 0;
end)

-- test abstract class --
test("AbstractClassTest", function()
	-- abstract data structure
	local SomeAbstract = class({}::{
		some_field: number;
		some_method: (any?) -> any?;
	})
	
	-- instantiate abstract data structure with default values
	local new_abstract = SomeAbstract.new {
		some_field = 4;
		some_method = function(self: any?) 
			return self.some_field
		end;
	}
	
	print(new_abstract:some_method())
	return 0; 
end)

-- test __init__ --
test("InitMethodTest",function()
	local SomeClass = class {
		character = nil;
		hrp = nil;

		__init__ = function(self: SomeClass)
			if self.character ~= nil then
				self.hrp = self.character:FindFirstChild("HumanoidRootPart")
			end
		end;
	}
	type SomeClass = typeof(SomeClass)
	local ev = Instance.new("BindableEvent")
	local success
	local err
	game.Players.PlayerAdded:Connect(function(plr)
		local instance = SomeClass.new {
			character = plr.Character or plr.CharacterAdded:Wait()
		}
		success, err = pcall(print,instance.hrp.Position)
		ev:Fire()
	end)
	ev.Event:Wait()
	if success then
		return 0
	else
		error(err)
	end
end)
