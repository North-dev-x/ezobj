--!strict

local class = require(script.Parent)

local passed = 0;
local failed = 0;
local errors = {}

function test(test_name: string, func: () -> any?)
	local success, err = pcall(func)
	if success then
		passed += 1
	elseif err and not success then
		failed += 1
		table.insert(errors,"TEST "..test_name.." FAILED WITH ERROR: ".. err)
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
--test("InheritanceTest", function()
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
--	return 0; 
--end)

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
	print(new_abstract)
	print(new_abstract:some_method())
	return 0; 
end)



test("NewSuperMethodTest", function()
	local Dividable = class {
		val = 3;
		run = function(self: any?, other_val: number): number?
			if other_val == 0 then
				return nil
			end

			return self.val / other_val
		end,
	}
	type Dividable = typeof(Dividable)
	local Multiplicable = Dividable:extend {
		val = 4;
		run = function(self: any?, other_val: number): number
			return self.val * other_val
		end,
	}
	type Multiplicable = typeof(Multiplicable)

	local mul = Multiplicable.new {
		val = 3;
	}

	assert(mul:run(10) == 30, "This should return 30.")
	mul.val = 5;
	assert(mul.super:run(2) == 2.5, "This should return 2.5.")
	assert(mul.super.val == 3, "This should equal 3.") -- test super property

	return 0
end)

test("constructorTest",function()
	
	local SomeClass = class {
		value = nil;
		test = nil;
		constructor = function(self: SomeClass, value: number, test: string)
			self.value = value;
			self.test = test;
		end,
	}
	
	type SomeClass = typeof(SomeClass)
	local constructed = SomeClass.new(30,"Hello, world!")
	
	print(constructed)
	if constructed.value ~= 30 then return error("failed to construct") end
	if constructed.test ~= "Hello, world!" then return error("failed to construct") end
	
	-- example monad/functor implementation
	local Maybe: class.Object<any>
	Maybe = class {
		value = nil;
		constructor = function(self, val)
			self.value = val;
		end,
		bind = function(self: any, func): typeof(Maybe.type())
			local val = func(self.value)
			return Maybe.new(val)
		end,
	}
	type Maybe = typeof(Maybe.type())
	local mayb: Maybe = Maybe.new("test")
		:bind(function(val: string) return val:sub(1,2) end)
		:bind(function(val: string) return val:len() end)
	assert(mayb.value == 2, "Something is broken with this function")
	
	return 0
end)

test("Immutability", function()
	local Foo = class {
		something = 5;
		hello = "Hello";
		method = function(self)
			return self.hello;
		end,
	}

	local success = pcall(function()
		Foo.hello = "World"
	end)
	if success then return error("Class table should not be mutable.") end
	
	local success = pcall(function()
		Foo["Bar"] = 100;
	end)
	if success then return error("Class table should not be able to host new indexes.") end
	
	local success = pcall(function()
		local newfoo = Foo.new {
			hello = 30;
			something = function()
				print("something");
			end,
			method = false;
		}
	end)
	if success then return error("Class should not be able to be instantiated with incorrect types.") end
	
	return 0
end)

test("ImmutabilityForExtendedClass", function()
	local superclass = class {
		something = 5;
		hello = "Hello";
		method = function(self)
			return self.hello;
		end,
	}
	
	local Foo = superclass:extend {
		baz = 500;
	}
	local success = pcall(function()
		Foo.hello = "World"
	end)
	if success then return error("Class table should not be mutable.") end

	local success = pcall(function()
		Foo["Bar"] = 100;
	end)
	if success then return error("Class table should not be able to host new indexes.") end

	local success = pcall(function()
		local newfoo = Foo.new {
			hello = 500;
			something = function()
				print("something");
			end,
			method = false;
		}
		
	end)
	if success then return error("Class should not be able to be instantiated with incorrect types.") end

	return 0;
end)

local httpservice = game:GetService("HttpService")

test("Speed Benchmark", function()

	local to_instance = class({}::{
		value: number;
		id: string;
		method: (number) -> string;
	})
	type to_instance = typeof(to_instance)
	local instances: {to_instance} = {}
	
	local times = 10000;
	local start = os.clock()
	for i = 1,times do
		
		local instance: to_instance = to_instance {
			value = math.random(-20000,20000);
			id = httpservice:GenerateGUID(false);
			method = function(num: number)
				return tostring(num)
			end,
		}
		
		table.insert(instances, instance)
	end
	print(times.." class instances took "..((os.clock() - start)*1000).."ms")
	return 0;
end)


print("\n\n\n        "..passed.." passed, "..failed.." failed")
if #errors > 0 then
	error(errors)
end
