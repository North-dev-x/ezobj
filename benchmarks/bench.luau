local class = require(path-to-ezobj)

local to_instance = class({}::{
	value: number;
	id: string;
	method: (any) -> string;
})

type to_instance = typeof(to_instance.type())
local instances: {to_instance} = {}
	
local times = 10000;
local start = os.clock()
for i = 1,times do
		
	local instance: to_instance = to_instance {
		value = math.random(-20000,20000);
		id = httpservice:GenerateGUID(false);
		method = function(self: any)
			return tostring(self.value)..self.id
		end,
	}
		
	table.insert(instances, instance)
end

print(times.." class instances took "..((os.clock() - start)*1000).."ms")

print(instances
