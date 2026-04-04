local ALARM_CLOCK = {}

BeckyMod.Trinket.ALARM_CLOCK = ALARM_CLOCK

ALARM_CLOCK.ID = Isaac.GetTrinketIdByName("Alarm Clock")


function ALARM_CLOCK:PostRoomClear()
    local mult = PlayerManager.GetTotalTrinketMultiplier(ALARM_CLOCK.ID)
    if mult <= 0 then return end
    local time = math.floor( (1-(19/20)^mult) *100 ) *30
    BeckyMod.Game.TimeCounter = BeckyMod.Game.TimeCounter - time
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_ROOM_TRIGGER_CLEAR, ALARM_CLOCK.PostRoomClear)