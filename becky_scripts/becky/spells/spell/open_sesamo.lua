local SPELL_COST = 35
local JOHN_ANGLE= Vector(1,0)


local function fun(player)
    local data = BeckyMod.GetEntData(player)
    if data.MagicStaff_SelectSpellDir == nil then
        data.MagicStaff_SelectSpellDir = { Type = BeckyMod.Spells.SpellType.OPEN_SESAMO }
        return
    end
    local angle = -180 + data.MagicStaff_SelectSpellDir.Dir * 90

    local laser = player:FireTechLaser(player.Position, LaserOffset.LASER_TECH1_OFFSET, JOHN_ANGLE:Rotated(angle), false, true, player, 1)
    laser.CollisionDamage = 24
    laser.GridHit = false
    laser.TearFlags = BitSet128(0,0)
    laser.Timeout = 5
    laser.Color = Color.LaserAlmond

    laser:Update()
    --laser:GetData().OpenSesamo_LaserInfo = { Angle = angle, }
    local hitPos = laser.EndPoint - (JOHN_ANGLE * 20):Rotated(angle)
    local room = BeckyMod.Game:GetRoom()
    local gridEnt = room:GetGridEntityFromPos(hitPos)
    if gridEnt and gridEnt:ToDoor() then
        local doorEnt = gridEnt:ToDoor()
        --print((doorEnt and doorEnt:GetType()) or -1)
        if doorEnt:IsLocked() or not doorEnt:IsOpen() then
            doorEnt:SetLocked(false)
            doorEnt:Open()
        end
    end

    data.MagicStaff_SelectSpellDir = nil
end

local function canSelectFun(player, manaLeft)
    return manaLeft >= SPELL_COST
end

return {
    BeckyMod.Spells.SpellType.OPEN_SESAMO,
    Func = fun,
    CanSelect = canSelectFun,
    Cost = SPELL_COST,
    Frame = 12
}