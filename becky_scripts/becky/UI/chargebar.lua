local chargeBar = {
    fps = 30,
    charge = 0,
    maxCharge = 0,
    released = false,
    chargeState = 0,
    chargingFrames = 101,
    anm2File = "gfx/chargebar_beckyghost.anm2",
    invertChargeSprites = false,
    target = nil,
    targetOffset = Vector.Zero,
    initCallbacks = true
}

local ChargeBarState = {
    INACTIVE = 0,
    CHARGING = 1,
    CHARGED = 2,
    DISAPPEARING = 3
}

function chargeBar.chargeBarRender(_)
    if not Options.ChargeBars or not chargeBar.target or ((REPENTOGON and RoomTransition.IsRenderingBossIntro()) or (not REPENTOGON and Game():IsPaused() and not Game():IsPauseMenuOpen())) then return end
    local inv = 0
    if chargeBar.invertChargeSprites then inv = -1 end

    if not chargeBar.sprite then
        chargeBar.sprite = Sprite()
        chargeBar.sprite:Load(chargeBar.anm2File, true)
    end

    if ChargeBarState.INACTIVE ~= chargeBar.chargeState then
        if chargeBar.released then
            chargeBar.released = false
            chargeBar.chargeState = ChargeBarState.DISAPPEARING
            chargeBar.sprite:Play("Disappear", false)
        end

        if Isaac.GetFrameCount() % math.floor((60 / chargeBar.fps) * chargeBar.sprite.PlaybackSpeed) == 0 then
            if ChargeBarState.DISAPPEARING == chargeBar.chargeState then
                if chargeBar.sprite:IsFinished("Disappear") then
                    chargeBar.chargeState = ChargeBarState.INACTIVE
                elseif not chargeBar.sprite:IsPlaying("Disappear") then
                    chargeBar.sprite:Play("Disappear", false)
                end
            elseif chargeBar.sprite:IsFinished("StartCharged") then
                chargeBar.sprite:Play("Charged", true)
            elseif chargeBar.sprite:IsFinished() and not chargeBar.sprite:IsFinished("Charged") then
                chargeBar.sprite:Play("Charging", true)
            end

            if ChargeBarState.CHARGING == chargeBar.chargeState then
                chargeBar.sprite:SetFrame(math.floor(chargeBar.chargingFrames * (1 - (chargeBar.charge / chargeBar.maxCharge))))

                if chargeBar.charge == 0 then
                    chargeBar.chargeState = ChargeBarState.CHARGED
                    chargeBar.sprite:Play("StartCharged", true)
                end
            else
                chargeBar.sprite:Update()
            end
        end
    
        chargeBar.sprite:Render(Isaac.WorldToScreen(chargeBar.target.Position) + chargeBar.targetOffset)
    elseif chargeBar.charge ~= chargeBar.maxCharge then
        chargeBar.chargeState = ChargeBarState.CHARGING
    end
end

function chargeBar.chargeBarInit(_)
    chargeBar.released = true
    chargeBar.chargeState = ChargeBarState.INACTIVE
    chargeBar.target = nil
end

function chargeBar.alreadyHasChargeBar(player)
    local returnBool = false
    local chargebarItems = {
        CollectibleType.COLLECTIBLE_BRIMSTONE,
        CollectibleType.COLLECTIBLE_MOMS_KNIFE,
        CollectibleType.COLLECTIBLE_MONSTROS_LUNG,
        CollectibleType.COLLECTIBLE_TECH_X,
        CollectibleType.COLLECTIBLE_C_SECTION
    }
    local chargebarPlayers = {
        PlayerType.PLAYER_AZAZEL,
        PlayerType.PLAYER_AZAZEL_B
    }

    for i, item in pairs(chargebarItems) do
        local itemNum = player:GetEffects():GetCollectibleEffectNum(item) + player:GetCollectibleNum(item)
        if itemNum > 0 then
            returnBool = true
        end
    end

    for i, playerType in pairs(chargebarPlayers) do
        if playerType == player:GetPlayerType() then
            returnBool = true
        end
    end

    if not player:CanShoot() then
        returnBool = false
    end

    return returnBool
end

function chargeBar.getAmountOfChargeBarItems(player) -- for offsetting with existing chargebars because forgotten has bone chargebar and becky ghost has different chargerate
    local returnNum = 0
    local chargebarItems = {
    }
    local chargebarPlayers = {
        PlayerType.PLAYER_THEFORGOTTEN,
        PlayerType.PLAYER_THEFORGOTTEN_B
    }

    for i, item in pairs(chargebarItems) do
        local itemNum = player:GetEffects():GetCollectibleEffectNum(item) + player:GetCollectibleNum(item)
        if itemNum > 0 then
            returnNum = returnNum + 1
        end
    end

    for i, playerType in pairs(chargebarPlayers) do
        if playerType == player:GetPlayerType() then
            returnNum = returnNum + 1
        end
    end

    if not player:CanShoot() then
        returnNum = 0
    end

    -- add repentogon weapon solution for bone weapon character case

    return returnNum
end

return chargeBar