modifier_pudge_dirty_bomb_lua_thinker = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_pudge_dirty_bomb_lua_thinker:IsHidden()
	return true
end

function modifier_pudge_dirty_bomb_lua_thinker:IsDebuff()
	return false
end

function modifier_pudge_dirty_bomb_lua_thinker:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_pudge_dirty_bomb_lua_thinker:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	-- references
	self.name = "particles/units/heroes/hero_dawnbreaker/dawnbreaker_celestial_hammer_return.vpcf"
	self.speed = self:GetAbility():GetSpecialValueFor( "projectile_speed" )
	self.delay = self:GetAbility():GetSpecialValueFor( "pause_duration" )
	self.duration = self:GetAbility():GetSpecialValueFor( "flare_debuff_duration" )
	self.vision = 200
	self.interval = 0.1

	self.origin = self:GetParent():GetOrigin()
	self.point = Vector( kv.x, kv.y, 0 )
	self.direction = self.point - self.origin
	self.distance = self.direction:Length2D()
	self.direction.z = 0
	self.direction = self.direction:Normalized()
	self.enemies = {}



	-- NOTE: arbitrary decision to mimic original spell
	self.max_return = 1.5

	if not IsServer() then return end

	-- play effects
	local sound_loop = "Hero_Dawnbreaker.Celestial_Hammer.Projectile"
	EmitSoundOn( sound_loop, self.parent )
end

function modifier_pudge_dirty_bomb_lua_thinker:OnRefresh( kv )
end

function modifier_pudge_dirty_bomb_lua_thinker:OnRemoved()
end

function modifier_pudge_dirty_bomb_lua_thinker:OnDestroy()
	if not IsServer() then return end
	UTIL_Remove( self:GetParent() )
	self:GetParent():RemoveHorizontalMotionController( self )
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_pudge_dirty_bomb_lua_thinker:OnIntervalThink()
	if not self.converge then
		self:Return()
		return
	end

	
	self.prev_pos = self.parent:GetOrigin()
end

--------------------------------------------------------------------------------
-- Helper
function modifier_pudge_dirty_bomb_lua_thinker:Delay()
	self:PlayEffects1()
	self:StartIntervalThink( self.delay )

	-- add viewer
	AddFOWViewer( self.caster:GetTeamNumber(), self.parent:GetOrigin(), self.vision, self.delay, false)
end

function modifier_pudge_dirty_bomb_lua_thinker:Return()
	if self.converge then return end

	self.converge = true
	local caster = self:GetCaster()
	local point = self:GetCaster():GetCursorPosition()

	local maxrange = self:GetAbility():GetSpecialValueFor( "hook_range" )

	local direction = point-caster:GetOrigin()
	if direction:Length2D() > maxrange then
		direction.z = 0
		direction = direction:Normalized()

		point = caster:GetOrigin() + direction * maxrange
	end

end

function modifier_pudge_dirty_bomb_lua_thinker:UpdateHorizontalMotion( me, dt )
	local origin = me:GetOrigin()
	local target = origin + self.direction*self.speed*dt
	me:SetOrigin( target )

	GridNav:DestroyTreesAroundPoint( origin, self.tree, false )

	local dist = (target-self.origin):Length2D()
	if dist>self.distance then
		self:Destroy()
	end
end

function modifier_pudge_dirty_bomb_lua_thinker:OnHorizontalMotionInterrupted()
	self:Destroy()
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_pudge_dirty_bomb_lua_thinker:PlayEffects1()
	-- Get Resources
	local particle_cast = "particles/heroes/plague/dirty_bomb/plague_hook_grounded.vpcf"
	local sound_cast = "Hero_Dawnbreaker.Celestial_Hammer.Impact"

	-- Get Data
	local direction = self:GetParent():GetOrigin()-self:GetCaster():GetOrigin()
	direction.z = 0
	direction = direction:Normalized()

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self:GetParent() )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, self:GetCaster():GetOrigin() )
	ParticleManager:SetParticleControlForward( effect_cast, 0, direction )
	self.effect_cast = effect_cast

	-- buff particle
	self:AddParticle(
		effect_cast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)

	-- Create Sound
	EmitSoundOn( sound_cast, self.parent )
end

function modifier_pudge_dirty_bomb_lua_thinker:PlayEffects2()
	if self.effect_cast then
		ParticleManager:DestroyParticle( self.effect_cast, false )
		ParticleManager:ReleaseParticleIndex( self.effect_cast )
	end

	local sound_cast = "Hero_Dawnbreaker.Celestial_Hammer.Return"
	EmitSoundOn( sound_cast, self.parent )
end