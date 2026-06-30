
-- wish you luck if you are looking how the hell this is working

local BECKY_B = {}

BECKY_B.PLAYERTYPE = Isaac.GetPlayerTypeByName("Becky", true)

BECKY_B.HAIR_COSTUME = Isaac.GetCostumeIdByPath("gfx/characters/becky_b_hair.anm2")
BECKY_B.BODY_COSTUME = Isaac.GetCostumeIdByPath("gfx/characters/becky_b_scarf.anm2")


local taintedBeckysWandAnim = "gfx/becky_magic_staff.anm2"
BECKY_B.StaffFireSprite = Sprite(taintedBeckysWandAnim, true)
BECKY_B.ManaBarSprite = Sprite("gfx/ui/taintedBecky/mana_bar.anm2", true)

BECKY_B.ManaTearCost = 10
BECKY_B.ManaRegenBuffZone = 15
BECKY_B.SPIRIT_SWORD_SYNERGY = Isaac.GetNullItemIdByName("Spirit Sword Stat up")

local game = BeckyMod.Game
local sfx = BeckyMod.SFX

BeckyMod.Character.BECKY_B = BECKY_B

local BASE_TEAR_DPS = 30 /11 /2
local MAX_TEARS_DPS_C_SECTION = 30 / (0.1*3+1)/2
local CURSE_EYE_COOLDOWN = 0
local DirToVector = {
    [Direction.NO_DIRECTION] = Vector(0,-1),
    [Direction.LEFT] = Vector(-1,0),
    [Direction.RIGHT] = Vector(1,0),
    [Direction.UP] = Vector(0,1),
    [Direction.DOWN] = Vector(0,-1),
}

BECKY_B.FamiliarWhiteList = {
    [FamiliarVariant.INCUBUS] = true,
    [FamiliarVariant.TWISTED_BABY] = true,
    [FamiliarVariant.UMBILICAL_BABY] = true,
    [FamiliarVariant.CAINS_OTHER_EYE] = true,
    [FamiliarVariant.BLOOD_BABY] = true,
}

BECKY_B.ValidBoneClubs = {
    [KnifeVariant.BONE_CLUB] = true,
    [KnifeVariant.BONE_SCYTHE] = true,
}


BECKY_B.BlockItems = {
    MonstrosLung = Isaac.GetNullItemIdByName("Monstro's Lung Blocker"),
    ChocolateMilk = Isaac.GetNullItemIdByName("Chocolate Milk Blocker"),
    --Neptunus = Isaac.GetNullItemIdByName("Neptunus Blocker"),
    EpicFetus = Isaac.GetNullItemIdByName("Epic Fetus Blocker"),
    DrFetus = Isaac.GetNullItemIdByName("Dr Fetus Blocker"),
}

local ITEMS_TO = {
    Blocker = {
        [CollectibleType.COLLECTIBLE_MONSTROS_LUNG] = BECKY_B.BlockItems.MonstrosLung,
        [CollectibleType.COLLECTIBLE_CHOCOLATE_MILK] = BECKY_B.BlockItems.ChocolateMilk,
        --[CollectibleType.COLLECTIBLE_NEPTUNUS] = BECKY_B.BlockItems.Neptunus,
        [CollectibleType.COLLECTIBLE_EPIC_FETUS] = BECKY_B.BlockItems.EpicFetus,
        [CollectibleType.COLLECTIBLE_DR_FETUS] = BECKY_B.BlockItems.DrFetus,
    },
    Normal = {
        [BECKY_B.BlockItems.MonstrosLung] = CollectibleType.COLLECTIBLE_MONSTROS_LUNG,
        [BECKY_B.BlockItems.ChocolateMilk] = CollectibleType.COLLECTIBLE_CHOCOLATE_MILK,
        --[BECKY_B.BlockItems.Neptunus] = CollectibleType.COLLECTIBLE_NEPTUNUS,
        [BECKY_B.BlockItems.EpicFetus] = CollectibleType.COLLECTIBLE_EPIC_FETUS,
        [BECKY_B.BlockItems.DrFetus] = CollectibleType.COLLECTIBLE_DR_FETUS,
    }
}

local CAN_RENDER_CHARGE_TO_FAMILIARS = {
    FamiliarVariant.INCUBUS,
    FamiliarVariant.TWISTED_BABY,
    FamiliarVariant.UMBILICAL_BABY,
    FamiliarVariant.CAINS_OTHER_EYE,
    FamiliarVariant.BLOOD_BABY,
}


local function GetBecky(entity)
    local player = BeckyMod:TryGetPlayer(entity, false)
    if player == nil or player:GetPlayerType() ~= BECKY_B.PLAYERTYPE then return end
    return player
end

local function IsKnifeSwinging(sp)
    return sp:IsPlaying("Swing") or sp:IsPlaying("Swing2") or sp:IsPlaying("SwingDown") or sp:IsPlaying("SwingDown2")
end


local function HasShouldDoCursedEye(player)
    local effects = player:GetEffects()
    if player:HasCollectible(CollectibleType.COLLECTIBLE_C_SECTION) or
    player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) or
    effects:HasNullEffect(BECKY_B.BlockItems.DrFetus) or
    effects:HasNullEffect(BECKY_B.BlockItems.EpicFetus) or
    effects:HasNullEffect(BECKY_B.BlockItems.MonstrosLung) or
    player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X) or
    player:HasCollectible(CollectibleType.COLLECTIBLE_NEPTUNUS) then
        return false
    end
    return player:HasCollectible(CollectibleType.COLLECTIBLE_CURSED_EYE)
end

local function HasShouldDoNeptunus(player)
    local effects = player:GetEffects()
    if player:HasCollectible(CollectibleType.COLLECTIBLE_C_SECTION) or
    player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) or
    effects:HasNullEffect(BECKY_B.BlockItems.DrFetus) or
    effects:HasNullEffect(BECKY_B.BlockItems.EpicFetus) or
    effects:HasNullEffect(BECKY_B.BlockItems.MonstrosLung) or
    (player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X) and not player:HasCollectible(CollectibleType.COLLECTIBLE_HAEMOLACRIA)) or
    player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY) then
        return false
    end
    return player:HasCollectible(CollectibleType.COLLECTIBLE_NEPTUNUS)
end
local DoNeptunusCluster = function() print("didn't load") end

local function ShouldDoChocolateMilk(player)
    local effects = player:GetEffects()
    if player:HasCollectible(CollectibleType.COLLECTIBLE_C_SECTION) or
    effects:HasNullEffect(BECKY_B.BlockItems.DrFetus) or
    effects:HasNullEffect(BECKY_B.BlockItems.EpicFetus) then
        return false
    end
    return effects:HasNullEffect(BECKY_B.BlockItems.ChocolateMilk)
end

local function ShouldDoBrimstone(player)
    local effects = player:GetEffects()
    if player:HasCollectible(CollectibleType.COLLECTIBLE_C_SECTION) or
    player:HasCollectible(CollectibleType.COLLECTIBLE_HAEMOLACRIA) or
    player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X)or
    effects:HasNullEffect(BECKY_B.BlockItems.DrFetus) or
    effects:HasNullEffect(BECKY_B.BlockItems.EpicFetus) then
        return false
    end
    return player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE)
end

local function ShouldDoTechX(player)
    local effects = player:GetEffects()
    if player:HasCollectible(CollectibleType.COLLECTIBLE_C_SECTION) or
    effects:HasNullEffect(BECKY_B.BlockItems.DrFetus) or
    effects:HasNullEffect(BECKY_B.BlockItems.EpicFetus) then
        return false
    end
    return player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X)
end

local function ShouldDoMonstrosLung(player)
    local effects = player:GetEffects()
    if (not effects:HasNullEffect(BECKY_B.BlockItems.EpicFetus) and player:HasCollectible(CollectibleType.COLLECTIBLE_C_SECTION)) or
    player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) then
        return false
    end
    return effects:HasNullEffect(BECKY_B.BlockItems.MonstrosLung)
end


local function GetAimVector(owner, player)
    --local markTarget = player:GetMarkedTarget()

    if owner.Type == 3 and player:HasCollectible(CollectibleType.COLLECTIBLE_KING_BABY) then
        local kingBaby = BeckyMod.GetEntData(player).knownKingBaby

        if kingBaby == nil or not kingBaby:Exists() then
            local ptr = GetPtrHash(player)
            for _, e in pairs(Isaac.FindByType(3, FamiliarVariant.KING_BABY)) do
                local f = e:ToFamiliar()
                if f and f.Player and GetPtrHash(f.Player) == ptr then
                    if f.Parent == nil then
                        kingBaby = f
                        break
                    else
                        kingBaby = f
                    end
                end
            end
            BeckyMod.GetEntData(player).knownKingBaby = kingBaby
        end
        if kingBaby.Target then
            return (owner.Position - kingBaby.Target.Position):Normalized()
        end
    end

    if player:GetLastDirection():Length() == 0 then
        local movement = player:GetMovementJoystick()
        if movement:Length() == 0 then
            return DirToVector[1]
        end
        return movement
    --elseif markTarget then
    --    return (owner.Position - markTarget.Position):Normalized()
    end
    return player:GetLastDirection()
end

local function GetAimAngle(owner, player)
    return GetAimVector(owner, player):GetAngleDegrees()
end

