--cape_of_evil
function item_cape_of_evil_OnAttacked(keys)
	local dmg = keys.attacker:GetAttackDamage()
	local percent = keys.ability:GetSpecialValueFor("incoming_damage_mana_regen_percent")
	
	keys.caster:GiveMana(tonumber(dmg * percent / 100))
end

function item_cape_of_evil_Cast(keys)
	local caster = keys.caster
	local damage = tonumber(caster:GetMaxHealth() * 10 / 100)
	local initial_scale = caster:GetModelScale()
	
	caster:SetModelScale(tonumber(initial_scale/2))
	
	Timers:CreateTimer(1.0, function()
		caster:SetModelScale(initial_scale)
	
		ApplyDamage({
			victim = caster,
			attacker = caster,
			damage = damage,
			damage_type = DAMAGE_TYPE_PURE,
		})
		
		local units = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), nil, 250, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _,unit in pairs(units) do 
			if unit and unit:IsAlive() then
				ApplyDamage({
					victim = unit,
					attacker = caster,
					damage = damage,
					damage_type = DAMAGE_TYPE_PURE,
				})
			end
		end
	end)
end
--

--dark_boots
function item_dark_boots_Think(keys)
	local caster = keys.caster
	local item = keys.ability
	
	if item.time == nil then item.time = 0 end;
	if item.pos == nil then item.pos = caster:GetOrigin() end;
	
	local distance = item:GetSpecialValueFor("distance_to_increase_speed")
	local inc = item:GetSpecialValueFor("distance_increase_percent")
	local max = item:GetSpecialValueFor("max_distance_increase_percent")
	local timeLimit = item:GetSpecialValueFor("standing_duration_to_drop_bonus")
	
	local dif = (item.pos - caster:GetOrigin()):Length2D()
	
	if dif < 100 then
		item.time = item.time + 0.5
		if item.time >= timeLimit then
			item.time = 0
			caster:RemoveModifierByName("modifier_item_dark_boots_stack")
		end
	else
		item.time = 0
		
		if not caster:HasModifier("modifier_item_dark_boots_stack") then
			item.mod = item:ApplyDataDrivenModifier(caster, caster, "modifier_item_dark_boots_stack", {})
		end
		
		local scount = caster:GetModifierStackCount("modifier_item_dark_boots_stack", item)
		if scount < max then
			local ncount = tonumber(scount + (math.floor(dif/100)*inc))
			if ncount > max then ncount = max end
			caster:SetModifierStackCount("modifier_item_dark_boots_stack", item, ncount)
		end
	end
	
	item.pos = caster:GetOrigin()
end
--