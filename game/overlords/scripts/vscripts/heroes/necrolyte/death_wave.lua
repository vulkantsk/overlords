--LinkLuaModifier("modifier_necrolyte_death_wave_debuff", "heroes/hero_tangin/fire_breathe", LUA_MODIFIER_MOTION_NONE)

necrolyte_death_wave = class({})

function necrolyte_death_wave:GetCastRange()
	return self:GetSpecialValueFor("wave_distance")
end

function necrolyte_death_wave:OnSpellStart()
  local caster = self:GetCaster()

  local vDirection = (self:GetCursorPosition() - caster:GetOrigin() + caster:GetForwardVector()):Normalized()
  EmitSoundOn("Hero_DragonKnight.BreathFire", self:GetCaster())

  local particle = "particles/units/heroes/hero_dragon_knight/dragon_knight_breathe_fire.vpcf"

  ProjectileManager:CreateLinearProjectile({
    EffectName = particle,
    Ability = self,
    vSpawnOrigin = self:GetCaster():GetOrigin(),
    fStartRadius = self:GetSpecialValueFor("wave_width_initial"),
    fEndRadius = self:GetSpecialValueFor("wave_width_end"),
    vVelocity = vDirection * self:GetSpecialValueFor("wave_speed"),
    fDistance = self:GetSpecialValueFor("wave_distance"),
    Source = self:GetCaster(),
    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
--      iUnitTargetFlags = self:GetAbilityTargetFlags(),
    bProvidesVision = true,
    iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
    iVisionRadius = self:GetSpecialValueFor("wave_width_end"),
  })

end

function necrolyte_death_wave:OnProjectileHit( hTarget, vLocation )
	if hTarget ~= nil then
		local caster = self:GetCaster()
    local damage = self:GetSpecialValueFor("damage")
--		local debuff_duration = self:GetSpecialValueFor("debuff_duration")

		ApplyDamage({
      attacker = caster,
      victim = hTarget,
      damage = damage,
      damage_type = self:GetAbilityDamageType(),
      ability = self,
    })
--		hTarget:AddNewModifier(self:GetCaster(), self, "modifier_necrolyte_death_wave_debuff", {duration = debuff_duration})

	end
end