local EPIPHORA_TIME_MULT = (30 *6)
local EPIPHORA_FRAME_MULT = 1/EPIPHORA_TIME_MULT
local function BeckyFire(entShooting, player, data, autofire)
    
    if ShouldDoMonstrosLung(player) then
        if player:GetEffects():HasNullEffect(BECKY_B.BlockItems.ChocolateMilk) then
            local minCharge = BeckyMod:InverseLerp(0.01, 30, BeckyMod:toTearsPerSecond(player.MaxFireDelay))
            local charge = data.MagicStaff_ChargeBar.Charge / data.MagicStaff_ChargeBar.MaxCharge
            
            if charge >= minCharge and charge > 0.12 then
                local chocoMult = BeckyMod:Lerp(0, 2, charge)
                if chocoMult < 0.1 then chocoMult = 0.1 end
                BECKY_B:FireWeapon(entShooting, player, {MonstroLung = true, ChocoMilk = chocoMult})
            end

            if autofire then data.MagicStaff_ChargeBar.Charge = 0 end
        elseif data.MagicStaff_ChargeBar.Charge == data.MagicStaff_ChargeBar.MaxCharge then
            BECKY_B:FireWeapon(entShooting, player, {MonstroLung = true})
            if autofire then data.MagicStaff_ChargeBar.Charge = 0 end
        end
    elseif ShouldDoChocolateMilk(player) then
        local minCharge = BeckyMod:InverseLerp(0.01, 30, BeckyMod:toTearsPerSecond(player.MaxFireDelay))
        local charge = data.MagicStaff_ChargeBar.Charge / data.MagicStaff_ChargeBar.MaxCharge
        if charge >= minCharge and charge > 0.075 then
            local chocoMult = BeckyMod:Lerp(0, 4, charge)
            if chocoMult < 0.1 then chocoMult = 0.1 end

            if HasShouldDoCursedEye(player) then
                local shots = 0
            
                if player:HasCollectible(CollectibleType.COLLECTIBLE_EPIPHORA) then
                    shots = math.floor(BeckyMod:Lerp(1, 5, charge* ( 1+ EPIPHORA_FRAME_MULT * player:GetEpiphoraCharge() )))
                else
                    shots = math.floor(BeckyMod:Lerp(0, 4, charge))
                end


                if shots > 0 then
                    data.MagicStaff_CursedEyeTears = {
                        Shots = shots,
                        Cooldown = CURSE_EYE_COOLDOWN,
                        FireData = {
                            ForceDir = GetAimVector(entShooting, player),
                            CursedEye = true,
                            ChocoMilk = chocoMult,
                        }
                    }
                end
                BECKY_B:FireWeapon(entShooting, player, {ChocoMilk = chocoMult})
            elseif ShouldDoTechX(player) then
                if data.MagicStaff_ChargeBar.Charge >= data.MagicStaff_ChargeBar.MaxCharge /7 then
                    BECKY_B:FireWeapon(entShooting, player, {ChocoMilk = chocoMult})
                end
            else
                BECKY_B:FireWeapon(entShooting, player, {ChocoMilk = chocoMult})
            end
            if autofire then data.MagicStaff_ChargeBar.Charge = 0 end
        end
    elseif ShouldDoTechX(player) then
        if data.MagicStaff_ChargeBar.Charge >= data.MagicStaff_ChargeBar.MaxCharge /7 then
            BECKY_B:FireWeapon(entShooting, player)
            if autofire then data.MagicStaff_ChargeBar.Charge = 0 end
        end
    elseif HasShouldDoCursedEye(player) then
        if data.MagicStaff_ChargeBar.Charge >= data.MagicStaff_ChargeBar.MaxCharge /5 then
            local shots = 0
            
            if player:HasCollectible(CollectibleType.COLLECTIBLE_EPIPHORA) then
                shots = math.floor(BeckyMod:Lerp(1, 5, data.MagicStaff_ChargeBar.Charge / data.MagicStaff_ChargeBar.MaxCharge* ( 1+ EPIPHORA_FRAME_MULT * player:GetEpiphoraCharge() )))
            else
                shots = math.floor(BeckyMod:Lerp(0, 4, data.MagicStaff_ChargeBar.Charge / data.MagicStaff_ChargeBar.MaxCharge))
            end

            if shots > 0 then
                data.MagicStaff_CursedEyeTears = {
                    Shots = shots,
                    Cooldown = CURSE_EYE_COOLDOWN,
                    FireData = {
                        ForceDir = GetAimVector(entShooting, player),
                        CursedEye = true,
                    }
                }
            end
            BECKY_B:FireWeapon(entShooting, player)
            
            if autofire then data.MagicStaff_ChargeBar.Charge = 0 end
        end
    elseif data.MagicStaff_ChargeBar.Charge == data.MagicStaff_ChargeBar.MaxCharge then
        BECKY_B:FireWeapon(entShooting, player)
        if autofire then data.MagicStaff_ChargeBar.Charge = 0 end
    end
    if not autofire then
        data.MagicStaff_ChargeBar.Charge = 0
    end
end



local function ProcessStaffSwing(entShooting, player)
    local data = BeckyMod.GetEntData(entShooting)
    --local save = BeckyMod:RunSave(player)
    if not player:IsExtraAnimationFinished() then return end
    local weapon
    if entShooting.Type == 1 then weapon = entShooting:GetWeapon(1)
    elseif entShooting.Type == 3 then weapon = entShooting:GetWeapon()
    end
    if weapon == nil then return end
    local knife = weapon:GetMainEntity() --data.MagicStaff_Ent
    knife = knife and knife:ToKnife()
    if knife == nil or not knife:Exists() then return end

    local aimVec = player:GetAimDirection()
    
    if not data.MagicStaff_ChargeBar then
        data.MagicStaff_ChargeBar = {
            Charge = 0,
            MaxCharge = 30, -- 1 seconds
            Sprite = Sprite("gfx/chargebar.anm2", true)
        }
    end
    local CountForgotenLullaby = entShooting.Type == 3 and player:HasTrinket(TrinketType.TRINKET_FORGOTTEN_LULLABY)
    if aimVec:Length() ~= 0 then
        local sprite = knife:GetSprite()
        local playerMaxFireDelay = player.MaxFireDelay
        if ShouldDoBrimstone(player) and data.MagicStaff_ChargeBar.Charge <= 3 and weapon:GetFireDelay() <=0 then
            local mult = 1
            if entShooting.Type == 3 then
                local fam = entShooting:ToFamiliar()
                if fam then
                    if fam.Variant == FamiliarVariant.TWISTED_BABY then
                        mult= 0.375 * fam:GetMultiplier()
                    elseif fam.Variant == FamiliarVariant.BLOOD_BABY then
                        mult= 0.35 * fam:GetMultiplier()
                    else
                        mult= 0.75 * fam:GetMultiplier()
                    end
                end
            end
            local ballEnt = player:FireBrimstoneBall(entShooting.Position, aimVec:Resized(5), aimVec:Resized(math.max(player.TearRange / 260, 1)*40 * mult))
            ballEnt.CollisionDamage = ballEnt.CollisionDamage *3 *mult
            ballEnt.SpriteScale = ballEnt.SpriteScale * mult
            ballEnt.Size = ballEnt.Size * mult
            
            ballEnt:SetTimeout(4)
            weapon:SetFireDelay( weapon:GetMaxFireDelay() )
        end
        if HasShouldDoNeptunus(player) then
            if IsKnifeSwinging(sprite) and sprite:GetFrame() == 1 and data.MagicStaff_ChargeBar then
                DoNeptunusCluster(entShooting, player, (data.MagicStaff_ChargeBar.Charge / data.MagicStaff_ChargeBar.MaxCharge)) 
                data.MagicStaff_ChargeBar.Charge = 0
            end
            return
        end
        if CountForgotenLullaby then playerMaxFireDelay = playerMaxFireDelay /2 end
        local C_SectionIsMainWeapon = not player:GetEffects():HasNullEffect(BECKY_B.BlockItems.EpicFetus) and player:HasCollectible(CollectibleType.COLLECTIBLE_C_SECTION)
        
        if playerMaxFireDelay <= 3.2 then
            if C_SectionIsMainWeapon then
                data.MagicStaff_ChargeBar.NoRender = false
            else
                data.MagicStaff_ChargeBar.NoRender = true
            end
        elseif IsKnifeSwinging(sprite) and sprite:GetFrame() < sprite:GetCurrentAnimationData():GetLength() - 3 then
            data.MagicStaff_ChargeBar.Charge = 0
            data.MagicStaff_ChargeBar.NoRender = false
            return
        end
        
        data.MagicStaff_CursedEyeTears = nil
        --if entShooting.Type == 1 and save.ManaCharge < BECKY_B.ManaTearCost then return end
        
        local addToCharge = 1
        if C_SectionIsMainWeapon then
            local c_sectionCharge = 30 /(playerMaxFireDelay *3 +1)
            if c_sectionCharge > MAX_TEARS_DPS_C_SECTION *1.5 then c_sectionCharge = MAX_TEARS_DPS_C_SECTION *1.5 end
            addToCharge = addToCharge * (c_sectionCharge /BASE_TEAR_DPS * 1.25)
        else
            addToCharge = addToCharge * (BeckyMod:toTearsPerSecond(playerMaxFireDelay) /BASE_TEAR_DPS * 1.25)
            if HasShouldDoCursedEye(player) then
                addToCharge = addToCharge /4
                if player:GetEffects():HasNullEffect(BECKY_B.BlockItems.ChocolateMilk) then
                    addToCharge = addToCharge /2.5
                end
            elseif ShouldDoChocolateMilk(player) then
                if player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) then
                    addToCharge = addToCharge /3.75
                --elseif ShouldDoMonstrosLung(player) and not player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X) then
                    --addToCharge = addToCharge /2
                else
                    addToCharge = addToCharge /2.5
                end
            end
        end
        data.MagicStaff_ChargeBar.Charge = math.min(data.MagicStaff_ChargeBar.Charge +addToCharge, data.MagicStaff_ChargeBar.MaxCharge)
        

        --local fireDelay = weapon:GetFireDelay()
        --local maxTearDelay = playerMaxFireDelay/4
        --if maxTearDelay > 0.5 then maxTearDelay = 0.5
        ----elseif maxTearDelay < 0 then maxTearDelay = weapon:GetMaxFireDelay()
        --end
        --if data.MagicStaff_ChargeBar.Charge > 3 and fireDelay < maxTearDelay then fireDelay = maxTearDelay end
        --weapon:SetFireDelay(fireDelay)

        if not (ShouldDoChocolateMilk(player) or HasShouldDoCursedEye(player)) or (C_SectionIsMainWeapon) or playerMaxFireDelay <= 3.2 then
            --if data.MagicStaff_ChargeBar.Charge == data.MagicStaff_ChargeBar.MaxCharge then
                BeckyFire(entShooting, player, data, true)
            --end
        end
    else
        if HasShouldDoNeptunus(player) then
            local sprite = knife:GetSprite()
            if IsKnifeSwinging(sprite) then return end

            local addToCharge = 1
            addToCharge = addToCharge * (BeckyMod:toTearsPerSecond(player.MaxFireDelay) /BASE_TEAR_DPS * 1.25) /5

            if CountForgotenLullaby then
                addToCharge = addToCharge * 2
            end
            data.MagicStaff_ChargeBar.Charge = math.min(data.MagicStaff_ChargeBar.Charge +addToCharge, data.MagicStaff_ChargeBar.MaxCharge)

        else
            BeckyFire(entShooting, player, data)
        end
    end
end


BeckyMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function(_, player)
    
    if player:GetPlayerType() ~= BECKY_B.PLAYERTYPE then return end
    PlayerAnimLib:SetDefaultAnm2(player, "gfx/player_becky_b.anm2")
    player:AddNullCostume(BECKY_B.BODY_COSTUME)
    local save = BeckyMod:RunSave(player)
    save.ManaCharge = save.ManaCharge or 0
    --if not save.SelectedSpells then
    --    save.ForceSelectSpells = save.ForceSelectSpells or 2
    --end
end)


BeckyMod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, 200, function(_, player, cacheFlags)
    if player:GetPlayerType() ~= BECKY_B.PLAYERTYPE then return end
    if CacheFlag.CACHE_DAMAGE & cacheFlags > 0 then
        player.Damage = player.Damage * 0.666666
    --elseif CacheFlag.CACHE_FIREDELAY & cacheFlags > 0 then
        --local tps = BeckyMod:toTearsPerSecond(player.MaxFireDelay)
        --tps = tps * 0.42
        --player.MaxFireDelay = BeckyMod:toMaxFireDelay(tps)
    elseif CacheFlag.CACHE_TEARCOLOR & cacheFlags > 0 then
        --player.TearColor = player.TearColor * COLOR_WHITE
        --player.LaserColor = player.LaserColor * COLOR_WHITE
    end
end)

BeckyMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, cacheFlags)
    if player:GetPlayerType() ~= BECKY_B.PLAYERTYPE then return end
    if CacheFlag.CACHE_DAMAGE & cacheFlags > 0 then
        if player:HasCollectible(CollectibleType.COLLECTIBLE_SPIRIT_SWORD) then
            player.Damage = player.Damage * 1.25 + 0.5
        end
    elseif CacheFlag.CACHE_FIREDELAY & cacheFlags > 0 then
        if player:HasCollectible(CollectibleType.COLLECTIBLE_SPIRIT_SWORD) then
            local tps = BeckyMod:toTearsPerSecond(player.MaxFireDelay)
            tps = tps * 1.12
            player.MaxFireDelay = BeckyMod:toMaxFireDelay(tps)
        end
    end
end)


BeckyMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
    if player:GetPlayerType() ~= BECKY_B.PLAYERTYPE then return end
    if player:IsDead() then return end
    local weapon = player:GetWeapon(1)
    local effects = player:GetEffects()
    local data = BeckyMod.GetEntData(player)
    if effects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_BERSERK) then
        if not data.DestroidWeapon then
            data.DestroidWeapon = true
        end 
        return
    elseif effects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_NOTCHED_AXE) then
        if not data.DestroidWeapon then
            if weapon then Isaac.DestroyWeapon(weapon) end
            data.DestroidWeapon = true
        end
        return
    end
    if weapon == nil or weapon:GetWeaponType() ~= WeaponType.WEAPON_BONE or data.DestroidWeapon then
        if weapon then Isaac.DestroyWeapon(weapon) end
        weapon = Isaac.CreateWeapon(WeaponType.WEAPON_BONE, player)
        player:SetWeapon(weapon, 1)
        player:EnableWeaponType(WeaponType.WEAPON_BONE, 1)
        --player:SetWeapon()
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE| CacheFlag.CACHE_FIREDELAY, true)
        data.DestroidWeapon = false
    end
    if weapon:GetMainEntity() == nil then return end
    local data = BeckyMod.GetEntData(player)
    if not HasShouldDoNeptunus(player) and data.MagicStaff_ChargeBar and data.MagicStaff_ChargeBar.Charge > 0 then
        weapon:SetCharge(1.0)
    else
        weapon:SetCharge(0.0)
    end
end)

BeckyMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)
    if player:GetPlayerType() ~= BECKY_B.PLAYERTYPE or player:IsDead() then return end
    local save = BeckyMod:RunSave(player)
    if save.UnblockCursedEyeNextFrame then
        player:UnblockCollectible(CollectibleType.COLLECTIBLE_CURSED_EYE)
        save.UnblockCursedEyeNextFrame = false
    end
    local effects = player:GetEffects()
    if effects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_BERSERK) or effects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_NOTCHED_AXE) then
        return
    end
    local data = BeckyMod.GetEntData(player)
    
    if data.MagicStaff_CursedEyeTears then
        if data.MagicStaff_CursedEyeTears.Cooldown > 0 then
            data.MagicStaff_CursedEyeTears.Cooldown = data.MagicStaff_CursedEyeTears.Cooldown -1
        else
            BECKY_B:FireWeapon(player, player, data.MagicStaff_CursedEyeTears.FireData )
            data.MagicStaff_CursedEyeTears.Shots = data.MagicStaff_CursedEyeTears.Shots -1
            if data.MagicStaff_CursedEyeTears.Shots <= 0 then data.MagicStaff_CursedEyeTears = nil
            else data.MagicStaff_CursedEyeTears.Cooldown = CURSE_EYE_COOLDOWN end
        end
    end
    ProcessStaffSwing(player, player)
end)

BeckyMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, ent)
    local player = ent:ToPlayer()
    if player and player:GetPlayerType() == BECKY_B.PLAYERTYPE then
        local save = BeckyMod:RunSave(player)
        player:BlockCollectible(CollectibleType.COLLECTIBLE_CURSED_EYE)
        save.UnblockCursedEyeNextFrame = true
    end
end)
BeckyMod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, function(_, ent)
    local player = ent:ToPlayer()
    if player and player:GetPlayerType() == BECKY_B.PLAYERTYPE then
        local save = BeckyMod:RunSave(player)
        save.UnblockCursedEyeNextFrame = false
        player:UnblockCollectible(CollectibleType.COLLECTIBLE_CURSED_EYE)
        if player:HasCollectible(CollectibleType.COLLECTIBLE_CURSED_EYE) and not player:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE) then
            local data = BeckyMod.GetEntData(player)
            if data.MagicStaff_ChargeBar == nil then return end
            if data.MagicStaff_ChargeBar.Charge > 0 and data.MagicStaff_ChargeBar.Charge < data.MagicStaff_ChargeBar.MaxCharge then
                local level = game:GetLevel()
                level.LeaveDoor = -1
                game:StartRoomTransition(
                    level:GetRandomRoomIndex(false, player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_CURSED_EYE):Next()),
                    -1,
                    RoomTransitionAnim.TELEPORT,
                    player,
                    level:GetDimension()
                )
            end
        end
    end
end)


BeckyMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
    if BECKY_B.FamiliarWhiteList[fam.Variant] == nil then return end

    local player = fam.Player
    if player == nil or player:GetPlayerType() ~= BECKY_B.PLAYERTYPE then return end
    
    if player:IsDead() then return end
    local effects = player:GetEffects()
    if effects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_BERSERK) or effects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_NOTCHED_AXE) then
        return
    end
    local weapon = fam:GetWeapon()
    if weapon == nil or weapon:GetMainEntity() == nil then return end
    
    local data = BeckyMod.GetEntData(fam)
    if not HasShouldDoNeptunus(player) and data.MagicStaff_ChargeBar and data.MagicStaff_ChargeBar.Charge > 0 then
        weapon:SetCharge(1.0)
    else
        weapon:SetCharge(0.0)
    end
    if data.MagicStaff_CursedEyeTears then
        if data.MagicStaff_CursedEyeTears.Cooldown > 0 then
            data.MagicStaff_CursedEyeTears.Cooldown = data.MagicStaff_CursedEyeTears.Cooldown -1
        else
            BECKY_B:FireWeapon(fam, player, data.MagicStaff_CursedEyeTears.FireData )
            data.MagicStaff_CursedEyeTears.Shots = data.MagicStaff_CursedEyeTears.Shots -1
            if data.MagicStaff_CursedEyeTears.Shots <= 0 then data.MagicStaff_CursedEyeTears = nil
            else data.MagicStaff_CursedEyeTears.Cooldown = CURSE_EYE_COOLDOWN end
        end
    end
    ProcessStaffSwing(fam, player)
end)


-------------------------------------------------
--------------------MANA STUFF-------------------
-------------------------------------------------
BeckyMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)
    if player:GetPlayerType() ~= BECKY_B.PLAYERTYPE then return end
    local save = BeckyMod:RunSave(player)
    local data = BeckyMod.GetEntData(player)
    local manaCap = 100 - (data.MaxManaOffset or 0)

    if BeckyMod.Spells:HasSpell(player, BeckyMod.Spells.SpellType.MANA_REGEN) then
        manaCap = 150 - (data.MaxManaOffset or 0)
    end
    --if BeckyMod.Spells:HasSpell(player, BeckyMod.Spells.SpellType.MANA_REGEN) and (data.NoChargeMana == nil or data.NoChargeMana <= 0) then
    --    if not game:GetRoom():IsClear() then
    --        local midCap = 50 - (data.MaxManaOffset or 0)
    --        if save.ManaCharge < midCap then
    --            save.ManaCharge = save.ManaCharge + 0.038
    --        end
    --    end
    --end

    if save.ManaCharge > 0 and data.ManaDischarge and data.ManaDischarge > 0 then
        save.ManaCharge = math.max(save.ManaCharge -data.ManaDischarge, 0)
    end
    if save.ManaCharge > manaCap then save.ManaCharge = manaCap end
end)


BeckyMod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, function(_, ent, dmg, dmgFlags, src, cooldown)
    if ent.Type == 1 or dmg <= 0 then return end
    if not BeckyMod.IsEnemy(ent) or not ent:CanShutDoors() or ent:ToNPC() == nil then return end
    if not (ent:GetEntityFlags() & (EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_ICE_FROZEN) > 0 or dmgFlags & (DamageFlag.DAMAGE_FAKE | DamageFlag.DAMAGE_CLONES) ) then return end
    local srcEnt = src.Entity
    local player = srcEnt
    if player == nil or BeckyMod.GetEntData(srcEnt).NoGrantMana or (srcEnt.SpawnerEntity and BeckyMod.GetEntData(srcEnt.SpawnerEntity).NoGrantMana) then return
    else player = BeckyMod:TryGetPlayer(player, false) end

    if player == nil or player:GetPlayerType() ~= BECKY_B.PLAYERTYPE then return end
    local data = BeckyMod.GetEntData(player)
    if not (data.NoChargeMana and data.NoChargeMana > 0) then
        local save = BeckyMod:RunSave(player)
        local manaGranted = math.min(ent.HitPoints, dmg) *0.80
        if BeckyMod.Spells:HasSpell(player, BeckyMod.Spells.SpellType.SPELL_DMG_UP) then
            save.ManaCharge = save.ManaCharge + manaGranted / 1.35
        end
        save.ManaCharge = save.ManaCharge + manaGranted
    end
end)


-------------------------------------------------
----------------MAGIC STAFF STUFF----------------
-------------------------------------------------
BeckyMod:AddCallback(ModCallbacks.MC_POST_KNIFE_RENDER, function(_, knife, offset)
    if not BECKY_B.ValidBoneClubs[knife.Variant] or knife.SubType == KnifeSubType.CLUB_HITBOX then return end
    if GetBecky(knife.Parent) == nil then return end

    local sp = knife:GetSprite()
    local nullFrame = sp:GetNullFrame("flame")

    if nullFrame and nullFrame:IsVisible() then
        BECKY_B.StaffFireSprite.Scale = sp.Scale
        local pos = knife:GetNullOffset("flame")

        local room = game:GetRoom()
        BECKY_B.StaffFireSprite:SetFrame("flame", knife.FrameCount %4)
        BECKY_B.StaffFireSprite:Render(room:WorldToScreenPosition(knife.Position + pos + knife.PositionOffset))
    end
end)


BeckyMod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, function(_, knife)
    local player = GetBecky(knife.Parent)
    if player == nil then return end
    if not BECKY_B.ValidBoneClubs[knife.Variant] then return end
    --knife.SpriteScale = Vector.One * 0.85
    local data = BeckyMod.GetEntData(knife)
    local sp = knife:GetSprite()
    if data.Inited or knife.FrameCount >1 then
        knife.Charge = -1
        sp:GetLayer(1):SetVisible(false)
        return
    end
    sp:Load(taintedBeckysWandAnim, true)
    sp:Play("Idle", true)
    data.Inited = true
end, KnifeSubType.DEFAULT)

BeckyMod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, function(_, knife)
    local player = GetBecky(knife.Parent)
    if player == nil then return end
    if not BECKY_B.ValidBoneClubs[knife.Variant] then return end
    local parent = knife:GetHitboxParentKnife()
    local data = BeckyMod.GetEntData(knife)
    if parent ~= nil and parent.Size then --parent.SpriteScale then
        knife.Size = parent.Size * 1.2805
        --knife.SpriteScale = parent.SpriteScale * 1.2805
    end
    if data.Inited or knife.FrameCount >1 then
        return
    end

    local sp = knife:GetSprite()
    local isPlaying = sp:GetAnimation()
    sp:Load(taintedBeckysWandAnim, true)
    sp:Play(isPlaying, true)
    sp:GetLayer(0):SetVisible(false)
    --sp.Color.A = 0.0
    data.Inited = true
end, KnifeSubType.CLUB_HITBOX)

--[[
BeckyMod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_MULTI_SHOT_PARAMS, 3000, function(_, player, multishotParam, weaponType)
    if player:GetPlayerType() == BECKY_B.PLAYERTYPE and weaponType == WeaponType.WEAPON_BONE then
        multishotParam:SetNumTears(1)
        multishotParam:SetNumLanesPerEye(1)
        multishotParam:SetSpreadAngle(WeaponType.WEAPON_BONE, 0)
        return multishotParam
    end
end)]]

