local Mod = BeckyMod
local DEAD_SOCKET = {}

DEAD_SOCKET.ID = Isaac.GetItemIdByName("Dead Socket")
BeckyMod.Item.DEAD_SOCKET = DEAD_SOCKET

local chargeAnimations = {
	[1] = true,
	[2] = true,
	[3] = true,
	[4] = true,
	[5] = true,
	[6] = true,
	[8] = true,
	[12] = true
}

---@param itemID CollectibleType
function DEAD_SOCKET:IsValidActiveItem(itemID)
	local itemConfig = Mod.itemconfig:GetCollectible(itemID)
	return itemConfig
	and itemConfig.ChargeType == ItemConfig.CHARGE_NORMAL
	and chargeAnimations[itemConfig.MaxCharges]
end

local customChargebar = Sprite()
customChargebar:Load("gfx/ui/ui_chargebar.anm2", false)
customChargebar:ReplaceSpritesheet(0, "gfx/ui/ui_deadsocket_chargebar.png")
customChargebar:LoadGraphics()

HudHelper.RegisterHUDElement({
	Name = "Dead Socket Chargebar",
	Priority = HudHelper.Priority.HIGH,
	Condition = function(player, playerHUDIndex, hudLayout, slot)
		---@cast slot ActiveSlot
		return HudHelper.ShouldActiveBeDisplayed(player, player:GetActiveItem(slot), slot)
			and player:GetEffects():GetCollectibleEffect(DEAD_SOCKET.ID)
			and not player:NeedsCharge(slot)
			and DEAD_SOCKET:IsValidActiveItem(player:GetActiveItem(slot))
	end,
	OnRender = function(player, playerHUDIndex, hudLayout, position, alpha, scale, slot, chargebarOffset)
		---@cast slot ActiveSlot
		---@cast chargebarOffset Vector
		local maxCharges = Mod.itemconfig:GetCollectible(player:GetActiveItem(slot)).MaxCharges
		local numCharges = math.min(maxCharges, player:GetEffects():GetCollectibleEffectNum(DEAD_SOCKET.ID))
		local barAnim = chargeAnimations[maxCharges] and maxCharges or 1
		local chargebarPos = chargebarOffset
		customChargebar.Color = Color(1,1,1,alpha)
		customChargebar.Scale = Vector(scale, scale)
		customChargebar:SetFrame("BarFull", 0)
		customChargebar:Render(chargebarPos, Vector(0, 3 + (23 - 23 * (numCharges / maxCharges))))
		customChargebar:SetFrame("BarOverlay" .. barAnim, 0)
		customChargebar:Render(chargebarPos)
	end
}, HudHelper.HUDType.ACTIVE)

---@param player EntityPlayer
function DEAD_SOCKET:ChargeDeadSocket(player)
	if player:HasCollectible(DEAD_SOCKET.ID)
		and DEAD_SOCKET:IsValidActiveItem(player:GetActiveItem(ActiveSlot.SLOT_PRIMARY))
		and not player:NeedsCharge(ActiveSlot.SLOT_PRIMARY)
	then
		local effects = player:GetEffects()
		if effects:GetCollectibleEffectNum(DEAD_SOCKET.ID) < player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY) then
			local roomShape = Mod.Game:GetRoom():GetRoomShape() >= RoomShape.ROOMSHAPE_2x2
			effects:AddCollectibleEffect(DEAD_SOCKET.ID, false, roomShape and 2 or 1)
		end
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_TRIGGER_ROOM_CLEAR, CallbackPriority.LATE, DEAD_SOCKET.ChargeDeadSocket)

---@param itemID CollectibleType
---@param rng RNG
---@param player EntityPlayer
function DEAD_SOCKET:OnUseItem(itemID, rng, player, flags, slot)
	if DEAD_SOCKET:IsValidActiveItem(itemID) and not player:NeedsCharge(slot) then
		local effects = player:GetEffects()
		if effects:HasCollectibleEffect(DEAD_SOCKET.ID) then
			local maxCharges = Mod.itemconfig:GetCollectible(itemID).MaxCharges
			local numToRemove = math.min(maxCharges, effects:GetCollectibleEffectNum(DEAD_SOCKET.ID))
			for _ = 1, numToRemove do
				local ghost = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PURGATORY, 1,
				player.Position, Vector.Zero, player)
				ghost.CollisionDamage = player.Damage * 1.5
			end
			effects:RemoveCollectibleEffect(DEAD_SOCKET.ID, numToRemove)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, DEAD_SOCKET.OnUseItem)