--!strict

local struct = require(script.Parent)

type SomeStruct = {
	something: string;
	some_other_thing: number;
}

local SomeStruct = struct({} :: SomeStruct) {
	method = function(self: SomeStruct, x: any)
		self.some_other_thing += x
	end, 
}
 
local newtest = SomeStruct  {
	something = ""; 
	some_other_thing = 304;
}  

newtest:method(3) 

assert(newtest.some_other_thing == 307, "non-functional") 

local MathObject = struct({}::{
	value: number;
}) {
	div = function(self, denom: number): number
		if denom == 0 then return error("Cannot divide by zero") end
		self.value /= denom;
		return self.value;
	end;
	mul = function(self, with: number): number
		self.value *= with
		return self.value;
	end
}

local new = MathObject {
	value = 30;
}

assert(new:div(30) == 1, "failed division test")

assert(new:mul(2) == 2, "failed multiplication test")