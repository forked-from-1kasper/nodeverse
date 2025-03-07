local function grass_callback(
    origin, minp, maxp, area, A, A1, A2, mapping, planet, ground_buffer, custom
)
    local x = origin.x
    local z = origin.z
    local base = area.MinEdge
    local extent = area:getExtent()
    local k = (z - base.z) * extent.x + x - base.x + 1
    local ground = math.floor(ground_buffer[k])
    if ground < custom.min_height or ground > custom.max_height then
        return
    end
    if minp.y + mapping.offset.y > ground + (custom.max_plant_height or 256) or maxp.y + mapping.offset.y < ground - (custom.max_plant_depth or 256) then
        return
    end
    local grass_height = 3 + math.floor((x % 4) / 2 - 0.5)
    local yrot = (x * 23 + z * 749) % 24
    local color_index = (custom.color - 1) % 8
    for y=math.max(ground - mapping.offset.y, minp.y),math.min(ground + grass_height - mapping.offset.y, maxp.y),1 do
        local i = area:index(x, y, z)
        if y + mapping.offset.y == ground then
            if A[i] == nil
            or A[i] == minetest.CONTENT_AIR
            or not minetest.registered_nodes[minetest.get_name_from_content_id(A[i])].walkable then
                return
            end
        else
            if not(A[i] == nil
            or A[i] == minetest.CONTENT_AIR
            or minetest.get_name_from_content_id(A[i]) == "nv_planetgen:snow") then
                return
            end
        end
    end
    for y=math.max(ground + 1 - mapping.offset.y, minp.y),math.min(ground + grass_height - mapping.offset.y, maxp.y),1 do
        local i = area:index(x, y, z)
        if A[i] == nil
        or A[i] == minetest.CONTENT_AIR
        or minetest.get_name_from_content_id(A[i]) == "nv_planetgen:snow" then
            A[i] = custom.node
            if custom.is_colorful then
                A2[i] = yrot + (color_index + math.floor((y + mapping.offset.y - ground) / 2)) % 48 * 32
            else
                A2[i] = yrot + color_index * 32
            end
        end
    end
end

function nv_flora.get_tall_grass_meta(seed, index)
    local r = {}
    local G = PcgRandom(seed, index)
    local meta = generate_planet_metadata(seed)
    local colors = get_planet_plant_colors(seed)
    -- General
    if meta.life == "lush" then
        r.density = 1/(G:next(2, 10)^2)
    else
        r.density = 1/(G:next(10, 20)^2)
    end
    r.seed = 638262 + index
    r.side = 1
    r.order = 100
    r.callback = grass_callback
    -- Grass-specific
    r.color = colors[G:next(1, #colors)]
    local color_group = math.floor((r.color - 1) / 8) + 1
    local plant_type_nodes = gen_weighted(G, {
        [nv_flora.node_types.cane_grass] = 1,
        [nv_flora.node_types.thick_grass] = 1,
        [nv_flora.node_types.ball_grass] = 1
    })
    r.node = plant_type_nodes[color_group]
    r.is_colorful = (G:next(0, 2) == 0)
    if meta.has_oceans then
        r.min_height = G:next(1, 4)^2
        r.max_height = r.min_height + G:next(1, 3)^2
    else
        r.min_height = G:next(1, 6)^2 - 18
        r.max_height = r.min_height + G:next(1, 5)^2
    end
    r.max_plant_height = 5
    r.max_plant_depth = 2
    return r
end
