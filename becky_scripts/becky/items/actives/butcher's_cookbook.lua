local BUTCHERS_ID = Isaac.GetItemIdByName("Butcher's Cookbook")
local SAW_VARIANT = Isaac.GetEntityVariantByName("Butcher's Cookbook Sawblade")
local SAW_LIFETIME = 20 --in seconds
local SAW_DPS = 20
local BUTCHERS = {}

local START_SOUND = Isaac.GetSoundIdByName("saw_start")
local LOOP_SOUND = Isaac.GetSoundIdByName("saw_loop")

---@param player EntityPlayer
local function butchersUse(_, collectibleID, rngObj, player, useFlags, activeSlot, varData)
    local room = BeckyMod.Game:GetRoom()
    local gridIndex = room:GetGridIndex(player.Position)
    local pos = room:GetGridPosition(gridIndex)

    local saw = BeckyMod.Game:Spawn(EntityType.ENTITY_EFFECT, SAW_VARIANT, pos, Vector.Zero, player, 0, 1):ToEffect()
    saw:SetTimeout(SAW_LIFETIME * 30)

    BeckyMod.SFX:Play(START_SOUND)
end
BeckyMod:AddCallback(ModCallbacks.MC_USE_ITEM, butchersUse, BUTCHERS_ID)

---@param effect EntityEffect
local function sawInit(_, effect)
    local sprite = effect:GetSprite()
    sprite:Play("Spawn")

end
BeckyMod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, sawInit, SAW_VARIANT)

---@param effect EntityEffect
local function sawUpdate(_, effect)
    if effect.Timeout == 0 then
        BeckyMod.SFX:Stop(LOOP_SOUND)
        effect:Remove()
        return
    end

    local sprite = effect:GetSprite()

    if sprite:IsFinished("Spawn") then
        sprite:Play("Idle")
    end

    if not BeckyMod.SFX:IsPlaying(START_SOUND) and not BeckyMod.SFX:IsPlaying(LOOP_SOUND) then
        BeckyMod.SFX:Play(LOOP_SOUND, 10, 2, true)
    end

    local dmgSource = effect.SpawnerEntity or effect
    local entRef = EntityRef(dmgSource)
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity:IsVulnerableEnemy() and entity.Position:Distance(effect.Position) < 40 then
            entity:TakeDamage(SAW_DPS/30, DamageFlag.DAMAGE_CLONES, entRef, 0)
        end
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, sawUpdate, SAW_VARIANT)

local function newRoom(_)
    BeckyMod.SFX:Stop(LOOP_SOUND)
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, newRoom)

BUTCHERS.ID = BUTCHERS_ID
BeckyMod.Item.BUTCHERS_COOKBOOK = BUTCHERS

return BUTCHERS