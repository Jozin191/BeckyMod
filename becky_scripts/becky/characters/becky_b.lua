local BECKY_B = {}

BECKY_B.PLAYERTYPE = Isaac.GetPlayerTypeByName("Becky", true)

BECKY_B.HAIR_COSTUME = Isaac.GetCostumeIdByPath("gfx/characters/becky_b_hair.anm2")
BECKY_B.BODY_COSTUME = Isaac.GetCostumeIdByPath("gfx/characters/becky_b_scarf.anm2")

local taintedBeckysWandAnim = "gfx/becky_magic_staff.anm2"
BECKY_B.StaffFireSprite = Sprite(taintedBeckysWandAnim, true)
BECKY_B.ManaBarSprite = Sprite("gfx/ui/taintedBecky/mana_bar.anm2", true)

BECKY_B.MagicStaffId =      Isaac.GetEntityVariantByName("Magic Staff (Weapon)")
BECKY_B.MagicStaffDummyId = Isaac.GetEntityVariantByName("Magic Staff (Dummy)")
BECKY_B.MagicStaff_Offset = Vector(8,0)
BECKY_B.MagicStaff_PositionOffset = Vector(0,-8)
BECKY_B.MagicStaff_SwingCooldown = 30 -- 1 seconds
BECKY_B.MagicStaff_CapsuleSize = 48
BECKY_B.MagicStaff_CapsulePosition = Vector(32,0)
BECKY_B.MagicStaff_Damage = 3.75
BECKY_B.MagicStaff_PushStrength = Vector(14, 0)

BECKY_B.ManaTearCost = 10
BECKY_B.ManaRegenBuffZone = 15   -- (og thing ->) 1/16 * 100 

local game = BeckyMod.Game
local sfx = BeckyMod.SFX

BeckyMod.Character.BECKY_B = BECKY_B

local BASE_TEAR_DPS = 30 /11
local MAX_TEARS_DPS_C_SECTION = 30 / (149.66666667*3+1)
local DirToAngle = {
    [Direction.NO_DIRECTION] = 90,
    [Direction.LEFT] = 180,
    [Direction.RIGHT] = 0,
    [Direction.UP] = -90,
    [Direction.DOWN] = 90,
}

BECKY_B.FamiliarWhiteList = {
    [FamiliarVariant.INCUBUS] = true,
    [FamiliarVariant.TWISTED_BABY] = true,
    [FamiliarVariant.UMBILICAL_BABY] = true,
    [FamiliarVariant.CAINS_OTHER_EYE] = true,
    [FamiliarVariant.BLOOD_BABY] = true,
}

local getGridPosVector = Vector(0,0)
local gridRadiusCapVector = Vector(0,0)
local function FindGridInRadius(pos, tileRadius, fromCenter,  squareRadius)
	local tab = {}
	local tileRadius = math.max(tileRadius, 0)
	local room = game:GetRoom()

	if squareRadius then
		for x = -tileRadius, tileRadius do
			getGridPosVector.X = pos.X + x *40
			for y = -tileRadius, tileRadius do
				getGridPosVector.Y = pos.Y + y *40
				local grid = room:GetGridEntityFromPos(getGridPosVector)
				if grid then
					table.insert(tab, grid)
				end
			end
		end
	else
		gridRadiusCapVector.X = pos.X + tileRadius*40
		gridRadiusCapVector.Y = pos.Y

		if not fromCenter then gridRadiusCapVector.X = gridRadiusCapVector.X +20 end -- taking the full grid end


		local cap = gridRadiusCapVector:Distance(pos)

		local angle = 0
		for x = -tileRadius, tileRadius do
			getGridPosVector.X = pos.X + x *40
			for y = -tileRadius, tileRadius do
				getGridPosVector.Y = pos.Y + y *40
				
				local grid = room:GetGridEntityFromPos(getGridPosVector)

				if grid and getGridPosVector:Distance(pos) <= cap then
					table.insert(tab, grid)
				end
			end
		end
	end

	return tab
end



