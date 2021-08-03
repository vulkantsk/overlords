LinkLuaModifier("modifier_undying_walking_dead", "heroes/undying/walking_dead", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_undying_walking_dead_spawner", "heroes/undying/walking_dead", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_undying_walking_dead_spawner_cooldown", "heroes/undying/walking_dead", LUA_MODIFIER_MOTION_NONE)


undying_walking_dead = class({})

function undying_walking_dead:OnSpellStart()
	local max_count = self:GetSpecialValueFor("max_count")
	local zombies = self.zombies or {}
	
	for key,value in pairs(zombies) do
		value:ForceKill(false)
--		value = nil
	end

	for i=1, max_count do
		self:CreateZombie()
	end
end


function undying_walking_dead:CreateZombie()
	local caster = self:GetCaster()
	local player = caster:GetPlayerID()
	local fv = caster:GetForwardVector()
	local point = caster:GetAbsOrigin() + RandomVector(150)
	local team = caster:GetTeam()

	local unit = CreateUnitByName( "npc_dota_undying_zombie", point, true, caster, caster, team )
	unit.zombie = true
	if not self.zombies then
		self.zombies = {}
	end
	self.zombies[unit:entindex()]= unit
	
	unit:AddNewModifier( unit, ability, "modifier_phased", {})
	unit:AddNewModifier( unit, ability, "modifier_undying_walking_dead", {})
--	unit:SetControllableByPlayer(player, false)
	unit:SetOwner(caster)
	unit:SetForwardVector(fv)

	local spawner_modifier = caster:FindModifierByName("modifier_undying_walking_dead_spawner")
	spawner_modifier:IncrementStackCount()
end

function undying_walking_dead:GetIntrinsicModifierName()
	return "modifier_undying_walking_dead_spawner"
end


modifier_undying_walking_dead = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	RemoveOnDeath 			= function(self) return true end,
	DeclareFunctions		= function(self) return 
		{   MODIFIER_EVENT_ON_DEATH} end,
})

function modifier_undying_walking_dead:OnDeath(data)
	if IsServer() then
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local owner = self:GetParent():GetOwner()
		local killer = data.attacker
		local killed_unit = data.unit
		
		if parent == killed_unit then
			print("ggg")
			self:GetAbility().zombies[killed_unit:entindex()] = nil
		
			local spawner_modifier = caster:FindModifierByName("modifier_undying_walking_dead_spawner")
			spawner_modifier:DecrementStackCount()
		end
	end
end

modifier_undying_walking_dead_spawner = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
})

function modifier_undying_walking_dead_spawner:OnCreated()
	self.ability = self:GetAbility()
	self.caster = self:GetCaster()
	self.spawn_interval = self.ability:GetSpecialValueFor("spawn_interval")
	self.max_count = self.ability:GetSpecialValueFor("max_count")

	self:StartIntervalThink(0.25)
end

function modifier_undying_walking_dead_spawner:OnRefresh()
	self:OnCreated()
end


function modifier_undying_walking_dead_spawner:OnIntervalThink()
	if IsServer() then
		
		if not self.caster:HasModifier("modifier_undying_walking_dead_spawner_cooldown") and self:GetStackCount() < self.max_count then
			self.ability:CreateZombie()
			self.caster:AddNewModifier(self.caster, self.ability, "modifier_undying_walking_dead_spawner_cooldown", {duration = self.spawn_interval})
		end
	end
end

modifier_undying_walking_dead_spawner_cooldown = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
})



