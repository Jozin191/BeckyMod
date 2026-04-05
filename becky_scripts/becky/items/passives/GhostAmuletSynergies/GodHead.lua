local mod = BeckyMod
local GHOST_BALL = Isaac.GetEntityVariantByName("Ghost Ball")

---@param fam EntityFamiliar
---@param tearParams TearParams
BeckyMod:AddCallback(BeckyMod.Callbacks.GHOST_UPDATE_HELPER, function(_, fam, tearParams)
    local ghostData = fam:GetData()
    local tearRef = ghostData.GodHeadAura and ghostData.GodHeadAura.Ref 
    local exists = tearRef and tearRef:Exists()
    local glowing = (tearParams.TearFlags & TearFlags.TEAR_GLOW == TearFlags.TEAR_GLOW)
    if not exists and glowing then 
        local tear = BeckyMod.Game:Spawn(EntityType.ENTITY_TEAR, 0, fam.Position, Vector.Zero, fam, 0, math.max(Random(), 1)):ToTear() ---@cast tear EntityTear
        ghostData.GodHeadAura = EntityPtr(tear)
        tear:SetInitSound(SoundEffect.SOUND_NULL)
        tear:AddTearFlags(TearFlags.TEAR_GLOW | TearFlags.TEAR_PIERCING | TearFlags.TEAR_SPECTRAL)
        tear.Color = Color(1, 1, 1, 0)
        tear:Update()
    elseif exists  then
        if not glowing then
            if exists then
                tearRef:Remove()
            end
            ghostData.GodHeadAura = nil
        elseif tearRef then
            local tearRef = tearRef:ToTear()
            tearRef.Velocity = fam.Velocity-- Setting the velocity adds automatic interpolation
            tearRef.Position = fam.Position-fam.Velocity*.33-- A little too much interoplation so just push the tear slightly back lol
            tearRef.Scale = fam.SpriteScale:Length()/1.33
            tearRef.Height = -5
            tearRef.FallingSpeed = 0
        end
    end
end)
