local NULL_BOMBS = {}

NULL_BOMBS.ID = Isaac.GetItemIdByName("Null Bombs")
NULL_BOMBS.BOMB_VARIANT = Isaac.GetEntityVariantByName("Null Bomb")

NULL_BOMBS.MAW_TIMEOUT = 80
NULL_BOMBS.MAW_RADIUS = 50
NULL_BOMBS.REDUCE_DAMAGE_THRESHOLD = 1.5
NULL_BOMBS.REDUCED_SCATTER_RADIUS_MULT = 4
NULL_BOMBS.REDUCED_SCATTER_DAMAGE_MULT = 7.5

NULL_BOMBS.DR_FETUS_CHANCE = 10
NULL_BOMBS.NANCY_BOMBS_CHANCE = 5

BeckyMod.Item.NULL_BOMBS = NULL_BOMBS

local max = math.max
local CBMAPICallbacks = CustomBombModifiersAPI.Callbacks

function NULL_BOMBS:Explode(bomb, player, extraData)
    local pos = bomb.Position
    local maw = player:SpawnMawOfVoid(NULL_BOMBS.MAW_TIMEOUT)

    maw.DisableFollowParent = true
    maw.Position = pos
    maw.Radius = NULL_BOMBS.MAW_RADIUS
    maw.CollisionDamage = player.Damage - max(0, player.Damage - NULL_BOMBS.REDUCE_DAMAGE_THRESHOLD) / 2

    if extraData.SmallExplosion then
        maw.Radius = maw.Radius / NULL_BOMBS.REDUCED_SCATTER_RADIUS_MULT
        maw.CollisionDamage = maw.CollisionDamage / NULL_BOMBS.REDUCED_SCATTER_DAMAGE_MULT
    end
end

CBMAPICallbacks.AddCallback(CBMAPICallbacks.ID.POST_BOMB_EXPLODE, NULL_BOMBS.Explode, "Null Bomb")

function NULL_BOMBS:Pre(bomb, player)
    print('pre')
end

CBMAPICallbacks.AddCallback(CBMAPICallbacks.ID.PRE_PROPER_BOMB_INIT, NULL_BOMBS.Pre, "Null Bomb")


function NULL_BOMBS:Post(bomb, player)
    print('post')
end

CBMAPICallbacks.AddCallback(CBMAPICallbacks.ID.POST_PROPER_BOMB_INIT, NULL_BOMBS.Post, "Null Bomb")