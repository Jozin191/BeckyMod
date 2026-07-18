local GHOST_BALL = Isaac.GetEntityVariantByName("Ghost Ball")
local Game = Game()

local worms = {
    [TearFlags.TEAR_WIGGLE] = {
        id = TrinketType.TRINKET_WIGGLE_WORM,
        func = function (player, fam, time, power)
            local function calc(time)
                return player:GetLastDirection():Rotated(90)*math.sin(time)*(35)*power
            end
            fam.Position = fam.Position + calc(time/4) - (calc((time-1)/4))
        end
    },
    [TearFlags.TEAR_SPIRAL] = {
        id = TrinketType.TRINKET_RING_WORM,
        func = function (player, fam, time, power)
            local function calc(time)
                return player:GetLastDirection()*math.sin(time)*(50)*power + player:GetLastDirection():Rotated(90)*math.cos(time)*(25)*power
            end
            fam.Position = fam.Position + calc(time/3) - (calc((time-1)/3))
        end
    },
    [TearFlags.TEAR_BIG_SPIRAL] = {
        id = TrinketType.TRINKET_OUROBOROS_WORM,
        func = function (player, fam, time, power)
            local function calc(time)
                return player:GetLastDirection()*math.sin(time)*(130)*power + player:GetLastDirection():Rotated(90)*math.cos(time)*(95)*power
            end
            fam.Position = fam.Position + calc(time/2.5) - (calc((time-1)/2.5))
        end
    },
    [TearFlags.TEAR_SQUARE] = {
        id = TrinketType.TRINKET_HOOK_WORM,
        func = function (player, fam, time, power)
            local function calc(time)
                local durr = math.sin(time%(math.pi/2))
                if math.sin(time*2) > 0 then
                    durr = -durr
                end
                return player:GetLastDirection():Rotated(90)*(durr)*(40)*power
            end
            fam.Position = fam.Position+calc(time/8) - (calc((time-1)/8))
        end
    },
    [TearFlags.TEAR_TURN_HORIZONTAL] = {
        id = TrinketType.TRINKET_BRAIN_WORM,
        ---@param player EntityPlayer
        ---@param fam EntityFamiliar
        func = function (player, fam, time, power) -- i dont really know wtf i was doing here lol
            local datas = BeckyMod.GetEntData(fam)
            if fam.FrameCount % 2 == 0 and datas.BrainWormTimer <= 0 then
                local enemies = Isaac.FindInRadius(fam.Position, 120, EntityPartition.ENEMY)
                for i, v in ipairs(enemies) do
                    local npc = v and v:ToNPC()
                    
                    if npc and fam.Position:Distance(npc.Position) >= 30 then
                        local shoot = player:GetLastDirection():Normalized()
                        if fam.Velocity:Length() >= 5 then
                            shoot = fam.Velocity:Normalized()
                        end
                        local norm = (npc.Position - fam.Position):Normalized()
                        local dunno = math.abs((norm:GetAngleDegrees()-shoot:GetAngleDegrees()))
                        local final = dunno
                        if dunno > 180 then
                            final = dunno-180
                        end
                        if final >= 82 and final <= 98 then
                            datas.BrainWormTimer = math.floor(40/power)
                            fam.Velocity = fam.Velocity/4 + (norm*(12+(npc.Position - fam.Position):Length()/3.5))
                            break
                        end
                    end
                end 
            end
            
        end
    },
}
---@param player EntityPlayer
---@param tearFlags any
---@param tearFlag TearFlags
local function GetWormStrength(player, tearFlags, tearFlag)
    local trinket = worms[tearFlag]
    if trinket and tearFlags & tearFlag == tearFlag then
        return math.max(player:GetTrinketMultiplier(trinket.id), 1)
    end
end

---@param fam EntityFamiliar
---@param tearParams TearParams
BeckyMod:AddCallback(BeckyMod.Callbacks.GHOST_UPDATE_HELPER, function(_, fam, tearParams)
    local data = BeckyMod.GetEntData(fam)
    data.WormTimer = data.WormTimer or 0
    data.BrainWormTimer = data.BrainWormTimer or 0
    local player = fam.Player
    local tearFlags = tearParams.TearFlags
    if fam.State > 0 then
        for tearFlag, juicey in pairs(worms) do
            local strength = GetWormStrength(player, tearFlags, tearFlag)
            if strength then
                juicey.func(player, fam, data.WormTimer, strength)
            end
        end
        data.WormTimer = data.WormTimer+1+fam.Velocity:Length()/50
    end
    data.BrainWormTimer = math.max(data.BrainWormTimer - 1, 0)
end)