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
local BombLibCallbacks = BombLib.Callbacks

BombLib:RegisterBombModifier("Null Bomb",
    {
		HasModifier = function(player) return player:HasCollectible(NULL_BOMBS.ID) end,

		FetusChance = BombLib.DefaultFetusChance, --Shared with epic fetus. you can input a function to scale with luck
		NancyChance = -1, --Whacky.

		IgnoreKamikaze = false, --Shared with Swallowed M80
		IgnoreEpicFetus = false,
		IgnoreWarLocust = false,
		IgnoreBobsBrain = false,
		IgnoreBobsRottenHead = false,
		IgnoreBBF = false,

		IgnoreHotPotato = false,

		Variant = Isaac.GetEntityVariantByName("Null Bomb"),
		Path = "gfx/items/pick ups/bombs/null",
		AddPathSuffixOnGolden = true,

		CopperBombSprite = true,
	}
)

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

BombLibCallbacks.AddCallback(BombLibCallbacks.ID.POST_BOMB_EXPLODE, NULL_BOMBS.Explode, "Null Bomb")