----------------------------------------------------------------------------
---------------------------------BECKY HUD----------------------------------
----------------------------------------------------------------------------
HudHelper.RegisterHUDElement({
	Name = "Mana Bar (Becky)",
	Priority = HudHelper.Priority.NORMAL,
	XPadding = 0,
	YPadding = 30,
	Condition = function(player, playerHUDIndex, hudLayout)
		return player:GetPlayerType() == BECKY_B.PLAYERTYPE
	end,
	OnRender = function(player, playerHUDIndex, hudLayout, position)
        local save = BeckyMod:RunSave(player)
        local manaOffset = (BeckyMod.GetEntData(player).MaxManaOffset or 0)

        local a = math.min(math.floor(save.ManaCharge + manaOffset), 100)
        local b = math.min(math.floor(manaOffset), 100)

        BECKY_B.ManaBarSprite:SetFrame("ChargeBar", a )
        BECKY_B.ManaBarSprite:Render(position)
        BECKY_B.ManaBarSprite:SetFrame("ChargeBarGray", b)
        BECKY_B.ManaBarSprite:Render(position)

        if BeckyMod.Spells:HasSpell(player, BeckyMod.Spells.SpellType.MANA_REGEN) then
            local a2 = math.min(save.ManaCharge + manaOffset - a, 50) *2
            local b2 = math.min(manaOffset - b, 50) *2
    
            BECKY_B.ManaBarSprite:SetFrame("ChargeBar2", math.floor(a2) )
            BECKY_B.ManaBarSprite:Render(position)
            BECKY_B.ManaBarSprite:SetFrame("ChargeBarGray2", math.floor(b2) )
            BECKY_B.ManaBarSprite:Render(position)
        end
	end,
	--BypassGhostBaby = true,
}, HudHelper.HUDType.EXTRA)


local function UpdateChargebar(data)
	local sp = data.Sprite
	local charge = math.floor(data.Charge / data.MaxCharge *100)+1


	if charge == 101 then
		if not sp:IsPlaying("Charged") then sp:Play("Charged", true) end
		if not game:IsPaused() then sp:Update() end
	elseif charge > 0 and charge < 101 then
		if not sp:IsPlaying("Charging") then sp:Play("Charging") end
		sp:SetFrame("Charging", charge)
	elseif charge <= 0 then
		if not sp:IsPlaying("Disappear") and not sp:IsFinished("Disappear") then
			sp:Play("Disappear", true)
		elseif not game:IsPaused() then sp:Update() end
	end
end


-------------------------------------------------------------------------------------------------------
----------------------------------------------CHARGE BAR-----------------------------------------------
-------------------------------------------------------------------------------------------------------
local CHARGEBAR_POS = Vector(-18.5, -54)
local function renderPlayerChargebar(player)
	if player.Parent ~= nil or player:IsDead() or player:IsCoopGhost() or not (player:GetPlayerType() == BECKY_B.PLAYERTYPE) then return end

	local chargeData = BeckyMod.GetEntData(player).MagicStaff_ChargeBar
	if not chargeData or chargeData.NoRender then return end
    local sp = chargeData.Sprite
    UpdateChargebar(chargeData)
    if sp:IsPlaying("Disappear") or chargeData.Charge > 0  then
        sp:Render(game:GetRoom():WorldToScreenPosition( (player:GetFlyingOffset() *1.5) + player.Position + CHARGEBAR_POS))
    end
end

local function renderFamiliarChargebar(fam)
    local player = fam.Player
	if player == nil or player.Parent ~= nil or player:IsDead() or player:IsCoopGhost() or not (player:GetPlayerType() == BECKY_B.PLAYERTYPE) then return end

	local chargeData = BeckyMod.GetEntData(fam).MagicStaff_ChargeBar
	if not chargeData or chargeData.NoRender then return end
    local sp = chargeData.Sprite
    UpdateChargebar(chargeData)
    if sp:IsPlaying("Disappear") or chargeData.Charge > 0  then
        sp:Render(game:GetRoom():WorldToScreenPosition( (fam.Position + CHARGEBAR_POS) * fam.SpriteScale ))
    end
end

BeckyMod:AddPriorityCallback(ModCallbacks.MC_POST_ROOM_RENDER_ENTITIES, -300, function()
	if not Options.ChargeBars then return end
    BeckyMod:ForEachPlayer(renderPlayerChargebar)
    for _, famVar in ipairs(CAN_RENDER_CHARGE_TO_FAMILIARS) do
        for _, ent in ipairs(Isaac.FindByType(3, famVar)) do
            local fam = ent:ToFamiliar()
            if fam then renderFamiliarChargebar(fam) end
        end
    end
end)

-----------------------------------------------------------------------------------
--------------------------------SOME SYNERGIES-------------------------------------
-----------------------------------------------------------------------------------

BeckyMod:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_ADDED, function(_,player, itemID)
    if player:GetPlayerType() ~= BECKY_B.PLAYERTYPE then return end
    if ITEMS_TO.Blocker[itemID] then
        player:AddNullItemEffect(ITEMS_TO.Blocker[itemID], true)
    elseif itemID == CollectibleType.COLLECTIBLE_SPIRIT_SWORD then
        player:AddNullItemEffect(BECKY_B.SPIRIT_SWORD_SYNERGY)
    end
end)

BeckyMod:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, function(_,player, itemID)
    if player:GetPlayerType() ~= BECKY_B.PLAYERTYPE then return end
    if ITEMS_TO.Blocker[itemID] then
        player:GetEffects():RemoveNullEffect(ITEMS_TO.Blocker[itemID], 1)
    elseif itemID == CollectibleType.COLLECTIBLE_SPIRIT_SWORD then
        player:GetEffects():RemoveNullEffect(BECKY_B.SPIRIT_SWORD_SYNERGY, 1)
    end
end)

BeckyMod:AddCallback(ModCallbacks.MC_POST_PLAYER_ADD_EFFECT, function(_,player, itemCon)
    if itemCon:IsNull() and itemCon.ID == BECKY_B.BlockItems.MonstrosLung then
        player:BlockCollectible(CollectibleType.COLLECTIBLE_MONSTROS_LUNG)
    elseif itemCon:IsNull() and itemCon.ID == BECKY_B.BlockItems.ChocolateMilk then
        player:BlockCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK)
    ---elseif itemCon:IsNull() and itemCon.ID == BECKY_B.BlockItems.Neptunus then
    ---    player:BlockCollectible(CollectibleType.COLLECTIBLE_NEPTUNUS)
    elseif itemCon:IsNull() and itemCon.ID == BECKY_B.BlockItems.DrFetus then
        player:BlockCollectible(CollectibleType.COLLECTIBLE_DR_FETUS)
    elseif itemCon:IsNull() and itemCon.ID == BECKY_B.BlockItems.EpicFetus then
        player:BlockCollectible(CollectibleType.COLLECTIBLE_EPIC_FETUS)
    end
end)

BeckyMod:AddCallback(ModCallbacks.MC_POST_PLAYER_TRIGGER_EFFECT_REMOVED, function(_,player, itemCon)
    local effects = player:GetEffects()
    if itemCon:IsNull() and itemCon.ID == BECKY_B.BlockItems.MonstrosLung and not effects:HasNullEffect(BECKY_B.BlockItems.MonstrosLung) then
        player:UnblockCollectible(CollectibleType.COLLECTIBLE_MONSTROS_LUNG)
    elseif itemCon:IsNull() and itemCon.ID == BECKY_B.BlockItems.ChocolateMilk and not effects:HasNullEffect(BECKY_B.BlockItems.ChocolateMilk) then
        player:UnblockCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK)
    ---elseif itemCon:IsNull() and itemCon.ID == BECKY_B.BlockItems.Neptunus and not effects:HasNullEffect(BECKY_B.BlockItems.Neptunus) then
    ---    player:UnblockCollectible(CollectibleType.COLLECTIBLE_NEPTUNUS)
    elseif itemCon:IsNull() and itemCon.ID == BECKY_B.BlockItems.DrFetus then
        player:UnblockCollectible(CollectibleType.COLLECTIBLE_DR_FETUS)
    elseif itemCon:IsNull() and itemCon.ID == BECKY_B.BlockItems.EpicFetus then
        player:UnblockCollectible(CollectibleType.COLLECTIBLE_EPIC_FETUS)
    end
end)
BeckyMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)
    local effects = player:GetEffects()
    if player:GetPlayerType() == BECKY_B.PLAYERTYPE then
        local data = BeckyMod.GetEntData(player)
        if data.HeadSpriteData and data.HeadSpriteData.Update then
            data.HeadSpriteData.Sprite:Update()
        end
        if effects:HasNullEffect(BECKY_B.BlockItems.MonstrosLung) then
            player:BlockCollectible(CollectibleType.COLLECTIBLE_MONSTROS_LUNG)
        else
            player:UnblockCollectible(CollectibleType.COLLECTIBLE_MONSTROS_LUNG)
        end
        if effects:HasNullEffect(BECKY_B.BlockItems.ChocolateMilk) then
            player:BlockCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK)
        --elseif effects:HasNullEffect(BECKY_B.BlockItems.Neptunus) then
        ---    player:BlockCollectible(CollectibleType.COLLECTIBLE_NEPTUNUS)
        else
            player:UnblockCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK)
        end
        if effects:HasNullEffect(BECKY_B.BlockItems.DrFetus) then
            player:BlockCollectible(CollectibleType.COLLECTIBLE_DR_FETUS)
        else
            player:UnblockCollectible(CollectibleType.COLLECTIBLE_DR_FETUS)
        end
        if effects:HasNullEffect(BECKY_B.BlockItems.EpicFetus) then
            player:BlockCollectible(CollectibleType.COLLECTIBLE_EPIC_FETUS)
        else
            player:UnblockCollectible(CollectibleType.COLLECTIBLE_EPIC_FETUS)
        end
        return
    end
    if effects:HasNullEffect(BECKY_B.BlockItems.MonstrosLung) then
        player:GetEffects():RemoveNullEffect(BECKY_B.BlockItems.MonstrosLung, -1)
        player:UnblockCollectible(CollectibleType.COLLECTIBLE_MONSTROS_LUNG)
    end
    if effects:HasNullEffect(BECKY_B.BlockItems.ChocolateMilk) then
        player:GetEffects():RemoveNullEffect(BECKY_B.BlockItems.ChocolateMilk, -1)
        player:UnblockCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK)
    --elseif effects:HasNullEffect(BECKY_B.BlockItems.Neptunus) then
    --    player:GetEffects():RemoveNullEffect(BECKY_B.BlockItems.Neptunus, -1)
    end
    if effects:HasNullEffect(BECKY_B.BlockItems.DrFetus) then
        player:GetEffects():RemoveNullEffect(BECKY_B.BlockItems.DrFetus, -1)
        player:UnblockCollectible(CollectibleType.COLLECTIBLE_DR_FETUS)
    end
    if effects:HasNullEffect(BECKY_B.BlockItems.EpicFetus) then
        player:GetEffects():RemoveNullEffect(BECKY_B.BlockItems.EpicFetus, -1)
        player:UnblockCollectible(CollectibleType.COLLECTIBLE_EPIC_FETUS)
    end
end)


