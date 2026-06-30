local SKETCHY_BEGGAR = {}
SKETCHY_BEGGAR.ID = Isaac.GetEntityVariantByName("Sketchy Beggar")

BeckyMod.Slot.SKETCHY_BEGGAR = SKETCHY_BEGGAR

local game = BeckyMod.Game
local itemPool = game:GetItemPool()

BeckyMod:AddCallback(ModCallbacks.MC_POST_SLOT_INIT, function(_, slot)
    slot:SetState(SlotState.IDLE)
end, SKETCHY_BEGGAR.ID)


BeckyMod:AddCallback(ModCallbacks.MC_POST_SLOT_COLLISION, function(_, slot, collEnt)
    if slot:GetState() ~= SlotState.IDLE then return end
    local player = collEnt:ToPlayer()
    if player == nil then return end

    local sprite = slot:GetSprite()
    if not sprite:IsPlaying("Idle") then return end

    if player:GetNumBombs() > 0 then
        player:AddBombs(-1)
        slot:SetState(SlotState.REWARD)
        sprite:Play("PayPrizeBomb", true)

    elseif player:GetNumKeys() > 0 then
        player:AddKeys(-1)
        slot:SetState(SlotState.REWARD)
        sprite:Play("PayPrizeKey", true)
    else
        sprite:Play("Nothing", true)
    end
end, SKETCHY_BEGGAR.ID)


BeckyMod:AddCallback(ModCallbacks.MC_POST_SLOT_UPDATE, function(_, slot)
    local state = slot:GetState()
    local sprite = slot:GetSprite()
    if state == SlotState.IDLE then
        if not sprite:IsPlaying("Idle") and sprite:IsFinished() then
            sprite:Play("Idle")
        end
    elseif state == SlotState.REWARD then
        if sprite:IsFinished("Prize") then
            local rng = slot:GetDropRNG()

            for _=1, rng:RandomInt(3, 5) do
                Isaac.Spawn(5, 20, 1, slot.Position, rng:RandomVector():Resized(rng:RandomInt(5, 12) /3), nil)
            end
            local save = BeckyMod:RunSave()
            save.SketchyBeggar = save.SketchyBeggar or {}

            local beggarPayouts = save.SketchyBeggar[slot.InitSeed] or 0

            if beggarPayouts > 3 and (rng:RandomInt(5) == 0 or beggarPayouts >= 12) then
                sprite:Play("Teleport")
                slot:SetState(SlotState.PAYOUT)
                save.SketchyBeggar[slot.InitSeed] = nil


                local itemPayout
                if Isaac.GetPersistentGameData():Unlocked(Achievement.EVERYTHING_JAR) and itemPool:HasCollectible(CollectibleType.COLLECTIBLE_EVERYTHING_JAR) and rng:RandomInt(5) == 0 then
                    if itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_EVERYTHING_JAR) then
                        itemPayout = CollectibleType.COLLECTIBLE_EVERYTHING_JAR
                    end
                end
                if itemPayout == nil then
                    itemPayout = itemPool:GetCollectible(ItemPoolType.POOL_BEGGAR, true, rng:Next(), CollectibleType.COLLECTIBLE_BREAKFAST)
                end

                local spawnPos = game:GetRoom():FindFreePickupSpawnPosition(slot.Position, 40, true, false)
                Isaac.Spawn(5, 100, itemPayout, spawnPos, Vector.Zero, nil)
            else
                slot:SetState(SlotState.IDLE)
                save.SketchyBeggar[slot.InitSeed] = beggarPayouts +1
            end
        elseif sprite:IsFinished() then
            sprite:Play("Prize")
        end
    end
end, SKETCHY_BEGGAR.ID)

BeckyMod:AddCallback(ModCallbacks.MC_PRE_SLOT_CREATE_EXPLOSION_DROPS, function(_, slot)
    slot:GetSprite():Play("Teleport", true)
    slot:Die()
    slot.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    slot.Velocity = Vector.Zero
    return false
end, SKETCHY_BEGGAR.ID)