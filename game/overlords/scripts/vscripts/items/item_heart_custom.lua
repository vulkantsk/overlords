LinkLuaModifier("modifier_item_heart_custom", "items/item_heart_custom", LUA_MODIFIER_MOTION_NONE)

item_heart_custom = class({})

function item_heart_custom:GetIntrinsicModifierName()
	return "modifier_item_heart_custom"
end

modifier_item_heart_custom = class({
	IsHidden 		= function(self) return true end,
	GetAttributes 	= function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,
	DeclareFunctions  = function(self) return {
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
	}end,
})

function modifier_item_heart_custom:GetModifierHealthBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_hp")
end

function modifier_item_heart_custom:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_hpreg")
end

function modifier_item_heart_custom:GetModifierHealthRegenPercentage()
	return self:GetAbility():GetSpecialValueFor("bonus_hpreg_pct")
end
