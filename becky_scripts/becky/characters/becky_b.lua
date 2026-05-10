local BECKY_B = {}

BECKY_B.PLAYERTYPE = Isaac.GetPlayerTypeByName("Becky", true)

BECKY_B.HAIR_COSTUME = Isaac.GetCostumeIdByPath("gfx/characters/becky_b_hair.anm2")
BECKY_B.BODY_COSTUME = Isaac.GetCostumeIdByPath("gfx/characters/becky_b_scarf.anm2")

local taintedBeckysWandAnim = "gfx/becky_magic_staff.anm2"
BECKY_B.StaffFireSprite = Sprite(taintedBeckysWandAnim, true)
BECKY_B.ManaBarSprite = Sprite("gfx/ui/taintedBecky/mana_bar.anm2", true)

BECKY_B.ManaTearCost = 10
BECKY_B.ManaRegenBuffZone = 15   -- (og thing ->) 1/16 * 100 

local game = BeckyMod.Game
local sfx = BeckyMod.SFX

BeckyMod.Character.BECKY_B = BECKY_B

local BASE_TEAR_DPS = 30 /11 /2
local MAX_TEARS_DPS_C_SECTION = 30 / (149.66666667*3+1)
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


local function GetBecky(entity)
    local player = BeckyMod:TryGetPlayer(entity, false)
    if player then player = player:ToPlayer() else return end
    if player == nil or player:GetPlayerType() ~= BECKY_B.PLAYERTYPE then return end
    return player
end


local function GetAimVector(owner, player)
    local markTarget = player:GetMarkedTarget()

    if owner.Type == 3 and player:HasCollectible(CollectibleType.COLLECTIBLE_KING_BABY) then
        local kingBaby = player:GetData().knownKingBaby

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
            player:GetData().knownKingBaby = kingBaby
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
    elseif markTarget then
        return (owner.Position - markTarget.Position):Normalized()
    end
    return player:GetLastDirection()
end

local function GetAimAngle(owner, player)
    return GetAimVector(owner, player):GetAngleDegrees()
end


