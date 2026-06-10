
local SPELL_COST = 10
local DASH_DIS = Vector(40 *4,0)
local game = BeckyMod.Game

local function fun(player)
    local pos = player.Position
    local moveDir = player.Velocity
    if moveDir:Length() < 0.16 then return true end

    local room = game:GetRoom()
    local _, newPos = room:CheckLine(pos, pos + DASH_DIS:Rotated(moveDir:GetAngleDegrees()), (player.CanFly and 3 or 0))
    local x = newPos.X % 40
	local y = newPos.Y % 40
	if x >= 20 then
		newPos.X = newPos.X + (40- x)
	else newPos.X = newPos.X - x
	end
	if y >= 20 then
		newPos.Y = newPos.Y + (40- y)
	else newPos.Y = newPos.Y - y
	end
    
    local dis = newPos:Distance(pos)
    if dis > 20 then
        local trailAmount = (dis *1.1) // 40
        for i=1, trailAmount do
            player:CreateAfterimage(12, BeckyMod:Lerp(pos, newPos, i / trailAmount))
            
        end
        player.Position = newPos
        player.Velocity = player.Velocity *1.5
        if player:GetDamageCooldown() < 30 then
            --player:ResetDamageCooldown()
            player:SetMinDamageCooldown(30)
        end

        --local damageEnemiesList = {}
        --local dmg = 3.5
        --local ref = EntityRef(player)
        --for i=1, trailAmount*2 do
        --    for _, e in ipairs(Isaac.FindInRadius( BeckyMod:Lerp(pos, newPos, i / trailAmount), 10, EntityPartition.ENEMY)) do
        --        local ptr = GetPtrHash(e)
        --        if not damageEnemiesList[ptr] then
        --            if not e:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) and e:IsVulnerableEnemy() then
        --                e:TakeDamage(dmg, 0, ref, 0)
        --            end
        --            damageEnemiesList[ptr] = true
        --        end
        --    end
        --end

    else return true
    end
end

local function canSelectFun(player, manaLeft)
    return manaLeft >= SPELL_COST
end

return {
    BeckyMod.Spells.SpellType.DASH,
    Func = fun,
    CanSelect = canSelectFun,
    Cost = SPELL_COST,
    Frame = 8
}