local function GetPlayerAimAngle(owner, player)
    local angle = player:GetAimDirection()
    --if owner.Type == 3 then angle = player:GetLastDirection() end

    if angle:Length() == 0 then
        angle = player:GetMovementJoystick()
        if angle:Length() == 0 then angle = 90
        else angle = angle:GetAngleDegrees() end

    elseif player:GetMarkedTarget() or player:HasCollectible(CollectibleType.COLLECTIBLE_ANALOG_STICK) then
        angle = angle:GetAngleDegrees()
    else
        angle = DirToAngle[player:GetHeadDirection()]
    end
    return angle
end

--- * Make Mana Tears auto fire when the "tear per second" is to high (for stuff like "Soy Milk")
local function ProcessStaffSwing(entShooting, player)
    local data = entShooting:GetData()
    --local save = BeckyMod:RunSave(player)
    if not player:CanShoot() or not player:IsExtraAnimationFinished() then
        data.MagicStaff_HasSwing = false

        if data.MagicStaff_ChargeBar then
            if data.MagicStaff_ChargeBar.Charge == data.MagicStaff_ChargeBar.MaxCharge then
                --save.ManaCharge = save.ManaCharge -BECKY_B.ManaTearCost
                --ShootManaTear(player, entShooting)
                BECKY_B:FireWeapon(entShooting, player)
            end
            data.MagicStaff_ChargeBar.Charge = 0
        end
        return 
    end
    local knife = data.MagicStaff_Ent

    local aimVec = player:GetAimDirection()

    if not data.MagicStaff_ChargeBar then
        data.MagicStaff_ChargeBar = {
            Charge = 0,
            MaxCharge = 30, -- 1 seconds
            Sprite = Sprite("gfx/chargebar.anm2", true)
        }
    end
    if aimVec:Length() ~= 0 then
        if not data.MagicStaff_HasSwing and data.MagicStaff_SwingCool <= 0 then

            local anim = "Swing"
            if data.MagicStaff_SwingSide then
                anim = "Swing2"
                data.MagicStaff_SwingSide = false
            else
                data.MagicStaff_SwingSide = true
            end

            local pitch = (7 + knife:GetDropRNG():RandomInt(5)) /10

            sfx:Play(SoundEffect.SOUND_SHELLGAME, 1, 0, false, pitch)
            knife:GetSprite():Play(anim, true)
            knife:SetIsSwinging(true)
            local scale = knife.Scale
            data.MagicStaff_SwingCool = BECKY_B.MagicStaff_SwingCooldown
            
            local angle = GetPlayerAimAngle(entShooting, player)
            if entShooting.Type == 3 and entShooting.Variant == FamiliarVariant.CAINS_OTHER_EYE then
                local rng = entShooting:GetDropRNG()
                if player:HasCollectible(CollectibleType.COLLECTIBLE_ANALOG_STICK) then
                    angle = rng:RandomInt(360) -180
                else
                    angle = -180 + (90 * rng:RandomInt(4))
                end
            end

            local shootPos = entShooting.Position + BECKY_B.MagicStaff_Offset:Rotated(angle) + BECKY_B.MagicStaff_CapsulePosition:Rotated(angle) *scale
            local list = Isaac.FindInRadius(
                shootPos,
                BECKY_B.MagicStaff_CapsuleSize * scale,
                EntityPartition.ENEMY
            )
            local entRef = EntityRef(entShooting)
            local entPos = entShooting.Position
            for _, ent in ipairs(list) do
                if ent.Type == EntityType.ENTITY_BOMB then
                    local strength = BECKY_B.MagicStaff_PushStrength * (ent.Position:Distance(entPos) / 64)
                    ent:AddVelocity( strength:Rotated( (ent.Position - entPos):GetAngleDegrees() ) )
                else
                    ent:TakeDamage(BECKY_B.MagicStaff_Damage, 0, entRef, 0)
                    ent:AddKnockback(
                        entRef,
                        BECKY_B.MagicStaff_PushStrength:Rotated( (ent.Position - entPos):GetAngleDegrees() ),
                        3,
                        false
                    )
                end
            end

            local gridList = FindGridInRadius(shootPos, 2 *scale)
            for _, grid in ipairs(gridList) do
                if grid:GetType() == GridEntityType.GRID_POOP then
                    grid:HurtWithSource(350, entRef)
                else
                    grid:HurtWithSource(35, entRef)
                end
            end

            data.MagicStaff_HasSwing = true

            if entShooting.Type == 1 then
                entShooting:SetHeadDirectionLockTime(10)
            elseif entShooting.Type == 3 then
                entShooting.FireCooldown = BECKY_B.MagicStaff_SwingCooldown //10
            end
        else
            knife:SetIsSwinging(false)
        end

        --if entShooting.Type == 1 and save.ManaCharge < BECKY_B.ManaTearCost then return end
        local addToCharge = 1
        if player:HasCollectible(CollectibleType.COLLECTIBLE_C_SECTION) then
            local c_sectionCharge = 30 /(player.MaxFireDelay *3 +1)
            if c_sectionCharge < MAX_TEARS_DPS_C_SECTION then c_sectionCharge = MAX_TEARS_DPS_C_SECTION end
            addToCharge = addToCharge * (c_sectionCharge /BASE_TEAR_DPS)
        else
            addToCharge = addToCharge * (BeckyMod:toTearsPerSecond(player.MaxFireDelay) /BASE_TEAR_DPS)
        end
    
        data.MagicStaff_ChargeBar.Charge = math.min(data.MagicStaff_ChargeBar.Charge +addToCharge, data.MagicStaff_ChargeBar.MaxCharge)

        if player:HasCollectible(CollectibleType.COLLECTIBLE_MARKED) then
            if data.MagicStaff_ChargeBar.Charge == data.MagicStaff_ChargeBar.MaxCharge then
                --save.ManaCharge = save.ManaCharge -BECKY_B.ManaTearCost
                --ShootManaTear(player, entShooting)
                BECKY_B:FireWeapon(entShooting, player)
                data.MagicStaff_HasSwing = false
            end

            data.MagicStaff_ChargeBar.Charge = 0
        end
    else
        data.MagicStaff_HasSwing = false

        if data.MagicStaff_ChargeBar.Charge == data.MagicStaff_ChargeBar.MaxCharge then
            --save.ManaCharge = save.ManaCharge -BECKY_B.ManaTearCost
            --ShootManaTear(player, entShooting)
            BECKY_B:FireWeapon(entShooting, player)
        end
        data.MagicStaff_ChargeBar.Charge = 0
    end
