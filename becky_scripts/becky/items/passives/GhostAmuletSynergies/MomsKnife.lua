local GHOST_BALL_VAR = Isaac.GetEntityVariantByName("Ghost Ball")
local KNIFE_EFFECT = Isaac.GetEntityVariantByName("Knife (Ghost Ball Synergy)")
local KNIFE_RANDIUS = Vector(-30,0)
local GHOST_BALL_DMG = 1.25
local ROTATION_SPEED = 3.5
local RAD = 360 / ROTATION_SPEED

BeckyMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
    local player = fam.Player
    if not player or not player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE) then return end
    
    local ghostData = fam:GetData()
    local knifeEnt = ghostData.KnifeEnt

    if not (knifeEnt and knifeEnt:Exists()) then
        local effect = Isaac.Spawn(1000, KNIFE_EFFECT, 0, fam.Position, Vector.Zero, fam):ToEffect()
        effect.Parent = fam
        effect:FollowParent(fam)
        effect.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
        effect.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
        ghostData.KnifeEnt = effect
    end

end, GHOST_BALL_VAR)


BeckyMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, eff)
    if eff.Parent == nil then return end
    local fam = eff.Parent:ToFamiliar()
    if fam == nil then return end
    local player = fam.Player
    if player == nil then return end

    eff.Size = 12
    local angle = eff.FrameCount % RAD * -ROTATION_SPEED
    eff.ParentOffset = KNIFE_RANDIUS:Rotated(angle) * fam.SizeMulti
    eff.SpriteRotation = angle

    --BeckyMod.Item.GHOST_AMULET:GetGhostDamage(player)
    local entRef = EntityRef(player)
    for _, ent in ipairs(Isaac.FindInRadius(eff.Position, eff.Size, EntityPartition.ENEMY)) do
        ent:TakeDamage(player.Damage*2, 0, entRef, 0)
    end
end, KNIFE_EFFECT)