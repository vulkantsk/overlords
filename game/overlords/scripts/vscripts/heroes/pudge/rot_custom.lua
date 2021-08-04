
LinkLuaModifier( "modifier_pudge_rot_custom", "heroes/pudge/rot_custom", LUA_MODIFIER_MOTION_NONE )

pudge_rot_custom = {}

function pudge_rot_custom:GetCastRange()
	return self:GetSpecialValueFor("radius")
end

function pudge_rot_custom:GetIntrinsicModifierName()
	return	"modifier_pudge_rot_custom"
end

modifier_pudge_rot_custom = {}

function modifier_pudge_rot_custom:IsHidden()
	return true
end

function modifier_pudge_rot_custom:IsDebuff()
	return false
end

function modifier_pudge_rot_custom:IsPurgable()
	return false
end

function modifier_pudge_rot_custom:OnCreated( kv )
	self.dps = self:GetAbility():GetSpecialValueFor( "damage_per_second" )
	self.interval = self:GetAbility():GetSpecialValueFor( "interval" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )

	if not IsServer() then return end
	self.damage = self.dps * self.interval

	self:StartIntervalThink( self.interval )

	if not self.refresh then		
		EmitSoundOn("Hero_Pudge.Rot", self:GetCaster())
		self.effect = ParticleManager:CreateParticle(
			"particles/units/heroes/hero_pudge/pudge_rot.vpcf",
			PATTACH_ABSORIGIN_FOLLOW,
			self:GetParent()
		)
		ParticleManager:SetParticleControl( self.effect, 1, Vector( self.radius, 0, 0 ) )

		self:AddParticle(
			self.effect,
			false,
			false,
			-1,
			false,
			false 
		)
	else
		self.refresh = false
		ParticleManager:SetParticleControl( self.effect, 1, Vector( self.radius, 0, 0 ) )
	end		

end

function modifier_pudge_rot_custom:OnRefresh( kv )
	self.refresh = true
	self:OnCreated(kv)
end

function modifier_pudge_rot_custom:OnDestroy( kv )
	StopSoundOn("Hero_Pudge.Rot", self:GetCaster())
end

function modifier_pudge_rot_custom:OnIntervalThink()
	local enemies = FindUnitsInRadius(self:GetCaster():GetTeam(), 
									self:GetCaster():GetAbsOrigin(), 
									nil, 
									500, 
									DOTA_UNIT_TARGET_TEAM_ENEMY, 
									DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 
									DOTA_UNIT_TARGET_FLAG_NONE, 
									FIND_ANY_ORDER, false)
	--print(#enemies)
	for _,enemy in pairs(enemies) do
		ApplyDamage({
			victim = enemy,
			attacker = self:GetCaster(),
			damage = self.damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self:GetAbility(),
		})

		local effect_cast = ParticleManager:CreateParticle(
			"particles/units/heroes/hero_doom_bringer/doom_bringer_scorched_earth_debuff.vpcf",
			PATTACH_ABSORIGIN_FOLLOW,
			target 
		)
		ParticleManager:ReleaseParticleIndex( effect_cast )
	end
end

