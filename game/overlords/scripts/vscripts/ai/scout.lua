LinkLuaModifier("modifier_ai_scout", "ai/scout", LUA_MODIFIER_MOTION_NONE)

ai_scout = class({})

function ai_scout:GetIntrinsicModifierName()
	return "modifier_ai_scout"
end

modifier_ai_scout = ({
	IsHidden = function(self) return false end,
--[[	CheckState = function(self) return {
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
	}end,]]
})

function modifier_ai_scout:OnCreated()
	if IsClient() then return end
	self.parent = self:GetParent()
	self.team = self.parent:GetTeam()
	self.point = nil
	self.search_radius = SCOUT_SEARCH_RADIUS
	self.is_searching = true
	self:StartIntervalThink(0.25)
end

function modifier_ai_scout:OnIntervalThink()
	if self.is_searching then
		local units = FindUnitsInRadius(
			self.team, 
			self.parent:GetAbsOrigin(), 
			nil, 
			self.search_radius, 
			DOTA_UNIT_TARGET_TEAM_ENEMY, 
			DOTA_UNIT_TARGET_BASIC, 
			DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD , 
			FIND_CLOSEST, 
			false)
		for _, unit in pairs(units) do
			if unit:GetUnitName() == "npc_fow_point" and not unit.init[self.team] and not unit.search[self.team]  then
				unit.search[self.team] = true
				self.point = unit
				self.is_searching = false
				ExecuteOrderFromTable({
					UnitIndex = self.parent:entindex(),
					OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
					Position = unit:GetOrigin(),
			--		Queue = 0,
				})
				break
			end
		end
	elseif self.point and not self.point.init[self.team] then
		local length = (self.parent:GetAbsOrigin() - self.point:GetAbsOrigin()):Length2D()
		if length <= SCOUT_FOW_REVEAL_RADIUS then
			self:IncrementStackCount()
			GameMode:RevealFOWPoint(self.point, self.team)

			self.point = nil
			self.is_searching = true
		end
	else
		self.point = nil
		self.is_searching = true		
	end
end

function modifier_ai_scout:OnDestroy()
	if self.point then
		self.point.search[self.team] = false
	end
end