BeckyMod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, -400000, function(_, player, cacheFlag)
    local effects = player:GetEffects()
    if cacheFlag & CacheFlag.CACHE_FIREDELAY == CacheFlag.CACHE_FIREDELAY then
        local tps = BeckyMod:toTearsPerSecond(player.MaxFireDelay)

        if (effects:HasNullEffect(BECKY_B.BlockItems.DrFetus) and not player:HasCollectible(CollectibleType.COLLECTIBLE_HAEMOLACRIA)) or effects:HasNullEffect(BECKY_B.BlockItems.EpicFetus) then
            tps = tps /2.5
        end

        if ShouldDoMonstrosLung(player) then
            if not player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) and ShouldDoTechX(player) then
                tps = tps /3.1
            elseif not (effects:HasNullEffect(BECKY_B.BlockItems.DrFetus) or effects:HasNullEffect(BECKY_B.BlockItems.EpicFetus) or player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE)) and
                player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY) then
            else
                tps = tps /4.3
            end
        end

        player.MaxFireDelay = BeckyMod:toMaxFireDelay(tps)
    elseif cacheFlag & CacheFlag.CACHE_TEARCOLOR == CacheFlag.CACHE_TEARCOLOR then
        if effects:HasNullEffect(BECKY_B.BlockItems.ChocolateMilk) then
            local tearColor = player.TearColor
            local laserColor = player.LaserColor
            tearColor:SetTint(0.33, 0.18, 0.18, 1)
            tearColor:SetOffset(0.258824, 0.156863, 0.156863)
            laserColor:SetColorize(3, 1.7, 1.7, 1)
            player.TearColor = tearColor
            player.LaserColor = laserColor
        end
    end
end)

local itemConfig = Isaac.GetItemConfig()
--HeadLeftCharge
--HeadUpShoot
--HeadRightChargeFull

local SkinColorToString = {
    [SkinColor.SKIN_PINK] = ".png",
    [SkinColor.SKIN_WHITE] = "_white.png",
    [SkinColor.SKIN_BLACK] = "_black.png",
    [SkinColor.SKIN_BLUE] = "_blue.png",
    [SkinColor.SKIN_RED] = "_red.png",
    [SkinColor.SKIN_GREEN] = "_green.png",
    [SkinColor.SKIN_GREY] = "_grey.png",
}
local DirToHeadAnim = {
    [Direction.UP] = "HeadUp",
    [Direction.DOWN] = "HeadDown",
    [Direction.LEFT] = "HeadLeft",
    [Direction.RIGHT] = "HeadRight",
}
local LayerToString = {
    [PlayerSpriteLayer.SPRITE_HEAD] = "head",
    [PlayerSpriteLayer.SPRITE_HEAD0] = "head0",
    [PlayerSpriteLayer.SPRITE_HEAD1] = "head1",
    [PlayerSpriteLayer.SPRITE_HEAD2] = "head2",
    [PlayerSpriteLayer.SPRITE_HEAD3] = "head3",
    [PlayerSpriteLayer.SPRITE_HEAD4] = "head4",
    [PlayerSpriteLayer.SPRITE_HEAD5] = "head5",
    [PlayerSpriteLayer.SPRITE_TOP0] = "top0",
}

local function renderHeadCostumes(player, renderPos, headAnim, minLayer, maxLayer)
    minLayer = minLayer or PlayerSpriteLayer.SPRITE_HEAD0
    maxLayer = maxLayer or PlayerSpriteLayer.SPRITE_TOP0

    local costumeSpriteDescs = player:GetCostumeSpriteDescs()
    for layer, mapData in ipairs(player:GetCostumeLayerMap()) do
        local trueLayerNum = layer-1
        if mapData.costumeIndex == -1 or (trueLayerNum < minLayer or trueLayerNum > maxLayer) then goto continue end
        local costumeSpriteDesc = costumeSpriteDescs[mapData.costumeIndex + 1]
        local sprite = costumeSpriteDesc:GetSprite()
        sprite:SetAnimation(headAnim, false)
        local layerID = sprite:GetLayer(LayerToString[trueLayerNum]):GetLayerID()
        sprite:RenderLayer(layerID, renderPos)
        ::continue::
    end
end

BeckyMod:AddCallback(ModCallbacks.MC_PRE_RENDER_PLAYER_HEAD, function(_, player, renderPos)
    if player:GetPlayerType() ~= BECKY_B.PLAYERTYPE then return end
    local effects = player:GetEffects()
    local data = BeckyMod.GetEntData(player)
    if effects:HasNullEffect(BECKY_B.BlockItems.MonstrosLung) and player:IsItemCostumeVisible(itemConfig:GetNullItem(BECKY_B.BlockItems.MonstrosLung), PlayerSpriteLayer.SPRITE_HEAD) then
        if not data.MagicStaff_ChargeBar then return end
        local spriteData = data.HeadSpriteData
        local sprite
        if spriteData == nil or spriteData.SpriteType ~= "Monstro's Lung" then
            data.HeadSpriteData = {
                Sprite = Sprite("gfx/characters/229_monstros lung.anm2", true),
                SpriteType = "Monstro's Lung",
                Update = false,
                PrevCharge = 0,
            }
            spriteData = data.HeadSpriteData
            sprite = spriteData.Sprite
            sprite:ReplaceSpritesheet(0, "gfx/characters/costumes_becky/costume_monstros lung.png", true)
        else
            sprite = spriteData.Sprite
        end
        local sprite = spriteData.Sprite
        
        local dir = player:GetHeadDirection()
        local charge = data.MagicStaff_ChargeBar.Charge / data.MagicStaff_ChargeBar.MaxCharge

        if effects:HasNullEffect(BECKY_B.BlockItems.ChocolateMilk) then
            if charge == 1 then
                if not sprite:IsPlaying(DirToHeadAnim[dir].."ChargeFull") then
                    sprite:Play(DirToHeadAnim[dir].."ChargeFull", true)
                    spriteData.WasPlayingCharge = true
                    --player:SetHeadDirectionLockTime(sprite:GetCurrentAnimationData():GetLength())
                end
                spriteData.Update = true
            elseif spriteData.WasPlayingCharge then
                sprite:Play(DirToHeadAnim[dir].."Shoot", true)
                player:SetHeadDirectionLockTime(sprite:GetCurrentAnimationData():GetLength())
                spriteData.WasPlayingCharge = false
                spriteData.Update = true
            else
                if spriteData.PrevCharge > charge and charge > 0.12 then
                    sprite:Play(DirToHeadAnim[dir].."Shoot", true)
                    player:SetHeadDirectionLockTime(sprite:GetCurrentAnimationData():GetLength())
                    spriteData.WasPlayingCharge = false
                    spriteData.Update = true
                elseif not (sprite:IsPlaying(DirToHeadAnim[0].."Shoot") or sprite:IsPlaying(DirToHeadAnim[1].."Shoot") or sprite:IsPlaying(DirToHeadAnim[2].."Shoot") or sprite:IsPlaying(DirToHeadAnim[3].."Shoot") ) then
                    sprite:SetFrame( DirToHeadAnim[dir].."Charge", math.floor(18 * charge))
                    spriteData.Update = false
                end
                spriteData.PrevCharge = charge
            end
        else
            if charge == 1 then
                if not sprite:IsPlaying(DirToHeadAnim[dir].."ChargeFull") then
                    sprite:Play(DirToHeadAnim[dir].."ChargeFull", true)
                    spriteData.WasPlayingCharge = true
                    --player:SetHeadDirectionLockTime(sprite:GetCurrentAnimationData():GetLength())
                end
                spriteData.Update = true
            elseif spriteData.WasPlayingCharge then
                sprite:Play(DirToHeadAnim[dir].."Shoot", true)
                player:SetHeadDirectionLockTime(sprite:GetCurrentAnimationData():GetLength())
                spriteData.WasPlayingCharge = false
                spriteData.Update = true
            elseif not (sprite:IsPlaying(DirToHeadAnim[0].."Shoot") or sprite:IsPlaying(DirToHeadAnim[1].."Shoot") or sprite:IsPlaying(DirToHeadAnim[2].."Shoot") or sprite:IsPlaying(DirToHeadAnim[3].."Shoot") ) then
                sprite:SetFrame( DirToHeadAnim[dir].."Charge", math.floor(18 * charge))
                spriteData.Update = false
            end
        end

        sprite:Render(renderPos)
        renderHeadCostumes(player, renderPos, DirToHeadAnim[dir])
        return false
    elseif player:IsItemCostumeVisible(itemConfig:GetCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE), PlayerSpriteLayer.SPRITE_HEAD) or player:IsItemCostumeVisible(itemConfig:GetNullItem(NullItemID.ID_BRIMSTONE2), PlayerSpriteLayer.SPRITE_HEAD) then
        if not data.MagicStaff_ChargeBar then return end
        local spriteData = data.HeadSpriteData
        local num = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BRIMSTONE)
        if spriteData == nil or (num == 1 and spriteData.SpriteType ~= "Brimstone") or (num > 1 and spriteData.SpriteType ~= "Brimstone2") then
            data.HeadSpriteData = {
                Sprite = (num > 1 and Sprite("gfx/characters/n045_brimstone2.anm2", true)) or Sprite("gfx/characters/118_brimstone.anm2", true),
                SpriteType = (num > 1 and "Brimstone2") or "Brimstone",
                Update = false,
            }
            spriteData = data.HeadSpriteData
            spriteData.Sprite:ReplaceSpritesheet(0, "gfx/characters/costumes_becky/costume_019_brimstone.png", true)
        end
        local sprite = spriteData.Sprite
        
        local dir = player:GetHeadDirection()
        local charge = data.MagicStaff_ChargeBar.Charge / data.MagicStaff_ChargeBar.MaxCharge

        if charge == 1 then
            if not sprite:IsPlaying(DirToHeadAnim[dir].."ChargeFull") then
                sprite:Play(DirToHeadAnim[dir].."ChargeFull", true)
                spriteData.WasPlayingCharge = true
                --player:SetHeadDirectionLockTime(sprite:GetCurrentAnimationData():GetLength())
            end
            spriteData.Update = true
        elseif spriteData.WasPlayingCharge then
            sprite:Play(DirToHeadAnim[dir].."Shoot", true)
            player:SetHeadDirectionLockTime(sprite:GetCurrentAnimationData():GetLength())
            spriteData.WasPlayingCharge = false
            spriteData.Update = true
        elseif not (sprite:IsPlaying(DirToHeadAnim[0].."Shoot") or sprite:IsPlaying(DirToHeadAnim[1].."Shoot") or sprite:IsPlaying(DirToHeadAnim[2].."Shoot") or sprite:IsPlaying(DirToHeadAnim[3].."Shoot") ) then
            sprite:SetFrame( DirToHeadAnim[dir].."Charge", math.floor(18 * charge))
            spriteData.Update = false
        end

        sprite:Render(renderPos)
        renderHeadCostumes(player, renderPos, DirToHeadAnim[dir])
        return false
    elseif ShouldDoChocolateMilk(player) and player:IsItemCostumeVisible(itemConfig:GetNullItem(BECKY_B.BlockItems.ChocolateMilk), PlayerSpriteLayer.SPRITE_HEAD) then
        if not data.MagicStaff_ChargeBar then return end
        local spriteData = data.HeadSpriteData
        local sprite
        if spriteData == nil or spriteData.SpriteType ~= "Chocolate Milk" then
            data.HeadSpriteData = {
                Sprite = Sprite("gfx/characters/069_chocolate milk.anm2", true),
                SpriteType = "Chocolate Milk",
                Update = false,
            }
            spriteData = data.HeadSpriteData
            sprite = spriteData.Sprite
            sprite:ReplaceSpritesheet(0, "gfx/characters/costumes_becky/costume_chocolate milk.png", true)
        else
            sprite = spriteData.Sprite
        end
        
        local dir = player:GetHeadDirection()
        local charge = data.MagicStaff_ChargeBar.Charge / data.MagicStaff_ChargeBar.MaxCharge

        if charge == 1 then
            sprite:SetFrame( DirToHeadAnim[dir].."ChargeFull", 0)
        else
            sprite:SetFrame( DirToHeadAnim[dir].."Charge", math.floor(18 * charge))
        end
        sprite:Render(renderPos)
        renderHeadCostumes(player, renderPos, DirToHeadAnim[dir])
        return false
    elseif HasShouldDoNeptunus(player) and player:IsItemCostumeVisible(itemConfig:GetCollectible(CollectibleType.COLLECTIBLE_NEPTUNUS), PlayerSpriteLayer.SPRITE_HEAD) then
        if not data.MagicStaff_ChargeBar then return end
        local spriteData = data.HeadSpriteData
        if spriteData == nil or spriteData.SpriteType ~= "Neptunus" then
            data.HeadSpriteData = {
                Sprite = Sprite("gfx/characters/044x_neptunus.anm2", true),
                SpriteType = "Neptunus",
                Update = false,
            }
            spriteData = data.HeadSpriteData
        end
        local sprite = spriteData.Sprite
        
        local dir = player:GetHeadDirection()
        local charge = data.MagicStaff_ChargeBar.Charge / data.MagicStaff_ChargeBar.MaxCharge

        if charge == 1 then
            sprite:SetFrame(DirToHeadAnim[dir].."ChargeFull", 0)
        else
            spriteData.WasPlayingCharge = false
            sprite:SetFrame( DirToHeadAnim[dir].."Charge", math.floor(18 * charge))
        end
        sprite:Render(renderPos)
        renderHeadCostumes(player, renderPos, DirToHeadAnim[dir])
        return false
    elseif not effects:HasNullEffect(BECKY_B.BlockItems.ChocolateMilk) and HasShouldDoCursedEye(player) and player:IsItemCostumeVisible(itemConfig:GetCollectible(CollectibleType.COLLECTIBLE_CURSED_EYE), PlayerSpriteLayer.SPRITE_HEAD2) then
        if not data.MagicStaff_ChargeBar then return end
        local spriteData = data.HeadSpriteData
        if spriteData == nil or spriteData.SpriteType ~= "Cursed Eye" then
            data.HeadSpriteData = {
                Sprite = Sprite("gfx/characters/316_cursedeye.anm2", true),
                SpriteType = "Cursed Eye",
                Update = false,
            }
            spriteData = data.HeadSpriteData
        end
        local sprite = spriteData.Sprite
        
        local dir = player:GetHeadDirection()
        local charge = data.MagicStaff_ChargeBar.Charge / data.MagicStaff_ChargeBar.MaxCharge

        if charge == 1 then
            if not sprite:IsPlaying(DirToHeadAnim[dir].."ChargeFull") then
                sprite:Play(DirToHeadAnim[dir].."ChargeFull", true)
            end
            spriteData.Update = true
        else
            spriteData.Update = false
            sprite:SetFrame( DirToHeadAnim[dir].."Charge", 0)
        end

        renderHeadCostumes(player, renderPos, DirToHeadAnim[dir], PlayerSpriteLayer.SPRITE_HEAD, PlayerSpriteLayer.SPRITE_HEAD1)
        sprite:Render(renderPos)
        renderHeadCostumes(player, renderPos, DirToHeadAnim[dir], PlayerSpriteLayer.SPRITE_HEAD3)
        return false
    end