local function ProcessStaffSwing(entShooting, player)
    local data = entShooting:GetData()
    --local save = BeckyMod:RunSave(player)
    if not player:IsExtraAnimationFinished() then
        if data.MagicStaff_ChargeBar then
            if player:HasCollectible(CollectibleType.COLLECTIBLE_CURSED_EYE) then
                if data.MagicStaff_ChargeBar.Charge >= data.MagicStaff_ChargeBar.MaxCharge /5 then
                    data.MagicStaff_CursedEyeTears = math.ceil(data.MagicStaff_ChargeBar.MaxCharge / data.MagicStaff_ChargeBar.Charge)
                    BECKY_B:FireWeapon(entShooting, player)
                end
            elseif data.MagicStaff_ChargeBar.Charge == data.MagicStaff_ChargeBar.MaxCharge then
                --save.ManaCharge = save.ManaCharge -BECKY_B.ManaTearCost
                --ShootManaTear(player, entShooting)
                BECKY_B:FireWeapon(entShooting, player)
            end
            data.MagicStaff_ChargeBar.Charge = 0
        end
        return 
    end
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
    if aimVec:Length() ~= 0 then
        local sprite = knife:GetSprite()
        local SoyMilkMod = weapon:GetModifiers() & (WeaponModifier.CHOCOLATE_MILK | WeaponModifier.SOY_MILK) > 0
        if not SoyMilkMod and sprite:GetAnimation():match("Swing") and sprite:GetFrame() < sprite:GetCurrentAnimationData():GetLength() - 3 then return end
        --if entShooting.Type == 1 and save.ManaCharge < BECKY_B.ManaTearCost then return end
        local addToCharge = 1
        if player:HasCollectible(CollectibleType.COLLECTIBLE_C_SECTION) then
            local c_sectionCharge = 30 /(player.MaxFireDelay *3 +1)
            if c_sectionCharge < MAX_TEARS_DPS_C_SECTION then c_sectionCharge = MAX_TEARS_DPS_C_SECTION end
            addToCharge = addToCharge * (c_sectionCharge /BASE_TEAR_DPS * 1.25)
        else
            addToCharge = addToCharge * (BeckyMod:toTearsPerSecond(player.MaxFireDelay) /BASE_TEAR_DPS * 1.25)
        end
        if player:HasCollectible(CollectibleType.COLLECTIBLE_CURSED_EYE) then
            addToCharge = addToCharge /5
        end
        if entShooting.Type == 3 and player:HasTrinket(TrinketType.TRINKET_FORGOTTEN_LULLABY) then
            addToCharge = addToCharge * 2
        end
        data.MagicStaff_ChargeBar.Charge = math.min(data.MagicStaff_ChargeBar.Charge +addToCharge, data.MagicStaff_ChargeBar.MaxCharge)
        
        if player:HasCollectible(CollectibleType.COLLECTIBLE_MARKED) or SoyMilkMod then
            
            if player:HasCollectible(CollectibleType.COLLECTIBLE_CURSED_EYE) then
                if data.MagicStaff_ChargeBar.Charge >= data.MagicStaff_ChargeBar.MaxCharge /5 then
                    data.MagicStaff_CursedEyeTears = math.ceil(data.MagicStaff_ChargeBar.MaxCharge / data.MagicStaff_ChargeBar.Charge)
                    BECKY_B:FireWeapon(entShooting, player)
                end
            elseif data.MagicStaff_ChargeBar.Charge == data.MagicStaff_ChargeBar.MaxCharge then
                --save.ManaCharge = save.ManaCharge -BECKY_B.ManaTearCost
                --ShootManaTear(player, entShooting)
                BECKY_B:FireWeapon(entShooting, player)
            end

            data.MagicStaff_ChargeBar.Charge = 0
        else
            local fireDelay = weapon:GetFireDelay()
            if fireDelay < 0.5 then fireDelay = 0.5 end
            weapon:SetFireDelay(fireDelay)
        end
    else
        
        if player:HasCollectible(CollectibleType.COLLECTIBLE_CURSED_EYE) then
            if data.MagicStaff_ChargeBar.Charge >= data.MagicStaff_ChargeBar.MaxCharge /5 then
                data.MagicStaff_CursedEyeTears = math.ceil(data.MagicStaff_ChargeBar.MaxCharge / data.MagicStaff_ChargeBar.Charge)
                BECKY_B:FireWeapon(entShooting, player)
            end
        elseif data.MagicStaff_ChargeBar.Charge == data.MagicStaff_ChargeBar.MaxCharge then
            --save.ManaCharge = save.ManaCharge -BECKY_B.ManaTearCost
            --ShootManaTear(player, entShooting)
            BECKY_B:FireWeapon(entShooting, player)
        end
        data.MagicStaff_ChargeBar.Charge = 0
    end
end


BeckyMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function(_, player)
    if player:GetPlayerType() ~= BECKY_B.PLAYERTYPE then return end
    PlayerAnimLib:SetDefaultAnm2(player, "gfx/player_becky_b.anm2")
    player:AddNullCostume(BECKY_B.BODY_COSTUME)
    local save = BeckyMod:RunSave(player)
    save.ManaCharge = save.ManaCharge or 0
end)


BeckyMod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, 200, function(_, player, cacheFlags)
    if player:GetPlayerType() ~= BECKY_B.PLAYERTYPE then return end
    if CacheFlag.CACHE_DAMAGE & cacheFlags > 0 then
        player.Damage = player.Damage * 0.5
    elseif CacheFlag.CACHE_FIREDELAY & cacheFlags > 0 then
        local tps = BeckyMod:toTearsPerSecond(player.MaxFireDelay)
        --tps = tps * 0.42
        player.MaxFireDelay = BeckyMod:toMaxFireDelay(tps)
    end
end)


BeckyMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
    if player:GetPlayerType() ~= BECKY_B.PLAYERTYPE then return end
    if player:IsDead() then return end
    local weapon = player:GetWeapon(1)
    if weapon == nil or weapon:GetWeaponType() ~= WeaponType.WEAPON_BONE then
        if weapon then Isaac.DestroyWeapon(weapon) end
        weapon = Isaac.CreateWeapon(WeaponType.WEAPON_BONE, player)
        player:SetWeapon(weapon, 1)
        player:EnableWeaponType(WeaponType.WEAPON_BONE, 1)
        --player:SetWeapon()
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE| CacheFlag.CACHE_FIREDELAY, true)
    end
    if weapon:GetMainEntity() == nil then return end
    local data = player:GetData()
    if data.MagicStaff_ChargeBar and data.MagicStaff_ChargeBar.Charge > 0 then
        weapon:SetCharge(1.0)
    else
        weapon:SetCharge(0.0)
    end
