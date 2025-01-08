--!nocheck

-- CONFIG --

local config = {
	type_checking = true; -- Setting this to false will disable typechecking on class instantiation.
}

------------

local ezobj = {}
ezobj.__index = ezobj

local function getTableType(t)
	if next(t) == nil then return "Abstract" end
	local isArray = true
	local isDictionary = true
	local isClassTable = true;
	for k, _ in next, t do
		if type(k) == "number" and k%1 == 0 and k > 0 then
			isDictionary = false
		elseif type(k) ~= "string" then
			isClassTable = false;
		else
			isArray = false
		end
	end
	if isClassTable then
		return "ClassTable"
	end
	if isArray then
		return "Array"
	elseif isDictionary then
		return "Dictionary"
	else
		return "MixedTable"
	end
end

function deepFreeze(tbl: {[any]: any}): {[any]: any}
	for _,v in ipairs(tbl) do
		if type(v) == "table" and not table.isfrozen(v) then
			deepFreeze(v)
		end
	end
	return table.freeze(tbl)
end

--[[
	Abstract type for created objects. Can be used as a function return value for functions that return classes.
	where T is type of initialization table
]]
export type Object<T> = (T
	& {
		new: (T?) -> T;
		extend: <I>(T,I) -> InheritedObject<T & I, T>;
		type: () -> T;
	}) & (T?) -> T


--[[
	Abstract type for objects that inherit from other objects. Can be used as a function return value for functions that return inherited classes.
	where T is type of initialization table and I is inherited object type
]]
export type InheritedObject<T,I> = (T
	& {
		new: (T?) -> T & {super: I};
		extend: <N>(T,N) -> InheritedObject2<T & N,T>;
		type: () -> T & {super: I};
		super: I;
	}) & (T?) -> T

--[[
	This is the WORST.
	I have to do this to prevent extended classes being labeled as `*error-type*`. 
	This is what allows autocomplete to function with classes.
	Feel free to add more inheritance levels if it is TRULY NEEDED, but 7 should be enough for most projects.
]]

type InheritedObject2<T,I> = (T
	& {
		new: (T?) -> T & {super: I};
		extend: <N>(T,N) -> InheritedObject3<T & N,T>;
		type: () -> T & {super: I};
		super: I;
	}) & (T?) -> T

type InheritedObject3<T,I> =( T 
	& {
		new: (T?) -> T & {super: I};
		extend: <N>(T,N) -> InheritedObject4<T & N,T>;
		type: () -> T & {super: I};
		super: I;
	}) & (T?) -> T 


type InheritedObject4<T,I> = (T 
	& {
		new: (T?) -> T & {super: I};
		extend: <N>(T,N) -> InheritedObject5<T & N,T>;
		type: () -> T & {super: I};
		super: I;
	}) & (T?) -> T

type InheritedObject5<T,I> = (T 
	& {
		new: (T?) -> T & {super: I};
		extend: <N>(T,N) -> InheritedObject6<T & N,T>;
		type: () -> T & {super: I};
		super: I;
	}) & (T?) -> T

type InheritedObject6<T,I> = (T 
	& {
		new: (T?) -> T & {super: I};
		extend: <N>(T,N) -> InheritedObject7<T & N,T>;
		type: () -> T & {super: I};
		super: I;
	}) & (T?) -> T

type InheritedObject7<T,I> = (T 
	& {
		new: (T?) -> T & {super: I};
		extend: <N>(T,N) -> any; -- will not work with autocomplete and will no longer be type-safe
		type: () -> T & {super: I};
		super: I;
	}) & (T?) -> T

--[[
	add more inheritance levels here if you genuinely need it
	also add them to the unioned return type of mod.extend()
]] 

