local settings = minetest.settings

local regular = settings:get_bool("enable_regular_grenade")
local flash = settings:get_bool("enable_flashbang_grenade")
local smoke = settings:get_bool("enable_smoke_grenade")

if not regular or regular == true then
    grenades.register_grenade("regular", {
        description = "A regular grenade (Kills anyone near where it explodes)",
        image = "grenades_regular.png",
        on_explode = function(pos, player, self)
            local radius = 3

            minetest.add_particlespawner({
                amount = 20,
                time = 0.5,
                minpos = vector.subtract(pos, radius),
                maxpos = vector.add(pos, radius),
                minvel = {x=0, y=5, z=0},
                maxvel = {x=0, y=7, z=0},
                minacc = {x=0, y=1, z=0},
                maxacc = {x=0, y=1, z=0},
                minexptime = 0.3,
                maxexptime = 0.6,
                minsize = 7,
                maxsize = 10,
                collisiondetection = true,
                collision_removal = false,
                vertical = false,
                texture = "grenades_smoke.png",
            })

            for k, v in ipairs(minetest.get_objects_inside_radius(pos, radius)) do
                if v:is_player() and v:get_hp() > 0 then
                    v:punch(player, 2, {damage_groups = {fleshy = 20-vector.distance(pos, v:get_pos())}}, nil)
                end
            end
        end,
        timeout = 3
    })
end

if not flash or flash == true then
    grenades.register_grenade("flashbang", {
        description = "A flashbang grenade (Blinds all who look at the explosion)",
        image = "grenades_flashbang.png",
        on_explode = function(pos, player, self)
            for k, v in ipairs(minetest.get_objects_inside_radius(pos, 15)) do
                if v:is_player() and v:get_hp() > 0 then
                    local playerdir = vector.round(v:get_look_dir())
                    local grenadedir = vector.round(vector.direction(v:get_pos(), pos))

                    if playerdir.x == grenadedir.x and playerdir.z == grenadedir.z then
                        for i = 1, 3, 1 do
                            local key = v:hud_add({
                                hud_elem_type = "image",
                                position = {x=0, 0},
                                name = "death_list_hud",
                                scale = {x=1000, y=1000},
                                text = "grenades_white_"..tostring(i)..".png",
                                alignment = {x=0, y=0},
                                offset = {x=0, y=0}
                            })

                            minetest.after(1.7*i, function() v:hud_remove(key) end)
                        end
                    end
                end
            end
        end,
        timeout = 3
    })
end

if not smoke or smoke == true then
    grenades.register_grenade("smoke_greande", {
        description = "A smoke grenade (Generates a lot of smoke around the detonation area)",
        image = "grenades_smoke_grenade.png",
        on_explode = function(pos, player, self)
            for i = 0, 5, 1 do
                minetest.add_particlespawner({
                    amount = 100,
                    time = 10,
                    minpos = vector.subtract(pos, 3.5),
                    maxpos = vector.add(pos, 3.5),
                    minvel = {x=0, y=2, z=0},
                    maxvel = {x=0, y=3, z=0},
                    minacc = {x=1, y=0.2, z=1},
                    maxacc = {x=1, y=0.2, z=1},
                    minexptime = 0.3,
                    maxexptime = 1,
                    minsize = 100,
                    maxsize = 100,
                    collisiondetection = false,
                    collision_removal = false,
                    vertical = false,
                    texture = "grenades_smoke.png",
                })
            end
        end,
        timeout = 3
    })
end
