local SPELL_COST = 20
local SPELL_COST2 = 45
local SPELL_COST3 = 30
local SPELL_COST4 = 35
local CanPickupGridList = {}

local game = BeckyMod.Game

local SPEED = Vector(10,0)
local COOLDOWN = 90
local ATTACKING_COOLDOWN = 7
local PROJ_SPEED = Vector(15,0)

local NULL_ITEM_ID = Isaac.GetNullItemIdByName("SPELL_Summon_BroberBobby")
local NULL_ITEM_ID2 = Isaac.GetNullItemIdByName("SPELL_Summon_2")
local NULL_ITEM_ID3 = Isaac.GetNullItemIdByName("SPELL_Summon_3")
local NULL_ITEM_ID4 = Isaac.GetNullItemIdByName("SPELL_Summon_4")
BeckyMod.Spells.NULL_ITEMS.SUMMON = NULL_ITEM_ID
BeckyMod.Spells.NULL_ITEMS.SUMMON2 = NULL_ITEM_ID2
BeckyMod.Spells.NULL_ITEMS.SUMMON3 = NULL_ITEM_ID3
BeckyMod.Spells.NULL_ITEMS.SUMMON4 = NULL_ITEM_ID4

local GhostVar = Isaac.GetEntityVariantByName("Becky Summon Spell Ghost")

local VALID_FAMS = {
    [FamiliarVariant.BROTHER_BOBBY] = true,
    [FamiliarVariant.LIL_HAUNT] = true,
    [FamiliarVariant.MULTIDIMENSIONAL_BABY] = true,
    [GhostVar] = true,
}

BeckyMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player)
    player:CheckFamiliar(
        FamiliarVariant.BROTHER_BOBBY,
        player:GetEffects():GetNullEffectNum(NULL_ITEM_ID),
        player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_BROTHER_BOBBY),
        nil,
        120
    )
    player:CheckFamiliar(
        FamiliarVariant.LIL_HAUNT,
        player:GetEffects():GetNullEffectNum(NULL_ITEM_ID2),
        player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_LIL_HAUNT),
        nil,
        120
    )
    player:CheckFamiliar(
        GhostVar,
        player:GetEffects():GetNullEffectNum(NULL_ITEM_ID3),
        player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_PUNCHING_BAG),
        nil,
        120
    )
    player:CheckFamiliar(
        FamiliarVariant.MULTIDIMENSIONAL_BABY,
        player:GetEffects():GetNullEffectNum(NULL_ITEM_ID4),
        player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_MULTIDIMENSIONAL_BABY),
        nil,
        120
    )
end, CacheFlag.CACHE_FAMILIARS)

BeckyMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function(_, fam)
    if fam.Variant == GhostVar then
        fam:AddToFollowers()
    end

    if fam.SubType ~= 120 then return end
    if VALID_FAMS[fam.Variant] then
        local color = fam:GetSprite().Color
        color:SetColorize(1, 1, 1, 1)
        color.A = 0.85
        fam:GetSprite().Color = color
        BeckyMod.GetEntData(fam).NoGrantMana = true
    end
end)


