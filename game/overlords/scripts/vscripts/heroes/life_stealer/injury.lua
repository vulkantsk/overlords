LinkLuaModifier("modifier_life_stealer_injury", "heroes/life_stealer/injury", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_life_stealer_injury_debuff", "heroes/life_stealer/injury", LUA_MODIFIER_MOTION_NONE)

life_stealer_injury = class({})

function life_stealer_injury:GetCastRange()
    return self:GetSpecialValueFor("strike_range")
end

function life_stealer_injury:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local debuff_duration = self:GetSpecialValueFor("debuff_duration")

    caster:AddNewModifier(caster, self, "modifier_life_stealer_injury", {Duration = 0.1})
    
    target:AddNewModifier(caster, self, "modifier_life_stealer_injury_debuff", {Duration = debuff_duration})
    caster:PerformAttack(target, false, true, true, true, true, false, true)

end

modifier_life_stealer_injury = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
    DeclareFunctions        = function(self) return 
        {
            MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        } end,
})


function modifier_life_stealer_injury:GetModifierPreAttack_CriticalStrike()
    return self:GetAbility():GetSpecialValueFor("crit_multiplier")
end


modifier_life_stealer_injury_debuff = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return false end,
    DeclareFunctions        = function(self) return 
        {
            MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
            MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        } end,
})

function modifier_life_stealer_injury_debuff:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("armor_decrease")*(-1)
end

function modifier_life_stealer_injury_debuff:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("as_decrease")*(-1)
end
