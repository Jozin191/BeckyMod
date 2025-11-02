local mod = BeckyMod
local enums = mod.Enums
local items = enums.CollectibleType
local utils = enums.Utils
local game = utils.Game

local DEAD_SOCKET = {}
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
	local itemConfig = mod.itemconfig:GetCollectible(itemID)
	return itemConfig
	and itemConfig.ChargeType == ItemConfig.CHARGE_NORMAL
	and chargeAnimations[itemConfig.MaxCharges]
end

---@param player EntityPlayer
---@param slot ActiveSlot
function DEAD_SOCKET:ShouldRenderDeadSocket(player, slot)
	local itemSlot = player:GetActiveItem(slot)

	-- print(HudHelper.ShouldActiveBeDisplayed(player, itemSlot, slot) ~= nil)
	-- print(player:HasCollectible(items.DEAD_SOCKET))
	-- print(not player:NeedsCharge(ActiveSlot.SLOT_PRIMARY))
	-- print(DEAD_SOCKET:IsValidActiveItem(itemSlot))

	return (
		HudHelper.ShouldActiveBeDisplayed(player, itemSlot, slot) ~= nil and
		player:HasCollectible(items.DEAD_SOCKET) and
		not player:NeedsCharge(ActiveSlot.SLOT_PRIMARY) and
		DEAD_SOCKET:IsValidActiveItem(itemSlot)
	)	
	-- local HasDeadSocket = player:HasCollectible(items.DEAD_SOCKET)
end

local customChargebar = Sprite("gfx/ui/ui_chargebar.anm2", true)
customChargebar:ReplaceSpritesheet(0, "gfx/ui/ui_deadsocket_chargebar.png", true)

HudHelper.RegisterHUDElement({
	Name = "Dead Socket Chargebar",
	Priority = HudHelper.Priority.HIGH,
	Condition = function(player, playerHUDIndex, hudLayout, slot)
		---@cast slot ActiveSlot
		return DEAD_SOCKET:ShouldRenderDeadSocket(player, slot)
	end,
	OnRender = function(player, playerHUDIndex, hudLayout, position, alpha, scale, slot, chargebarOffset)
		---@cast slot ActiveSlot
		---@cast chargebarOffset Vector
		local maxCharges = mod.itemconfig:GetCollectible(player:GetActiveItem(slot)).MaxCharges
		local numCharges = math.min(maxCharges, player:GetEffects():GetCollectibleEffectNum(items.DEAD_SOCKET))
		local barAnim = chargeAnimations[maxCharges] and maxCharges or 1
		local chargebarPos = chargebarOffset
		customChargebar.Color = Color(1,1,1,alpha)
		customChargebar.Scale = Vector(scale, scale)
		customChargebar:SetFrame("BarFull", 0)
		customChargebar:Render(chargebarPos, Vector(0, 3 + (23 - 23 * (numCharges / maxCharges))))
		customChargebar:SetFrame("BarOverlay" .. barAnim, 0)
		customChargebar:Render(chargebarPos)

		-- print("a[dka[pksdpakd[p]]]" )
	end
}, HudHelper.HUDType.ACTIVE)

---@param player EntityPlayer
function DEAD_SOCKET:ChargeDeadSocket(player)
	if not player:HasCollectible(items.DEAD_SOCKET) then return end
	if not DEAD_SOCKET:IsValidActiveItem(player:GetActiveItem(ActiveSlot.SLOT_PRIMARY)) then return end
	if not DEAD_SOCKET:IsValidActiveItem(player:GetActiveItem(ActiveSlot.SLOT_PRIMARY)) then return end 
	if player:NeedsCharge(ActiveSlot.SLOT_PRIMARY) then return end
	local effects = player:GetEffects()
	-- if not effects:GetCollectibleEffectNum(items.DEAD_SOCKET) < player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY) then return end

	local roomShape = game:GetRoom():GetRoomShape() >= RoomShape.ROOMSHAPE_2x2
	game:GetHUD():FlashChargeBar(player, ActiveSlot.SLOT_PRIMARY)
	utils.SFX:Play(SoundEffect.SOUND_BEEP, 1, 0, false, 0.8)
	effects:AddCollectibleEffect(items.DEAD_SOCKET, false, roomShape and 2 or 1)
end

mod:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_TRIGGER_ROOM_CLEAR, CallbackPriority.LATE, DEAD_SOCKET.ChargeDeadSocket)

---@param itemID CollectibleType
---@param rng RNG
---@param player EntityPlayer
function DEAD_SOCKET:OnUseItem(itemID, rng, player, flags, slot)
	if not (DEAD_SOCKET:IsValidActiveItem(itemID) and not player:NeedsCharge(slot)) then return end
	local effects = player:GetEffects()
	if not effects:HasCollectibleEffect(items.DEAD_SOCKET) then return end
	local maxCharges = mod.itemconfig:GetCollectible(itemID).MaxCharges
	local numToRemove = math.min(maxCharges, effects:GetCollectibleEffectNum(items.DEAD_SOCKET))
	for _ = 1, numToRemove do
		local ghost = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PURGATORY, 1,
		player.Position + rng:RandomVector():Resized(30), Vector.Zero, player)
		ghost.CollisionDamage = player.Damage * 1.5
	end
	effects:RemoveCollectibleEffect(items.DEAD_SOCKET, numToRemove)
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, DEAD_SOCKET.OnUseItem)