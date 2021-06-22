modifier_pudge_dirty_bomb_lua_hooker = {}

function modifier_pudge_dirty_bomb_lua_hooker:IsHidden()
	return false
end

function modifier_pudge_dirty_bomb_lua_hooker:IsDebuff()
	return false
end

function modifier_pudge_dirty_bomb_lua_hooker:IsStunDebuff()
	return false
end

function modifier_pudge_dirty_bomb_lua_hooker:IsPurgable()
	return false
end

function modifier_pudge_dirty_bomb_lua_hooker:OnCreated( kv )
	self.radius = self:GetAbility():GetSpecialValueFor( "hook_range" )
	self.speed = self:GetAbility():GetSpecialValueFor( "hook_speed" )
	self.tree = self:GetAbility():GetSpecialValueFor( "hook_dmg" )

	if not IsServer() then return end

	self.origin = self:GetParent():GetOrigin()
	self.point = Vector( kv.x, kv.y, 0 )
	self.direction = self.point - self.origin
	self.distance = self.direction:Length2D()
	self.direction.z = 0
	self.direction = self.direction:Normalized()
	self.enemies = {}

	--if not self:ApplyHorizontalMotionController() then
	--	self:Destroy()
	--	return
	--end
end

function modifier_pudge_dirty_bomb_lua_hooker:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_pudge_dirty_bomb_lua_hooker:OnRemoved()
end

function modifier_pudge_dirty_bomb_lua_hooker:OnDestroy()
	if not IsServer() then return end
	self:GetParent():RemoveHorizontalMotionController( self )
end

function modifier_pudge_dirty_bomb_lua_hooker:DeclareFunctions()
	return { MODIFIER_PROPERTY_OVERRIDE_ANIMATION }
end

function modifier_pudge_dirty_bomb_lua_hooker:GetOverrideAnimation()
	return ACT_DOTA_DISABLED
end

function modifier_pudge_dirty_bomb_lua_hooker:CheckState()
	return { [MODIFIER_STATE_STUNNED] = true }
end

function modifier_pudge_dirty_bomb_lua_hooker:UpdateHorizontalMotion( me, dt )
	local origin = me:GetOrigin()
	local target = origin + self.direction*self.speed*dt
	me:SetOrigin( target )

	GridNav:DestroyTreesAroundPoint( origin, self.tree, false )

	local dist = (target-self.origin):Length2D()
	if dist>self.distance then
		self:Destroy()
	end
end

function modifier_pudge_dirty_bomb_lua_hooker:OnHorizontalMotionInterrupted()
	self:Destroy()
end