end)

BeckyMod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_MULTI_SHOT_PARAMS, -40000, function(_, player, multishotParam, weaponType)
    local num = player:GetEffects():GetNullEffectNum(BECKY_B.BlockItems.MonstrosLung) -1
    if num > 0 then
        num = num *5 -1 + multishotParam:GetNumTears()
        multishotParam:SetNumTears( num *multishotParam:GetNumEyesActive() )
        multishotParam:SetNumLanesPerEye( num )
        if multishotParam:GetSpreadAngle(weaponType) == 0 then
            multishotParam:SetSpreadAngle(weaponType, 4.34)
        end
        
    end
    if num == 0 and weaponType == WeaponType.WEAPON_BRIMSTONE and not player:HasCollectible(CollectibleType.COLLECTIBLE_EYE_SORE) then
        multishotParam:SetNumRandomDirTears( player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_MONSTROS_LUNG):RandomInt(3,5) + multishotParam:GetNumRandomDirTears() )
    end
    return multishotParam
end)


-----------------------------------------------------------------------------------
---------------------------FIRING WEAPONS AND STUFF--------------------------------
-----------------------------------------------------------------------------------

--SFXManager():Play(SoundEffect.SOUND_MONSTROS_LUG_CHARGE, 1.5)
--SFXManager():Play(SoundEffect.SOUND_MONSTROS_LUNG_BARF, 1.5)
local SPREAD_RANGE = 20
DoNeptunusCluster = function (entShooting, player, charge)
    if charge < 0.05 then return end
    local shotSpeed = player:GetAimDirection():Resized(player.ShotSpeed *10)
    local shotPos = entShooting.Position
    local mult = 1
    local multishotParams = player:GetMultiShotParams(WeaponType.WEAPON_TEARS)
    local tps = BeckyMod:toTearsPerSecond(player.MaxFireDelay)

    if entShooting.Type == 3 and player:HasTrinket(TrinketType.TRINKET_FORGOTTEN_LULLABY) then tps = tps *2 end
    
    local TearsShoot = 12 + math.floor(multishotParams:GetNumTears() *2.4) * (tps *0.66)
    TearsShoot = math.floor(TearsShoot * charge)


    if entShooting.Type == 3 then
        local fam = entShooting:ToFamiliar()
        if entShooting.Variant == FamiliarVariant.TWISTED_BABY then
            mult = mult * 0.375
        elseif entShooting.Variant == FamiliarVariant.BLOOD_BABY then
            mult = mult * 0.35
        else
            mult = mult * 0.75
        end
        mult = mult * fam:GetMultiplier()
    end
    if ShouldDoChocolateMilk(player) then
        local chocoMult = math.max(BeckyMod:Lerp(0, 2.5, charge), 0.075)
        mult = mult * chocoMult
    end

    if BeckyMod.Spells:HasSpell(player, BeckyMod.Spells.SpellType.SPELL_DMG_UP) then
        mult = mult * 1.35
    end

    if TearsShoot > 48 then
        mult = mult * (1 + (TearsShoot - 48) / 48)
        TearsShoot = 48
    elseif TearsShoot <= 0 and charge > 0.2 then
        TearsShoot = 1
    end

    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_NEPTUNUS)
    --player.TearRange * (1.1 - 0.9 * rng:RandomFloat())
    local fallingAcc = 0.75 * (6.5 / (player.TearRange /40))
    

    for i=1, TearsShoot do
        local tear = player:FireTear(
            shotPos,
            shotSpeed:Rotated(BeckyMod.RandomFloat(-SPREAD_RANGE, SPREAD_RANGE, rng)),
            true, true, true, entShooting, mult
        )
        tear.FallingSpeed = BeckyMod.RandomFloat(-8, 4, rng)
        tear.FallingAcceleration = fallingAcc
    end
        

    if multishotParams:IsShootingBackwards() then
        for i=1, TearsShoot do
            local tear = player:FireTear(
                shotPos,
                shotSpeed:Rotated(BeckyMod.RandomFloat(-SPREAD_RANGE, SPREAD_RANGE, rng) +180),
                true, false, false, entShooting, mult
            )
            tear.FallingSpeed = BeckyMod.RandomFloat(-8, 4, rng)
            tear.FallingAcceleration = fallingAcc
        end
    end
    if multishotParams:IsShootingSideways() then
        for angle=-90, 90, 180 do

            for i=1, TearsShoot do
                local tear = player:FireTear(
                    shotPos,
                    shotSpeed:Rotated(BeckyMod.RandomFloat(-SPREAD_RANGE, SPREAD_RANGE, rng) +angle),
                    true, false, false, entShooting, mult
                )
                tear.FallingSpeed = BeckyMod.RandomFloat(-8, 4, rng)
                tear.FallingAcceleration = fallingAcc
            end
        end
    end
end

local MONSTROS_LUNG_SPREAD = 30
local function MonstrosLung_Tears(entShooting, player, shotDir, shotPos, shotSpeed, moveInhe, fireData, multishotParams, mult)
    local sizeMult = 1
    if fireData.ChocoMilk and fireData.ChocoMilk < 1 then sizeMult = fireData.ChocoMilk end
    local weapTab = {}
    local TearsShoot= math.floor( (14 + math.floor((multishotParams:GetNumTears() -1) *2.4)) * sizeMult )
    if fireData.Haemolacria then TearsShoot = math.ceil(TearsShoot *0.57) end
    local fallingAcc = 0.75 * ((player.TearRange /40) / 6.5)
    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_MONSTROS_LUNG)
    

    for i=1, TearsShoot do
        local tear = player:FireTear(
            shotPos,
            shotDir:Resized(shotSpeed):Rotated(BeckyMod.RandomFloat(-MONSTROS_LUNG_SPREAD, MONSTROS_LUNG_SPREAD, rng)) + moveInhe,
            fireData.CanBeEye, fireData.TractorBeam, true, entShooting, mult
        )
        tear.FallingSpeed = BeckyMod.RandomFloat(-8, 4, rng)
        tear.FallingAcceleration = fallingAcc
        tear.Scale = tear.Scale * BeckyMod.RandomFloat(0.9, 1.33, rng)

        table.insert(weapTab, tear)
    end

    return weapTab
end


local function MonstrosLung_Laser(entShooting, player, shotDir, shotPos, shotSpeed, moveInhe, fireData, multishotParams, mult)
    local sizeMult = 1
    if fireData.ChocoMilk and fireData.ChocoMilk < 1 then sizeMult = fireData.ChocoMilk end
    local weapTab = {}
    local TearsShoot= math.floor( (math.min(multishotParams:GetNumTears() *12, 128)) * sizeMult )
    local fallingAcc = 0.75 * ((player.TearRange /40) / 6.5)
    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_MONSTROS_LUNG)
    

    for i=1, TearsShoot do
        local laser = player:FireTechLaser(
            shotPos,
            LaserOffset.LASER_TECH1_OFFSET,
            shotDir:Rotated(BeckyMod.RandomFloat(-MONSTROS_LUNG_SPREAD, MONSTROS_LUNG_SPREAD, rng)) + moveInhe,
            false, false, entShooting, mult
        )
        laser.MaxDistance = player.TearRange * BeckyMod.RandomFloat(0.25, 0.4, rng)
        laser:SetNumChainedLasers(rng:RandomInt(3,4) + laser:GetNumChainedLasers())

        table.insert(weapTab, laser)
    end

    return weapTab
end


local function MonstrosLung_TechX(entShooting, player, shotDir, shotPos, shotSpeed, moveInhe, fireData, multishotParams, mult)
    local weapTab = {}
    local TearsShoot= multishotParams:GetNumTears() *3
    local fallingAcc = 0.75 * ((player.TearRange /40) / 6.5)
    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_MONSTROS_LUNG)
    
    for i=1, rng:RandomInt(TearsShoot, TearsShoot * (1 + 2/3)) do
        local laserMult = BeckyMod.RandomFloat(0.5, 1, rng)
        local laser = player:FireTechXLaser(
            shotPos,
            shotDir:Resized(shotSpeed):Rotated(BeckyMod.RandomFloat(-MONSTROS_LUNG_SPREAD, MONSTROS_LUNG_SPREAD, rng)) + moveInhe,
            40 * fireData.TechXCharge *laserMult,
            entShooting,
            mult *laserMult
        )

        table.insert(weapTab, laser)
    end

    return weapTab
