


pudge_dirty_bomb = class({})
LinkLuaModifier( "modifier_pudge_dirty_bomb", "heroes/plague/modifier_dirty_bomb", LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_pudge_dirty_bomb_nohammer", "heroes/plague/dirty_bomb", LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_pudge_dirty_bomb_lua_thinker", "heroes/plague/dirty_bomb_thinker", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_pudge_dirty_bomb_lua_hooker", "heroes/plague/dirty_bomb_hooker", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Init Abilities
function pudge_dirty_bomb:Precache( context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_dawnbreaker.vsndevts", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_celestial_hammer_projectile.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_celestial_hammer_grounded.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_celestial_hammer_aoe_impact.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_converge.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_converge_burning_trail.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_converge_trail.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_converge_debuff.vpcf", context )
end

function pudge_dirty_bomb:Spawn()
	if not IsServer() then return end
end


--------------------------------------------------------------------------------
-- Ability Cast Filter
function pudge_dirty_bomb:CastFilterResultLocation( vLoc )
	-- check nohammer
	if self:GetCaster():HasModifier( "modifier_pudge_dirty_bomb_nohammer" ) then
		return UF_FAIL_CUSTOM
	end

	return UF_SUCCESS
end

function pudge_dirty_bomb:OnUpgrade()
	local sub = self:GetCaster():FindAbilityByName( "pudge_dirty_bomb_converge" )
	if not sub then
		sub = self:GetCaster():AddAbility( "pudge_dirty_bomb_converge" )
	end

	sub:SetLevel( self:GetLevel() )
end

function pudge_dirty_bomb:GetCustomCastErrorLocation( vLoc )
	-- check nohammer
	if self:GetCaster():HasModifier( "modifier_pudge_dirty_bomb_nohammer" ) then
		return "#dota_hud_error_nohammer"
	end

	return ""
end

--------------------------------------------------------------------------------
-- Ability Start
function pudge_dirty_bomb:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	-- load data
	local name = ""
	local radius = self:GetSpecialValueFor( "projectile_radius" )
	local speed = self:GetSpecialValueFor( "hook_speed" )
	local distance = self:GetSpecialValueFor( "hook_range" )

	-- get direction
	local direction = point-caster:GetOrigin()
	local len = direction:Length2D()
	direction.z = 0
	direction = direction:Normalized()

	distance = math.min( distance, len )

	-- create thinker
	local thinker = CreateModifierThinker(
		caster, -- player source
		self, -- ability source
		"modifier_pudge_dirty_bomb_lua_thinker", -- modifier name
		{}, -- kv
		caster:GetOrigin(),
		self:GetCaster():GetTeamNumber(),
		false
	)

    self.hook_speed = self:GetSpecialValueFor( "hook_speed" )
	self.hook_width = 165
	self.hook_distance = self:GetSpecialValueFor( "hook_range" )
	self.hook_followthrough_constant = 0.6

	-- Create Particle
	if self:GetCaster() and self:GetCaster():IsHero() then
		local hHook = self:GetCaster():GetTogglableWearable( DOTA_LOADOUT_TYPE_WEAPON )
		if hHook ~= nil then
			hHook:AddEffects( EF_NODRAW )
		end
	end

	self.vStartPosition = self:GetCaster():GetOrigin()
	self.vProjectileLocation = vStartPosition

	local vDirection = self:GetCursorPosition() - self.vStartPosition
	vDirection.z = 0.0

	local vDirection = ( vDirection:Normalized() ) * self.hook_distance
	self.vTargetPosition = self.vStartPosition + vDirection

	local flFollowthroughDuration = ( self.hook_distance / self.hook_speed * self.hook_followthrough_constant )
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_meat_hook_followthrough_lua", { duration = duration } )


	-- create linear projectile
	local info = {
		Ability = self,
		vSpawnOrigin = self:GetCaster():GetOrigin(),
		vVelocity = vDirection:Normalized() * self.hook_speed,
		fDistance = self.hook_distance,
		fStartRadius = self.hook_width ,
		fEndRadius = self.hook_width ,
		Source = self:GetCaster(),
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_BOTH,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
	}


	self.bRetracting = false
	self.hVictim = nil
	self.bDiedInHook = false
	local data = {
		cast = 1,
		targets = {},
		thinker = thinker,
	}
	local id = ProjectileManager:CreateLinearProjectile( info )
	thinker.id = id
	self.projectiles[id] = data
	table.insert( self.thinkers, thinker )

	-- swap with sub-ability
	local ability = caster:FindAbilityByName( "pudge_dirty_bomb_converge" )
	if ability then
		ability:SetActivated( true )

		caster:SwapAbilities(
			"pudge_dirty_bomb",
			"pudge_dirty_bomb_converge",
			false,
			true
		)

		ability:StartCooldown( ability:GetCooldown( -1 ) )
	end

	-- set no hammer
	caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_pudge_dirty_bomb_nohammer", -- modifier name
		{} -- kv
	)

	-- play effects
	data.effect = self:PlayEffects1( caster:GetOrigin(), distance, direction * speed )
