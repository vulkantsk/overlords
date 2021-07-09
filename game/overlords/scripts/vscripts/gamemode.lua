
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
	--if newState == DOTA_GAMERULES_STATE_PRE_GAME then
		--self:InitFogOfWarPoints()
	if newState == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
		print('waves started')
    elseif newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then			
		print('waves started')
		GameMode:Raid()
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

function GameMode:BonusUnitStats(unit, bonus_hp, bonus_dmg, armor)	
	if not unit:IsAlive() then
		return
	end
		
	Timers:CreateTimer(0.02, function()				
		local armor = armor or 200	
		local new_armor = unit:GetPhysicalArmorBaseValue()*multiplier
		local max_hp = unit:GetMaxHealth()+bonus_hp
		local min_dmg = unit:GetBaseDamageMin()+bonus_dmg
		local max_dmg = unit:GetBaseDamageMax()+bonus_dmg

		if max_hp <= 1 then 
			 max_hp = 1
		elseif max_hp >= 2000000000 then
			 max_hp = 2000000000
		end
		unit:SetBaseMaxHealth(max_hp)
		unit:SetMaxHealth(max_hp)	
		unit:SetHealth(max_hp)

		if new_armor > armor then
			new_armor = armor
		end
		unit:SetPhysicalArmorBaseValue(new_armor)		
		if min_dmg >= 2000000000 then
			 min_dmg = 2000000000
		end
		unit:SetBaseDamageMin(min_dmg)

		if max_dmg >= 2000000000 then
			 max_dmg = 2000000000
		end				
		unit:SetBaseDamageMax(max_dmg)

	end)
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




function GameMode:Raid() -- Функция начнет выполняться, когда начнется матч( на часах будет 00:00 ).
      local point = Entities:FindByName( nil, "raid_spawn"):GetAbsOrigin() 
      local wave = 1
 	Timers:CreateTimer(0.1, function()  
      	
      	local hero = PlayerResource:GetPlayer(0)
      	local waypoint = hero:GetAbsOrigin() 
  	   return 1
  	end)
      
      local return_time = 1 -- Записываем в переменную значение '10'
    Timers:CreateTimer(0.1, function()  
         Timers:CreateTimer(3, function()
			for i=1, 4 do -- Произведет нижние действия столько раз, сколько указано в ROUND_UNITS. То есть в нашем случае создаст 2 юнита.
              local unit = CreateUnitByName( "npc_dota_dragon_knight_raid" , point + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS ) 
         unit:SetInitialGoalEntity( waypoint ) -- Посылаем мобов на наш way1, координаты которого мы записали в переменную 'waypoint'
         end
          local unit = CreateUnitByName( "npc_dota_legion_commander_raid" , point + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS ) 
         unit:SetInitialGoalEntity( waypoint ) -- Посылаем мобов на наш way1, координаты которого мы записали в переменную 'waypoint'

         end)
          Timers:CreateTimer(6, function()
			for i=1, 4 do -- Произведет нижние действия столько раз, сколько указано в ROUND_UNITS. То есть в нашем случае создаст 2 юнита.
              local unit = CreateUnitByName( "npc_dota_dragon_knight_raid" , point + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS ) 
         unit:SetInitialGoalEntity( waypoint ) -- Посылаем мобов на наш way1, координаты которого мы записали в переменную 'waypoint'
         end
          local unit = CreateUnitByName( "npc_dota_legion_commander_raid" , point + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS ) 
         unit:SetInitialGoalEntity( waypoint ) -- Посылаем мобов на наш way1, координаты которого мы записали в переменную 'waypoint'

         end)
           Timers:CreateTimer(9, function()
			for i=1, 4 do -- Произведет нижние действия столько раз, сколько указано в ROUND_UNITS. То есть в нашем случае создаст 2 юнита.
              local unit = CreateUnitByName( "npc_dota_dragon_knight_raid" , point + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS ) 
         unit:SetInitialGoalEntity( waypoint ) -- Посылаем мобов на наш way1, координаты которого мы записали в переменную 'waypoint'
         end
          local unit = CreateUnitByName( "npc_dota_legion_commander_raid" , point + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS ) 
         unit:SetInitialGoalEntity( waypoint ) -- Посылаем мобов на наш way1, координаты которого мы записали в переменную 'waypoint'

         end)
            Timers:CreateTimer(12, function()
			for i=1, 4 do -- Произведет нижние действия столько раз, сколько указано в ROUND_UNITS. То есть в нашем случае создаст 2 юнита.
              local unit = CreateUnitByName( "npc_dota_dragon_knight_raid" , point + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS ) 
         unit:SetInitialGoalEntity( waypoint ) -- Посылаем мобов на наш way1, координаты которого мы записали в переменную 'waypoint'
         end
          local unit = CreateUnitByName( "npc_dota_legion_commander_raid" , point + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS ) 
         unit:SetInitialGoalEntity( waypoint ) -- Посылаем мобов на наш way1, координаты которого мы записали в переменную 'waypoint'

         end)
             Timers:CreateTimer(15, function()
			for i=1, 4 do -- Произведет нижние действия столько раз, сколько указано в ROUND_UNITS. То есть в нашем случае создаст 2 юнита.
              local unit = CreateUnitByName( "npc_dota_dragon_knight_raid" , point + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS ) 
         unit:SetInitialGoalEntity( waypoint ) -- Посылаем мобов на наш way1, координаты которого мы записали в переменную 'waypoint'
         end
          local unit = CreateUnitByName( "npc_dota_legion_commander_raid" , point + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS ) 
         unit:SetInitialGoalEntity( waypoint ) -- Посылаем мобов на наш way1, координаты которого мы записали в переменную 'waypoint'

         end)
    end)
              if GameRules:GetDOTATime(false,false)>18 then
              Timers:CreateTimer(3, function()
			

			for i=1, 4 do -- Произведет нижние действия столько раз, сколько указано в ROUND_UNITS. То есть в нашем случае создаст 2 юнита.
              local unit = CreateUnitByName( "npc_dota_dragon_knight_raid" , point + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS ) 
         unit:SetInitialGoalEntity( waypoint ) -- Посылаем мобов на наш way1, координаты которого мы записали в переменную 'waypoint'
         end
          	GameMode:BonusUnitStats(unit, 5000*wave, 100*wave)
          	local unit_dk = CreateUnitByName( "npc_dota_legion_commander_raid" , point + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS ) 
         unit:SetInitialGoalEntity( waypoint ) -- Посылаем мобов на наш way1, координаты которого мы записали в переменную 'waypoint'
             GameMode:BonusUnitStats(unit_dk, 500*wave, 30*wave)
             wave = wave + 1
             return return_time
         end)
   
      
end	


GameMode:InitGameMode()