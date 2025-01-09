Interfaces act as an abstract way of defining the type of a class before creating it.

Interfaces are created with the following syntax:

```luau
local class = require(ezobj-path)

-- interface
type SomeInterface = {
	something: string;
	some_method: () -> string;
}
-- class that implements interface
local SomeClass = class ({} :: SomeInterface)
```

Another way to do this, is to define the type inside the function when calling `class {}`.

This acts more like an `abstract class`, which you may be familiar with from languages like Java and C#, or implementing an "anonymous interface".
```luau
local AbstractClass = class ({} :: {
	something: string;
	some_method: () -> string;
})
```

When implementing an interface, you get the guarantee that the data will be structured the way your methods expect.
```luau
type SomeInterface = {
	something: string;
	some_method: (any?) -> string;
}

local SomeClass = class ({
	some_method = function(self: SomeInterface): string
		return self.something;
	end;
} :: SomeInterface)
```
Even though `something` may not exist in the class, you still get autocomplete when using it in the function.

**When using strict mode, an error will occur if you do not define all methods and properties that you intend to have in the class in the interface.**
```luau
--!strict

type SomeInterface = {
	something: string;
}

local SomeClass = class ({
	-- defining a method not within the type SomeInterface
	some_method = function(self: any?): string
		if self then
			return self.something;
		end
		return "Failed to find self"
	end;
} :: SomeInterface) -- Cannot cast '{...}' into 'SomeInterface' because the types are unrelated
```

## Examples and Comparisons
When using types to predefine your class structures, some additional guarantees about your classes are made.

Given this example (from my current project):
```luau
export type NPCInterface = {
	dialogue: {{
		text: string;
		options: {
			Goodbye: ((plr) -> ())?;
			[string]: (plr) -> () 
		}	
	}};
	clicked: (NPC, plr) -> ();
}

-- This is similar to extending an interface in typescript
export type ShrineInterface = NPCInterface & {
	price: number?;
	purchase: (Shrine, plr) -> ();
	skills: {string};
}

local NPC = class({} :: NPCInterface)

local Shrine = NPC:extend({} :: ShrineInterface)
```

All functions that typecheck for a superclass's interface will work with instances of an extended class.
```luau
function something(x: NPCInterface)
	-- do something
end

test(Shrine.new()) -- no error
```
This builds upon the concept of Polymorphism.

`self` can be typed with full autocomplete using the interface, i.e `self: SomeInterface`
```luau
local Shrine = NPC:extend({
  purchase = function(self: ShrineInterface, plr: plr)
    self.pr --autocomplete self.price
  end
} :: ShrineInterface)
```

This behavior does not work with non-interfaced classes, as you usually would have to define the type after creating it.

As a final example, compare this typescript code to my original luau example.
Notice the similarities in definition and usage.

```ts
interface NPCInterface {
  dialogue: [{
    text: string;
    options: {
      Goodbye: (self: NPCInterface, plr: any) => void;
      [key: string]: (self: NPCInterface, plr: any) => void;
    };
  }];
  clicked: (self: NPCInterface, plr: any) => void;
}

interface ShrineInterface extends NPCInterface {
  price?: number;
  purchase: (self: ShrineInterface, plr: any) => void;
  skills: [string];  
}

class NPC implements NPCInterface {}

class Shrine extends NPC implements ShrineInterface {}
```

In this case, we can note that `::` is equivalent to `implements`, i.e
```luau
local Shrine = class({} implements ShrineInterface)
local Shrine = class({} :: ShrineInterface)
```

`&` in interface definition is equivalent to `extends`, i.e
```luau
export type ShrineInterface = extends NPCInterface {...}
export type ShrineInterface = NPCInterface & {...}
```