end

--------------------------------------------------------------------------------
-- Projectile
pudge_dirty_bomb.projectiles = {}
pudge_dirty_bomb.thinkers = {}
function pudge_dirty_bomb:OnProjectileThinkHandle( handle )
	local data = self.projectiles[handle]
	if data.thinker:IsNull() then return end

	if data.cast==1 then
		local location = ProjectileManager:GetLinearProjectileLocation( handle )
		-- move thinker along projectile
		data.thinker:SetOrigin( location )

		-- destroy trees
		local radius = self:GetSpecialValueFor( "projectile_radius" )
		GridNav:DestroyTreesAroundPoint( location, radius, false )

	elseif data.cast==2 then
		local location = ProjectileManager:GetTrackingProjectileLocation( handle )
		local radius = self:GetSpecialValueFor( "projectile_radius" )

		-- move thinker along projectile
		data.thinker:SetOrigin( location )

		-- find enemies not yet hit
		local enemies = FindUnitsInRadius(
			self:GetCaster():GetTeamNumber(),	-- int, your team number
			location,	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			0,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)
		for _,enemy in pairs(enemies) do
			if not data.targets[enemy] then
				data.targets[enemy] = true

				-- hammer hit
				self:HammerHit( enemy, location )
			end
		end

		-- destroy trees
		local radius = self:GetSpecialValueFor( "projectile_radius" )
		GridNav:DestroyTreesAroundPoint( location, radius, false )
	end
end

function pudge_dirty_bomb:OnProjectileHitHandle( target, location, handle )
	local data = self.projectiles[handle]
	if not handle then return end

	if data.cast==1 then
		if target then
			self:HammerHit( target, location )
			return false
		end

		-- set thinker origin
		local loc = GetGroundPosition( location, self:GetCaster() )
		data.thinker:SetOrigin( loc )

		-- begin delay
		local mod = data.thinker:FindModifierByName( "modifier_pudge_dirty_bomb_lua_thinker" )
		mod:Delay()

		-- stop effect
		self:StopEffects( data.effect )

		-- destroy handle
		self.projectiles[handle] = nil

	elseif data.cast==2 then
		local caster = self:GetCaster()

		-- destroy thinker
		for i,thinker in pairs(self.thinkers) do
			if thinker == data.thinker then
				table.remove( self.thinkers, i )
				break
			end
		end
		local mod = data.thinker:FindModifierByName( "modifier_pudge_dirty_bomb_lua_thinker" )
		mod:Destroy()

		-- reset sub-ability
		local ability = caster:FindAbilityByName( "pudge_dirty_bomb_converge" )
		if ability then
			caster:SwapAbilities(
				"pudge_dirty_bomb",
				"pudge_dirty_bomb_converge",
				true,
				false
			)
		end

		-- remove nohammer
		local nohammer = caster:FindModifierByName( "modifier_pudge_dirty_bomb_nohammer" )
		if nohammer then
			nohammer:Decrement()
		end

		-- destroy converge modifier
		local converge = caster:FindModifierByName( "modifier_pudge_dirty_bomb" )
		if converge then
			converge:Destroy()
		end

		-- destroy handle
		self.projectiles[handle] = nil

		-- play effects
		self:PlayEffects3()
	end
end

--------------------------------------------------------------------------------
-- Helper
function pudge_dirty_bomb:HammerHit( target, location )
	local damage = self:GetSpecialValueFor( "hook_dmg" )

	local damageTable = {
		victim = target,
		attacker = self:GetCaster(),
		damage = damage,
		damage_type = self:GetAbilityDamageType(),
		ability = self, --Optional.
	}
	ApplyDamage(damageTable)

	-- play effects
	self:PlayEffects2( target )
end

function pudge_dirty_bomb:Converge()
	local caster = self:GetCaster()

	local target
	for i,thinker in ipairs(self.thinkers) do
		target = thinker
		break
	end
	if not target then return end

	-- find projectile if exist
	if self.projectiles[target.id] then
		-- stop effect
		self:StopEffects( self.projectiles[target.id].effect )

		-- destroy projectile
		self.projectiles[target.id] = nil
		ProjectileManager:DestroyLinearProjectile( target.id )
	end

	-- set thinker to return
	-- add travel modifier

	-- play effects
	local sound_cast = "Hero_Dawnbreaker.Converge.Cast"
	EmitSoundOn( sound_cast, caster )
end