end)

BeckyMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)
    if player:GetPlayerType() ~= BECKY_B.PLAYERTYPE or player:IsDead() then return end
    local data = player:GetData()
    
    ProcessStaffSwing(player, player)
end)


BeckyMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
    if BECKY_B.FamiliarWhiteList[fam.Variant] == nil then return end

    local player = fam.Player
    if player == nil or player:GetPlayerType() ~= BECKY_B.PLAYERTYPE then return end
    
    if player:IsDead() then return end
    local weapon = fam:GetWeapon()
    if weapon == nil or weapon:GetMainEntity() == nil then return end
    
    local data = fam:GetData()
    if data.MagicStaff_ChargeBar and data.MagicStaff_ChargeBar.Charge > 0 then
        weapon:SetCharge(1.0)
    else
        weapon:SetCharge(0.0)
    end
    ProcessStaffSwing(fam, player)
end)


-------------------------------------------------
--------------------MANA STUFF-------------------
-------------------------------------------------
BeckyMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)
    if player:GetPlayerType() ~= BECKY_B.PLAYERTYPE then return end
    local save = BeckyMod:RunSave(player)
    local data = player:GetData()
    local manaCap = 100 - (data.MaxManaOffset or 0)

    if BeckyMod.Spells:HasSpell(player, BeckyMod.Spells.SpellType.MANA_REGEN) and (data.NoChargeMana == nil or data.NoChargeMana <= 0) then
        if not game:GetRoom():IsClear() then
            local midCap = 50 - (data.MaxManaOffset or 0)
            if save.ManaCharge < midCap then
                save.ManaCharge = save.ManaCharge + 0.025
            end
        end
    end

    if save.ManaCharge > 0 and data.ManaDischarge and data.ManaDischarge > 0 then
        save.ManaCharge = math.max(save.ManaCharge -data.ManaDischarge, 0)
    end
    if save.ManaCharge > manaCap then save.ManaCharge = manaCap end
end)


BeckyMod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, function(_, ent, dmg, dmgFlags, src, cooldown)
    if ent.Type == 1 or dmg <= 0 then return end
    if not BeckyMod.IsEnemy(ent) or not ent:CanShutDoors() or ent:ToNPC() == nil then return end
    if not (ent:GetEntityFlags() & (EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_ICE_FROZEN) > 0 or dmgFlags & (DamageFlag.DAMAGE_FAKE | DamageFlag.DAMAGE_CLONES) ) then return end
    local player = src.Entity
    if player == nil then return
    else player = BeckyMod:TryGetPlayer(player, false) end

    if player == nil or player:GetPlayerType() ~= BECKY_B.PLAYERTYPE then return end
    local data = player:GetData()
    if not (data.NoChargeMana and data.NoChargeMana > 0) then
        local save = BeckyMod:RunSave(player)
        save.ManaCharge = save.ManaCharge + math.min(ent.HitPoints, dmg) *1.12
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
    if knife.FrameCount >1 then
        knife.Charge = -1
        return
    end

    local sp = knife:GetSprite()
    sp:Load(taintedBeckysWandAnim, true)
    sp:Play("Idle", true)
end, KnifeSubType.DEFAULT)

BeckyMod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, function(_, knife)
    local player = GetBecky(knife.Parent)
    if player == nil then return end
    if not BECKY_B.ValidBoneClubs[knife.Variant] then return end
    if knife.FrameCount >1 then 
        local parent = knife:GetHitboxParentKnife()
        if parent ~= nil and parent.SpriteScale then
            knife.SpriteScale = parent.SpriteScale * 1.33
        end
        knife:GetSprite().Color.A = 0.0
        return
    end

    local sp = knife:GetSprite()
    local isPlaying = sp:GetAnimation()
    sp:Load(taintedBeckysWandAnim, true)
    sp:Play(isPlaying, true)
    sp.Color.A = 0.0
end, KnifeSubType.CLUB_HITBOX)


