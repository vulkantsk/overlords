--war
function WarDash(keys)
	local point = keys.target_points[1]
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

	if caster:HasModifier(modifier) then
		local stack_count = caster:GetModifierStackCount(modifier, ability)

		if stack_count < max_stacks then
			caster:SetModifierStackCount(modifier, ability, stack_count + 1)
			if (stack_count+1) == max_stacks then
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_military_tribunal_crit", {})
			end
		end
	else
		ability:ApplyDataDrivenModifier(caster, caster, modifier, {})
		caster:SetModifierStackCount(modifier, ability, 1)
	end
end
--war