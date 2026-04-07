---@param fam EntityFamiliar
---@param enemy EntityNPC
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function(_, fam, enemy)
    local player = fam.Player
    if not player then return end
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_EPIC_FETUS) then return end

    local ghostdata = fam:GetData()
    ghostdata.ROCKETCD = ghostdata.ROCKETCD or 0
  
    if ghostdata.ROCKETCD <= 0 then
        ghostdata.ROCKETCD = 180

        local rocket = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SMALL_ROCKET, 0, player.Position, Vector.Zero,player):ToEffect()
        rocket.State = 1
        local target = (enemy.Position+fam.Position)/2 -- midway point
        local dist = (target - player.Position)
        rocket:Update()
        rocket.Velocity = (dist) * math.cos(math.rad(45)) * (1 / 7)
        rocket.CollisionDamage = 0
        rocket.m_Height = 0
        
        SFXManager():Play(SoundEffect.SOUND_FETUS_FEET)
        SFXManager():Play(SoundEffect.SOUND_ROCKET_LAUNCH_SHORT, .8)
    end
end)

---@param fam EntityFamiliar
BeckyMod:AddCallback(BeckyMod.Callbacks.GHOST_UPDATE_HELPER, function(_, fam)
    local player = fam.Player
    if not player then return end
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_EPIC_FETUS) then return end

    local ghostdata = fam:GetData()
    ghostdata.ROCKETCD = ghostdata.ROCKETCD or 0
    ghostdata.ROCKETCD = math.max(ghostdata.ROCKETCD -1, 0)
end)


local target = Sprite("gfx/1000.030_dr. fetus target.anm2", true)
target:Play("Idle")
target.Color=Color(1,.1,.1, .5)
target.Scale = Vector(.5,.5)
---@param fam EntityFamiliar
---@param offset Vector
BeckyMod:AddCallback(BeckyMod.Callbacks.GHOST_RENDER_HELPER, function(_, fam, offset)
    local player = fam.Player
    if not player then return end
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_EPIC_FETUS) then return end

    local ghostdata = fam:GetData()
    local ghostsprite = fam:GetSprite()
    
    
    local cd = ghostdata.ROCKETCD or 1
    if cd <= 0 then
        local anim = ghostsprite:GetLayerFrameData(0)
        target.Scale = anim:GetScale()*.5
        target:Render(Isaac.WorldToRenderPosition(fam.Position+Vector(0,-15*anim:GetScale().Y)+anim:GetPos())+offset)
    end
end)