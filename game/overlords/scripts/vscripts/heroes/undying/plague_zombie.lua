LinkLuaModifier( "modifier_undying_plague_zombie", "heroes/undying/plague_zombie", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_undying_plague_zombie_debuff", "heroes/undying/plague_zombie", LUA_MODIFIER_MOTION_NONE )


undying_plague_zombie = class({})

function undying_plague_zombie:GetCastRange()
    return self:GetSpecialValueFor("cast_range")
end

function undying_plague_zombie:GetAOERadius()
    return self:GetSpecialValueFor("aoe_radius")
end

function undying_plague_zombie:OnAbilityPhaseStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
	local owner = target:GetOwner()
	local ability = self

   if (target.zombie or target.fleshgolem) and caster == owner then
--		Containers:DisplayError(caster:GetPlayerID(), "undying_plague_zombie_error_need_lvl")
--		caster:Hold()
		return true
    end
	
	return false
end

function undying_plague_zombie:OnSpellStart( keys )
    local target = self:GetCursorTarget()
    local caster = self:GetCaster()
	local player = caster:GetPlayerID()
    local ability = self
    local zombie_duration = ability:GetSpecialValueFor("zombie_duration")

	target:AddNewModifier(caster, ability, "modifier_undying_plague_zombie", nil)
	target:AddNewModifier(caster, ability, "modifier_kill", {duration = zombie_duration})

	target:AddAbility("undying_plague_zombie_suicide")
	target:SetControllableByPlayer(player, false)
	-- изменить цвет
end

function undying_plague_zombie:GetIntrinsicModifierName()
	return "modifier_undying_plague_zombie_passive"
end

undying_plague_zombie_suicide = class({})

function undying_plague_zombie_suicide:OnSpellStart()
    local caster = self:GetCaster()

	caster:ForceKill(false)
end

modifier_undying_plague_zombie = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
	DeclareFunctions		= function(self) return 
		{
		MODIFIER_EVENT_ON_DEATH,
		} end,
})

function modifier_undying_plague_zombie:GetEffectName()
	return "particles/units/heroes/hero_undying/undying_decay_strength_buff.vpcf"
end

function modifier_undying_plague_zombie:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_undying_plague_zombie:OnCreated()
	local ability = self:GetAbility()
	local caster = self:GetCaster()
	local target = self:GetParent()
	self.radius = ability:GetSpecialValueFor("aoe_radius")
	self.duration = ability:GetSpecialValueFor("debuff_duration")

end

function modifier_undying_plague_zombie:OnRefresh()
	self:OnCreated()
end

function modifier_undying_plague_zombie:OnDeath(data)
    local caster = self:GetCaster()
	local parent = self:GetParent()
	local unit = data.unit
    local ability = self:GetAbility()
	
--    target:EmitSound("")
	local effect_cast = ParticleManager:CreateParticle(
		"particles/units/heroes/hero_undying/undying_decay.vpcf",
		PATTACH_ABSORIGIN_FOLLOW,
		target 
	)
	ParticleManager:ReleaseParticleIndex( effect_cast )
    
    if parent == unit  then 
		local enemies = FindUnitsInRadius(
			self:GetParent():GetTeamNumber(),
			self:GetParent():GetOrigin(),
			nil,
			self.radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			0,
			0,
			false
		)

		for _,enemy in pairs(enemies) do
			enemy:AddNewModifier(caster, ability, "modifier_undying_plague_zombie_debuff", {duration = self.duration})
		end
    end
end


modifier_undying_plague_zombie_debuff = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return true end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return true end,
	DeclareFunctions		= function(self) return 
	{
	MODIFIER_EVENT_ON_DEATH,
	} end,
})


function modifier_undying_plague_zombie_debuff:OnCreated()
	local ability = self:GetAbility()
	local caster = self:GetCaster()
	local target = self:GetParent()
	self.damage = ability:GetSpecialValueFor("damage")
	self.interval = ability:GetSpecialValueFor("interval")
	
	self.damageTable = {
		attacker = caster,
		victim = target,
		damage = self.damage*self.interval,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self:GetAbility(),
	}

	self:StartIntervalThink(self.interval)
	
end


function modifier_undying_plague_zombie_debuff:OnIntervalThink()
	if self.damageTable.victim:IsAlive() then
		ApplyDamage(self.damageTable)
	end
end

function modifier_undying_plague_zombie_debuff:OnDeath(data)
    local dead = self:GetParent()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local unit = CreateUnitByName( "npc_dota_undying_zombie", dead:GetOrigin(), true, caster, caster, caster:GetTeam() )
	unit.zombie = true
	unit:AddNewModifier(caster, ability, "modifier_kill", {duration = ability:GetSpecialValueFor("zombie_duration")})
end
