--!nocheck
function create<T>(struct_tbl: T): <I>(I) -> (T) -> T & (I?)
	if type(struct_tbl) ~= "table" then error("Struct creation must receive a table.") end
	
	local constructed_meta = {__index = struct_tbl}
	
	return function(impl)
		
		if type(impl) ~= "table" then 
			return function(construct_definition) 
				return construct_definition 
			end 
		end
		
		return function(construct_definition)
			for k,v in impl do
				construct_definition[k] = v;
			end
			
			return construct_definition	 
		end
	end
end

return create

