local SPELL_COST = 100
local OgSound = -1
local SoundMult = 0
local PlayingNuke = false

local NukeFlash = Sprite("gfx/beckyMagic/nuke.anm2", true)


BeckyMod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    if BeckyMod.Game:IsPaused() then return end
    if PlayingNuke then
        NukeFlash:Update()
        if NukeFlash:IsFinished() then PlayingNuke = false end
    end
    if OgSound > 0 then
        if SoundMult >= 1 then
            Options.SFXVolume =OgSound
            OgSound = -1
        else
            Options.SFXVolume = BeckyMod:Lerp(0, OgSound, SoundMult)
            SoundMult = SoundMult + 0.0055555555556
        end
    end
end)

BeckyMod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    if not PlayingNuke then return end
    NukeFlash:Render(Vector.Zero)
end)


BeckyMod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function()
    if OgSound >0 then
        Options.SFXVolume =OgSound
        OgSound = -1
    end
    PlayingNuke = false
end)


local function DamageAllPlayers(player)
    player:TakeDamage(12, DamageFlag.DAMAGE_INVINCIBLE, EntityRef(player), 30)
end

local function fun(player)
    OgSound = Options.SFXVolume
    Options.SFXVolume = 0
    SoundMult = 0

    local room = BeckyMod.Game:GetRoom()
    for _, ent in ipairs(Isaac.GetRoomEntities()) do
        if ent:ToNPC() then
            if ent:IsBoss() then
                ent:TakeDamage(660, DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(ent), 0)
            else
                ent:Remove()
            end
        end
    end
    local playerRef = EntityRef(player)
    for idx =0, room:GetGridSize()-1 do
        local gridEnt = room:GetGridEntity(idx)
        if gridEnt then
            gridEnt:DestroyWithSource(true, playerRef)
            gridEnt:HurtWithSource(9999999, playerRef)
        end
    end

    BeckyMod:ForEachPlayer(DamageAllPlayers)

    NukeFlash:Play("Nuke", true)
    PlayingNuke = true
end

local function canSelectFun(player, manaLeft)
    return manaLeft >= SPELL_COST
end

return {
    BeckyMod.Spells.SpellType.NUKE,
    Func = fun,
    CanSelect = canSelectFun,
    Cost = SPELL_COST,
    Frame = 7
}
