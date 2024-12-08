local BeckyMod = RegisterMod("Becky (Character Mod)", 1)
local BeckyGhostItem = Isaac.GetItemIdByName("Becky Ghost")
local BeckyGhostFamiliar = Isaac.GetEntityTypeByName("Becky Ghost")
local esBecky = Isaac.GetPlayerTypeByName("Becky", false)
local hairCostume = Isaac.GetCostumeIdByPath("gfx/characters/becky_hair.anm2")
function BeckyMod:GiveCostumesOnInit(player)
    if player:GetPlayerType() ~= esBecky then
        return
    end

    player:AddNullCostume(hairCostume)
end

function BeckyMod:OnPickup(player)
    local familiar = player:AddFamiliar(BeckyGhostFamiliar, player.Position, player)
    familiar:GetSprite():Play("Idle", true) 
end

function BeckyMod:OnUpdate(familiar)
    local player = Isaac.GetPlayer(0) 

    familiar:FollowParent(player)

    if familiar.Position.Y < player.Position.Y then
        familiar:GetSprite():Play("IdleDown", true) 
    elseif familiar.Position.Y > player.Position.Y then
        familiar:GetSprite():Play("IdleUp", true) 
    else
        if familiar.Position.X < player.Position.X then
            familiar:GetSprite():Play("Idle", true) 
            familiar.Sprite.FlipX = false 
        else
            familiar:GetSprite():Play("Idle", true) 
            familiar.Sprite.FlipX = true 
        end
    end

    familiar:GetSprite():Update()
end

function BeckyMod:OnFamiliarInit(familiar)
    familiar:GetSprite():Load("gfx/familiar/becky_ghost.anm2", true) 
    familiar:GetSprite():Play("Idle", true) 
end

function BeckyMod:Init()
    BeckyMod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, BeckyMod.OnPickup)
    BeckyMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, BeckyMod.OnFamiliarInit)
    BeckyMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, BeckyMod.OnUpdate)
    BeckyMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, BeckyMod.GiveCostumesOnInit)
	end

BeckyMod:Init()