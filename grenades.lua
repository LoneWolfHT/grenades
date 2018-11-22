local settings = minetest.settings

if settings:get_bool("enable_regular_grenade") then
    grenades.register_grenade("regular", {
        description = "A regular grenade (Kills anyone near where it explodes)",
        image = "grenades_regular.png",
        on_explode = function(pos, player, self)
            minetest.add_particlespawner({
                amount = 20,
                time = 0.5,
                minpos = vector.subtract(pos, 2.3),
                maxpos = vector.add(pos, 2.3),
                minvel = {x=0, y=5, z=0},
                maxvel = {x=0, y=7, z=0},
                minacc = {x=0, y=1, z=0},
                maxacc = {x=0, y=1, z=0},
                minexptime = 0.3,
                maxexptime = 0.6,
                minsize = 5,
                maxsize = 7,
                collisiondetection = false,
                collision_removal = false,
                vertical = false,
                texture = "grenades_smoke.png",
            })

            for k, v in ipairs(minetest.get_objects_inside_radius(pos, 2.3)) do
                if v:is_player() and v:get_hp() > 0 then
                    v:punch(player, 2, {damage_groups = {fleshy = 20}}, nil)
                end
            end
        end,
        timeout = 3
    })
end

if settings:get_bool("enable_flashbang_grenade") then
    grenades.register_grenade("flashbang", {
        description = "A flashbang grenade (Blinds all who look at the explosion)",
        image = "grenades_flashbang.png",
        on_explode = function(pos, player, self)
            for k, v in ipairs(minetest.get_objects_inside_radius(pos, 6)) do
                if v:is_player() and v:get_hp() > 0 then
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

                        minetest.after(4*i, function() v:hud_remove(key) end)
                    end
                end
            end
        end,
        timeout = 3
    })
end
