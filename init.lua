orefields = {}

orefields.path = minetest.get_modpath(minetest.get_current_modname())

-- LUA Table deepcopy
local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- Base initializations

-- Ores seed (depends on map seed)
local deltaseed = 456

local mg_params = minetest.get_mapgen_params()
local baseseed = mg_params.seed;
if baseseed > deltaseed then 
	baseseed = baseseed - deltaseed 
else
	baseseed = baseseed + deltaseed
end

-- Copy and clear registered ores
registered_ores = deepcopy(minetest.registered_ores)

-- Remove ore from standard registry
function remove_ore(orenode)
	local found = false
 	for index, ore in pairs(registered_ores) do
		if ore.ore == orenode then
			registered_ores[index] = nil
			found = true
		end
	end
	return found
end

-- For tests
basenode = "default:stone"
--basenode = "air"
offset = 0

-- Add heterogeneous ore
local function add_field(ore, wherein, seed, y_min, y_max, threshhold, spread, clust_scarcity, clust_num_ores, clust_size)
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = ore,
		wherein        = wherein,
		clust_scarcity = clust_scarcity,
		clust_num_ores = clust_num_ores,
		clust_size     = clust_size,
		y_min          = y_min + offset,
		y_max          = y_max + offset,
		noise_threshhold = threshhold,
		noise_params = {
			offset = 0, 
			scale = 1, 
			spread = {x = spread, y = spread, z = spread}, 
			seed = baseseed + seed, 
			octaves = 2, 
			persist = 0.7
		},
	})
end

-- Add homogeneous ore
local function add_uniform(ore, wherein, y_min, y_max, clust_scarcity, clust_num_ores, clust_size)
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = ore,
		wherein        = wherein,
		clust_scarcity = clust_scarcity,
		clust_num_ores = clust_num_ores,
		clust_size     = clust_size,
		y_min          = y_min + offset,
		y_max          = y_max + offset,
	})
end

-- Coal (seed 1)
if remove_ore("default:stone_with_coal") then
	add_uniform("default:stone_with_coal", basenode, -31000, 0, 24 * 24 * 24, 27, 6)
	add_field("default:stone_with_coal",    basenode, 1, -31000, -128, 0.5,  100, 55, 8, 3)
end
-- Missing coal blocks

-- Iron (seed 2)
if remove_ore('default:stone_with_iron') then
	add_uniform("default:stone_with_iron", basenode, -31000,    -2, 12 * 12 * 12, 3, 2)
	add_field("default:stone_with_iron", basenode, 2,   -256,   -64, 0.3, 100, 80, 5, 3) -- To be tested
	add_field("default:stone_with_iron", basenode, 2, -31000,  -256, 0.5, 100, 80, 5, 3)
	add_field("default:stone_with_iron", basenode, 2, -31000, -1024, 0.8, 100, 5, 2, 2)
end

-- Mese (seed 3)
if remove_ore('default:stone_with_mese') then
	add_uniform("default:stone_with_mese", basenode,    -31000,  -64, 18 * 18 * 18, 3, 2)
	add_field("default:stone_with_mese",    basenode, 3, -31000, -256, 0.8,  100, 60, 5, 3)
end
if remove_ore('default:mese') then
	add_field("default:mese",               basenode, 3, -31000, -512, 0.9,  100, 400, 3, 2)
end

-- Gold (seed 4)
if remove_ore('default:stone_with_gold') then
	add_uniform("default:stone_with_gold", basenode,    -31000,  -64, 15 * 15 * 15, 3, 2)
	add_field("default:stone_with_gold",    basenode, 4, -31000, -128, 0.7,  100, 90, 5, 3)
end

-- Diamond (seed 5)
if remove_ore('default:stone_with_diamond') then
	add_uniform("default:stone_with_diamond", basenode, -31000,  -128, 17 * 17 * 17, 4, 3)
	add_field("default:stone_with_diamond", basenode, 5, -31000, -1024, 0.7,  100, 80, 4, 3)
	add_field("default:diamondblock", "default:stone_with_diamond", 5, -31000, -2048, 0.9,  100, 5, 1, 1)
end

-- Copper (seed 6)
if remove_ore('default:stone_with_copper') then
	add_uniform("default:stone_with_copper", basenode, -31000,  -16, 12 * 12 * 12, 4, 3)
	add_field("default:stone_with_copper",  basenode, 6, -512,   -128, 0.5,  100, 50, 5, 3)
	add_field("default:stone_with_copper",  basenode, 6, -31000, -512, 0.7,  100, 50, 5, 3)
end

-- Re-register ores that are not managed by module
for _, ore in pairs(registered_ores) do
  minetest.log("action", "[orefields] Ore not managed : "..ore.ore)
  ore.wherein        = "air"
  ore.y_max          = 500

  minetest.register_ore(ore)
end



