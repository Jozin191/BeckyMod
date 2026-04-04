-- noop
local GHOST_BALL = Isaac.GetEntityVariantByName("Ghost Ball")
local Game = Game()
---@param fam EntityFamiliar
---@param tearParams TearParams
BeckyMod:AddCallback(BeckyMod.Callbacks.GHOST_UPDATE_HELPER, function(_, fam, tearParams)
    local player = fam.Player
    if player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_LOST_CONTACT):RandomFloat()>.5 and (tearParams.TearFlags & TearFlags.TEAR_SHIELDED == TearFlags.TEAR_SHIELDED) then
        local bounce = (tearParams.TearFlags & TearFlags.TEAR_BOUNCE == TearFlags.TEAR_BOUNCE)
        for _, proj in ipairs(Isaac.FindInCapsule(fam:GetCollisionCapsule(), EntityPartition.BULLET)) do
            local proj = proj:ToProjectile()
            if proj then
                if bounce then
                    SFXManager():Play(SoundEffect.SOUND_RUBBER_CEMENT, 1, 2, false, 1.2)
                    local angle = (proj.Position-fam.Position):GetAngleDegrees()
                    proj:Deflect(proj.Velocity:Rotated(angle-proj.Velocity:GetAngleDegrees()))
                    proj.Position = fam.Position+Vector.FromAngle(angle)*(proj.Size+fam.Size)
                else
                    proj:Die()
                end
            end

        end
    end

end)