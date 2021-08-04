LinkLuaModifier( "modifier_undying_dead_frenzy", "heroes/undying/dead_frenzy", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_undying_dead_frenzy_debuff", "heroes/undying/dead_frenzy", LUA_MODIFIER_MOTION_NONE )

undying_dead_frenzy = class({})

function undying_dead_frenzy:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function undying_dead_frenzy:OnSpellStart( keys )
    local target = self:GetCursorTarget()
    local caster = self:GetCaster()
	local player = caster:GetPlayerID()
    local ability = self
    local zombie_duration = ability:GetSpecialValueFor("duration")
    local zombie_duration = ability:GetSpecialValueFor("radius")
	local target_point = target:GetAbsOrigin()
	
	local allies = caster:FindAbilityByName("undying_walking_dead").zombies
	target:AddNewModifier(caster, ability, "modifier_undying_dead_frenzy_debuff", nil)

	for _,ally in pairs(allies) do
		if ally and not ally:IsNull() and ally:IsAlive() then
			ally:AddNewModifier(caster, ability, "modifier_undying_dead_frenzy", nil)
			
			ExecuteOrderFromTable({
				UnitIndex = ally:entindex(),
				OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
				TargetIndex = target:entindex(),
			})			
		end
	end	

end


modifier_undying_dead_frenzy = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return true end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return true end,
	DeclareFunctions		= function(self) return 
		{
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		} end,
})

function modifier_undying_dead_frenzy:OnCreated()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	self.ms_bonus = ability:GetSpecialValueFor("ms_bonus")
	self.as_bonus = ability:GetSpecialValueFor("as_bonus")

end

function modifier_undying_dead_frenzy:OnRefresh()
	self:OnCreated()

end

function modifier_undying_dead_frenzy:GetEffectName()
	return "particles/item/black_queen_cape/black_king_bar_avatar.vpcf"
end

function modifier_undying_dead_frenzy:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_undying_dead_frenzy:GetModifierMoveSpeedBonus_Percentage()
	return self.ms_bonus
end

function modifier_undying_dead_frenzy:GetModifierAttackSpeedBonus_Constant()
	return self.as_bonus
end

modifier_undying_dead_frenzy_debuff = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return true end,
	IsDebuff 				= function(self) return true end,
	RemoveOnDeath 			= function(self) return true end,
})

function modifier_undying_dead_frenzy_debuff:OnDestroy()
    local ability = self:GetAbility()
	local target = self:GetParent()
	local caster = self:GetCaster()
    local zombie_duration = ability:GetSpecialValueFor("radius")
	local target_point = target:GetAbsOrigin()
	
	local allies = caster:FindAbilityByName("undying_walking_dead").zombies

	for _,ally in pairs(allies) do
		if ally and not ally:IsNull() and ally:IsAlive() then
			ally:RemoveModifierByName("modifier_undying_dead_frenzy")
		end
	end
end
