LinkLuaModifier("modifier_necrolyte_death_pulse_custom", "heroes/necrolyte/death_pulse", LUA_MODIFIER_MOTION_NONE)


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
    caster:GetTeamNumber(),
    caster:GetOrigin(),
    nil,
    radius,
    DOTA_UNIT_TARGET_TEAM_ENEMY,
    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
    0,
    0,
    false
  )

  for _,enemy in pairs(enemies) do
    local info = {
      EffectName = "particles/units/heroes/hero_sven/sven_spell_storm_bolt.vpcf",
      Ability = self,
      iMoveSpeed = pulse_speed,
      Source = self:GetCaster(),
      Target = target,
      iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
    }

    ProjectileManager:CreateTrackingProjectile( info )
  end
end

function necrolyte_death_pulse_custom:OnProjectileHit( hTarget, vLocation )
	if hTarget ~= nil then
    local caster = self:GetCaster()
    local pulse_damage = self:GetSpecialValueFor("pulse_damage")
    local pulse_heal = self:GetSpecialValueFor("pulse_heal")
    local duration = self:GetSpecialValueFor("duration")

		if hTarget ~= caster then
  --    EmitSoundOn("Hero_hoodwink.StormBoltImpact", hTarget)   
        self.damageTable = {
          attacker = caster,
          victim = hTarget,
          damage = damage,
          damage_type = self:GetAbility():GetAbilityDamageType(),
          ability = self:GetAbility(),
        }
        ApplyDamage(self.damageTable)

      hTarget:AddNewModifier(self:GetCaster(), self, "modifier_necrolyte_death_pulse_custom", {duration = duration})    
    else
      caster:Heal(heal, ability)
    end

	end
end


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
      parent:EmitSound("")

      local info = {
        EffectName = "particles/units/heroes/hero_sven/sven_spell_storm_bolt.vpcf",
        Ability = self,
        iMoveSpeed = pulse_speed,
        Source = parent,
        Target = caster,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
      }

      ProjectileManager:CreateTrackingProjectile( info )
    end
end

