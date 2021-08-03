necrolyte_reaper_scythe_custom = class({})

function necrolyte_reaper_scythe_custom:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local damage = self:GetSpecialValueFor('damage')
    local dmg_hp_pct = self:GetSpecialValueFor('dmg_hp_pct')

    local current_hp_pct = target:GetHealthPercent()
    if current_hp_pct <= dmg_hp_pct then
        target:Kill(self, caster)
    else
        local post_health = target:GetHealth()*(100 - dmg_hp_pct)/100
        target:SetHealth(post_health)
        
        ApplyDamage({
            attacker = caster,
            victim = target,
            damage = damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            damage_flag = DOTA_DAMAGE_FLAG_NONE,
            ability = self,
        })
    end
    
    target:EmitSound("Hero_Invoker.ColdSnap.Cast")
    caster:EmitSound("invoker_invo_ability_coldsnap_0" .. RandomInt(1,5))

    local effect_cast = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_doom_bringer/doom_bringer_scorched_earth_debuff.vpcf",
        PATTACH_ABSORIGIN_FOLLOW,
        target 
    )
    ParticleManager:SetParticleControl(effect_cast, 1, Vector())
    ParticleManager:ReleaseParticleIndex( effect_cast )    
end 
