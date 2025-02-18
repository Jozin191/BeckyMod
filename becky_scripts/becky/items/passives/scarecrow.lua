--[[
    CREDTIS:
        ITEM IDEA: MuffinTae
        ART: Jozin
        CODE: Tiburones202
]]

local SCARECROW = {}

SCARECROW.ID = Isaac.GetItemIdByName("Scarecrow")
SCARECROW.HITS_NEEDED = 10
SCARECROW.HITS_PER_SPAWNED_CROW = 5
SCARECROW.MAX_CROWS_AT_A_TIME = 5

BeckyMod.Item.SCARECROW = SCARECROW

local tearSaveThing = false
local ptrSaves = {} --TODO: change to the save because I'm stupid and did it without it lol

function SCARECROW:collideWithEnemy(EntityTear, Collider)
    local enemy = Collider:ToNPC()

    if not enemy then goto continue end
    if (not enemy:IsVulnerableEnemy()) or (not enemy:IsActiveEnemy(false)) or enemy:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then goto continue end

    local player = BeckyMod:TryGetPlayer(EntityTear)

    if not player then goto continue end
    if not player:HasCollectible(SCARECROW.ID) then goto continue end

    local save = BeckyMod:TempSave(player)
    local saveAll = BeckyMod:TempSave()
    if not saveAll.ScareCrowCount then saveAll.ScareCrowCount = 0 end
    if saveAll.ScareCrowCount >= SCARECROW.MAX_CROWS_AT_A_TIME then goto continue end

    if not ptrSaves[BeckyMod:GetPlayerString(player)] then
        ptrSaves[BeckyMod:GetPlayerString(player)] = GetPtrHash(enemy)
    end
    
    if ptrSaves[BeckyMod:GetPlayerString(player)] ~= GetPtrHash(enemy) then
        save.ScareCrowHits = 0
        ptrSaves[BeckyMod:GetPlayerString(player)] = GetPtrHash(enemy)
    end

    save.ScareCrowHits = save.ScareCrowHits and save.ScareCrowHits + 1 or 1

    if save.ScareCrowHits >= (SCARECROW.HITS_NEEDED + SCARECROW.HITS_PER_SPAWNED_CROW * saveAll.ScareCrowCount) then
        local ent = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DEAD_BIRD, 0, BeckyMod.Game:GetRoom():GetRandomPosition(400), Vector.Zero, player)
        ent = ent:ToEffect()
        ent.Timeout = 1

        ent.CollisionDamage = math.sqrt(BeckyMod.Level():GetAbsoluteStage())

        save.ScareCrowHits = 0
        saveAll.ScareCrowCount = saveAll.ScareCrowCount + 1
    end

    tearSaveThing = true

    ::continue::
end

BeckyMod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, SCARECROW.collideWithEnemy)

function SCARECROW:postTearDeath(EntityTear)
    local player = BeckyMod:TryGetPlayer(EntityTear) --Has a player
    if player and player:HasCollectible(SCARECROW.ID) then
        if not tearSaveThing then
            local save = BeckyMod:TempSave(player)
            save.ScareCrowHits = 0
        end
    end
    tearSaveThing = false
end

BeckyMod:AddCallback(ModCallbacks.MC_POST_TEAR_DEATH, SCARECROW.postTearDeath)