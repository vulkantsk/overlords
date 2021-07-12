--war
function WarStrip(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local modifier = keys.modifier
	local max_stacks = ability:GetSpecialValueFor("max_stacks")
	local stacks_for_silence = ability:GetSpecialValueFor("stacks_for_silence")

	if caster.warStrip_target then
		if caster.warStrip_target == target then
			if caster:HasModifier(modifier) then
				local stack_count = caster:GetModifierStackCount(modifier, ability)

				if stack_count < max_stacks then
					caster:SetModifierStackCount(modifier, ability, stack_count + 1)
				end
				
				if (stack_count+1) == stacks_for_silence then
					ability:ApplyDataDrivenModifier(caster, target, "modifier_war_strip_the_scabbard_silence", {})
				end
			else
				ability:ApplyDataDrivenModifier(caster, caster, modifier, {})
				caster:SetModifierStackCount(modifier, ability, 1)
			end
		else
			caster:RemoveModifierByName(modifier)
			caster.warStrip_target = target
		end
	else
		caster.warStrip_target = target
	end
end

function WarDash(keys)
	local point = keys.target:GetAbsOrigin()
	local caster = keys.caster
	local ability = keys.ability
	local range = ability:GetSpecialValueFor("damage_range")
	
	FindClearSpaceForUnit(caster, point, false)
	ProjectileManager:ProjectileDodge(caster)
	
	local units = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
	
	for _,unit in ipairs(units) do
		ProjectileManager:CreateTrackingProjectile({
			Target = unit,
			Source = caster,
			Ability = ability,	
			iMoveSpeed = range,
			vSourceLoc = point,
			bDodgeable = false,
			bIsAttack = true,
			EffectName = "particles/econ/events/ti9/ti9_monkey_projectile.vpcf",
		})
	end
	
	local blinkIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_blink_start.vpcf", PATTACH_ABSORIGIN, caster)
	Timers:CreateTimer(1, function()
		ParticleManager:DestroyParticle( blinkIndex, false )
	end)
end

function WarDashDamage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	
	ApplyDamage({ victim = target, attacker = caster, damage = caster:GetAttackDamage(), damage_type = DAMAGE_TYPE_PHYSICAL})
end

function MilitaryTribunal(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local modifier = keys.modifier
	local max_stacks = ability:GetSpecialValueFor("max_stacks")
	local duration = ability:GetSpecialValueFor("stack_duration")

	if caster:HasModifier(modifier) then
		local stack_count = caster:GetModifierStackCount(modifier, ability)

		if stack_count < max_stacks then
			caster:SetModifierStackCount(modifier, ability, stack_count + 1)
			MilitaryTribunalRemoveStack(caster, modifier, ability, duration)
			if (stack_count+1) == max_stacks then
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_military_tribunal_crit", {})
			end
		end
	else
		ability:ApplyDataDrivenModifier(caster, caster, modifier, {})
		caster:SetModifierStackCount(modifier, ability, 1)
		MilitaryTribunalRemoveStack(caster, modifier, ability, duration)
	end
end

function MilitaryTribunalRemoveStack(caster, modifier, ability, duration)
	Timers:CreateTimer(duration, function()
		local stack_count = caster:GetModifierStackCount(modifier, ability)
		caster:SetModifierStackCount(modifier, ability, stack_count-1)
		
		if (stack_count-1) <= 0 then 
			caster:RemoveModifierByName(modifier)
		end
	end)
end

function WarWarA(keys)
	WarWarDealDamage(keys.caster, keys.target, keys.ability:GetSpecialValueFor("enemy_dmg_active"))
end

function WarWarP(keys)
	WarWarDealDamage(keys.caster, keys.attacker, keys.ability:GetSpecialValueFor("enemy_dmg_passive"))
end

function WarWarDealDamage(caster, target, percent)
	ApplyDamage({ victim = target, attacker = caster, damage = (target:GetAttackDamage() / 100 * percent), damage_type = DAMAGE_TYPE_PHYSICAL})
end
--war