local GhostStates = {
    IDLE = 0,
    SHOOT_UPDOWN = 1,
    SHOOT_LEFTRIGHT = 2,
}
local GHOST_VEL = Vector(28,0)
BeckyMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
    local famData = BeckyMod.GetEntData(fam)
    if famData.SummonGhost_ChargeSprite == nil then
        BeckyMod.GetEntData(fam).SummonGhost_ChargeSprite = {
            Sprite = Sprite("gfx/chargebar_beckyghost.anm2", true),
            Charge = 0,
            MaxCharge = 75
        }
    end
    local player = fam.Player
    if player == nil then return end

    local state = fam.State
    local sp = fam:GetSprite()
    if state == GhostStates.IDLE and player:GetAimDirection():Length() > 0.3 then
        local dataCharge = famData.SummonGhost_ChargeSprite
        local add = 1
        if player:HasTrinket(TrinketType.TRINKET_FORGOTTEN_LULLABY) then add = 2 end
        dataCharge.Charge = math.min(dataCharge.Charge + add, dataCharge.MaxCharge)
    elseif state == GhostStates.SHOOT_UPDOWN then
        fam.Position = Vector(BeckyMod:Lerp(fam.Position.X, player.Position.X, 0.33), fam.Position.Y)
    elseif  state == GhostStates.SHOOT_LEFTRIGHT then
        fam.Position = Vector(fam.Position.X, BeckyMod:Lerp(fam.Position.Y, player.Position.Y, 0.33))
    else
        local dataCharge = famData.SummonGhost_ChargeSprite
        if dataCharge.Charge > 15 then
            local angle = player:GetLastDirection():GetAngleDegrees()
            local charge = dataCharge.Charge / dataCharge.MaxCharge +0.5
            fam.Position = player.Position
            if (angle > 45 and angle < 135) then
                sp:Play("ThrowDown", true)
                fam.Velocity = GHOST_VEL:Rotated(90) * charge
                fam.State = GhostStates.SHOOT_UPDOWN

            elseif (angle >= 135 or angle <= -135) then
                sp:Play("ThrowSide", true)
                fam.Velocity = GHOST_VEL:Rotated(180) * charge
                fam.State = GhostStates.SHOOT_LEFTRIGHT
                
            elseif (angle > -135 and angle < -45) then
                sp:Play("ThrowUp", true)
                fam.Velocity = GHOST_VEL:Rotated(-90) * charge
                fam.State = GhostStates.SHOOT_UPDOWN
            else
                sp:Play("ThrowSide", true)
                fam.FlipX = true
                fam.Velocity = GHOST_VEL * charge
                fam.State = GhostStates.SHOOT_LEFTRIGHT
            end
            fam:RemoveFromFollowers()
        end
        dataCharge.Charge = 0
    end

    if state == GhostStates.IDLE then
        fam:FollowParent()
    elseif famData.GotFar and player.Position:Distance(fam.Position) < 16 then
        fam:AddToFollowers()
        fam.State = GhostStates.IDLE
        fam.Velocity = Vector.Zero
        sp:Play("Idle", true)
        famData.GotFar = false
        fam.FlipX = false
    else
        if not famData.GotFar and player.Position:Distance(fam.Position) > 20 then
            famData.GotFar = true
        end
        if Isaac.CountEnemies() > 0 then
            local dmg = 5 * fam:GetMultiplier()
            local famRef = EntityRef(fam)
            for _, ent in ipairs(Isaac.FindInRadius(fam.Position, 10, EntityPartition.ENEMY)) do
                ent:TakeDamage(dmg, 0, famRef, 0)
            end
        end
        fam.Velocity = fam.Velocity:Lerp( GHOST_VEL:Rotated( (player.Position - fam.Position):GetAngleDegrees() ), 0.08 )
    end

end, GhostVar)

local CHARGEBAR_POS = Vector(18.5, -54)
local function UpdateChargebar(data)
	local sp = data.Sprite
	local charge = math.floor(data.Charge / data.MaxCharge *100)+1


	if charge == 101 then
		if not sp:IsPlaying("Charged") then sp:Play("Charged", true) end
		if not game:IsPaused() then sp:Update() end
	elseif charge > 0 and charge < 101 then
		if not sp:IsPlaying("Charging") then sp:Play("Charging") end
		sp:SetFrame("Charging", charge)
	elseif charge <= 0 then
		if not sp:IsPlaying("Disappear") and not sp:IsFinished("Disappear") then
			sp:Play("Disappear", true)
		elseif not game:IsPaused() then sp:Update() end
	end
end
local function renderFamiliarChargebar(fam)
	local chargeData = BeckyMod.GetEntData(fam).SummonGhost_ChargeSprite
	if not chargeData then return end
    local sp = chargeData.Sprite
    UpdateChargebar(chargeData)
    if sp:IsPlaying("Disappear") or chargeData.Charge > 0  then
        sp:Render(game:GetRoom():WorldToScreenPosition( (fam.Position + CHARGEBAR_POS) * fam.SpriteScale ))
    end
