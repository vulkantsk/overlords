LinkLuaModifier("modifier_necrolyte_nether_state", "heroes/necrolyte/nether_state", LUA_MODIFIER_MOTION_NONE)

necrolyte_nether_state = class({})

function necrolyte_nether_state:OnSpellStart()
    local target = self:GetCursorTarget()
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")
    target:AddNewModifier(caster, self, 'modifier_necrolyte_nether_state', {duration = duration})
 
    target:EmitSound("Hero_Invoker.GhostWalk")
    caster:EmitSound("invoker_invo_ability_ghostwalk_0" .. RandomInt(1, 5))
    caster:StartGesture(ACT_DOTA_CAST_GHOST_WALK)
end

modifier_necrolyte_nether_state = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    CheckState              = function(self)
        return {
--            [MODIFIER_STATE_MAGIC_IMMUNE] = true,
            [MODIFIER_STATE_DISARMED] = true,
            [MODIFIER_STATE_ATTACK_IMMUNE] = true,
        }
    end,
    DeclareFunctions        = function(self) return 
        {   MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
            MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS} end,
})

function modifier_necrolyte_nether_state:GetStatusEffectName()
    return "particles/status_fx/status_effect_ghost.vpcf"
end

function modifier_necrolyte_nether_state:GetModifierInvisibilityLevel()
    return 0.4
end

function modifier_necrolyte_nether_state:GetModifierMagicalResistanceBonus()
    return self:GetAbility():GetSpecialValueFor("resist_decrease")*(-1)
end
