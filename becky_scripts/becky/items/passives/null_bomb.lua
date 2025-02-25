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

function NULL_BOMBS:IsNullBomb(bomb, player)
	if not bomb then return false end
	if bomb.Type ~= EntityType.ENTITY_BOMB then return false end
	bomb = bomb:ToBomb()
	if not bomb:GetData().NullBomb then return false end

	if not player then return false end

	return true
end

function NULL_BOMBS:ReplaceSpritesheet(bomb)
    if bomb.Variant == NULL_BOMBS.BOMB_VARIANT then
        local sprite = bomb:GetSprite()
        local anim = sprite:GetAnimation()
        local file = sprite:GetFilename()

        local spritesheetSuffix = ""

        if bomb:HasTearFlags(TearFlags.TEAR_GOLDEN_BOMB) then
			spritesheetSuffix = "_gold"
		end

        sprite:Load("gfx/items/pick ups/bombs/null".. spritesheetSuffix .. file:sub(file:len()-5), true)
        sprite:Play(anim, true)
    elseif FiendFolio and (bomb.Variant == FiendFolio.BOMB.COPPER) and bomb:GetData().NullBomb then --Copper bomb stuff yeah
        local sprite = bomb:GetSprite()
        local anim = sprite:GetAnimation()
        local file = sprite:GetFilename()

        sprite:Load("gfx/items/pick ups/bombs/null_copper".. file:sub(file:len()-5), true)
        sprite:Play(anim, true)
    end
end

function NULL_BOMBS:ChangeVariant(bomb)
    if (bomb.Variant > BombVariant.BOMB_SUPERTROLL or bomb.Variant < BombVariant.BOMB_TROLL) then
        if bomb.Variant == 0 then
            bomb.Variant = NULL_BOMBS.BOMB_VARIANT
        end
    end

    bomb:GetData().NullBomb = true
end

---@param bomb EntityBomb
function NULL_BOMBS:ProperBombInit(bomb, player)
    if not player then return end
    if bomb.Variant == BombVariant.BOMB_GIGA then return end
    if bomb.Variant == BombVariant.BOMB_THROWABLE then return end

    --Detect nancy bombs anddddd the dr fetus from SMB yeah
    if player:HasCollectible(NULL_BOMBS.ID) then
        if bomb.IsFetus then
            local rng = bomb:GetDropRNG()

            if rng:RandomInt(100) > NULL_BOMBS.DR_FETUS_CHANCE then
                return
            end
        end

        NULL_BOMBS:ChangeVariant(bomb)
    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_NANCY_BOMBS) then
        if false then return end --TODO: Check if unlocked

        if player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_NANCY_BOMBS):RandomInt(100) > NULL_BOMBS.NANCY_BOMBS_CHANCE then
            return
        end

        NULL_BOMBS:ChangeVariant(bomb)
    end
end

---@param bomb EntityBomb
function NULL_BOMBS:BombUpdate(bomb)
    local player = BeckyMod:TryGetPlayer(bomb)

	if bomb.FrameCount == 1 then
		NULL_BOMBS:ProperBombInit(bomb, player)
        NULL_BOMBS:ReplaceSpritesheet(bomb)
	end

	if not NULL_BOMBS:IsNullBomb(bomb, player) then return end

    local sprite = bomb:GetSprite()
	if sprite:IsPlaying("Explode") then
        local pos = bomb.Position
        local maw = player:SpawnMawOfVoid(NULL_BOMBS.MAW_TIMEOUT)

        maw.DisableFollowParent = true
        maw.Position = pos
        maw.Radius = NULL_BOMBS.MAW_RADIUS
        maw.CollisionDamage = player.Damage - max(0, player.Damage - NULL_BOMBS.REDUCE_DAMAGE_THRESHOLD) / 2

        if bomb:GetData().IsSmallBomb then
            maw.Radius = maw.Radius / NULL_BOMBS.REDUCED_SCATTER_RADIUS_MULT
            maw.CollisionDamage = maw.CollisionDamage / NULL_BOMBS.REDUCED_SCATTER_DAMAGE_MULT
        end

        if bomb:HasTearFlags(TearFlags.TEAR_SCATTER_BOMB) then
            for _, scatterBomb in ipairs(Isaac.FindByType(EntityType.ENTITY_BOMB)) do
				if scatterBomb.FrameCount == 0 then --Just created bomb
					scatterBomb:GetData().IsSmallBomb = true
				end
			end
        end
	end
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, NULL_BOMBS.BombUpdate)