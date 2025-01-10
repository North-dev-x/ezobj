--!nonstrict

local ezobj = {}

type function optional<T>(input: T)
	if not input:is("table") then return error("") end

	local output = types.newtable()

	for key, value in input:properties() do
		output:setproperty(key, types.unionof(value.write,types.singleton(nil)))
	end

	local indexer = input:indexer()
	if indexer then
		output:setindexer(indexer.index,types.unionof(indexer.writeresult or indexer.readresult,types.singleton(nil)))
	end

	return output
end

type obj_functions<T> = ({
	new: (optional<T>?) -> T;
	type: () -> T?;
}) 

type obj_functions_extended<T,I> = {
	new: (optional<T>?) -> T & {super: I};
	type: () -> T?;
} & (optional<T>?) -> T & {super: I}

function create(_,classtbl)
	--if type(classtbl) ~= "table" then return classtbl end
	local stripped_tbl = table.clone(classtbl)
	local constructed_obj_meta = {__index = stripped_tbl}
	
	--function classtbl.new(x: T?): T
		
	--	return setmetatable({}, constructed_obj_meta)
	--end
	
	classtbl.type = function()
		return stripped_tbl;
	end
	return setmetatable(classtbl,{
		__index = ezobj;
	
	}) :: typeof(classtbl) & obj_functions<typeof(classtbl)> & typeof(ezobj)
end

function ezobj.extend<T,I>(from: T, to: I): T & I & obj_functions<T & I> & {extend: <I>(T,I) -> T & I & obj_functions<T & I> & {super: I}} & {super: I}

end


return setmetatable(ezobj, {
	__call = create
})

