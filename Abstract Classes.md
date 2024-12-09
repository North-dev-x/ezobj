Abstract classes act as a way of defining a template for classes extended from them.

Abstract classes can be created with the following syntax:
```lua
local class = require(ezobj-path)

type AbstractClass = {
	something: string;
	some_method: () -> string;
}
local AbstractClass = class ({} :: AbstractClass)
```

Another way to do this, is to define the type inside the function when calling `class {}`.
```lua
local AbstractClass = class ({} :: {
	something: string;
	some_method: () -> string;
})
```

A good way to think of it is like this:
```lua
class (
	{} -- non-abstract
	:: 
	{} -- abstract
)
```


You can define default implementations of abstract methods and variables.
```lua
type AbstractClass = {
	something: string;
	some_method: (any?) -> string;
}

local AbstractClass = class ({
	some_method = function(self: any?): string
		if self then
			return self.something;
		end
	end;
} :: AbstractClass)
```

A class defined precisely like this will have some_method as a non-abstract method, and something as an undefined abstract string variable.

**When using strict Luau, a linting error will occur if you do not define all non-abstract method's signatures in the abstract section.**
```lua
--!strict

type AbstractClass = {
	something: string;
}

local AbstractClass = class ({
	-- defining a method not within the type AbstractClass
	some_method = function(self: any?): string
		if self then
			return self.something;
		end
		return "Failed to find self"
	end;
} :: AbstractClass) -- Cannot cast '{...}' into 'AbstractClass' because the types are unrelated
```

## Extension

Abstract classes are extended the same way as other classes.
```lua
type AbstractClass = {
	something: string;
	some_method: (any?) -> string;
}

local AbstractClass = class ({
	some_method = function(self: any?): string
		if self then
			return self.something;
		end
	end;
} :: AbstractClass)

local SomeClass = AbstractClass:extend {
	something = "Hello, world!"
}

print(SomeClass:some_method()) -- Hello, world!
```