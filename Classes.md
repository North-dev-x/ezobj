A class is created by calling the module as a function.
```lua
function ezobj:__call<T>(object: T): Object<T>
```
Creates a class with the given table as its members.
`object` must be an [empty table](Abstract%20Classes.md) or a dictionary(key-value pairs).

Example usage:
```lua
local class = require(ezobj-path)

local Foo = class {
	bar = 50;
	foobar = function(self: Foo)
		print(self.bar)
	end
}
type Foo = typeof(Foo)
```

### Instantiating Classes

Classes can be instantiated with `Class.new()`.
```lua
local newFoo = Foo.new()
newFoo:foobar() -- 50
```

Classes can also be instantiated with initial values.
```lua
local newFoo = Foo.new {
	bar = 4905;
}
newFoo:foobar() -- 4905
```

Classes do not need to be instantiated to be used, but if not instantiating or extending, I would recommend creating a normal table with the same values.
```lua
Foo:foobar() -- 50
```

### Extending Classes

Classes can be extended with `Class:extend {}`.
```lua
local Bar = Foo:extend {
	foo = 30; -- new member unique to this class
	bar = "bar"; -- overrides field bar from superclass
}
Bar:foobar() -- "bar" - inherits this method from superclass Foo
Bar.super:foobar() -- 50 - superclass methods only access the super table
```
Doing this creates a new class, with all of the members of the superclass, and any added in the provided table.

The superclass itself can be accessed with `Class.super`.
