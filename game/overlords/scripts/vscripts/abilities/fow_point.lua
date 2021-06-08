LinkLuaModifier("modifier_fow_point", "abilities/fow_point", LUA_MODIFIER_MOTION_NONE)

fow_point = class({})

function fow_point:GetIntrinsicModifierName()
	return "modifier_fow_point"
end

modifier_fow_point = ({
	IsHidden = function(self) return true end,
	CheckState = function(self) return {
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
	}end,
})