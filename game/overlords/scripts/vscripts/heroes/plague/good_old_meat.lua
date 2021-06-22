LinkLuaModifier( "modifier_pudge_good_old_meat", "heroes/plague/good_old_meat", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_pudge_good_old_meat_active", "heroes/plague/good_old_meat", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_pudge_good_old_meat_as_buff", "heroes/plague/good_old_meat", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_pudge_good_old_meat_vacuum", "heroes/plague/good_old_meat", LUA_MODIFIER_MOTION_HORIZONTAL )

pudge_good_old_meat = {}

function pudge_good_old_meat:GetAOERadius()
	return self:GetSpecialValueFor( "agr_radius" )
end

function pudge_good_old_meat:OnSpellStart()
   local caster = self:GetCaster()
   local duration = self:GetSpecialValueFor("agr_duration")
   --caster:AddNewModifier(caster, self, "modifier_pudge_good_old_meat_active", {duration = duration})
   self.strength = caster:GetStrength()
   local maxrange = self:GetSpecialValueFor( "agr_radius" )



   local point = caster:GetAbsOrigin()
   local enemies =  FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
    self:GetCaster():GetAbsOrigin(),
    nil,
    1000,
    DOTA_UNIT_TARGET_TEAM_ENEMY,
    DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
    DOTA_UNIT_TARGET_FLAG_NONE,
    FIND_ANY_ORDER,
    false)

   for _,unit in pairs(enemies) do
   	     unit:AddNewModifier(
			caster,
			self,
			"modifier_pudge_good_old_meat_vacuum",
			{
				duration = 1,
				x = point.x,
			    y = point.y,
	}
			)
   	    self.order_caster =
    {
        UnitIndex = unit:entindex(),
        OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
        TargetIndex = caster:entindex()
    }
    ExecuteOrderFromTable(self.order_caster)
    unit:SetForceAttackTarget(caster)
   	   unit:AddNewModifier(caster, self, "modifier_pudge_good_old_meat_as_buff", {duration = duration})
   end

end

function pudge_good_old_meat:GetIntrinsicModifierName()
	return "modifier_pudge_good_old_meat"
end



modifier_pudge_good_old_meat = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
	DeclareFunctions		= function(self) return 
		{

            MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
         
		
		} end,
})

function modifier_pudge_good_old_meat:GetModifierPhysicalArmorBonus()
  return self:GetAbility():GetSpecialValueFor("bonus_armor")
end

modifier_pudge_good_old_meat_active = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
	DeclareFunctions		= function(self) return 
		{

            MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
         
		
		} end,
})

function modifier_pudge_good_old_meat_active:GetModifierBonusStats_Strength()
	return self:GetCaster():GetStrength()
end

modifier_pudge_good_old_meat_as_buff = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
	DeclareFunctions		= function(self) return 
		{

            MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
         
		
		} end,
})

function modifier_pudge_good_old_meat_as_buff:GetModifierAttackSpeedBonus_Constant()
	return 100
end

function modifier_pudge_good_old_meat_as_buff:OnRemoved()
	if IsServer() then
		self:GetParent():SetForceAttackTarget( nil )
	end
end

modifier_pudge_good_old_meat_vacuum = {}

function modifier_pudge_good_old_meat_vacuum:IsHidden()
	return false
end

function modifier_pudge_good_old_meat_vacuum:IsDebuff()
	return true
end

function modifier_pudge_good_old_meat_vacuum:IsStunDebuff()
	return true
end

function modifier_pudge_good_old_meat_vacuum:IsPurgable()
	return true
end


function modifier_pudge_good_old_meat_vacuum:ApplyHorizontalMotionController()
   
end



function modifier_pudge_good_old_meat_vacuum:OnCreated( kv )

	if not IsServer() then
		return
	end

    local caster = self:GetCaster()
	local center = Vector( kv.x, kv.y, 0 )
	self.direction = center - self:GetParent():GetOrigin()
	self.speed = self.direction:Length2D()/self:GetDuration()

	self.direction.z = 0
	self.direction = self.direction:Normalized()

	if not self:ApplyHorizontalMotionController() then
		self:Destroy()
	end
end

function modifier_pudge_good_old_meat_vacuum:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_pudge_good_old_meat_vacuum:OnDestroy()
	if not IsServer() then
		return
	end

	self:GetParent():RemoveHorizontalMotionController( self )
end

function modifier_pudge_good_old_meat_vacuum:UpdateHorizontalMotion( me, dt )
	local target = me:GetAbsOrigin() + self.direction * self.speed * dt
	me:SetAbsOrigin( target )
end

function modifier_pudge_good_old_meat_vacuum:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

function modifier_pudge_good_old_meat_vacuum:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end

function modifier_pudge_good_old_meat_vacuum:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end


function modifier_pudge_good_old_meat_vacuum:OnHorizontalMotionInterrupted()
	self:Destroy()
end