end


local function MonstrosLung_Bomb(entShooting, player, shotDir, shotPos, shotSpeed, moveInhe, fireData, multishotParams, mult)
    local weapTab = {}
    local TearsShoot= 6 + multishotParams:GetNumTears() -1
    local fallingAcc = 0.75 * ((player.TearRange /40) / 6.5)
    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_MONSTROS_LUNG)
    
    for i=1, TearsShoot do
        local bomb = player:FireBomb(
            shotPos,
            shotDir:Resized(shotSpeed):Rotated(BeckyMod.RandomFloat(-MONSTROS_LUNG_SPREAD, MONSTROS_LUNG_SPREAD, rng)) + moveInhe,
            entShooting
        )
        bomb:SetScale(0.5)
        bomb:SetFallSpeed(BeckyMod.RandomFloat(-8, 4, rng))
        bomb:SetFallAcceleration(fallingAcc)
        bomb:SetExplosionCountdown( math.floor(bomb:GetExplosionCountdown() * BeckyMod.RandomFloat(0.86, 1.2, rng)) )

        table.insert(weapTab, bomb)
    end

    return weapTab
end



---@param entShooting   - the entity that is shooting. can be the player or a familiar
---@param player        - entity player
---@param fireData      - table
    ---@param ForceDir      - force a shooting direction
    ---@param ForceMult     - force a damage multiplayer
    ---@param CanBeEye      - can be evil eye. only tears stuff
    ---@param ExtraTears    - can shoot tears like moms contact or lokis horn
    ---@param TractorBeam   -
    ---@param CursedEye     -
    ---@param MonstrosLung  -
    ---@param ChocoMilk     -
