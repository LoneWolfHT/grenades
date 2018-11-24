local settings = minetest.settings

grenades = {}

local function throw_grenade(name, player)
    local dir = player:get_look_dir()
    local pos = player:get_pos()
    local obj = minetest.add_entity({x=pos.x+dir.x, y=pos.y+1.3, z=pos.z+dir.z}, name)
    local yaw = player:get_look_yaw()

    obj:setvelocity({x=dir.x * 16, y=dir.y * 16, z=dir.z * 16})
    obj:setacceleration({x=dir.x * -3, y=-17, z=dir.z * -3})
    obj:setyaw(yaw + math.pi)

    return(obj:get_luaentity())
end

function grenades.register_grenade(name, def)
    if not def.type then def.type = "shaped" end

    local grenade_entity = {
        physical = true,
        timer = 0,
        visual = "sprite",
        visual_size = {x=1, y=1, z=1},
        textures = {def.image},
        collisionbox = {1, 1, 1, 1, 1, 1},
        on_step = function(self, dtime)
            local pos = self.object:getpos()
            local node = minetest.get_node(pos)
            local player

            if self.timer then
                self.timer = self.timer + dtime
            else
                self.timer = dtime
            end

            if self.thrower_name then
                player = minetest.get_player_by_name(self.thrower_name)
            end
    
            if player and (self.timer > def.timeout or node.name ~= "air") then
                def.on_explode(pos, player, self)

                self.object:remove()
            elseif self.timer > def.timeout or node.name ~= "air" then
                self.object:remove()
            end
        end
    }
    
    minetest.register_entity("grenades:grenade_"..name, grenade_entity)

    if def.placeable == true then
        minetest.register_node("grenades:grenade_"..name, {
            description = def.description,
            stack_max = 1,
            range = 4,
            paramtype = "light",
            sunlight_propagates = true,
            walkable = false,
            drawtype = "plantlike",
            selection_box = {
                type = "fixed",
                fixed = {-0.3, -0.5, -0.3, 0.3, 0.4, 0.3},
            },
            tiles = {def.image},
            inventory_image = def.image,
            groups = {oddly_breakable_by_hand = 2},
            on_use = function(itemstack, user, pointed_thing)
                local player_name = user:get_player_name()
                local inv = user:get_inventory()

                if pointed_thing.type ~= "node" then
                    local grenade = throw_grenade("grenades:grenade_"..name, user)
                    grenade.timer = 0
                    grenade.thrower_name = player_name

                    if not minetest.setting_getbool("creative_mode") then
                        itemstack = ""
                    end
                end

                return itemstack
            end
        })
    else
        minetest.register_craftitem("grenades:grenade_"..name, {
            description = def.description,
            stack_max = 1,
            range = 4,
            inventory_image = def.image,
            on_use = function(itemstack, user, pointed_thing)
                local player_name = user:get_player_name()
                local inv = user:get_inventory()

                if pointed_thing.type ~= "node" then
                    local grenade = throw_grenade("grenades:grenade_"..name, user)
                    grenade.timer = 0
                    grenade.thrower_name = player_name

                    if not minetest.setting_getbool("creative_mode") then
                        itemstack = ""
                    end
                end

                return itemstack
            end
        })
    end

    if def.recipe and (not settings:get_bool("enable_grenade_recipes") or 
        settings:get_bool("enable_grenade_recipes") == true) then
        minetest.register_craft({
            type = def.type,
            output = "grenades:grenade_"..name,
            recipe = def.recipe
        })
    end
end

dofile(minetest.get_modpath("grenades").."/grenades.lua")
