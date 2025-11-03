local mod = BeckyMod
local enums = mod.Enums
local trinkets = enums.TrinketType
local utils = enums.Utils
local game = utils.Game

local CORPSE_TAG = {}

BeckyMod.Trinket.CORPSE_TAG = CORPSE_TAG

CORPSE_TAG.ID = Isaac.GetTrinketIdByName("Corpse Tag")
CORPSE_TAG.MIN = -1
CORPSE_TAG.MAX = 3

local sfx = SFXManager()

---@param player EntityPlayer
function CORPSE_TAG:OnRoomClear(player)
    local num = player:GetTrinketMultiplier(trinkets.CORPSE_TAG) if num == 0 then return end
    local rng = player:GetTrinketRNG(trinkets.CORPSE_TAG)
    local spawned

    for _ = 1, num do
        for _ = 1, rng:RandomInt(CORPSE_TAG.MIN, CORPSE_TAG.MAX) do
            game:Spawn(
                EntityType.ENTITY_FAMILIAR,
                FamiliarVariant.BONE_ORBITAL,
                player.Position,
                Vector.Zero,
                player,
                0,
                rng:Next()
            ):ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            spawned = true
        end
    end

    if spawned then
        player:AnimateTrinket(trinkets.CORPSE_TAG, "UseItem")
        sfx:Play(SoundEffect.SOUND_BONE_HEART)
    end
end
BeckyMod:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_TRIGGER_ROOM_CLEAR, CallbackPriority.LATE, CORPSE_TAG.OnRoomClear)