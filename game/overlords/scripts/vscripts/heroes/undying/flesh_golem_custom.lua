undying_flesh_golem_custom = class({})

function undying_flesh_golem_custom:OnSpellStart()
	return self:GetSpecialValueFor("radius")
end

function undying_flesh_golem_custom:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self
	local target = self:GetCursorTarget()
	local radius = ability:GetSpecialValueFor("radius")
	local base_hp = ability:GetSpecialValueFor("base_hp")
	local base_dmg = ability:GetSpecialValueFor("base_dmg")
	local hp_per_zombie = ability:GetSpecialValueFor("hp_per_zombie")
	local dmg_per_zombie = ability:GetSpecialValueFor("dmg_per_zombie")
	local duration = ability:GetSpecialValueFor("duration")
	

	target:ForceKill(false)
	target:AddNoDraw()
	local unit_count = 1
	local target_point = target:GetAbsOrigin()
	
	local allies = FindUnitsInRadius(
		caster:GetTeamNumber(),
		target_point,
		nil,
		radius,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		DOTA_UNIT_TARGET_BASIC,
		0,
		0,
		false
	)

	for _,ally in pairs(allies) do
		local owner = ally:GetOwner()

		if caster == owner and ally.zombie then
			local ally_point = ally:GetAbsOrigin()
			ally:ForceKill(false)
			local effect_cast = ParticleManager:CreateParticle(
				"particles/units/heroes/hero_doom_bringer/doom_bringer_scorched_earth_debuff.vpcf",
				PATTACH_ABSORIGIN_FOLLOW,
				target 
			)
			ParticleManager:SetParticleControl(effect_cast, 1, Vector())
			ParticleManager:ReleaseParticleIndex( effect_cast )

			unit_count = unit_count + 1
		end
	end		
	
	local unit = CreateUnitByName( "npc_dota_undying_flesh_golem", target_point, true, caster, caster, caster:GetTeam() )
	unit:StartGesture(ACT_DOTA_SPAWN)
	
	unit:AddNewModifier( unit, ability, "modifier_phased", {} )
	unit:AddNewModifier( unit, ability, "modifier_kill", {duration = duration} )

--	unit:SetControllableByPlayer(player, false)
	unit:SetOwner(caster)
	--unit:SetForwardVector(fv)
	
	local total_hp = base_hp + hp_per_zombie * unit_count
	local total_dmg = base_dmg + dmg_per_zombie * unit_count

	unit:SetBaseDamageMin( base_dmg )
	unit:SetBaseDamageMax( base_dmg )				
--	unit:SetPhysicalArmorBaseValue( total_count )
	unit:SetBaseMaxHealth( total_hp )
	unit:SetMaxHealth( total_hp )
	unit:SetHealth( total_hp )

	unit:EmitSound("")
end
