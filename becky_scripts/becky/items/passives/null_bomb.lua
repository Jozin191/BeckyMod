local NULL_BOMBS = {}

NULL_BOMBS.ID = Isaac.GetItemIdByName("Null Bombs")
NULL_BOMBS.MAW_TIMEOUT = 80
NULL_BOMBS.MAW_RADIUS = 50
NULL_BOMBS.REDUCE_DAMAGE_THRESHOLD = 5

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

---@param bomb EntityBomb
function NULL_BOMBS:ProperBombInit(bomb, player)
    if not player then return end
    if bomb.Variant == BombVariant.BOMB_GIGA then return end

    --Detect nancy bombs anddddd the dr fetus from SMB yeah
    if player:HasCollectible(NULL_BOMBS.ID) then
        bomb:GetData().NullBomb = true
    end
end

---@param bomb EntityBomb
function NULL_BOMBS:BombUpdate(bomb)
    local player = BeckyMod:TryGetPlayer(bomb)

	if bomb.FrameCount == 1 then
		NULL_BOMBS:ProperBombInit(bomb, player)
		--Add skin laterrr
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
	end
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, NULL_BOMBS.BombUpdate)