dragon_knight_dragon_blood = class({})
LinkLuaModifier( "modifier_dragon_knight_dragon_blood", "abilities/dk/dragon_knight_dragon_blood", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Passive Modifier
function dragon_knight_dragon_blood:GetIntrinsicModifierName()
	return "modifier_dragon_knight_dragon_blood"
end

modifier_dragon_knight_dragon_blood = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_dragon_knight_dragon_blood:IsHidden()
	return true
end

function modifier_dragon_knight_dragon_blood:IsDebuff()
	return false
end

function modifier_dragon_knight_dragon_blood:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_dragon_knight_dragon_blood:OnCreated( kv )
	-- references
	self.armor = self:GetAbility():GetSpecialValueFor( "bonus_armor" )
	self.regen = self:GetAbility():GetSpecialValueFor( "bonus_health_regen" )
end

function modifier_dragon_knight_dragon_blood:OnRefresh( kv )
	-- references
	self.armor = self:GetAbility():GetSpecialValueFor( "bonus_armor" )
	self.regen = self:GetAbility():GetSpecialValueFor( "bonus_health_regen" )	
end

function modifier_dragon_knight_dragon_blood:OnRemoved()
end

function modifier_dragon_knight_dragon_blood:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_dragon_knight_dragon_blood:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}

	return funcs
end

function modifier_dragon_knight_dragon_blood:GetModifierConstantHealthRegen()
	if not self:GetParent():PassivesDisabled() then
		return self.regen
	end
end

function modifier_dragon_knight_dragon_blood:GetModifierPhysicalArmorBonus()
	if not self:GetParent():PassivesDisabled() then
		return self.armor
	end
end