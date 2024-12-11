local ezobj = {}

local function getTableType(t)
	if next(t) == nil then return "Empty" end
	local isArray = true
	local isDictionary = true
	local isClassTable = true;
	for k, _ in next, t do
		if typeof(k) == "number" and k%1 == 0 and k > 0 then
			isDictionary = false
		elseif typeof(k) ~= "string" then
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




--[[
	Abstract type for created objects. Can be used as a function return value for functions that return classes.
	where T is type of initialization table
]]
export type Object<T> = T 
& {
	new: (T?) -> T;
	extend: <I>(T,I) -> InheritedObject<T & I, T>
}
--[[
	Abstract type for objects that inherit from other objects. Can be used as a function return value for functions that return inherited classes.
	where T is type of initialization tablev and I is inherited object type
]]
export type InheritedObject<T,I> = T 
& {
	new: (T?) -> T;
	extend: <N>(T,N) -> InheritedObject2<T & N,T>;
	super: I;
}

--[[
	This is the WORST.
	I have to do this to prevent extended classes being labeled as `*error-type*`. 
	This is what allows autocomplete to function with classes.
	Feel free to add more inheritance levels if it is TRULY NEEDED, but 4 should be enough for most projects.
]]

type InheritedObject2<T,I> = T 
& {
	new: (T?) -> T;
	extend: <N>(T,N) -> InheritedObject3<T & N,T>;
	super: I;
}

type InheritedObject3<T,I> = T 
& {
	new: (T?) -> T;
	extend: <N>(T,N) -> InheritedObject4<T & N,T>;
	super: I;
}

type InheritedObject4<T,I> = T 
& {
	new: (T?) -> T;
	extend: <N>(T,N) -> unknown; -- will not work with autocomplete and will no longer be type-safe
	super: I;
}
--[[
	add more inheritance levels here if you genuinely need it
	also add them to the unioned return type of mod.extend()
]] 

--[[
	Extend the current object into a new object with the given table. Must be a dictionary.
	Must be called with a :, i.e object:extend {} instead of object.extend {}
]] 
function ezobj.extend<I,T>(object: I, classtbl: T): InheritedObject<T,I> | InheritedObject2<T,I> | InheritedObject3<T,I> | InheritedObject4<T,I>
	assert(typeof(classtbl) == "table", "Objects must be initialized with a dictionary.")
	local t = getTableType(object)
	if t ~= "ClassTable" and t ~= "Empty" then
		return error("Expected ClassTable {[string]: any} or Empty when initializing Object, got "..t)
	end
	for k,v in pairs(object) do
		if classtbl[k] == nil then
			classtbl[k] = v
		end
	end
	local new_obj_metatable = {__index = classtbl}
	classtbl.new = function(tbl: T?): Object<T>
		local obj = setmetatable({},new_obj_metatable)
		for i,v in pairs(classtbl) do
			rawset(obj,i,v)
		end
		if tbl then
			for k,v in pairs(tbl) do
				rawset(obj,k,v)
			end
		end
		return obj :: Object<T>
	end
	classtbl.super = object

	return setmetatable(classtbl,{__index = ezobj})
end

-- Initialize an object with the given table. Must be a dictionary.
function ezobj:__call<T>(object: T): Object<T>
	-- where T: {[any]: any}
	assert(typeof(object) == "table", "Objects must be initialized with a dictionary.")
	local t = getTableType(object)
	if t ~= "ClassTable" and t ~= "Empty" then
		return error("Expected ClassTable {[string]: any} or Empty when initializing Object, got "..t)
	end

	local new_obj_metatable = {__index = object}
	object.new = function(tbl: T?): Object<T>
		local obj = setmetatable({},new_obj_metatable)
		for i,v in pairs(object) do
			rawset(obj,i,v)
		end
		if tbl then
			
			for k,v in pairs(tbl) do
				rawset(obj,k,v)
			end
		end
		return obj :: Object<T>
	end

	return setmetatable(object,{__index = ezobj})
end



return setmetatable(ezobj, ezobj)
