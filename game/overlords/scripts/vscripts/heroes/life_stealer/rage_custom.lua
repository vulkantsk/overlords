LinkLuaModifier("modifier_life_stealer_rage_custom", "heroes/life_stealer/rage_custom", LUA_MODIFIER_MOTION_NONE)

life_stealer_rage_custom = class({})

function life_stealer_rage_custom:OnSpellStart()
	local caster = self:GetCaster()
	local buff_duration = self:GetSpecialValueFor("buff_duration")
	caster:AddNewModifier(caster, self, "modifier_life_stealer_rage_custom", {duration = buff_duration})
	
	EmitSoundOn("sven_sven_ability_godstrength_02", caster)
end

modifier_life_stealer_rage_custom = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return true end,
--	GetAttributes 			= function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,
	DeclareFunctions		= function(self) return 
		{
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		} end,
})
function modifier_life_stealer_rage_custom:CheckState()
	local states = {
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
	}
	return states
end

function modifier_life_stealer_rage_custom:OnCreated()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	self.ms_bonus = ability:GetSpecialValueFor("ms_bonus")
	self.as_bonus = ability:GetSpecialValueFor("as_bonus")

end

function modifier_life_stealer_rage_custom:GetEffectName()
	return "particles/item/black_queen_cape/black_king_bar_avatar.vpcf"
end

function modifier_life_stealer_rage_custom:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_life_stealer_rage_custom:GetModifierMoveSpeedBonus_Percentage()
	return self.ms_bonus
end

function modifier_life_stealer_rage_custom:GetModifierAttackSpeedBonus_Constant()
	return self.as_bonus
end
