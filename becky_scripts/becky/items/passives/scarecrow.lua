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
local test = 0.5
SCARECROW.MAX_COLOR = Color(0, 0, 0, 1.0, 244/255 * test, 241/255 * test, 134/255 * test)

BeckyMod.Item.SCARECROW = SCARECROW

local tearSaveThing = false

function SCARECROW:GetCurrentColor(percent, entity)
    return Color(entity.Color.R, entity.Color.G, entity.Color.B, 1.0,
                 SCARECROW.MAX_COLOR.RO*percent, SCARECROW.MAX_COLOR.GO*percent, SCARECROW.MAX_COLOR.BO*percent)
    --[[
    return Color(SCARECROW.MAX_COLOR.R*percent, SCARECROW.MAX_COLOR.G*percent, SCARECROW.MAX_COLOR.B*percent, 1.0,
                 SCARECROW.MAX_COLOR.RO, SCARECROW.MAX_COLOR.GO, SCARECROW.MAX_COLOR.BO)
    ]]
end

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

    if not saveAll.ScarecrowEnemyPtrSave then
        saveAll.ScarecrowEnemyPtrSave = GetPtrHash(enemy)
    elseif saveAll.ScarecrowEnemyPtrSave ~= GetPtrHash(enemy) then
        save.ScareCrowHits = 0

        for _, entity in ipairs(Isaac.GetRoomEntities()) do
            if GetPtrHash(entity) == saveAll.ScarecrowEnemyPtrSave then
                entity:SetColor(SCARECROW:GetCurrentColor(0, entity), 0, 1, false, false) --Idk man
                --entity:SetColor(entity:GetColor(), -1, 1, false, false)
                break
            end
        end

        saveAll.ScarecrowEnemyPtrSave = GetPtrHash(enemy)
    end

    save.ScareCrowHits = save.ScareCrowHits and save.ScareCrowHits + 1 or 1

    local neededHits = (SCARECROW.HITS_NEEDED + SCARECROW.HITS_PER_SPAWNED_CROW * saveAll.ScareCrowCount)

    if save.ScareCrowHits >= neededHits then
        local ent = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DEAD_BIRD, 0, BeckyMod.Game:GetRoom():GetRandomPosition(400), Vector.Zero, player)
        ent = ent:ToEffect()
        ent.Timeout = 1

        ent.CollisionDamage = math.sqrt(BeckyMod.Level():GetAbsoluteStage())

        save.ScareCrowHits = 0
        saveAll.ScareCrowCount = saveAll.ScareCrowCount + 1
    end

    local percent = save.ScareCrowHits/neededHits

    enemy:SetColor(SCARECROW:GetCurrentColor(percent, enemy), -1, 1, false, false)

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