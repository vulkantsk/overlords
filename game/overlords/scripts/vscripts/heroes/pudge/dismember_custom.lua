LinkLuaModifier( "modifier_pudge_dismember_custom_debuff", "heroes/pudge/dismember_custom", LUA_MODIFIER_MOTION_NONE )


pudge_dismember_custom = class({})

function pudge_dismember_custom:GetChannelTime()
	return self:GetSpecialValueFor("duration")
end

function pudge_dismember_custom:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	-- load data
	local maxDuration = self:GetChannelTime()

	-- cancel if linken
	if target:TriggerSpellAbsorb( self ) then
		return
	end

	-- add modifier
	self.modifier = target:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_pudge_dismember_custom_debuff", -- modifier name
		{ duration = maxDuration } -- kv
    )
    
	self:PlayEffects( target )
end

function pudge_dismember_custom:StopSpell()
	if self.modifier then
		self.modifier:Destroy()
		
		if self:IsChanneling() then
			self:GetCaster():Stop()
		end

		-- stop effects
		StopSoundOn( self.sound_cast, self:GetCaster() )
		StopSoundOn( self.sound_target, self.target )
		self.target = nil
	end
end

--------------------------------------------------------------------------------
-- Ability Channeling
function pudge_dismember_custom:OnChannelFinish( bInterrupted )
	self:StopSpell()
end

--------------------------------------------------------------------------------
function pudge_dismember_custom:PlayEffects( target )
	-- Get Resources
	self.sound_cast = "Hero_Bane.FiendsGrip.Cast"
	self.sound_target = "Hero_Bane.FiendsGrip"

	-- Create Sound
	EmitSoundOn( sound_cast, self:GetCaster() )
	EmitSoundOn( self.sound_target, target )
	self.target = target
end

modifier_pudge_dismember_custom_debuff = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_pudge_dismember_custom_debuff:IsHidden()
	return false
end

function modifier_pudge_dismember_custom_debuff:IsDebuff()
	return true
end

function modifier_pudge_dismember_custom_debuff:IsStunDebuff()
	return true
end

function modifier_pudge_dismember_custom_debuff:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_pudge_dismember_custom_debuff:OnCreated( kv )
	-- references
	self.damage = self:GetAbility():GetSpecialValueFor( "damage" ) -- special value
	self.interval = self:GetAbility():GetSpecialValueFor( "damage_interval" ) -- special value

	-- Start interval
	if IsServer() then
		-- precache damage
		self.damageTable = {
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = self.damage * self.interval,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self, --Optional.
		}

		-- start interval
		self:OnIntervalThink()
		self:StartIntervalThink( self.interval )

		-- play effects
		self:PlayEffects()
	end
end

function modifier_pudge_dismember_custom_debuff:OnRefresh( kv )
	-- references
	self.damage = self:GetAbility():GetSpecialValueFor( "damage" ) -- special value

	if IsServer() then
		self.damageTable.damage = self.damage * self.interval
	end
end

function modifier_pudge_dismember_custom_debuff:OnDestroy( kv )
	if IsServer() then
		self:GetAbility():StopSpell()

		-- stop effects
		-- self:StopEffects()
	end
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_pudge_dismember_custom_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

function modifier_pudge_dismember_custom_debuff:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_pudge_dismember_custom_debuff:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_pudge_dismember_custom_debuff:OnIntervalThink()
	if IsServer() then
		-- damage
		if not self:GetParent():IsMagicImmune() then
			ApplyDamage(self.damageTable)
		end
	end
end

function modifier_pudge_dismember_custom_debuff:PlayEffects()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_pudge/pudge_dismember.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )

	-- buff particle
	self:AddParticle(
		effect_cast,
		false,
		false,
		-1,
		false,
		false
	)
end