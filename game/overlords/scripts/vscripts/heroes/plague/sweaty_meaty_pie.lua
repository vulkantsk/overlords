LinkLuaModifier( "modifier_pudge_sweaty_meaty_pie", "heroes/plague/sweaty_meaty_pie", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_pudge_sweaty_meaty_pie_collector", "heroes/plague/sweaty_meaty_pie", LUA_MODIFIER_MOTION_NONE )

pudge_sweaty_meaty_pie = class({})


function pudge_sweaty_meaty_pie:GetIntrinsicModifierName()
	return "modifier_pudge_sweaty_meaty_pie"
end



modifier_pudge_sweaty_meaty_pie = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
	DeclareFunctions		= function(self) return 
		{

            MODIFIER_EVENT_ON_DEATH,
            MODIFIER_EVENT_ON_ATTACK_LANDED,
            MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
            MODIFIER_PROPERTY_MODEL_SCALE,
         
		
		} end,
})

function modifier_pudge_sweaty_meaty_pie:OnAttackLanded( keys )
  local caster = self:GetCaster()
  local damage = self:GetAbility():GetSpecialValueFor("dmg_to_attacker_per_str")*caster:GetStrength()
     local attacker = keys.attacker
   
   if attacker ~= caster then

   ApplyDamage({victim = attacker, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})

 end
end
function modifier_pudge_sweaty_meaty_pie:OnDeath(data)
	if IsServer() then
		local parent = self:GetParent()
		local killer = data.attacker
		local killed_unit = data.unit
		local scale = parent:GetModelScale()
		local bonus_scale = self:GetAbility():GetSpecialValueFor("bonus_modelscale")
		
    

		if killer == parent  then
			if killer:IsRealHero() == false then
				killer = killer:GetPlayerOwner():GetAssignedHero()
			end
			killer:FindModifierByName("modifier_pudge_sweaty_meaty_pie"):IncrementStackCount()

			local effect = "particles/units/heroes/hero_pudge/pudge_fleshheap_count.vpcf"
			local pfx = ParticleManager:CreateParticle(effect, PATTACH_ABSORIGIN_FOLLOW, killer)
			ParticleManager:ReleaseParticleIndex(pfx)
		end
	end
end
function modifier_pudge_sweaty_meaty_pie:GetModifierModelScale()
	return self:GetStackCount()*2
end

function modifier_pudge_sweaty_meaty_pie:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_pudge_sweaty_meaty_pie:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		local soul_modifier_count = caster:FindModifierByName("modifier_pudge_sweaty_meaty_pie"):GetStackCount()
		self:SetStackCount(soul_modifier_count)

	end
end

function modifier_pudge_sweaty_meaty_pie:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_str") * self:GetStackCount()
end

modifier_pudge_sweaty_meaty_pie_collector = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
	DeclareFunctions		= function(self) return 
		{

            MODIFIER_EVENT_ON_DEATH,
         
		
		} end,
})

