LinkLuaModifier("modifier_item_daedalus_custom", "items/item_daedalus_custom", LUA_MODIFIER_MOTION_NONE)

item_daedalus_custom = class({})

function item_daedalus_custom:GetIntrinsicModifierName()
	return "modifier_item_daedalus_custom"
end

modifier_item_daedalus_custom = class({
	IsHidden 		= function(self) return true end,
	GetAttributes 	= function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,
	DeclareFunctions  = function(self) return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
	}end,
})

function modifier_item_daedalus_custom:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_dmg")
end

function modifier_item_daedalus_custom:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("bonus_as")
end

function modifier_item_daedalus_custom:GetModifierPreAttack_CriticalStrike()
	local crit_chance = self:GetAbility():GetSpecialValueFor("crit_chance")
	local crit_multiplier = self:GetAbility():GetSpecialValueFor("crit_multiplier")

	if RollPercentage(crit_chance) then
		return crit_multiplier
	else
		return 0
	end
end
