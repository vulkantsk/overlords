LinkLuaModifier( "modifier_pudge_plague_spirit", "heroes/plague/plague_spirit", LUA_MODIFIER_MOTION_NONE )

pudge_plague_spirit = class({})
--------------------------------------------------------------------------------
-- Ability Start

function pudge_plague_spirit:OnChannelFinish()
   local caster = self:GetCaster()
   local duration = self:GetSpecialValueFor("cloud_duration")


   caster:AddNewModifier( caster, self, "modifier_pudge_plague_spirit", {
		duration = duration
	} )
	caster:AddNewModifier( caster, self, "modifier_ability_sand_storm_invis", {
		duration = duration
	} )

	EmitSoundOn( "Ability.SandKing_SandStorm.start", caster )

  

end


modifier_pudge_plague_spirit = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return true end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
	DeclareFunctions		= function(self) return 
		{

         
		
		} end,
})



function modifier_pudge_plague_spirit:OnCreated()
	if IsClient() then
		return
	end

	local ability = self:GetAbility()
	local parent = self:GetParent()

	self.radius = ability:GetSpecialValueFor( "cloud_range" )
	self.damage_interval = ability:GetSpecialValueFor( "damage_tick_rate" )
	self.next_damage_time = GameRules:GetGameTime() + self.damage_interval
	self.start_pos = parent:GetAbsOrigin()
	self.damageTable = {
		attacker = parent,
		damage =   parent:GetMaxHealth()*0.1,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = ability
	}
	self.damageTable2 = {
		attacker = parent,
		damage =   parent:GetMaxHealth()*0.05,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = ability
	}

	local enemies = FindUnitsInRadius(
		parent:GetTeamNumber(),
		parent:GetOrigin(),
		nil,
		self.radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		0,
		0,
		false
	)

	for _,enemy in pairs(enemies) do
		self.damageTable.victim = enemy
		ApplyDamage( self.damageTable )
	end

	self.effect = ParticleManager:CreateParticle(
		"particles/heroes/plague/plague_cloud.vpcf",
		PATTACH_WORLDORIGIN,
		nil
	)
	ParticleManager:SetParticleControl( self.effect, 0, parent:GetAbsOrigin() )
	ParticleManager:SetParticleControl( self.effect, 1, Vector( self.radius, self.radius, self.radius ) )

	EmitSoundOn( "Hero_Pudge.Rot", self:GetCaster() )

	self:StartIntervalThink( 0.25 )
end

function modifier_pudge_plague_spirit:OnDestroy()
	ParticleManager:DestroyParticle( self.effect, false )
	StopSoundOn( "Hero_Pudge.Rot", self:GetCaster() )
end

function modifier_pudge_plague_spirit:OnIntervalThink()
	if ( self.start_pos - self:GetParent():GetAbsOrigin() ):Length2D() > self.radius then
		self:Destroy()

		return
	end

    local parent = self:GetParent()
    local heal = parent:GetMaxHealth()*0.01
	local enemies = FindUnitsInRadius(
		parent:GetTeamNumber(),
		parent:GetOrigin(),
		nil,
		self.radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		0,
		0,
		false
	)

	parent:Heal(heal, parent)

	for _,enemy in pairs(enemies) do
		self.damageTable2.victim = enemy
		ApplyDamage( self.damageTable2 )
	end

	local friends = FindUnitsInRadius(
		parent:GetTeamNumber(),
		parent:GetOrigin(),
		nil,
		self.radius,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		0,
		0,
		false
	)

	for _,friend in pairs(friends) do
     friend:Heal(parent:GetMaxHealth()*0.01, parent)
 end

end

