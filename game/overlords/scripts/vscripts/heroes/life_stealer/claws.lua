LinkLuaModifier("modifier_life_stealer_claws", "heroes/life_stealer/claws", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_life_stealer_claws_buff", "heroes/life_stealer/claws", LUA_MODIFIER_MOTION_NONE)

life_stealer_claws = class({})

function life_stealer_claws:GetIntrinsicModifierName()
    return "modifier_life_stealer_claws"
end

modifier_life_stealer_claws = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
    DeclareFunctions        = function(self) return 
        {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        } end,
})

function modifier_life_stealer_claws:OnCreated( params )
    local ability = self:GetAbility()
    self.attack_required = ability:GetSpecialValueFor("attack_required")
    self.disarm_duration = ability:GetSpecialValueFor("disarm_duration")

end

function modifier_life_stealer_claws:OnRefresh()
    self:OnCreated()
end

function modifier_life_stealer_claws:OnAttackLanded( params )
    if IsServer() then
        local ability = self:GetAbility()
        local caster = self:GetCaster()
        local target = params.target
        local attacker = params.attacker
        
        if target and target:GetTeam() ~= caster:GetTeam() and attacker == caster and ( not caster:IsIllusion() )  then
            if caster:HasModifier("modifier_life_stealer_claws_buff") then
                target:AddNewModifier(caster, ability, "modifier_disarmed", {duration = self.disarm_duration})
                caster:RemoveModifierByName("modifier_life_stealer_claws_buff")
            else
                if caster:PassivesDisabled() then
                    return 0
                end
 
                self:IncrementStackCount()
                
                if self:GetStackCount() == self.attack_required then
                    self:SetStackCount(0)
                    EmitSoundOn("Hero_MonkeyKing.IronCudgel", caster)
                    caster:AddNewModifier(caster, ability, "modifier_life_stealer_claws_buff", {})
                end
            end
        end
    end

    return 0
end

modifier_life_stealer_claws_buff = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return false end,
    DeclareFunctions        = function(self) return 
        {
            MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
            MODIFIER_EVENT_ON_TAKEDAMAGE,
        } end,

})

function modifier_life_stealer_claws_buff:GetEffectName()
    return "particles/units/heroes/life_stealer/king_quad_tap_overhead.vpcf"
end

function modifier_life_stealer_claws_buff:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

function modifier_life_stealer_claws_buff:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("bonus_dmg")
end
