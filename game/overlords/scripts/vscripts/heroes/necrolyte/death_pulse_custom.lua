--LinkLuaModifier("modifier_necrolyte_death_pulse_custom", "heroes/necrolyte/death_pulse_custom", LUA_MODIFIER_MOTION_NONE)


necrolyte_death_pulse_custom = class({})

function necrolyte_death_pulse_custom:GetCastRange()
	return self:GetSpecialValueFor("radius")
end

function necrolyte_death_pulse_custom:OnSpellStart()
	local caster = self:GetCaster()
    local radius = self:GetSpecialValueFor("radius")
    local pulse_speed = self:GetSpecialValueFor("pulse_speed")
   	
 	local index = RandomInt(1, 20)
    if index < 10 then
        index = "0"..index
    end
    caster:EmitSound("hoodwink_hoodwink_arb_hit_"..index)
    caster:EmitSound("Hero_Hoodwink.Sharpshooter.Projectile")
  
	local enemies = FindUnitsInRadius(
		caster:GetTeam(),
		caster:GetOrigin(),
		nil,
		radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_ALL,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false
	)
	--print(#enemies)

	for _,enemy in pairs(enemies) do
		ProjectileManager:CreateTrackingProjectile({
			EffectName = "particles/units/heroes/hero_sven/sven_spell_storm_bolt.vpcf",
			Ability = self,
			iMoveSpeed = pulse_speed,
			Source = self:GetCaster(),
			Target = enemy,
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
		})
	end
end

function necrolyte_death_pulse_custom:OnProjectileHit( hTarget, vLocation )
	if hTarget ~= nil then
    local caster = self:GetCaster()
    local pulse_damage = self:GetSpecialValueFor("pulse_damage")
    local pulse_heal = self:GetSpecialValueFor("pulse_heal")
    local duration = self:GetSpecialValueFor("duration")
	local pulse_speed = self:GetSpecialValueFor("pulse_speed")

	print(hTarget:GetUnitName())

	if hTarget ~= caster then
  --    EmitSoundOn("Hero_hoodwink.StormBoltImpact", hTarget)   
        ApplyDamage({
			attacker = caster,
			victim = hTarget,
			damage = pulse_damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self,
        })

		--hTarget:AddNewModifier(self:GetCaster(), self, "modifier_necrolyte_death_pulse_custom", {duration = duration}) 
		if not hTarget:IsAlive() then
			ProjectileManager:CreateTrackingProjectile({
				EffectName = "particles/units/heroes/hero_sven/sven_spell_storm_bolt.vpcf",
				Ability = self,
				iMoveSpeed = pulse_speed,
				Source = hTarget,
				Target = caster,
				iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
			})
		end
    else
		caster:Heal(pulse_heal, ability)
    end

	end
end

--[[
modifier_necrolyte_death_pulse_custom = class({
  IsHidden        = function(self) return true end,
  IsPurgable        = function(self) return false end,
  IsDebuff        = function(self) return false end,
  IsBuff                  = function(self) return true end,
  RemoveOnDeath       = function(self) return false end,
  DeclareFunctions    = function(self) return 
    {
    MODIFIER_EVENT_ON_DEATH,
    } end,
})


function modifier_necrolyte_death_pulse_custom:OnDeath(data)
    local caster = self:GetCaster()
    local parent = self:GetParent()
    local pulse_speed = self:GetSpecialValueFor("pulse_speed")
    local unit = data.unit
    local ability = self:GetAbility()

    if parent == unit  then 
		--parent:EmitSound("")
		ProjectileManager:CreateTrackingProjectile({
			EffectName = "particles/units/heroes/hero_sven/sven_spell_storm_bolt.vpcf",
			Ability = self,
			iMoveSpeed = pulse_speed,
			Source = parent,
			Target = caster,
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
		})
    end
end
]]