end

BeckyMod:AddPriorityCallback(ModCallbacks.MC_POST_ROOM_RENDER_ENTITIES, -300, function()
	if not Options.ChargeBars then return end
    for _, ent in ipairs(Isaac.FindByType(3, GhostVar)) do
        local fam = ent:ToFamiliar()
        if fam then renderFamiliarChargebar(fam) end
    end
end)


local function fun(player)
    local data = BeckyMod.GetEntData(player)
    --if data.MagicStaff_SelectSpellDir == nil then
    --    data.MagicStaff_SelectSpellDir = { Type = BeckyMod.Spells.SpellType.SUMMON }
    --    return
    --end
    local save = BeckyMod:RunSave(player)
    if data.MagicStaff_SelectSpellDir == nil then
        data.MagicStaff_SelectSpellDir = { Type = BeckyMod.Spells.SpellType.SUMMON, Choices = {
            Anim = "SummonSpellFams",
            [Direction.LEFT] =  (save.ManaCharge >= SPELL_COST  and 1) or 5, --Shooting familiar
            [Direction.UP] =    (save.ManaCharge >= SPELL_COST2 and 3) or 7, --Chase familiar
            [Direction.RIGHT] = (save.ManaCharge >= SPELL_COST4 and 0) or 4, --Follower familiar
            [Direction.DOWN] =  (save.ManaCharge >= SPELL_COST3 and 2) or 6, --Charge familiar
        } }
        return
    end
    local effects = player:GetEffects()

    if effects:HasNullEffect(NULL_ITEM_ID) then
        effects:RemoveNullEffect(NULL_ITEM_ID, -1)
    elseif effects:HasNullEffect(NULL_ITEM_ID2) then
        effects:RemoveNullEffect(NULL_ITEM_ID2, -1)
    elseif effects:HasNullEffect(NULL_ITEM_ID3) then
        effects:RemoveNullEffect(NULL_ITEM_ID3, -1)
    elseif effects:HasNullEffect(NULL_ITEM_ID4) then
        effects:RemoveNullEffect(NULL_ITEM_ID4, -1)
    end


    if data.MagicStaff_SelectSpellDir.Dir == Direction.RIGHT then
        if save.ManaCharge - SPELL_COST4 >= 0 then
            player:AddNullItemEffect(NULL_ITEM_ID4)
            save.ManaCharge = save.ManaCharge - SPELL_COST4
        else return true end
    elseif data.MagicStaff_SelectSpellDir.Dir == Direction.UP then
        if save.ManaCharge - SPELL_COST2 >= 0 then
            player:AddNullItemEffect(NULL_ITEM_ID2)
            save.ManaCharge = save.ManaCharge - SPELL_COST2
        else return true end
    elseif data.MagicStaff_SelectSpellDir.Dir == Direction.DOWN then
        if save.ManaCharge - SPELL_COST3 >= 0 then
            player:AddNullItemEffect(NULL_ITEM_ID3)
            save.ManaCharge = save.ManaCharge - SPELL_COST3
        else return true end
    else
        if save.ManaCharge - SPELL_COST >= 0 then
            player:AddNullItemEffect(NULL_ITEM_ID)
            save.ManaCharge = save.ManaCharge - SPELL_COST
        else return true end
    end
    data.MagicStaff_SelectSpellDir = nil
end

local function canSelectFun(player, manaLeft)
    return manaLeft >= SPELL_COST
end

return {
    BeckyMod.Spells.SpellType.SUMMON,
    Func = fun,
    CanSelect = canSelectFun,
    Cost = 0,
    Frame = 3
}



--[[
tint : 1 | 1 | 1 | 1
colorize : 1.8 | 0.9 | 0.3 | 1
offset : 0.3 | 0 | 0
]]