BeckyMod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_MULTI_SHOT_PARAMS, 3000, function(_, player, multishotParam, weaponType)
    if player:GetPlayerType() == BECKY_B.PLAYERTYPE and weaponType == WeaponType.WEAPON_BONE then
        multishotParam:SetNumTears(1)
        multishotParam:SetNumLanesPerEye(1)
        multishotParam:SetSpreadAngle(WeaponType.WEAPON_BONE, 0)
        return multishotParam
    end
end)

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
        local manaOffset = (player:GetData().MaxManaOffset or 0)

        BECKY_B.ManaBarSprite:SetFrame("ChargeBar", math.floor(save.ManaCharge + manaOffset) )
        BECKY_B.ManaBarSprite:SetOverlayRenderPriority(false)
        BECKY_B.ManaBarSprite:SetOverlayFrame("ChargeBarGray", math.floor(manaOffset))
        BECKY_B.ManaBarSprite:Render(position)
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

	local chargeData = player:GetData().MagicStaff_ChargeBar
	if not chargeData then return end
    local sp = chargeData.Sprite
    UpdateChargebar(chargeData)
    if sp:IsPlaying("Disappear") or chargeData.Charge > 0  then
        sp:Render(game:GetRoom():WorldToScreenPosition( (player:GetFlyingOffset() *1.5) + player.Position + CHARGEBAR_POS))
    end
end

BeckyMod:AddPriorityCallback(ModCallbacks.MC_POST_ROOM_RENDER_ENTITIES, -300, function()
	if not Options.ChargeBars then return end
    BeckyMod:ForEachPlayer(renderPlayerChargebar)
end)


-----------------------------------------------------------------------------------
---------------------------FIRING WEAPONS AND STUFF--------------------------------
-----------------------------------------------------------------------------------


