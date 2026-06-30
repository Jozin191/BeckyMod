local Glow = Sprite("gfx/lightgradient.anm2", true)
Glow:SetAnimation("Default")
Glow:SetFrame(1)
local BlendMode = Glow:GetLayer(0):GetBlendMode()
BlendMode.RGBSourceFactor = BlendFactor.DST_COLOR
BlendMode.RGBDestinationFactor = BlendFactor.DST_ALPHA
BlendMode.AlphaSourceFactor = BlendFactor.DST_COLOR
BlendMode.AlphaDestinationFactor = BlendFactor.ONE_MINUS_SRC_ALPHA
---@param familiar EntityFamiliar
---@param offset Vector
BeckyMod:AddCallback(BeckyMod.Callbacks.GHOST_RENDER_HELPER, function(_, familiar, offset)
    local player = familiar.Player
    local ghostData = BeckyMod.GetEntData(familiar)
    if true then
        local info = ghostData.DeadEyeMulti
        if info and info.Multi > 0 then
            local position = Isaac.WorldToRenderPosition(familiar.Position)+offset
            Glow.Color = Color(1,0,0,2*info.Multi)
            Glow.Scale = familiar.SpriteScale*.2
            Glow:Render(position)
            
            Glow.Color = Color(1,0,0,1*info.Multi)
            Glow.Scale = familiar.SpriteScale*info.Multi*.5
            Glow:Render(position)
        end
    end
end)
---@param familiar EntityFamiliar
BeckyMod:AddCallback(BeckyMod.Callbacks.GHOST_UPDATE_HELPER, function(_, familiar)
    local player = familiar.Player
    local ghostData = BeckyMod.GetEntData(familiar)

    local info = ghostData.DeadEyeMulti or {
            Multi = 0,
            Interval = 0
        }
    if info.Multi > 0 then
        info.Interval = info.Interval - (1/30)
        if info.Interval <= 0 then
            info.Multi = math.max(info.Multi-(1/15), 0)
        end
    end
    ghostData.DeadEyeMulti = info
end)
---@param familiar EntityFamiliar
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function(_, familiar)
    local player = familiar.Player
    local ghostData = BeckyMod.GetEntData(familiar)
    local info = ghostData.DeadEyeMulti
    if info and player:HasCollectible(CollectibleType.COLLECTIBLE_DEAD_EYE) then
        info.Multi = math.min(info.Multi + .075, 1)
        info.Interval = 2
    end
end)