---@return (weapon entity type)[]
function BECKY_B:FireWeapon(entShooting, player, fireData)
    fireData = fireData or {}
    local shotDir = fireData.ForceDir or GetAimVector(entShooting, player)
    if fireData.CanBeEye == nil then fireData.CanBeEye = true end
    if fireData.ExtraTears == nil then fireData.ExtraTears = true end
    if fireData.TractorBeam == nil then fireData.TractorBeam = true end
    --if fireData.MonstrosLung == nil then fireData.MonstrosLung = player:HasCollectible(CollectibleType.COLLECTIBLE_MONSTROS_LUNG) or player:HasCollectible(BECKY_B.FakeItems.Monstros_Lung) end
    local effects = player:GetEffects()

    local shotSpeed = player.ShotSpeed *10
    local shotPos = entShooting.Position
    local scale = entShooting.Size
    local mult = 1
    local weaponList = {}

    --if player:GetPlayerType() == BECKY_B.PLAYERTYPE then
    --    mult = 3.25
    --end

    if entShooting.Type == 3 then
        local fam = entShooting:ToFamiliar()
        if entShooting.Variant == FamiliarVariant.TWISTED_BABY then
            mult = mult * 0.375
        elseif entShooting.Variant == FamiliarVariant.BLOOD_BABY then
            mult = mult * 0.35
        else
            mult = mult * 0.75
        end
        mult = mult * fam:GetMultiplier()
    end
    if fireData.ChocoMilk then
        mult = mult *fireData.ChocoMilk
    end

    if BeckyMod.Spells:HasSpell(player, BeckyMod.Spells.SpellType.SPELL_DMG_UP) then
        mult = mult * 1.35
    end

    if fireData.ForceMult then mult = fireData.ForceMult end
    if fireData.CursedEye then
        fireData.ExtraTears = false
    end

    local moveInhe = player:GetTearMovementInheritance(shotDir)
    if effects:HasNullEffect(BECKY_B.BlockItems.EpicFetus) then
        local multishotParams = player:GetMultiShotParams(WeaponType.WEAPON_BOMBS)
        
        if fireData.MonstroLung then
            BeckyMod:AppendTable(weaponList, MonstrosLung_Bomb(
                entShooting,
                player,
                shotDir, shotPos, shotSpeed, moveInhe,
                fireData,
                multishotParams,
                mult))
        else
            for i=0, multishotParams:GetNumTears()-1 do
                local posVel = player:GetMultiShotPositionVelocity(i, WeaponType.WEAPON_BOMBS, shotDir, shotSpeed, multishotParams)
                local bomb = player:FireBomb(shotPos + posVel.Position *scale, posVel.Velocity + moveInhe, entShooting)
                table.insert(weaponList, bomb)
            end
        end

        if fireData.ExtraTears then
            if multishotParams:IsShootingBackwards() then
                local bomb = player:FireBomb(shotPos, shotDir:Resized(shotSpeed):Rotated(180) , entShooting)
                table.insert(weaponList, bomb)
            end
            if multishotParams:IsShootingSideways() then
                for angle=-90, 90, 180 do
                    local bomb = player:FireBomb(shotPos, shotDir:Resized(shotSpeed):Rotated(angle) , entShooting)
                    table.insert(weaponList, bomb)
                end
            end

            for i=1, multishotParams:GetNumRandomDirTears() do
                local angle = Random() % 360
                local bomb = player:FireBomb(shotPos, shotDir:Resized(shotSpeed):Rotated(angle) , entShooting)
                table.insert(weaponList, bomb)
            end
        end

        if fireData.ChocoMilk then mult = mult / fireData.ChocoMilk end
        for _, ent in ipairs(weaponList) do
            local bomb = ent:ToBomb()
            if bomb then
                bomb.ExplosionDamage = bomb.ExplosionDamage *mult
            end
        end

    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_C_SECTION) then
        local multishotParams = player:GetMultiShotParams(WeaponType.WEAPON_FETUS)
        local tearFlags = TearFlags.TEAR_FETUS
        if effects:HasNullEffect(BECKY_B.BlockItems.DrFetus) then tearFlags = tearFlags | TearFlags.TEAR_FETUS_BOMBER end
        if player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X) then tearFlags = tearFlags | TearFlags.TEAR_FETUS_TECHX end
        if player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) then tearFlags = tearFlags | TearFlags.TEAR_FETUS_BRIMSTONE end
        if player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY) then tearFlags = tearFlags | TearFlags.TEAR_FETUS_TECH end
        if player:HasCollectible(CollectibleType.COLLECTIBLE_SPIRIT_SWORD) then tearFlags = tearFlags | TearFlags.TEAR_FETUS_SWORD
        elseif player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE) then tearFlags = tearFlags | TearFlags.TEAR_FETUS_KNIFE end

        for i=0, multishotParams:GetNumTears()-1 do
            local posVel = player:GetMultiShotPositionVelocity(i, WeaponType.WEAPON_FETUS, shotDir, shotSpeed, multishotParams)
            local tear = player:FireTear(
                shotPos + posVel.Position *scale,
                posVel.Velocity,
                false, true, true, entShooting, mult
            )
            tear:ChangeVariant(TearVariant.FETUS)
            tear:AddTearFlags(tearFlags)
            
            table.insert(weaponList, tear)
        end

        if fireData.ExtraTears then
            if multishotParams:IsShootingBackwards() then
                local tear = player:FireTear(
                    shotPos,
                    shotDir:Resized(shotSpeed):Rotated(180),
                    false, false, false, entShooting, mult
                )
                tear:ChangeVariant(TearVariant.FETUS)
                tear:AddTearFlags(tearFlags)

                table.insert(weaponList, tear)
            end
            if multishotParams:IsShootingSideways() then
                for angle=-90, 90, 180 do
                    local tear = player:FireTear(
                        shotPos,
                        shotDir:Resized(shotSpeed):Rotated(angle),
                        false, false, false, entShooting, mult
                    )
                    tear:ChangeVariant(TearVariant.FETUS)
                    tear:AddTearFlags(tearFlags)
                
                    table.insert(weaponList, tear)
                end
            end

            for i=1, multishotParams:GetNumRandomDirTears() do
                local angle = Random() % 360
                local tear = player:FireTear(
                    shotPos,
                    shotDir:Resized(shotSpeed):Rotated(angle),
                    false, false, false, entShooting, mult
                )
                tear:ChangeVariant(TearVariant.FETUS)
                tear:AddTearFlags(tearFlags)
                
                table.insert(weaponList, tear)
            end
        end
    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_HAEMOLACRIA) then
        local multishotParams = player:GetMultiShotParams(WeaponType.WEAPON_TEARS)
        fireData.Haemolacria = true

        if fireData.MonstroLung then
            BeckyMod:AppendTable(weaponList, MonstrosLung_Tears(
                entShooting,
                player, shotDir, shotPos, shotSpeed, moveInhe,
                fireData,
                multishotParams,
                mult))
        else
            for i=0, multishotParams:GetNumTears()-1 do
                local posVel = player:GetMultiShotPositionVelocity(i, WeaponType.WEAPON_TEARS, shotDir, shotSpeed, multishotParams)
                local tear = player:FireTear(
                    shotPos + posVel.Position *scale,
                    posVel.Velocity + moveInhe,
                    fireData.CanBeEye, fireData.TractorBeam, true, entShooting, mult
                )
                table.insert(weaponList, tear)
            end
        end

        if fireData.ExtraTears then
            fireData.TractorBeam = false
            if multishotParams:IsShootingBackwards() then
                if fireData.MonstroLung then
                    BeckyMod:AppendTable(weaponList, MonstrosLung_Tears(
                        entShooting,
                        player,
                        shotDir:Rotated(180),
                        shotPos, shotSpeed, Vector.Zero,
                        fireData,
                        multishotParams,
                        mult))
                else
                    local tear = player:FireTear(
                        shotPos,
                        shotDir:Resized(shotSpeed):Rotated(180),
                        fireData.CanBeEye, false, false, entShooting, mult
                    )

                    table.insert(weaponList, tear)
                end
            end
            if multishotParams:IsShootingSideways() then
                for angle=-90, 90, 180 do
                    if fireData.MonstroLung then
                        BeckyMod:AppendTable(weaponList, MonstrosLung_Tears(
                            entShooting,
                            player,
                            shotDir:Rotated(angle),
                            shotPos, shotSpeed, Vector.Zero,
                            fireData,
                            multishotParams,
                            mult))
                    else
                        local tear = player:FireTear(
                            shotPos,
                            shotDir:Resized(shotSpeed):Rotated(angle),
                            fireData.CanBeEye, false, false, entShooting, mult
                        )
                    
                        table.insert(weaponList, tear)
                    end
                end
            end

            for i=1, multishotParams:GetNumRandomDirTears() do
                local angle = Random() % 360
                if fireData.MonstroLung then
                    BeckyMod:AppendTable(weaponList, MonstrosLung_Tears(
                        entShooting,
                        player,
                        shotDir:Rotated(angle),
                        shotPos, shotSpeed, Vector.Zero,
                        fireData,
                        multishotParams,
                        mult))
                else
                    local tear = player:FireTear(
                        shotPos,
                        shotDir:Resized(shotSpeed):Rotated(angle),
                        fireData.CanBeEye, false, false, entShooting, mult
                    )
                    
                    table.insert(weaponList, tear)
                end
            end
        end
    elseif effects:HasNullEffect(BECKY_B.BlockItems.DrFetus) then
        local multishotParams = player:GetMultiShotParams(WeaponType.WEAPON_BOMBS)
        
        if fireData.MonstroLung then
            BeckyMod:AppendTable(weaponList, MonstrosLung_Bomb(
                entShooting,
                player,
                shotDir, shotPos, shotSpeed, moveInhe,
                fireData,
                multishotParams,
                mult))
        else
            for i=0, multishotParams:GetNumTears()-1 do
                local posVel = player:GetMultiShotPositionVelocity(i, WeaponType.WEAPON_BOMBS, shotDir, shotSpeed, multishotParams)
                local bomb = player:FireBomb(shotPos + posVel.Position *scale, posVel.Velocity + moveInhe, entShooting)
                table.insert(weaponList, bomb)
            end
        end

        if fireData.ExtraTears then
            if multishotParams:IsShootingBackwards() then
                local bomb = player:FireBomb(shotPos, shotDir:Resized(shotSpeed):Rotated(180) , entShooting)
                table.insert(weaponList, bomb)
            end
            if multishotParams:IsShootingSideways() then
                for angle=-90, 90, 180 do
                    local bomb = player:FireBomb(shotPos, shotDir:Resized(shotSpeed):Rotated(angle) , entShooting)
                    table.insert(weaponList, bomb)
                end
            end

            for i=1, multishotParams:GetNumRandomDirTears() do
                local angle = Random() % 360
                local bomb = player:FireBomb(shotPos, shotDir:Resized(shotSpeed):Rotated(angle) , entShooting)
                table.insert(weaponList, bomb)
            end
        end

        if fireData.ChocoMilk then mult = mult / fireData.ChocoMilk end
        for _, ent in ipairs(weaponList) do
            local bomb = ent:ToBomb()
            if bomb then
                bomb.ExplosionDamage = bomb.ExplosionDamage *mult
            end
        end
    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X) then
        local multishotParams = player:GetMultiShotParams(WeaponType.WEAPON_TECH_X)
        local data = BeckyMod.GetEntData(entShooting)
        local charge = BeckyMod:InverseLerp(
            data.MagicStaff_ChargeBar.MaxCharge /7, 
            data.MagicStaff_ChargeBar.MaxCharge,
            data.MagicStaff_ChargeBar.Charge
        )

        mult = mult * BeckyMod:Lerp(0.25, 1, charge)
        fireData.TechXCharge = charge
        for i=0, multishotParams:GetNumTears()-1 do
            local posVel = player:GetMultiShotPositionVelocity(i, WeaponType.WEAPON_TECH_X, shotDir, shotSpeed, multishotParams)
            local tech_x = player:FireTechXLaser(shotPos + posVel.Position *scale, posVel.Velocity + moveInhe, 40 * charge, entShooting, mult)
            table.insert(weaponList, tech_x)
        end
        if fireData.MonstroLung then
            BeckyMod:AppendTable(weaponList, MonstrosLung_TechX(
                entShooting,
                player,
                shotDir, shotPos, shotSpeed, moveInhe,
                fireData,
                multishotParams,
                mult))
        end

        if fireData.ExtraTears then
            if multishotParams:IsShootingBackwards() then
                local tech_x = player:FireTechXLaser(shotPos, shotDir:Resized(shotSpeed):Rotated(180), 40 * charge, entShooting, mult)
                table.insert(weaponList, tech_x)
            end
            if multishotParams:IsShootingSideways() then
                for angle=0, 180, 180 do
                    local tech_x = player:FireTechXLaser(shotPos, shotDir:Resized(shotSpeed):Rotated(angle), 40 * charge, entShooting, mult)
                    table.insert(weaponList, tech_x)
                end
            end

            for i=1, multishotParams:GetNumRandomDirTears() do
                local angle = Random() % 360
                local tech_x = player:FireTechXLaser(shotPos, shotDir:Resized(shotSpeed):Rotated(angle), 40 * charge, entShooting, mult)
                table.insert(weaponList, tech_x)
            end
        end
    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) then
        local multishotParams = player:GetMultiShotParams(WeaponType.WEAPON_BRIMSTONE)
        local widthMult = 1
        if fireData.ChocoMilk then
            mult = mult / fireData.ChocoMilk

            local charge = BeckyMod:InverseLerp(0, 4, fireData.ChocoMilk)
            local chocoMult = BeckyMod:Lerp(0, 2.5, charge)
            if chocoMult < 0.25 then chocoMult = 0.25 end

            mult = mult * chocoMult

            --widthMult = BeckyMod:Lerp(0, 0.79056942462921, charge)
            --if widthMult < 0.5 then widthMult = 0.5 end
        end

        for i=0, multishotParams:GetNumTears()-1 do
            local posVel = player:GetMultiShotPositionVelocity(i, WeaponType.WEAPON_BRIMSTONE, shotDir, shotSpeed, multishotParams)
            local brim = player:FireBrimstone(posVel.Velocity, entShooting, mult)
            brim.Parent = entShooting
            if brim == nil or not brim:Exists() then print("Brimstone fail to be fire with", player.Damage * mult,"damage. fired by", entShooting.Type,"",entShooting.Variant) end
            table.insert(weaponList, brim)
        end
        
        if fireData.ExtraTears then
            if multishotParams:IsShootingBackwards() then
                local brim = player:FireBrimstone(shotDir:Resized(shotSpeed):Rotated(180), entShooting, mult)
                table.insert(weaponList, brim)
            end
            if multishotParams:IsShootingSideways() then
                for angle=-90, 90, 180 do
                    local brim = player:FireBrimstone(shotDir:Resized(shotSpeed):Rotated(angle), entShooting, mult)
                    table.insert(weaponList, brim)
                end
            end

            for i=1, multishotParams:GetNumRandomDirTears() do
                local angle = Random() % 360
                local brim = player:FireBrimstone(shotDir:Resized(shotSpeed):Rotated(angle), entShooting, mult)
                table.insert(weaponList, brim)
            end
        end
        
        --[[
        for _, ent in ipairs(weaponList) do
            local laser = ent:ToLaser()
            if laser then
                laser:SetScale(laser:GetScale() / 2)
            end
        end]]
        
    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY) then
        local multishotParams = player:GetMultiShotParams(WeaponType.WEAPON_LASER)

        if fireData.MonstroLung then
            BeckyMod:AppendTable(weaponList, MonstrosLung_Laser(
                entShooting,
                player,
                shotDir, shotPos, shotSpeed, moveInhe,
                fireData,
                multishotParams,
                mult))
        else
            for i=0, multishotParams:GetNumTears()-1 do
                local posVel = player:GetMultiShotPositionVelocity(i, WeaponType.WEAPON_LASER, shotDir, shotSpeed, multishotParams)
                local tech = player:FireTechLaser(
                    shotPos + posVel.Position *scale,
                    LaserOffset.LASER_TECH1_OFFSET,
                    posVel.Velocity + moveInhe,
                    false, false, entShooting, mult
                )
                table.insert(weaponList, tech)
            end
        end

        if fireData.ExtraTears then
            if multishotParams:IsShootingBackwards() then
                local bomb = player:FireBomb(shotPos, shotDir:Resized(shotSpeed):Rotated(180) , entShooting)
                local tech = player:FireTechLaser(
                    shotPos,
                    LaserOffset.LASER_TECH1_OFFSET,
                    shotDir:Resized(shotSpeed):Rotated(180),
                    false, false, entShooting, mult
                )
                table.insert(weaponList, tech)
            end
            if multishotParams:IsShootingSideways() then
                for angle=-90, 90, 180 do
                    local tech = player:FireTechLaser(
                        shotPos,
                        LaserOffset.LASER_TECH1_OFFSET,
                        shotDir:Resized(shotSpeed):Rotated(angle),
                        false, false, entShooting, mult
                    )
                    table.insert(weaponList, tech)
                end
            end

            for i=1, multishotParams:GetNumRandomDirTears() do
                local angle = Random() % 360
                local tech = player:FireTechLaser(
                    shotPos,
                    LaserOffset.LASER_TECH1_OFFSET,
                    shotDir:Resized(shotSpeed):Rotated(angle),
                    false, false, entShooting, mult
                )
                table.insert(weaponList, tech)
            end
        end
    --elseif player:HasCollectible(CollectibleType.COLLECTIBLE_) then
    --elseif player:HasCollectible(CollectibleType.COLLECTIBLE_) then
    --elseif player:HasCollectible(CollectibleType.COLLECTIBLE_) then
    else
        local multishotParams = player:GetMultiShotParams(WeaponType.WEAPON_TEARS)

        if fireData.MonstroLung then
            BeckyMod:AppendTable(weaponList, MonstrosLung_Tears(
                entShooting,
                player, shotDir, shotPos, shotSpeed, moveInhe,
                fireData,
                multishotParams,
                mult))
        else
            for i=0, multishotParams:GetNumTears()-1 do
                local posVel = player:GetMultiShotPositionVelocity(i, WeaponType.WEAPON_TEARS, shotDir, shotSpeed, multishotParams)
                local tear = player:FireTear(
                    shotPos + posVel.Position *scale,
                    posVel.Velocity + moveInhe,
                    fireData.CanBeEye, fireData.TractorBeam, true, entShooting, mult
                )
                table.insert(weaponList, tear)
            end
        end

        if fireData.ExtraTears then
            fireData.TractorBeam = false
            if multishotParams:IsShootingBackwards() then
                if fireData.MonstroLung then
                    BeckyMod:AppendTable(weaponList, MonstrosLung_Tears(
                        entShooting,
                        player,
                        shotDir:Rotated(180),
                        shotPos, shotSpeed, Vector.Zero,
                        fireData,
                        multishotParams,
                        mult))
                else
                    local tear = player:FireTear(
                        shotPos,
                        shotDir:Resized(shotSpeed):Rotated(180),
                        fireData.CanBeEye, false, false, entShooting, mult
                    )

                    table.insert(weaponList, tear)
                end
            end
            if multishotParams:IsShootingSideways() then
                for angle=-90, 90, 180 do
                    if fireData.MonstroLung then
                        BeckyMod:AppendTable(weaponList, MonstrosLung_Tears(
                            entShooting,
                            player,
                            shotDir:Rotated(angle),
                            shotPos, shotSpeed, Vector.Zero,
                            fireData,
                            multishotParams,
                            mult))
                    else
                        local tear = player:FireTear(
                            shotPos,
                            shotDir:Resized(shotSpeed):Rotated(angle),
                            fireData.CanBeEye, false, false, entShooting, mult
                        )
                    
                        table.insert(weaponList, tear)
                    end
                end
            end

            for i=1, multishotParams:GetNumRandomDirTears() do
                local angle = Random() % 360
                if fireData.MonstroLung then
                    BeckyMod:AppendTable(weaponList, MonstrosLung_Tears(
                        entShooting,
                        player,
                        shotDir:Rotated(angle),
                        shotPos, shotSpeed, Vector.Zero,
                        fireData,
                        multishotParams,
                        mult))
                else
                    local tear = player:FireTear(
                        shotPos,
                        shotDir:Resized(shotSpeed):Rotated(angle),
                        fireData.CanBeEye, false, false, entShooting, mult
                    )
                    
                    table.insert(weaponList, tear)
                end
            end
        end
    end

    for _, ent in ipairs(weaponList) do
        local color = ent:GetSprite().Color
        color:SetColorize(1, 1, 1, 0.66)
        ent:GetSprite().Color = color
    end

    return weaponList
end
