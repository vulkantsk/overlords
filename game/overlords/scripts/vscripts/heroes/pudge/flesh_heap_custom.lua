LinkLuaModifier("modifier_pudge_flesh_heap_custom", "heroes/pudge/flesh_heap_custom", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pudge_flesh_heap_custom_aura", "heroes/pudge/flesh_heap_custom", LUA_MODIFIER_MOTION_NONE)

pudge_flesh_heap_custom = class({})

function pudge_flesh_heap_custom:GetCastRange()
	return self:GetSpecialValueFor("aura_radius")
end

function pudge_flesh_heap_custom:GetIntrinsicModifierName()
	return "modifier_pudge_flesh_heap_custom"
end

modifier_pudge_flesh_heap_custom = class({
	IsHidden 		= function(self) return false end,
	IsAura 			= function(self) return true end,
	GetAuraRadius 	= function(self) return self:GetAbility():GetSpecialValueFor("aura_radius") end,
	GetAuraSearchTeam = function(self) return DOTA_UNIT_TARGET_TEAM_ENEMY end,
	GetAuraSearchType = function(self) return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO end,
	GetModifierAura   = function(self) return "modifier_pudge_flesh_heap_custom_aura" end,

	DeclareFunctions  = function(self) return {
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE
	}end,
})

function modifier_pudge_flesh_heap_custom:OnCreated()
	local ability = self:GetAbility()
	self.stack_hp = ability:GetSpecialValueFor("stack_hp")
	self.regen_pct = ability:GetSpecialValueFor("regen_pct")
end

function modifier_pudge_flesh_heap_custom:OnRefresh()
	self:OnCreated()
end

function modifier_pudge_flesh_heap_custom:GetModifierHealthBonus()
	return self:GetStackCount()*self.stack_hp
end

function modifier_pudge_flesh_heap_custom:GetModifierHealthRegenPercentage()
	return self.regen_pct
end


modifier_pudge_flesh_heap_custom_aura= class({
	IsHidden 		= function(self) return true end,
})
function modifier_pudge_flesh_heap_custom_aura:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end

function modifier_pudge_flesh_heap_custom_aura:OnDeath( params )
	if IsServer() then
		local target = params.unit
		local attacker = params.attacker
		local Ability = params.inflictor
		local flDamage = params.damage
		local parent = self:GetParent()

		if target and target == parent and not target:IsBuilding() then
			local caster = self:GetCaster()
			local flesh_heap_modifier = caster:FindModifierByName("modifier_pudge_flesh_heap_custom")
			flesh_heap_modifier:IncrementStackCount()
			caster:CalculateStatBonus(true)

			local nFXIndex = ParticleManager:CreateParticle( "particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, attacker )
			ParticleManager:ReleaseParticleIndex( nFXIndex )
		end
	end
	return 0
end
