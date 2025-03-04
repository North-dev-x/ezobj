A class is created by calling the module as a function.
```luau
function ezobj:__call<T>(object: T): Object<T>
```
Creates a class with the given table as its members.
`object` must be an [empty table](Abstract%20Classes%20and%20Interfaces.md) or a dictionary(key-value pairs).

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

Classes do not need to be instantiated to be used, but if not instantiating or extending, I would recommend creating a normal table with the same values.
```luau
Foo:foobar() -- 50
```

Classes can also be instantiated with the following syntax, instead of with .new().

```luau
local newFoo = Foo()

local newFoo = Foo {
	bar = 391238;
}
```

### Initialization Functions
Classes can include a `constructor` method which will override the default behavior or `.new()`.

```luau
local SomeClass = class {
	character = nil;
	hrp = nil;
	
	constructor = function(self: any, char: Model)
		self.character = char
		self.hrp = char:WaitForChild("HumanoidRootPart")
	end;
}
type SomeClass = typeof(SomeClass.type())

local instance = SomeClass.new(plr.Character or plr.CharacterAdded:Wait())
print(instance.hrp.Position) -- some vector3


```
This can be used to add custom constructor behavior, when `.new()`'s default behavior isn't enough for your use case.

Using the alternate constructor syntax can override this, i.e 
```luau
local instance = SomeClass {
	chr = some_character;
	hrp = some_character.HumanoidRootPart;
}
```

### .type() and type hinting
When creating a type hint for a class, use .type() to get the type of a constructed instance, rather than the type of the actual class.
```luau
local SomeClass = class {
	foo = "foo";
}
type SomeClass = typeof(SomeClass.type())
```

### Extending Classes

Classes can be extended with `Class:extend {}`.
```luau
local Bar = Foo:extend {
	foo = 30; -- new member unique to this class
	bar = "bar"; -- overrides field bar from superclass
	foobar = function(self: any) -- overrides method foobar from superclass
		print(self.foo)
	end
}

local instance = Bar()
instance:foobar() -- 30 - overrided method 
instance.super:foobar() -- "bar" - Superclass behavior retained with the super table
```
Doing this creates a new class, with all of the members of the superclass, and any added in the provided table.


The superclass itself can be accessed with `Class.super`.
