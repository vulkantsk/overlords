LinkLuaModifier("modifier_life_stealer_feast_custom", "heroes/life_stealer/feast_custom", LUA_MODIFIER_MOTION_NONE)


life_stealer_feast_custom = class({})

function life_stealer_feast_custom:GetIntrinsicModifierName()
    return "modifier_life_stealer_feast_custom"
end

modifier_life_stealer_feast_custom = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return false end,
    DeclareFunctions        = function(self) return 
        {
           MODIFIER_EVENT_ON_TAKEDAMAGE,
        } end,

})

function modifier_life_stealer_feast_custom:OnTakeDamage( params )
    if IsServer() then
        local parent = self:GetParent()
        local Target = params.unit
        local Attacker = params.attacker
        local Ability = params.inflictor
        local flDamage = params.damage
        local lifesteal_pct = self:GetAbility():GetSpecialValueFor("lifesteal_pct")
        
        if Attacker ~= nil and Attacker == parent and Target ~= nil and not Target:IsBuilding() and Ability == nil then

            local heal =  flDamage * lifesteal_pct / 100 
            parent:Heal( heal, self:GetAbility() )
            local nFXIndex = ParticleManager:CreateParticle( "particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent )
            ParticleManager:ReleaseParticleIndex( nFXIndex )

        end
    end
    return 0
end