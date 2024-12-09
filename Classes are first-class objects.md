ezobj's classes, being Lua tables, can be passed to and returned from functions, allowing for a lot of interesting shenanigans you can get yourself into.

Like a class, with a method, that returns a class:
```lua
local class = require(ezobj-path)

local TestClass = class {
	method = function(self: any?, val: any): class.Object<{val: any}>
		return class {
			val = val;
		}
	end;
}

local ConstructedClass = TestClass:method(50)
local new = ConstructedClass.new()
print(new.val) -- 50
```

Or a function that composes 2 classes together:
```lua
local class = require(ezobj-path)

function compose<A,B>(class1: A, class2: B): class.Object<A & B>
	if typeof(class1) ~= "table" or typeof(class2) ~= "table" then 
		return error("Compose must take 2 classes") 
	end
	local composed = {}
	for k,v in pairs(class1) do
		composed[k] = v
	end
	for k,v in pairs(class2) do
		if composed[k] ~= nil then continue end
		composed[k] = v
	end
	return class(composed)
end
```

### Types
ezobj contains 2 types that can be used for this kind of behavior.
###### Object
```lua
export type Object<T> = T & {...}
```
*where T is the class table*
###### InheritedObject
```lua
export type InheritedObject<T,I> = T & {...}
```
*where T is an intersection type of this object and what it inherits from*
*where I is the class it inherits from*

