grenades = {}

local function throw_grenade(name, player)
	local dir = player:get_look_dir()
	local pos = player:get_pos()
	local obj = minetest.add_entity({x = pos.x + dir.x, y = pos.y + 1.8, z = pos.z + dir.z}, name)
	local self = obj:get_luaentity()

	obj:set_velocity(vector.add(player:get_player_velocity(), {x = dir.x * 40, y = dir.y * 30, z = dir.z * 40}))
	obj:set_acceleration(vector.add(player:get_player_velocity(), {x = 0, y = -41, z = 0}))
	self.dir = dir

	return(obj:get_luaentity())
end

function grenades.register_grenade(name, def)
	if not def.clock then
		def.clock = 3
	end

	local grenade_entity = {
		physical = true,
		collide_with_objects = true,
		timer = 0,
		visual = "sprite",
		visual_size = {x = 0.5, y = 0.5, z = 0.5},
		textures = {def.image},
		collisionbox = {-0.2, -0.2, -0.2, 0.2, 0.15, 0.2},
		pointable = false,
		static_save = false,
		particle = 0,
		on_step = function(self, dtime)
			local obj = self.object
			local vel = obj:get_velocity()
			local pos = obj:get_pos()

			self.timer = self.timer + dtime

			if not self.last_vel then
				self.last_vel = vel
			end

			-- Collision Check

			if not vector.equals(self.last_vel, vel) and vector.distance(self.last_vel, vel) > 3.5 then
				if math.abs(self.last_vel.z) - 5 > math.abs(vel.z) then
					self.last_vel.z = self.last_vel.z * -0.5
				end

				if math.abs(self.last_vel.x) - 5 > math.abs(vel.x) then
					self.last_vel.x = self.last_vel.x * -0.5
				end

				if self.last_vel.y <= -5 then
					self.last_vel.y = self.last_vel.y * -0.3
				end

				obj:set_velocity(self.last_vel)
				vel = obj:get_velocity()
			end

			-- Fix accel bug

			vel.x = vel.x / 1.07

			vel.z = vel.z / 1.07

			obj:set_velocity(vel)
			self.last_vel = vel

			-- Grenade Particles

			if def.particle and self.particle >= 4 then
				self.particle = 0

				minetest.add_particle({
					pos = obj:get_pos(),
					velocity = vector.divide(vel, 2),
					acceleration = vector.divide(obj:get_acceleration(), -5),
					expirationtime = def.particle.life,
					size = def.particle.size,
					collisiondetection = false,
					collision_removal = false,
					vertical = false,
					texture = def.particle.image,
					glow = def.particle.glow
				})
			elseif def.particle and self.particle < def.particle.interval then
				self.particle = self.particle + 1
			end

			-- Explode when clock is up

			if self.timer > def.clock or not self.thrower_name then
				if self.thrower_name then
					minetest.log("[Grenades] A grenade thrown by "..self.thrower_name..
					" is exploding at "..minetest.pos_to_string(pos))
                    def.on_explode(pos, self.thrower_name)
                end

				obj:remove()
			end
		end
	}

	minetest.register_entity(name, grenade_entity)

	local newdef = {}

	newdef.description = def.description
	newdef.stack_max = 1
	newdef.range = 2
	newdef.inventory_image = def.image
	newdef.on_use = function(itemstack, user, pointed_thing)
		local player_name = user:get_player_name()

		if pointed_thing.type ~= "node" then
			local grenade = throw_grenade(name, user)
			grenade.timer = 0
			grenade.thrower_name = player_name

			if not minetest.settings:get_bool("creative_mode") then
				itemstack = ""
			end
		end

		return itemstack
	end

	if def.placeable == true then

		newdef.tiles = {def.image}
		newdef.selection_box = {
			type = "fixed",
			fixed = {-0.3, -0.5, -0.3, 0.3, 0.4, 0.3},
		}
		newdef.groups = {oddly_breakable_by_hand = 2}
		newdef.paramtype = "light"
		newdef.sunlight_propagates = true
		newdef.walkable = false
		newdef.drawtype = "plantlike"

		minetest.register_node(name, newdef)
	else
		minetest.register_craftitem(name, newdef)
	end
end

minetest.register_craftitem("grenades:notice_flashbang", {
	description = "[Flashbang] This mod no longer adds grenades. Please get 'grenades_basic' to restore your items\n"..
	"Once the mod is added you can punch the air with this notice to turn it into the grenade it was before",
	range = 0,
	inventory_image = "grenades_notice.png",
	groups = {not_in_creative_inventory = 1},
	stack_max = 1,
	on_use = function()
		if minetest.get_modpath("grenades_basic") then
			return "grenades_basic:flashbang"
		end
	end
})

minetest.register_alias("grenades:grenade_flashbang", "grenades:notice_flashbang")

minetest.register_craftitem("grenades:notice_regular", {
	description = "[Regular Grenade] This mod no longer adds grenades. Please get 'grenades_basic' to restore "..
	"your items\n"..
	"Once the mod is added you can punch the air with this notice to turn it into the grenade it was before",
	inventory_image = "grenades_notice.png",
	groups = {not_in_creative_inventory = 1},
	range = 0,
	stack_max = 1,
	on_use = function()
		if minetest.get_modpath("grenades_basic") then
			return "grenades_basic:regular"
		end
	end
})

minetest.register_alias("grenades:grenade_regular", "grenades:notice_regular")

minetest.register_craftitem("grenades:notice_smoke", {
	description = "[Smoke] This mod no longer adds grenades. Please get 'grenades_basic' to restore your items\n"..
	"Once the mod is added you can punch the air with this notice to turn it into the grenade it was before",
	range = 0,
	inventory_image = "grenades_notice.png",
	groups = {not_in_creative_inventory = 1},
	stack_max = 1,
	on_use = function()
		if minetest.get_modpath("grenades_basic") then
			return "grenades_basic:smoke"
		end
	end
})

minetest.register_alias("grenades:grenade_smoke", "grenades:notice_smoke")
