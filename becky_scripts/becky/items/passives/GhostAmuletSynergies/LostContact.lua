local GHOST_BALL = Isaac.GetEntityVariantByName("Ghost Ball")
local Game = Game()
---@param fam EntityFamiliar
---@param tearParams TearParams
BeckyMod:AddCallback(BeckyMod.Callbacks.GHOST_UPDATE_HELPER, function(_, fam, tearParams)
    local player = fam.Player
    if (tearParams.TearFlags & TearFlags.TEAR_SHIELDED == TearFlags.TEAR_SHIELDED) then
        local bounce = (tearParams.TearFlags & TearFlags.TEAR_BOUNCE == TearFlags.TEAR_BOUNCE)
        for _, proj in ipairs(Isaac.FindInCapsule(fam:GetCollisionCapsule(), EntityPartition.BULLET)) do
            local proj = proj:ToProjectile()
            if proj and not (proj.ProjectileFlags & ProjectileFlags.CANT_HIT_PLAYER == ProjectileFlags.CANT_HIT_PLAYER)  then
                if bounce then --  rubber cement synergy: causes projectiles to bounce off and deal damage to enemies
                    SFXManager():Play(SoundEffect.SOUND_SLIPPED_RIB_DEFLECT)
                    local angle = (proj.Position-fam.Position):GetAngleDegrees()
                    proj:Deflect(proj.Velocity:Rotated(angle-proj.Velocity:GetAngleDegrees()))
                    proj.Velocity = proj.Velocity*1.3
                    proj.Position = fam.Position+Vector.FromAngle(angle)*(proj.Size+fam.Size)
                else
                    fam.Velocity =  fam.Velocity +(fam.Position-proj.Position):Normalized()*proj.Velocity:Length()/4
                    proj:Die()
                end
            end

        end
    end

end)