--[[
	Extend the current object into a new object with the given table. Must be a dictionary.
	Must be called with a :, i.e object:extend {} instead of object.extend {}
]] 
function ezobj.extend<I,T>(object: I, classtbl: T):
	InheritedObject<T,I>
	| InheritedObject2<T,I> 
	| InheritedObject3<T,I> 
	| InheritedObject4<T,I> 
	| InheritedObject5<T,I> 
	| InheritedObject6<T,I> 
	| InheritedObject7<T,I>

	-- add more inheritance levels here if genuinely needed
	-- {
	if type(classtbl) ~= "table" then
		return error("Expected table when reading class initializer, got "..type(classtbl),2)
	end
	local t = getTableType(object)
	if t ~= "ClassTable" and t ~= "Abstract" then
		return error("Expected ClassTable {[string]: any} or Empty when initializing Object, got "..t,2)
	end
	for k,v in pairs(object) do
		if classtbl[k] == nil then
			classtbl[k] = v
		end
	end
	local new_obj_metatable = {__index = object}

	if object["constructor"] ~= nil then
		if type(object["constructor"]) ~= "function" then
			return error("Key 'constructor' of class must be a function.")
		end
		classtbl.new = function(...): T & {super: I}
			local obj = {} 
			for i,v in pairs(classtbl) do
				if i == "new" or i == "type" then
					continue;
				end
				rawset(obj,i,v)
			end
			obj:constructor(...)
			obj.constructor = nil;
			local super = {}
			for i,func in pairs(object) do
				if obj[i] and type(func) == "function" and type(obj[i]) == "function" and i ~= "new" and i ~= "type" then
					local classtbl_key: string = "__S__"..i
					obj[classtbl_key] = func
					super[i] = function(...)
						local args = {...}
						if args[1] == obj.super then
							table.remove(args,1)
						end
						return func(obj,table.unpack(args))
					end
				elseif obj[i] and type(func) ~= "function" then
					local classtbl_key: string = "__S__"..i
					local other: any = func :: any
					obj[classtbl_key] = other
				end
			end

			setmetatable(super, {
				__index = function(self,index)
					return obj["__S__"..index]
				end,
			})
			obj.super = super;

			return setmetatable(obj,new_obj_metatable)
		end
	else
		classtbl.new = function(tbl: T?): T & {super: I}
			local obj = {} 
			for i,v in pairs(classtbl) do
				if i == "new" or i == "type" then
					continue;
				end
				rawset(obj,i,v)
			end

			if tbl then
				for k,v in pairs(tbl) do
					if type(v) ~= type(object[k]) and type(v) ~= "nil" and type(object[k]) ~= "nil" and config.type_checking then
						return error("Expected "..type(object[k]).." when instantiating object key '"..k.."', got "..type(v))
					end
					rawset(obj,k,v)
				end 
			end
			local super = {}
			for i,func in pairs(object) do
				if obj[i] and type(func) == "function" and type(obj[i]) == "function" and i ~= "new" and i ~= "type" then
					local classtbl_key: string = "__S__"..i
					obj[classtbl_key] = func
					super[i] = function(...)
						local args = {...}
						if args[1] == obj.super then
							table.remove(args,1)
						end
						return func(obj,table.unpack(args))
					end
				elseif obj[i] and type(func) ~= "function" then
					local classtbl_key: string = "__S__"..i
					local other: any = func :: any
					obj[classtbl_key] = other
				end
			end

			setmetatable(super, {
				__index = function(self,index)
					return obj["__S__"..index]
				end,
			})
			obj.super = super;

			return setmetatable(obj,new_obj_metatable)
		end
	end


	classtbl.super = object
	classtbl.type = function(): T & {super: I}
		return classtbl
	end
	return deepFreeze(setmetatable(classtbl,{__index = ezobj, __call = function(_,tbl: T?): T & {super: I}
		local obj = {} 
		for i,v in pairs(classtbl) do
			if i == "new" or i == "type" then
				continue;
			end
			rawset(obj,i,v)
		end

		if tbl then
			for k,v in pairs(tbl) do
				if type(v) ~= type(object[k]) and type(v) ~= "nil" and type(object[k]) ~= "nil" and config.type_checking then
					return error("Expected "..type(object[k]).." when instantiating object key '"..k.."', got "..type(v))
				end
				rawset(obj,k,v)
			end 
		end
		local super = {}
		for i,func in pairs(object) do
			if obj[i] and type(func) == "function" and type(obj[i]) == "function" and i ~= "new" and i ~= "type" then
				local classtbl_key: string = "__S__"..i
				obj[classtbl_key] = func
				super[i] = function(...)
					local args = {...}
					if args[1] == obj.super then
						table.remove(args,1)
					end
					return func(obj,table.unpack(args))
				end
			elseif obj[i] and type(func) ~= "function" then
				local classtbl_key: string = "__S__"..i
				local other: any = func :: any
				obj[classtbl_key] = other
			end
		end

		setmetatable(super, {
			__index = function(self,index)
				return obj["__S__"..index]
			end,
		})
		obj.super = super;

		return setmetatable(obj,new_obj_metatable)
	end}))
	-- }
end

--[[
	Initialize an object with the given table. Must be a dictionary of type {[string]: any}.
]] 
function ezobj:__call<T>(object: T): Object<T>
	-- where T: {[string]: any}
	if type(object) ~= "table" then
		return error("Expected table when reading class initializer, got "..type(object),2)
	end
	local t = getTableType(object)
	if t ~= "ClassTable" and t ~= "Abstract" then
		return error("Expected ClassTable {[string]: any} or Empty when initializing Object, got "..t,2)
	end

	local keys_in_object = {}
	for k,_ in object do
		table.insert(keys_in_object,k)
	end
	local new_obj_metatable = {__index = object}
	if object["constructor"] ~= nil then
		if type(object["constructor"]) ~= "function" then
			return error("Key 'constructor' of class must be a function.")
		end
		object.new = function(...): T
			local obj = {}
			for i,v in pairs(object) do
				if i == "new" or i == "type" then
					continue;
				end
				rawset(obj,i,v)
			end
			obj:constructor(...)
			obj.constructor = nil;
			return setmetatable(obj,new_obj_metatable)
		end
	else
		object.new = function(tbl: T?): T
			local obj = {}
			for i,v in pairs(object) do
				if i == "new" or i == "type" then
					continue;
				end
				rawset(obj,i,v)
			end
			if tbl then
				for k,v in pairs(tbl) do
					if type(v) ~= type(object[k]) and type(v) ~= "nil" and type(object[k]) ~= "nil" and config.type_checking then
						return error("Expected "..type(object[k]).." when instantiating object key '"..k.."', got "..type(v)) 
					end
					obj[k] = v
				end 
			end
			return setmetatable(obj,new_obj_metatable)
		end
	end

	object.type = function(): T
		return object;
	end

	return deepFreeze(setmetatable(object,{__index = ezobj, __call = function(_,tbl: T?): T
		local obj = {}
		for i,v in ipairs(object) do
			if i == "new" or i == "type" then
				continue;
			end
			rawset(obj,i,v)
		end
		if tbl then
			for k,v in pairs(tbl) do
				if type(v) ~= type(object[k]) and type(v) ~= "nil" and type(object[k]) ~= "nil" and config.type_checking then
					return error("Expected "..type(object[k]).." when instantiating object key '"..k.."', got "..type(v)) 
				end
				obj[k] = v
			end 
		end
		return setmetatable(obj,new_obj_metatable)
	end}))
end



return setmetatable({}, ezobj)