--------------------------------------------------------------------------------
-- Effects
function pudge_dirty_bomb:PlayEffects1( start, distance, velocity )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_pudge/pudge_meathook.vpcf"
	local sound_cast = "Hero_Dawnbreaker.Celestial_Hammer.Cast"

	-- Get Data
	local min_rate = 1
	local duration = distance/velocity:Length2D()
	local rotation = 0.5

	local rate = rotation/duration
	while rate<min_rate do
		rotation = rotation + 1
		rate = rotation/duration
	end

	self.hook_speed = self:GetSpecialValueFor( "hook_speed" )
	self.hook_width = 165
	self.hook_distance = self:GetSpecialValueFor( "hook_range" )
	self.hook_followthrough_constant = 0.6

	-- Create Particle
	if self:GetCaster() and self:GetCaster():IsHero() then
		local hHook = self:GetCaster():GetTogglableWearable( DOTA_LOADOUT_TYPE_WEAPON )
		if hHook ~= nil then
			hHook:AddEffects( EF_NODRAW )
		end
	end

	self.vStartPosition = self:GetCaster():GetOrigin()
	self.vProjectileLocation = vStartPosition

	local vDirection = self:GetCursorPosition() - self.vStartPosition
	vDirection.z = 0.0

	local vDirection = ( vDirection:Normalized() ) * self.hook_distance
	self.vTargetPosition = self.vStartPosition + vDirection

	local flFollowthroughDuration = ( self.hook_distance / self.hook_speed * self.hook_followthrough_constant )
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_meat_hook_followthrough_lua", { duration = duration } )

	self.vHookOffset = Vector( 0, 0, 96 )
	local vHookTarget = self.vTargetPosition + self.vHookOffset
	local vKillswitch = Vector( ( ( self.hook_distance / self.hook_speed ) * 2 ), 0, 0 )

	local effect_cast  = ParticleManager:CreateParticle( "particles/units/heroes/hero_pudge/pudge_meathook.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster() )
	ParticleManager:SetParticleAlwaysSimulate( effect_cast )
	ParticleManager:SetParticleControlEnt( effect_cast, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_weapon_chain_rt", self:GetCaster():GetOrigin() + self.vHookOffset, true )
	ParticleManager:SetParticleControl( effect_cast, 1, vHookTarget )
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( self.hook_speed, self.hook_distance, self.hook_width ) )
	ParticleManager:SetParticleControl( effect_cast, 3, vKillswitch )
	ParticleManager:SetParticleControl( effect_cast, 4, Vector( 1, 0, 0 ) )
	ParticleManager:SetParticleControl( effect_cast, 5, Vector( 0, 0, 0 ) )
	ParticleManager:SetParticleControlEnt( effect_cast, 7, self:GetCaster(), PATTACH_CUSTOMORIGIN, nil, self:GetCaster():GetOrigin(), true )

	EmitSoundOn( "Hero_Pudge.AttackHookExtend", self:GetCaster() )



	return effect_cast
end

function pudge_dirty_bomb:PlayEffects2( target )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_dawnbreaker/dawnbreaker_celestial_hammer_aoe_impact.vpcf"
	local sound_cast = "Hero_Dawnbreaker.Celestial_Hammer.Damage"

	-- Get Data
	local radius = self:GetSpecialValueFor( "projectile_radius" )

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( radius, radius, radius ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_cast, target )
end

function pudge_dirty_bomb:PlayEffects3()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_pudge/pudge_meathook.vpcf"

	-- Get Data
	local radius = self:GetSpecialValueFor( "projectile_radius" )

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		3,
		hTarget,
		PATTACH_POINT_FOLLOW,
		"attach_attack1",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function pudge_dirty_bomb:StopEffects( effect )
	ParticleManager:DestroyParticle( effect, false )
	ParticleManager:ReleaseParticleIndex( effect )
end

--------------------------------------------------------------------------------
-- Sub-ability: Converge
pudge_dirty_bomb_converge = class({})

function pudge_dirty_bomb_converge:OnSpellStart()
	-- unit identifier

	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	local maxrange = self:GetSpecialValueFor( "hook_range" )

	local direction = point-caster:GetOrigin()
	if direction:Length2D() > maxrange then
		direction.z = 0
		direction = direction:Normalized()

		point = caster:GetOrigin() + direction * maxrange
	end

	caster:AddNewModifier(
		caster,
		self,
		"modifier_pudge_dirty_bomb_lua_hooker",
		{
			x = point.x,
			y = point.y,
		}
	)
	self:SetActivated( false )
end

	-- set as inactive
	




modifier_pudge_dirty_bomb_nohammer = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_pudge_dirty_bomb_nohammer:IsHidden()
	return true
end

function modifier_pudge_dirty_bomb_nohammer:IsDebuff()
	return false
end

function modifier_pudge_dirty_bomb_nohammer:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_pudge_dirty_bomb_nohammer:OnCreated( kv )
	if not IsServer() then return end
	self:IncrementStackCount()
end

function modifier_pudge_dirty_bomb_nohammer:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_pudge_dirty_bomb_nohammer:OnRemoved()
end

function modifier_pudge_dirty_bomb_nohammer:OnDestroy()
	if not IsServer() then return end
end

--------------------------------------------------------------------------------
-- Other
function modifier_pudge_dirty_bomb_nohammer:Decrement()
	self:DecrementStackCount()
	if self:GetStackCount()<1 then
		self:Destroy()
	end
end