
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

function GameMode:OnNPCSpawned(keys)
	local npc = EntIndexToHScript(keys.entindex)
	local name = npc:GetUnitName()

	if npc:IsRealHero() and not npc.init then
		npc.init = true

		for i=0,2 do
			local ability = npc:GetAbilityByIndex(i)
        	ability:SetLevel(1)
    	end
	end
	
end

function GameMode:OnEntityKilled(keys)

	local unit = EntIndexToHScript(keys.entindex_killed)
	local unit_name = unit:GetUnitName()
	
end

GameMode:InitGameMode()