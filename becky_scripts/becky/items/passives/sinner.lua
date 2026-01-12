-- Damage = BASE_DAMAGE + speed * SPEED_PER_DAMAGE

local mod = BeckyMod
local enums = mod.Enums
local items = enums.CollectibleType
local variants = enums.Variants
local utils = enums.Utils
local game = utils.Game
local tempData = mod.getData

local SINNER = {}

---@type table<integer, string>
SINNER.SPEED_TO_SHEET = {
    [-2] = "gfx/familiar/Sin_Bat_Slower.png",
    [-1] = "gfx/familiar/Sin_Bat_Slow.png",
    [0] = "gfx/familiar/Sin_Bat_Standard.png",
    [1] = "gfx/familiar/Sin_Bat_Fast.png",
    [2] = "gfx/familiar/Sin_Bat_Faster.png",
}

SINNER.BASE_DAMAGE = 0.2
SINNER.SPEED_PER_DAMAGE = 0.4

SINNER.BASE_ORBIT_SPEED = 2.75
SINNER.ORBIT_SPEED_PER_SPEED = 0.8

SINNER.ORBIT_CORRECTION_SPEED = 0.2
SINNER.ORBIT_DIST = 70

---@generic T
---@param first T
---@param second T
---@param percent number
---@return T
function SINNER:Lerp(first, second, percent)
    return first + (second - first) * percent
end

---@param familiar Entity
function SINNER:GetFamiliarData(familiar)
    local data = tempData(familiar)
    data.__BECKY_SINNER = data.__BECKY_SINNER or {}
    ---@class SinnerFamiliarData
    ---@field Dist number
    ---@field OrbitOffset integer
    ---@field TargOrbitOffset integer
    ---@field PrevAngle number
    return data.__BECKY_SINNER
end

---@param player Entity
function SINNER:GetPlayerData(player)
    local data = tempData(player)
    data.__BECKY_SINNER = data.__BECKY_SINNER or {
        Speed = 0
    }
    ---@class SinnerPlayerData
    ---@field Speed integer
    ---@field Angle number
    return data.__BECKY_SINNER
end

function SINNER:EvaluateOrbitOffsets()
    ---@type table<integer, EntityFamiliar[]>
    local hashToFamiliars = {}

    for _, v in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, variants.SINNER)) do
        ---@diagnostic disable-next-line: cast-local-type
        v = v:ToFamiliar() ---@cast v EntityFamiliar
        local hash = GetPtrHash(v.Player)
        hashToFamiliars[hash] = hashToFamiliars[hash] or {}
        hashToFamiliars[hash][#hashToFamiliars[hash] + 1] = v
    end

    for _, v in pairs(hashToFamiliars) do
        for i, familiar in ipairs(v) do
            SINNER:GetFamiliarData(familiar).TargOrbitOffset = 360 / #v * i
        end
    end
end

---@param familiar EntityFamiliar
function SINNER:FamiliarInit(familiar)
    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, familiar.Position, Vector.Zero, nil)
    familiar:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    familiar:GetSprite():ReplaceSpritesheet(0, SINNER.SPEED_TO_SHEET[SINNER:GetPlayerData(familiar.Player).Speed], true)
    SINNER:EvaluateOrbitOffsets()
end
BeckyMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, SINNER.FamiliarInit, variants.SINNER)

---@param familiar EntityFamiliar
function SINNER:FamiliarUpdate(familiar)
    local fdata = SINNER:GetFamiliarData(familiar)

    if not fdata.TargOrbitOffset then
        SINNER:EvaluateOrbitOffsets()
    end

    if not fdata.Dist then
        fdata.Dist = 0
        familiar.Position = familiar.Player.Position
        familiar.Velocity = Vector.Zero
    end

    local pdata = SINNER:GetPlayerData(familiar.Player)

    fdata.Dist = SINNER:Lerp(fdata.Dist, SINNER.ORBIT_DIST, SINNER.ORBIT_CORRECTION_SPEED)
    fdata.OrbitOffset = fdata.OrbitOffset and SINNER:Lerp(fdata.OrbitOffset, fdata.TargOrbitOffset, SINNER.ORBIT_CORRECTION_SPEED) or fdata.TargOrbitOffset

    pdata.Angle = pdata.Angle or 0

    local frame = (pdata.Angle * SINNER.BASE_ORBIT_SPEED) % 360
    local targPos = (familiar.Player.Position + Vector(fdata.Dist, 0):Rotated(frame + fdata.OrbitOffset))

    familiar.Velocity = targPos - familiar.Position

    if game:GetRoom():GetFrameCount() == 0 then
        familiar.Velocity = Vector.Zero
        familiar.Position = targPos
    end

    familiar.CollisionDamage = SINNER.BASE_DAMAGE + SINNER.SPEED_PER_DAMAGE * (2 + pdata.Speed)

    if fdata.TargOrbitOffset == 360 then
        pdata.Angle = pdata.Angle + 1 + (2 + pdata.Speed) * SINNER.ORBIT_SPEED_PER_SPEED

        if fdata.PrevAngle and frame < fdata.PrevAngle then
            local hash = GetPtrHash(familiar.Player)

            pdata.Speed = pdata.Speed + 1 > 2 and -2 or pdata.Speed + 1

            for _, v in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, variants.SINNER)) do
                ---@diagnostic disable-next-line: cast-local-type
                v = v:ToFamiliar() ---@cast v EntityFamiliar

                if hash == GetPtrHash(v.Player) then
                    v:GetSprite():ReplaceSpritesheet(0, SINNER.SPEED_TO_SHEET[pdata.Speed], true)
                end
            end
        end
    end

    fdata.PrevAngle = frame
end
BeckyMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, SINNER.FamiliarUpdate, variants.SINNER)

---@param player EntityPlayer
function SINNER:EvaluateCache(player)
    player:CheckFamiliar(
        variants.SINNER,
        player:GetCollectibleNum(items.SINNER) + player:GetEffects():GetCollectibleEffectNum(items.SINNER),
        player:GetCollectibleRNG(items.SINNER),
        Isaac.GetItemConfig():GetCollectible(items.SINNER)
    )
end
BeckyMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, SINNER.EvaluateCache, CacheFlag.CACHE_FAMILIARS)

---@param entity Entity
function SINNER:PostEntityRemove(entity)
    if entity.Type ~= EntityType.ENTITY_FAMILIAR or entity.Variant ~= variants.SINNER then return end
    Isaac.CreateTimer(SINNER.EvaluateOrbitOffsets, 2, 1, true)
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, SINNER.PostEntityRemove)