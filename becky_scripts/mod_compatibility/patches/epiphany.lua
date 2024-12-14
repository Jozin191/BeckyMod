local loader = BeckyMod.PatchesLoader

local function EpiphanyPatch()
    local oldCallback = BeckyMod.areThereCurses

    function BeckyMod:areThereCurses()
        --BeckyMod:DebugLog('okay')

        local someoneHasMothersShadow = false

        BeckyMod:ForEachPlayer(function(player)
            if player:HasCollectible(Epiphany.Item.MOTHERS_SHADOW.ID) then
                someoneHasMothersShadow = true
            end
        end)

        local someoneHasBlackCandle = false

        BeckyMod:ForEachPlayer(function(player)
            if player:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE) then
                someoneHasBlackCandle = true
            end
        end)

        return oldCallback(self) or (someoneHasMothersShadow and not someoneHasBlackCandle)
    end
end

loader:RegisterPatch("Epiphany", EpiphanyPatch)