end


function BECKY_B:SetMagicStaffWeapon(owner)
    local knife = Isaac.Spawn(8, BECKY_B.MagicStaffId, 0, owner.Position, Vector.Zero, owner):ToKnife()
    knife:GetSprite():Load(taintedBeckysWandAnim, true)

    -- Doing this because a player cannot be the parent of a spawned knife (i guess)
    local eff = Isaac.Spawn(1000, BECKY_B.MagicStaffDummyId, 0, owner.Position, Vector.Zero, owner):ToEffect()
    eff.Timeout = -1
    eff.Visible = false
    eff.Child = knife -- if the knife is not the child of something gets deleted (this does not work on the player as far i tested :[ )
    knife.Parent = eff
    knife:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
    eff:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
    knife:GetSprite():Play("Idle", true)
    eff.Parent = owner
    eff:FollowParent(owner)
    if owner.Type == 3 then
        if owner.Variant == FamiliarVariant.TWISTED_BABY then
            knife.Scale = 0.5
            knife.SpriteScale = Vector(0.5, 0.5)
        else
            knife.Scale = 0.75
            knife.SpriteScale = Vector(0.75, 0.75)
        end
    else knife.Scale = 1
    end

    local data = owner:GetData()
    data.MagicStaff_Ent = knife
    data.MagicStaff_SwingCool = data.MagicStaff_SwingCool or 0
end



BeckyMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function(_, player)
    if player:GetPlayerType() ~= BECKY_B.PLAYERTYPE then return end
    PlayerAnimLib:SetDefaultAnm2(player, "gfx/player_becky_b.anm2")
    player:AddNullCostume(BECKY_B.BODY_COSTUME)
    local save = BeckyMod:RunSave(player)
    save.ManaCharge = save.ManaCharge or 0
end)



BeckyMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
    if player:GetPlayerType() ~= BECKY_B.PLAYERTYPE then return end
    local weapon = player:GetWeapon(1)
    if weapon ~= nil then
        Isaac.DestroyWeapon(weapon)
    end
    if player:IsDead() then return end
    local data = player:GetData()
    local effects = player:GetEffects()
    if effects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_BERSERK) or effects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_NOTCHED_AXE) then
        if data.MagicStaff_Ent and data.MagicStaff_Ent:Exists() then
            data.MagicStaff_Ent:Remove()
        end
        return
    end

    if not data.MagicStaff_Ent or not data.MagicStaff_Ent:Exists() then
        --print("no ent")
        BECKY_B:SetMagicStaffWeapon(player)
    end
end)

BeckyMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)
    if player:GetPlayerType() ~= BECKY_B.PLAYERTYPE or player:IsDead() then return end
    local data = player:GetData()

    if data.MagicStaff_Ent then
        if data.MagicStaff_SwingCool > 0 then
            data.MagicStaff_SwingCool = data.MagicStaff_SwingCool -1
        end
        ProcessStaffSwing(player, player)
    end
end)


BeckyMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
    if BECKY_B.FamiliarWhiteList[fam.Variant] == nil then return end

    local player = fam.Player
    if player == nil or player:GetPlayerType() ~= BECKY_B.PLAYERTYPE then return end
    
    local weapon = player:GetWeapon(1)
    if weapon ~= nil then
        Isaac.DestroyWeapon(weapon)
    end
    if player:IsDead() then return end
    local data = fam:GetData()
    local effects = player:GetEffects()
    if effects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_BERSERK) or effects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_NOTCHED_AXE) then
        if data.MagicStaff_Ent and data.MagicStaff_Ent:Exists() then
            data.MagicStaff_Ent:Remove()
        end
        return
    end

    if not data.MagicStaff_Ent or not data.MagicStaff_Ent:Exists() then
        BECKY_B:SetMagicStaffWeapon(fam)
    elseif data.MagicStaff_SwingCool then
        if data.MagicStaff_SwingCool > 0 then
            data.MagicStaff_SwingCool = data.MagicStaff_SwingCool -1
        end
        ProcessStaffSwing(fam, player)
    end

end)


-------------------------------------------------
--------------------MANA STUFF-------------------
-------------------------------------------------
BeckyMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)
    if player:GetPlayerType() ~= BECKY_B.PLAYERTYPE then return end
    local save = BeckyMod:RunSave(player)
    local data = player:GetData()
    local manaCap = 100 - (data.MaxManaOffset or 0)
    --[[
    if save.ManaCharge and save.ManaCharge < manaCap then
        local manaRegen = 0
        if not (data.NoChargeMana and data.NoChargeMana > 0) then
            manaRegen = 30 / (player.MaxFireDelay + 1) * 0.25
            --if save.ManaCharge < BECKY_B.ManaRegenBuffZone then
            --    manaRegen = manaRegen *2.25
            --end
        end
        save.ManaCharge = save.ManaCharge + manaRegen
    end]]
    if save.ManaCharge > 0 and data.ManaDischarge and data.ManaDischarge > 0 then
        save.ManaCharge = math.max(save.ManaCharge -data.ManaDischarge, 0)
    end
    if save.ManaCharge > manaCap then save.ManaCharge = manaCap end
end)


BeckyMod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, function(_, ent, dmg, dmgFlags, src, cooldown)
    if ent.Type == 1 or dmg <= 0 then return end
    local player = src.Entity
    if player == nil then return
    else player = BeckyMod:TryGetPlayer(player, false) end
    if player then
        player = player:ToPlayer()
    else return end

    if player:GetPlayerType() == BECKY_B.PLAYERTYPE then
        local data = player:GetData()
        if not (data.NoChargeMana and data.NoChargeMana > 0) then
            local save = BeckyMod:RunSave(player)
            save.ManaCharge = save.ManaCharge + dmg --*1.36
        end
    end
end)


-------------------------------------------------
----------------MAGIC STAFF STUFF----------------
-------------------------------------------------
BeckyMod:AddCallback(ModCallbacks.MC_POST_KNIFE_INIT, function(_, knife)
    if knife.Variant ~= BECKY_B.MagicStaffId then return end
    knife:GetSprite():Play("Idle", true)
end)