---@param entShooting   - the entity that is shooting. can be the player or a familiar
---@param player        - entity player
---@param forceDir      - force a shooting direction
---@param forceMult     - force a damage multiplayer
---@param canBeEye      - can be evil eye. only tears stuff
---@param extraTears    - can shoot tears like moms contact or lokis horn
---@return (weapon entity type)[]
function BECKY_B:FireWeapon(entShooting, player, forceDir, forceMult, canBeEye, extraTears)
    local shotDir = forceDir and forceDir or GetAimVector(entShooting, player)
    if canBeEye == nil then canBeEye = true end
    if extraTears == nil then extraTears = true end
    local shotSpeed = player.ShotSpeed *10
    local shotPos = entShooting.Position
    local scale = player.Size
    local mult = 1
    local weaponList = {}

    if player:GetPlayerType() == BECKY_B.PLAYERTYPE then
        mult = 3.25
    end

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
    if BeckyMod.Spells:HasSpell(player, BeckyMod.Spells.SpellType.SPELL_DMG_UP) then
        mult = mult * 1.25
    end

    if forceMult then mult = forceMult end

    if player:HasCollectible(CollectibleType.COLLECTIBLE_EPIC_FETUS) then
        local multishotParams = player:GetMultiShotParams(WeaponType.WEAPON_BOMBS)

        for i=0, multishotParams:GetNumTears()-1 do
            local bomb = player:FireBomb(shotPos + posVel.Position *scale, posVel.Velocity, entShooting)
            table.insert(weaponList, bomb)

            Isaac.RunCallback(ModCallbacks.MC_POST_FIRE_BOMB, bomb)
        end

        if extraTears then
            if multishotParams:IsShootingBackwards() then
                local bomb = player:FireBomb(shotPos, shotDir:Resized(shotSpeed):Rotated(shotDir:GetAngleDegrees() +180) , entShooting)
                table.insert(weaponList, bomb)

                Isaac.RunCallback(ModCallbacks.MC_POST_FIRE_BOMB, bomb)
            end
            if multishotParams:IsShootingSideways() then
                for angle=-90, 90, 180 do
                    local bomb = player:FireBomb(shotPos, shotDir:Resized(shotSpeed):Rotated(shotDir:GetAngleDegrees() + angle) , entShooting)
                    table.insert(weaponList, bomb)

                    Isaac.RunCallback(ModCallbacks.MC_POST_FIRE_BOMB, bomb)
                end
            end

            for i=1, multishotParams:GetNumRandomDirTears() do
                local angle = Random() % 360
                local bomb = player:FireBomb(shotPos, shotDir:Resized(shotSpeed):Rotated(shotDir:GetAngleDegrees() + angle) , entShooting)
                table.insert(weaponList, bomb)

                Isaac.RunCallback(ModCallbacks.MC_POST_FIRE_BOMB, bomb)
            end
        end

    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_C_SECTION) then
        local multishotParams = player:GetMultiShotParams(WeaponType.WEAPON_FETUS)
        local tearFlags = TearFlags.TEAR_FETUS
        if player:HasCollectible(CollectibleType.COLLECTIBLE_DR_FETUS) then tearFlags = tearFlags | TearFlags.TEAR_FETUS_BOMBER end
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
            Isaac.RunCallback(ModCallbacks.MC_POST_FIRE_TEAR, tear)
        end

        if extraTears then
            if multishotParams:IsShootingBackwards() then
                local tear = player:FireTear(
                    shotPos,
                    shotDir:Resized(shotSpeed):Rotated(shotDir:GetAngleDegrees() +180),
                    false, true, true, entShooting, mult
                )
                tear:ChangeVariant(TearVariant.FETUS)
                tear:AddTearFlags(tearFlags)

                table.insert(weaponList, tear)
                Isaac.RunCallback(ModCallbacks.MC_POST_FIRE_TEAR, tear)
            end
            if multishotParams:IsShootingSideways() then
                for angle=-90, 90, 180 do
                    local tear = player:FireTear(
                        shotPos,
                        shotDir:Resized(shotSpeed):Rotated(shotDir:GetAngleDegrees() +angle),
                        false, true, true, entShooting, mult
                    )
                    tear:ChangeVariant(TearVariant.FETUS)
                    tear:AddTearFlags(tearFlags)
                
                    table.insert(weaponList, tear)
                    Isaac.RunCallback(ModCallbacks.MC_POST_FIRE_TEAR, tear)
                end
            end

            for i=1, multishotParams:GetNumRandomDirTears() do
                local angle = Random() % 360
                local tear = player:FireTear(
                    shotPos,
                    shotDir:Resized(shotSpeed):Rotated(shotDir:GetAngleDegrees() +180),
                    false, true, true, entShooting, mult
                )
                tear:ChangeVariant(TearVariant.FETUS)
                tear:AddTearFlags(tearFlags)
                
                table.insert(weaponList, tear)
                Isaac.RunCallback(ModCallbacks.MC_POST_FIRE_TEAR, tear)
            end
        end
    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_DR_FETUS) then
        local multishotParams = player:GetMultiShotParams(WeaponType.WEAPON_BOMBS)

        for i=0, multishotParams:GetNumTears()-1 do
            local posVel = player:GetMultiShotPositionVelocity(i, WeaponType.WEAPON_BOMBS, shotDir, shotSpeed, multishotParams)
            local bomb = player:FireBomb(shotPos + posVel.Position *scale, posVel.Velocity, entShooting)
            table.insert(weaponList, bomb)

            Isaac.RunCallback(ModCallbacks.MC_POST_FIRE_BOMB, bomb)
        end

        if extraTears then
            if multishotParams:IsShootingBackwards() then
                local bomb = player:FireBomb(shotPos, shotDir:Resized(shotSpeed):Rotated(shotDir:GetAngleDegrees() +180) , entShooting)
                table.insert(weaponList, bomb)

                Isaac.RunCallback(ModCallbacks.MC_POST_FIRE_BOMB, bomb)
            end
            if multishotParams:IsShootingSideways() then
                for angle=-90, 90, 180 do
                    local bomb = player:FireBomb(shotPos, shotDir:Resized(shotSpeed):Rotated(shotDir:GetAngleDegrees() + angle) , entShooting)
                    table.insert(weaponList, bomb)

                    Isaac.RunCallback(ModCallbacks.MC_POST_FIRE_BOMB, bomb)
                end
            end

            for i=1, multishotParams:GetNumRandomDirTears() do
                local angle = Random() % 360
                local bomb = player:FireBomb(shotPos, shotDir:Resized(shotSpeed):Rotated(shotDir:GetAngleDegrees() + angle) , entShooting)
                table.insert(weaponList, bomb)

                Isaac.RunCallback(ModCallbacks.MC_POST_FIRE_BOMB, bomb)
            end
        end
    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X) then
        local multishotParams = player:GetMultiShotParams(WeaponType.WEAPON_TECH_X)

        for i=0, multishotParams:GetNumTears()-1 do
            local posVel = player:GetMultiShotPositionVelocity(i, WeaponType.WEAPON_TECH_X, shotDir, shotSpeed, multishotParams)
            local tech_x = player:FireTechXLaser(shotPos + posVel.Position *scale, posVel.Velocity, 40, entShooting, mult)
            table.insert(weaponList, tech_x)
            
            Isaac.RunCallback(ModCallbacks.MC_POST_FIRE_TECH_X_LASER, tech_x)
        end

        if extraTears then
            if multishotParams:IsShootingBackwards() then
                local tech_x = player:FireTechXLaser(shotPos, shotDir:Resized(shotSpeed):Rotated(shotDir:GetAngleDegrees() +180), 40 *mult, entShooting, mult)
                table.insert(weaponList, tech_x)

                Isaac.RunCallback(ModCallbacks.MC_POST_FIRE_TECH_X_LASER, tech_x)
            end
            if multishotParams:IsShootingSideways() then
                for angle=-90, 90, 180 do
                    local tech_x = player:FireTechXLaser(shotPos, shotDir:Resized(shotSpeed):Rotated(shotDir:GetAngleDegrees() +angle), 40 *mult, entShooting, mult)
                    table.insert(weaponList, tech_x)

                    Isaac.RunCallback(ModCallbacks.MC_POST_FIRE_TECH_X_LASER, tech_x)
                end
            end

            for i=1, multishotParams:GetNumRandomDirTears() do
                local angle = Random() % 360
                local tech_x = player:FireTechXLaser(shotPos, shotDir:Resized(shotSpeed):Rotated(shotDir:GetAngleDegrees() +angle), 40 *mult, entShooting, mult)
                table.insert(weaponList, tech_x)

                Isaac.RunCallback(ModCallbacks.MC_POST_FIRE_TECH_X_LASER, tech_x)
            end
        end
    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) then
        local multishotParams = player:GetMultiShotParams(WeaponType.WEAPON_BRIMSTONE)

        for i=0, multishotParams:GetNumTears()-1 do
            local posVel = player:GetMultiShotPositionVelocity(i, WeaponType.WEAPON_BRIMSTONE, shotDir, shotSpeed, multishotParams)
            local brim = player:FireBrimstone(posVel.Velocity, entShooting, mult)
            table.insert(weaponList, brim)

            Isaac.RunCallback(ModCallbacks.MC_POST_FIRE_BRIMSTONE, brim)
        end
        
        if extraTears then
            if multishotParams:IsShootingBackwards() then
                local brim = player:FireBrimstone(shotDir:Resized(shotSpeed):Rotated(shotDir:GetAngleDegrees() +180), entShooting, mult)
                table.insert(weaponList, brim)

                Isaac.RunCallback(ModCallbacks.MC_POST_FIRE_BRIMSTONE, brim)
            end
            if multishotParams:IsShootingSideways() then
                for angle=-90, 90, 180 do
                    local brim = player:FireBrimstone(shotDir:Resized(shotSpeed):Rotated(shotDir:GetAngleDegrees() + angle), entShooting, mult)
                    table.insert(weaponList, brim)

                    Isaac.RunCallback(ModCallbacks.MC_POST_FIRE_BRIMSTONE, brim)
                end
            end

            for i=1, multishotParams:GetNumRandomDirTears() do
                local angle = Random() % 360
                local brim = player:FireBrimstone(shotDir:Resized(shotSpeed):Rotated(shotDir:GetAngleDegrees() + angle), entShooting, mult)
                table.insert(weaponList, brim)

                Isaac.RunCallback(ModCallbacks.MC_POST_FIRE_BRIMSTONE, brim)
            end
        end
    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY) then
        local multishotParams = player:GetMultiShotParams(WeaponType.WEAPON_LASER)

        for i=0, multishotParams:GetNumTears()-1 do
            local posVel = player:GetMultiShotPositionVelocity(i, WeaponType.WEAPON_LASER, shotDir, shotSpeed, multishotParams)
            local tech = player:FireTechLaser(
                shotPos + posVel.Position *scale,
                LaserOffset.LASER_TECH1_OFFSET,
                posVel.Velocity,
                false, false, entShooting, mult
            )
            table.insert(weaponList, tech)

            Isaac.RunCallback(ModCallbacks.MC_POST_FIRE_TECH_LASER, tech)
        end

        if extraTears then
            if multishotParams:IsShootingBackwards() then
                local bomb = player:FireBomb(shotPos, shotDir:Resized(shotSpeed):Rotated(shotDir:GetAngleDegrees() +180) , entShooting)
                local tech = player:FireTechLaser(
                    shotPos,
                    LaserOffset.LASER_TECH1_OFFSET,
                    shotDir:Resized(shotSpeed):Rotated(shotDir:GetAngleDegrees() +180),
                    false, false, entShooting, mult
                )
                table.insert(weaponList, tech)

                Isaac.RunCallback(ModCallbacks.MC_POST_FIRE_TECH_LASER, tech)
            end
            if multishotParams:IsShootingSideways() then
                for angle=-90, 90, 180 do
                    local tech = player:FireTechLaser(
                        shotPos,
                        LaserOffset.LASER_TECH1_OFFSET,
                        shotDir:Resized(shotSpeed):Rotated(shotDir:GetAngleDegrees() + angle),
                        false, false, entShooting, mult
                    )
                    table.insert(weaponList, tech)

                    Isaac.RunCallback(ModCallbacks.MC_POST_FIRE_TECH_LASER, tech)
                end
            end

            for i=1, multishotParams:GetNumRandomDirTears() do
                local angle = Random() % 360
                local tech = player:FireTechLaser(
                    shotPos,
                    LaserOffset.LASER_TECH1_OFFSET,
                    shotDir:Resized(shotSpeed):Rotated(shotDir:GetAngleDegrees() + angle),
                    false, false, entShooting, mult
                )
                table.insert(weaponList, tech)

                Isaac.RunCallback(ModCallbacks.MC_POST_FIRE_TECH_LASER, tech)
            end
        end
    --elseif player:HasCollectible(CollectibleType.COLLECTIBLE_) then
    --elseif player:HasCollectible(CollectibleType.COLLECTIBLE_) then
    --elseif player:HasCollectible(CollectibleType.COLLECTIBLE_) then
    else
        local multishotParams = player:GetMultiShotParams(WeaponType.WEAPON_TEARS)

        for i=0, multishotParams:GetNumTears()-1 do
            local posVel = player:GetMultiShotPositionVelocity(i, WeaponType.WEAPON_TEARS, shotDir, shotSpeed, multishotParams)
            local tear = player:FireTear(
                shotPos + posVel.Position *scale,
                posVel.Velocity,
                false, true, true, entShooting, mult
            )
            table.insert(weaponList, tear)

            Isaac.RunCallback(ModCallbacks.MC_POST_FIRE_TEAR, tear)
        end

        if extraTears then
            if multishotParams:IsShootingBackwards() then
                local tear = player:FireTear(
                    shotPos,
                    shotDir:Resized(shotSpeed):Rotated(shotDir:GetAngleDegrees() +180),
                    false, true, true, entShooting, mult
                )

                table.insert(weaponList, tear)
                Isaac.RunCallback(ModCallbacks.MC_POST_FIRE_TEAR, tear)
            end
            if multishotParams:IsShootingSideways() then
                for angle=-90, 90, 180 do
                    local tear = player:FireTear(
                        shotPos,
                        shotDir:Resized(shotSpeed):Rotated(shotDir:GetAngleDegrees() +angle),
                        false, true, true, entShooting, mult
                    )
                
                    table.insert(weaponList, tear)
                    Isaac.RunCallback(ModCallbacks.MC_POST_FIRE_TEAR, tear)
                end
            end

            for i=1, multishotParams:GetNumRandomDirTears() do
                local angle = Random() % 360
                local tear = player:FireTear(
                    shotPos,
                    shotDir:Resized(shotSpeed):Rotated(shotDir:GetAngleDegrees() +180),
                    false, true, true, entShooting, mult
                )
                
                table.insert(weaponList, tear)
                Isaac.RunCallback(ModCallbacks.MC_POST_FIRE_TEAR, tear)
            end
        end
    end

    return weaponList
end
