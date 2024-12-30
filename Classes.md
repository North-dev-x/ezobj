A class is created by calling the module as a function.
```luau
function ezobj:__call<T>(object: T): Object<T>
```
Creates a class with the given table as its members.
`object` must be an [empty table](Abstract%20Classes.md) or a dictionary(key-value pairs).

Example usage:
```luau
local class = require(ezobj-path)

local Foo = class {
	bar = 50;
	foobar = function(self: Foo)
		print(self.bar)
	end
}
type Foo = typeof(Foo.type())
```

### .type() and type hinting
Created classes get a method `.type()` which returns the type of the initial table you gave the class.
This is purely a convenience mechanism for type hinting.
```luau
local SomeClass = class {something = 3}
type SomeClass = typeof(SomeClass)

local x: SomeClass = SomeClass.new()
```
The autocomplete when using x will contain methods like `.new()`, `:extend()`, and `.type()`, being inconvenient when using the type hint for other usages.
However, if you replace `typeof(SomeClass)` with the following:
```luau
type SomeClass = typeof(SomeClass.type())
```
Using the type hint will only autocomplete methods and fields you put into the class yourself, rather than the injected construction and extension methods that `ezobj` includes for you.

### Instantiating Classes

Classes can be instantiated with `Class.new()`.
```luau
local newFoo = Foo.new()
newFoo:foobar() -- 50
```

Classes can also be instantiated with initial values.
```luau
local newFoo = Foo.new {
	bar = 4905;
}
newFoo:foobar() -- 4905
```

Classes can also be instantiated in a shorthand way by calling the class as a function, i.e.
```luau
local newFoo = Foo {
	bar = 4905;
}
newFoo:foobar() -- 4905
```


Classes do not need to be instantiated to be used, but if not instantiating or extending, I would recommend creating a normal table with the same values.
```luau
Foo:foobar() -- 50
```

#### Constructor Functions
Classes can include a `constructor` method which changes the behavior of the .new() function.

```luau
local SomeClass = class {
	character = nil;
	hrp = nil;
	
	constructor = function(self: SomeClass, character: Model)
		self.character = character
		self.hrp = character:WaitForChild("HumanoidRootPart")
		
	end;
}
type SomeClass = typeof(SomeClass.type())

local instance = SomeClass.new(plr.Character or plr.CharacterAdded:Wait())
print(instance.HumanoidRootPart.Position) -- some vector3
```
This can be used to add custom constructor behavior, when `.new()`'s default behavior isn't enough for your use case.

To instantiate a class that has a constructor without calling its constructor, the following syntax is provided.

```luau
local instance = SomeClass {
	character = plr.Character or plr.CharacterAdded:Wait()
}
```
*Calling the class as a function bypasses its constructor and grants the default behavior of .new().`

### Extending Classes

Classes can be extended with `Class:extend {}`.
```luau
local Bar = Foo:extend {
	foo = 30; -- new member unique to this class
	bar = "bar"; -- overrides field bar from superclass
}
Bar:foobar() -- "bar" - inherits this method from superclass Foo
Bar.super:foobar() -- 50 - superclass methods only access the super table
```

Doing this creates a new class, with all of the members of the superclass, and any added in the provided table.

The superclass itself can be accessed with `Class.super`.

### Immutability
Classes, after creation, cannot have their structure altered. 
The following code examples will error due to immutability.
```luau
local Foo = class {
	something = 5;
	hello = "Hello";
	method = function(self)
		return self.hello;
	end,
}
Foo.hello = "Bar" -- ERROR: attempt to modify a readonly table
```
*You can't edit fields within a class, it must be constructed first*

```luau
local Foo = class {
	something = 5;
	hello = "Hello";
	method = function(self)
		return self.hello;
	end,
}
Foo.Bar = 400 -- ERROR: attempt to modify a readonly table
```
*You can't add new fields to a class.*

### Typechecking
Attempting to instantiate a class with incorrect types will result in a runtime error.
```luau
local Foo = class {
	something = 5;
	hello = "Hello";
	method = function(self)
		return self.hello;
	end,
}

local newfoo = Foo.new { 
	hello = 500; -- ERROR: Expected string when instantiating object key 'hello', got number
	something = function() 
		print("something");
	end,
	method = false;
}
```