BeckyMod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, function(_, knife)
    if knife.Variant ~= BECKY_B.MagicStaffId then return end
    
    knife.PathOffset = 5
    knife.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    knife.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE

    local owner = knife.SpawnerEntity
    if owner == nil then return end
    local player
    if owner.Type == 1 then
        player = knife.SpawnerEntity:ToPlayer()
    elseif owner.Type == 3 then
        local fam = knife.SpawnerEntity:ToFamiliar()
        if fam.FireCooldown > 0 then return end
        player = fam.Player
    end
    if player == nil then return end

    local sp = knife:GetSprite()
    if not ( (sp:IsPlaying("Swing") or sp:IsPlaying("Swing2")) and sp:GetFrame() >0) then
        local angle = GetPlayerAimAngle(owner, player)
        if owner.Type == 3 and owner.Variant == FamiliarVariant.CAINS_OTHER_EYE then
            local rng = owner:GetDropRNG()
            if player:HasCollectible(CollectibleType.COLLECTIBLE_ANALOG_STICK) then
                angle = rng:RandomInt(360) -180
            else
                angle = -180 + (90 * rng:RandomInt(4))
            end
        end

        knife.Rotation = angle
    end
    
    knife.Position = owner.Position + BECKY_B.MagicStaff_Offset:Rotated(knife.Rotation)
    if owner.Type == 3 then
        knife.PositionOffset = BECKY_B.MagicStaff_PositionOffset * 2
    else
        knife.PositionOffset = BECKY_B.MagicStaff_PositionOffset
    end
end)

local WEIRD_ROTATION_OFFSET = Vector(0,8)
BeckyMod:AddCallback(ModCallbacks.MC_POST_KNIFE_RENDER, function(_, knife, offset)
    if knife.Variant ~= BECKY_B.MagicStaffId then return end

    local sp = knife:GetSprite()
    local nullFrame = sp:GetNullFrame("flame")

    if nullFrame and nullFrame:IsVisible() then
        BECKY_B.StaffFireSprite.Scale = sp.Scale
        local pos = knife:GetNullOffset("flame")
        if sp.Rotation < 180 and sp.Rotation > 0 then -- fixing the nullframe pos being wrong
            pos.X = -pos.X
            pos.Y = -pos.Y
            
            local mult = 1
            if knife.SpawnerEntity and knife.SpawnerEntity:GetData().MagicStaff_SwingSide then mult = -1 end

            pos = pos + (WEIRD_ROTATION_OFFSET * mult):Rotated(sp.Rotation)
        end

        local room = game:GetRoom()
        BECKY_B.StaffFireSprite:SetFrame("flame", knife.FrameCount %4)
        BECKY_B.StaffFireSprite:Render(room:WorldToScreenPosition(knife.Position + pos + knife.PositionOffset))
    end
end)

BeckyMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, eff)
    if eff.Parent == nil or eff.Child == nil then
        if eff.Child then eff.Child:Remove() end
        eff:Remove()
        return
    end
end, BECKY_B.MagicStaffDummyId)



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


