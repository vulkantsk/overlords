FOW_POINT_DISTANCE = 1500
FOW_POINT_REVEAL_RADIUS = FOW_POINT_DISTANCE * math.sqrt(2)/2+20
FOW_POINT_REVEAL_TIME = 10
SCOUT_SEARCH_RADIUS = 5000
SCOUT_FOW_REVEAL_RADIUS = FOW_POINT_REVEAL_RADIUS/2
FOW_REVEAL_RADIUS_ON_SPAWN = 3000

if GameMode == nil then
	_G.GameMode = class({})
end

function GameMode:InitGameMode()
	ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(self, 'OnGameRulesStateChange'), self)
	ListenToGameEvent("npc_spawned",Dynamic_Wrap( self, 'OnNPCSpawned' ), self )
	ListenToGameEvent('entity_killed', Dynamic_Wrap(self, 'OnEntityKilled'), self)

end

function GameMode:OnGameRulesStateChange()
	local newState = GameRules:State_Get()
	print("newState = "..newState)
	if newState == DOTA_GAMERULES_STATE_PRE_GAME then
		self:InitFogOfWarPoints()
	elseif newState == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then

	end
end
function GameMode:InitFogOfWarPoints()
	local max_point = Entities:FindByName(nil, "map_point_max"):GetAbsOrigin()
	local min_point = Entities:FindByName(nil, "map_point_min"):GetAbsOrigin()
	local length = max_point.x - min_point.x
	local width = max_point.y - min_point.y
	print("length ="..length)
	print("width ="..width)

	local count_length = math.floor(length/FOW_POINT_DISTANCE)
	local count_width = math.floor(width/FOW_POINT_DISTANCE)
	local total_count = count_length * count_width
	local delta_length = FOW_POINT_DISTANCE
	local delta_width = FOW_POINT_DISTANCE
	print("count_length ="..count_length)
	print("count_width ="..count_width)

	for i=1, count_length do
		for j=1, count_width do
--			k = k + 1
--			Timers:CreateTimer(0.1*k, function()
				local delta_x = delta_length*i - FOW_POINT_REVEAL_RADIUS
				local delta_y = delta_width*j - FOW_POINT_REVEAL_RADIUS
				local point = min_point + Vector(delta_x, delta_y, 0)

				local fow_point = CreateUnitByName("npc_fow_point", point, false, nil, nil, DOTA_TEAM_NEUTRALS)
				fow_point.init = {}
				fow_point.search = {}

--			end)		
		end
	end
end

function GameMode:RevealFOWPoint(unit, team)
	unit.init[team] = true
	unit.search[team] = false
	
	AddFOWViewer(team, unit:GetAbsOrigin(), FOW_POINT_REVEAL_RADIUS, FOW_POINT_REVEAL_TIME, true)
	Timers:CreateTimer(FOW_POINT_REVEAL_TIME, function()
		unit.init[team] = false
	end)
end

function GameMode:OnNPCSpawned(keys)
	local npc = EntIndexToHScript(keys.entindex)
	local name = npc:GetUnitName()

	if npc:IsRealHero() and not npc.base_init then
		npc.base_init = true
		Timers:CreateTimer(1,function()
			local units = FindUnitsInRadius(
				npc:GetTeam(), 
				npc:GetAbsOrigin(), 
				nil, 
				FOW_REVEAL_RADIUS_ON_SPAWN, 
				DOTA_UNIT_TARGET_TEAM_ENEMY, 
				DOTA_UNIT_TARGET_BASIC, 
				DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD , 
				FIND_CLOSEST, 
				false)
			for _, unit in pairs(units) do
				if unit:GetUnitName() == "npc_fow_point" and not unit.init[self.team] then
					self:RevealFOWPoint(unit, npc:GetTeam())
				end
			end
		end)
	end
	
end

function GameMode:OnEntityKilled(keys)

	local unit = EntIndexToHScript(keys.entindex_killed)
	local unit_name = unit:GetUnitName()
	
end

GameMode:InitGameMode()