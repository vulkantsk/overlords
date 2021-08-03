LinkLuaModifier( "modifier_pudge_devour", "heroes/pudge/devour", LUA_MODIFIER_MOTION_NONE )

pudge_devour = {}

function pudge_devour:CastFilterResultTarget( hTarget )
	local nResult = UnitFilter(
		hTarget,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_CREEP,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS + DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO,
		self:GetCaster():GetTeamNumber()
	)
	if nResult ~= UF_SUCCESS then
		return nResult
	end

	return UF_SUCCESS
end

function pudge_devour:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local heal = self:GetSpecialValueFor( "heal" )
	local heal_pct = self:GetSpecialValueFor( "heal_pct" )

	target:AddNoDraw()
	target:Kill( self, caster )

	local max_hp = caster:GetMaxHealth()
	local total_heal = heal + heal_pct*max_hp
	caster:Heal(total_heal, self)

	local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_doom_bringer/doom_bringer_devour.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )

	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0),
		true
	)

	ParticleManager:ReleaseParticleIndex( effect_cast )

	EmitSoundOn( "Hero_DoomBringer.Devour", self:GetCaster() )
	EmitSoundOn( "Hero_DoomBringer.DevourCast", target )
end

