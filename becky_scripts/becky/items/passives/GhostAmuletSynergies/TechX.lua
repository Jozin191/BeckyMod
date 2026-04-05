local mod = BeckyMod
local GHOST_BALL = Isaac.GetEntityVariantByName("Ghost Ball")

---@param fam EntityFamiliar
---@param tearParams TearParams
BeckyMod:AddCallback(BeckyMod.Callbacks.GHOST_UPDATE_HELPER, function(_, fam, tearParams)
    local ghostData = fam:GetData()
    local laserRef = ghostData.TechXRing and ghostData.TechXRing.Ref 
    local exists = laserRef and laserRef:Exists()
    local teching = fam.Player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X)
    if not exists and teching then 
        local laser = BeckyMod.Game:Spawn(EntityType.ENTITY_LASER, LaserVariant.THIN_RED, fam.Position, Vector.Zero, fam, LaserSubType.LASER_SUBTYPE_RING_FOLLOW_PARENT, 1):ToLaser()
        laser.Parent = fam
        laser.TearFlags = tearParams.TearFlags
        laser.Radius = fam.SpriteScale:Length()*40
        ghostData.TechXRing = EntityPtr(laser)
        -- hack to stop the annoying laser sound every room
        laser:Update()
        SFXManager():Stop(SoundEffect.SOUND_REDLIGHTNING_ZAP)
    elseif exists  then
        if not teching then
            if exists then
                laserRef:Remove()
            end
            ghostData.TechXRing = nil
        elseif teching then
            local laserRef = laserRef:ToLaser()
            laserRef.Radius = fam.SpriteScale:Length()*40
            laserRef:SetScale(fam.SpriteScale:Length()/1.5)
            laserRef.CollisionDamage = tearParams.TearDamage / 2
        end
    end
end)

--Thank you kotry. I just used most of your godhead code. You are the goat!!