--- TODO:
--- * Recreate "Marked" item
---     * the mark movement
---     * the mark line
---     * overwrite the "GetMarkedTarget" function to return this mark entity
---     * the mark line
--- * Make Incubus, Gello, Twisted Pair, etc. use this knife variant and other stuff
function BECKY_B:FireWeapon(entShooting, player, forceDir, forceMult, canBeEye)
    local shotDir
    local shotSpeed = player.ShotSpeed *10
    local shotPos = entShooting.Position
    local scale = player.Size
    local mult = 1
    local weaponList = {}
    local markTarget = player:GetMarkedTarget()
    if canBeEye == nil then canBeEye = true end
    if entShooting.Type == 3 then
        local fam = entShooting:ToFamiliar()
        if entShooting.Variant == FamiliarVariant.TWISTED_BABY then
            mult = 0.5
        else
            mult = 0.75
        end
        mult = mult * fam:GetMultiplier()
    end

    if entShooting.Type == 3 and player:HasCollectible(CollectibleType.COLLECTIBLE_KING_BABY) then
        
    elseif forceDir then
        shotDir = forceDir
    elseif markTarget then
    else
        shotDir = player:GetLastDirection()
    end
    if forceMult then mult = forceMult end

    if player:HasCollectible(CollectibleType.COLLECTIBLE_EPIC_FETUS) then
        local multishotParams = player:GetMultiShotParams(WeaponType.WEAPON_BOMBS)

        for i=0, multishotParams:GetNumTears()-1 do
            local posVel = player:GetMultiShotPositionVelocity(i, WeaponType.WEAPON_BOMBS, shotDir, shotSpeed, multishotParams)
            local bomb = player:FireBomb(shotPos + posVel.Position *scale, posVel.Velocity, entShooting)
            table.insert(weaponList, bomb)

            Isaac.RunCallback(ModCallbacks.MC_POST_FIRE_BOMB, bomb)
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
            local tear = player:FireTear(shotPos + posVel.Position *scale, posVel.Velocity, false, true, true, entShooting, mult)
            tear:ChangeVariant(TearVariant.FETUS)
            tear:AddTearFlags(tearFlags)
            
            table.insert(weaponList, tear)

            Isaac.RunCallback(ModCallbacks.MC_POST_FIRE_TEAR, tear)
        end
    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_DR_FETUS) then
        local multishotParams = player:GetMultiShotParams(WeaponType.WEAPON_BOMBS)

        for i=0, multishotParams:GetNumTears()-1 do
            local posVel = player:GetMultiShotPositionVelocity(i, WeaponType.WEAPON_BOMBS, shotDir, shotSpeed, multishotParams)
            local bomb = player:FireBomb(shotPos + posVel.Position *scale, posVel.Velocity, entShooting)
            table.insert(weaponList, bomb)

            Isaac.RunCallback(ModCallbacks.MC_POST_FIRE_BOMB, bomb)
        end
    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X) then
        local multishotParams = player:GetMultiShotParams(WeaponType.WEAPON_TECH_X)

        for i=0, multishotParams:GetNumTears()-1 do
            local posVel = player:GetMultiShotPositionVelocity(i, WeaponType.WEAPON_TECH_X, shotDir, shotSpeed, multishotParams)
            local tech_x = player:FireTechXLaser(shotPos + posVel.Position *scale, posVel.Velocity, 40, entShooting, mult)
            table.insert(weaponList, tech_x)
            
            Isaac.RunCallback(ModCallbacks.MC_POST_FIRE_TECH_X_LASER, tech_x)
        end
    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) then
        local multishotParams = player:GetMultiShotParams(WeaponType.WEAPON_BRIMSTONE)

        for i=0, multishotParams:GetNumTears()-1 do
            local posVel = player:GetMultiShotPositionVelocity(i, WeaponType.WEAPON_BRIMSTONE, shotDir, shotSpeed, multishotParams)
            local brim = player:FireBrimstone(posVel.Velocity, entShooting, mult)
            table.insert(weaponList, brim)

            Isaac.RunCallback(ModCallbacks.MC_POST_FIRE_BRIMSTONE, brim)
        end
    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY) then
        local multishotParams = player:GetMultiShotParams(WeaponType.WEAPON_LASER)

        for i=0, multishotParams:GetNumTears()-1 do
            local posVel = player:GetMultiShotPositionVelocity(i, WeaponType.WEAPON_LASER, shotDir, shotSpeed, multishotParams)
            local tech = player:FireTechLaser(shotPos + posVel.Position *scale, LaserOffset.LASER_TECH1_OFFSET, posVel.Velocity, false, false, entShooting, mult)
            table.insert(weaponList, tech)

            Isaac.RunCallback(ModCallbacks.MC_POST_FIRE_TECH_LASER, tech)
        end
    --elseif player:HasCollectible(CollectibleType.COLLECTIBLE_) then
    --elseif player:HasCollectible(CollectibleType.COLLECTIBLE_) then
    --elseif player:HasCollectible(CollectibleType.COLLECTIBLE_) then
    else
        local multishotParams = player:GetMultiShotParams(WeaponType.WEAPON_TEARS)

        for i=0, multishotParams:GetNumTears()-1 do
            local posVel = player:GetMultiShotPositionVelocity(i, WeaponType.WEAPON_TEARS, shotDir, shotSpeed, multishotParams)
            local tear = player:FireTear(shotPos + posVel.Position *scale, posVel.Velocity, canBeEye, false, true, entShooting, mult)
            table.insert(weaponList, tear)

            Isaac.RunCallback(ModCallbacks.MC_POST_FIRE_TEAR, tear)
        end
    end

    return weaponList
end
