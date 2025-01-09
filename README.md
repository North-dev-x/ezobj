ezobj is a Luau library for simple and straightforward class/object/struct creation.

Rather than having to deal with metatables, ezobj handles all of that and more behind the scenes while you code in peace!

[Toolbox Link](https://create.roblox.com/store/asset/111257770848071/ezobj)

[Wally](https://wally.run/package/north-dev-x/ezobj)

### Usage Example
ezobj allows you to easily create classes and derivative classes.
```luau
--[[
name this variable whatever your favorite class/object keyword is,
i.e struct, class, def, defstruct, etc
]] 
local class = require(path-to-ezobj)

local SomeClass = class {
	field = 3;
	-- a singleton function does not need a self parameter and can be called with class.method() without problem
	hello_world = function()
		print("Hello, world!")
	end;
	-- Initialize the first argument as `self: any?` to access class fields and methods
	-- A function with self: any? must be called with class:method() to work properly
	method = function(self: any?, val: number) 
		if self then
			self.field = val
			print(self.field)
		end
	end;
}
type SomeClass = typeof(SomeClass) -- define class type to use as a type hint if wanted later

-- call singleton method without constructing the class
SomeClass.hello_world()

local x = SomeClass.new() -- construct an instance of the class
x:method(42) -- 42

-- extend SomeClass into a new class
local ExtendClass = SomeClass:extend {
	field = "something"; -- overrides field from superclass
	-- self can also be initialized using the class type if you don't want to check if self exists every time, this is especially helpful when using strict mode
	method = function(self: ExtendClass, val: string)
		return val..self.field
	end;
}
type ExtendClass = typeof(ExtendClass) -- used internally in the class for self

-- construct an instance of the class with a default value
local y = ExtendClass.new {
	field = "Hello,"
}
print(y:method(" world!")) -- Hello, world!
y.hello_world() -- Hello, world! - retains method from superclass

y.super:method(500) -- 500 - Access superclass methods with class.super
```

### Documentation
[Classes](Classes.md)

[Abstract Classes and Interfaces](Abstract%20Classes%20and%20Interfaces.md)

[Classes are first-class objects](Classes%20are%20first-class%20objects.md)
