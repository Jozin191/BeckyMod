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
BECKY_B.MagicStaff_SwingCooldown = 60 -- 2 seconds
BECKY_B.MagicStaff_CapsuleSize = 48
BECKY_B.MagicStaff_CapsulePosition = Vector(32,0)
BECKY_B.MagicStaff_Damage = 3.0
BECKY_B.MagicStaff_PushStrength = Vector(14, 0)

BECKY_B.ManaTearCost = 10
BECKY_B.ManaRegenBuffZone = 15   -- (og thing ->) 1/16 * 100 

local game = BeckyMod.Game
local sfx = BeckyMod.SFX

BeckyMod.Character.BECKY_B = BECKY_B

local BASE_TEAR_DPS = 30 /11
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



--- TODO:
--- * Recreate "Marked" item
---     * the mark movement
---     * the mark line
---     * overwrite the "GetMarkedTarget" function to return this mark entity
---     * the mark line
--- * Make Incubus, Gello, Twisted Pair, etc. use this knife variant and other stuff
--- * Make Mana Tears auto fire when the "tear per second" is to high (for stuff like "Soy Milk")
local TEAR_VEL = Vector(1,0)
local function ShootManaTear(player, entShooting)
    local mult = 1

    local aimDir = player:GetLastDirection()
    local vel = TEAR_VEL:Resized(player.ShotSpeed *10):Rotated(aimDir:GetAngleDegrees())
    local pos = entShooting.Position
    -- player:GetMultiShotParams()
    -- player:GetMultiShotPositionVelocity()

    --- TODO: Multishot
    local tear = player:FireTear(pos, vel +player:GetTearMovementInheritance(aimDir), false, true, true, entShooting, mult)
    tear:ChangeVariant(BeckyMod.Spells.ENTITIES.MANA_TEAR.Variant)
end

local function GetPlayerAimAngle(player)
    local angle = player:GetAimDirection()
    local markedEff = player:GetMarkedTarget()
    if markedEff then
        angle = (markedEff.Position - player.Position):GetAngleDegrees()
    elseif angle:Length() == 0 then
        angle = player:GetMovementJoystick()
        if angle:Length() == 0 then angle = 90
        else angle = angle:GetAngleDegrees() end

    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_ANALOG_STICK) then
        angle = angle:GetAngleDegrees()
    else
        angle = DirToAngle[player:GetHeadDirection()]
    end
    return angle
end

local function ProcessStaffSwing(player, entShooting)
    local data = entShooting:GetData()
    local save = BeckyMod:RunSave(player)
    if not player:CanShoot() or not player:IsExtraAnimationFinished() then
        data.MagicStaff_HasSwing = false

        if data.MagicStaff_ChargeBar then
            if data.MagicStaff_ChargeBar.Charge == data.MagicStaff_ChargeBar.MaxCharge then
                save.ManaCharge = save.ManaCharge -BECKY_B.ManaTearCost
                ShootManaTear(player, entShooting)
            end
            data.MagicStaff_ChargeBar.Charge = 0
        end
        return 
    end
    local knife = data.MagicStaff_Ent

    local aimVec = player:GetAimDirection()
    local markedEff = player:GetMarkedTarget()

    if not data.MagicStaff_ChargeBar then
        data.MagicStaff_ChargeBar = {
            Charge = 0,
            MaxCharge = 60, -- 2 seconds
            Sprite = Sprite("gfx/chargebar.anm2", true)
        }
    end
    if markedEff or aimVec:Length() ~= 0 then
        --- TODO: Multishot, tho, i would also have to make becky have more staffs
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
            data.MagicStaff_SwingCool = BECKY_B.MagicStaff_SwingCooldown
            
            local angle = GetPlayerAimAngle(player)
            local shootPos = entShooting.Position + BECKY_B.MagicStaff_Offset:Rotated(angle) + BECKY_B.MagicStaff_CapsulePosition:Rotated(angle)
            local list = Isaac.FindInRadius(
                shootPos,
                BECKY_B.MagicStaff_CapsuleSize,
                EntityPartition.ENEMY
            )
            local entRef = EntityRef(entShooting)
            local entPos = entShooting.Position
            for _, ent in ipairs(list) do
                ent:TakeDamage(BECKY_B.MagicStaff_Damage, 0, entRef, 0)
                ent:AddKnockback(
                    entRef,
                    BECKY_B.MagicStaff_PushStrength:Rotated( (ent.Position - entPos):GetAngleDegrees() ),
                    3,
                    false
                )
            end

            local gridList = FindGridInRadius(shootPos, 2)
            for _, grid in ipairs(gridList) do
                if grid:GetType() == GridEntityType.GRID_POOP then
                    grid:HurtWithSource(math.floor(BECKY_B.MagicStaff_Damage * 1333), entRef)
                else
                    grid:HurtWithSource(math.floor(BECKY_B.MagicStaff_Damage *1.333), entRef)
                end
            end

            data.MagicStaff_HasSwing = true

            if entShooting.Type == 1 then
                entShooting:ToPlayer():SetHeadDirectionLockTime(10)
            end
        end

        if entShooting.Type == 1 and save.ManaCharge < BECKY_B.ManaTearCost then return end
        local addToCharge = 1 * (30 / (player.MaxFireDelay + 1) /BASE_TEAR_DPS)
    
        data.MagicStaff_ChargeBar.Charge = math.min(data.MagicStaff_ChargeBar.Charge +addToCharge, data.MagicStaff_ChargeBar.MaxCharge)

        if player:HasCollectible(CollectibleType.COLLECTIBLE_MARKED) then
            if data.MagicStaff_ChargeBar.Charge == data.MagicStaff_ChargeBar.MaxCharge then
                save.ManaCharge = save.ManaCharge -BECKY_B.ManaTearCost
                ShootManaTear(player, entShooting)
                data.MagicStaff_HasSwing = false
            end

            data.MagicStaff_ChargeBar.Charge = 0
        end
    else
        data.MagicStaff_HasSwing = false

        if data.MagicStaff_ChargeBar.Charge == data.MagicStaff_ChargeBar.MaxCharge then
            save.ManaCharge = save.ManaCharge -BECKY_B.ManaTearCost
            ShootManaTear(player, entShooting)
        end
        data.MagicStaff_ChargeBar.Charge = 0
    end
end


function BECKY_B:SetMagicStaffWeapon(player)
    local ent = Isaac.Spawn(8, BECKY_B.MagicStaffId, 0, player.Position, Vector.Zero, player)
    ent:GetSprite():Load(taintedBeckysWandAnim, true)

    -- Doing this because a player cannot be the parent of a spawned knife (i guess)
    local eff = Isaac.Spawn(1000, BECKY_B.MagicStaffId, 0, player.Position, Vector.Zero, player):ToEffect()
    eff.Timeout = -1
    eff.Visible = false
    eff.Child = ent -- if the knife is not the child of something gets deleted (this does not work on the player as far i tested :[ )
    ent.Parent = eff
    ent:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
    eff:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
    ent:GetSprite():Play("Idle", true)
    eff.Parent = player
    eff:FollowParent(player)

    local data = player:GetData()
    data.MagicStaff_Ent = ent:ToKnife()
    data.MagicStaff_SwingCool = data.MagicStaff_SwingCool or 0
end



BeckyMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function(_, player)
    if player:GetPlayerType() ~= BECKY_B.PLAYERTYPE then return end
    player:AddNullCostume(BECKY_B.BODY_COSTUME)
    local save = BeckyMod:RunSave(player)
    save.ManaCharge = save.ManaCharge or 0
end)



BeckyMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
    if player:GetPlayerType() ~= BECKY_B.PLAYERTYPE then return end
    local weapon = player:GetWeapon(1)
    if weapon ~= nil then Isaac.DestroyWeapon(weapon) end
    if player:IsDead() then return end
    local data = player:GetData()

    if not data.MagicStaff_Ent or not data.MagicStaff_Ent:Exists() then
        --print("no ent")
        BECKY_B:SetMagicStaffWeapon(player)
    elseif data.MagicStaff_SwingCool then
        if data.MagicStaff_SwingCool > 0 then
            data.MagicStaff_SwingCool = data.MagicStaff_SwingCool -1
        end
        ProcessStaffSwing(player, player)
    end
end)


BeckyMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)
    if player:GetPlayerType() ~= BECKY_B.PLAYERTYPE then return end
    local save = BeckyMod:RunSave(player)
    local data = player:GetData()
    local manaCap = 100 - (data.MaxManaOffset or 0)
    if save.ManaCharge and save.ManaCharge < manaCap then
        local manaRegen = 0
        if not (data.NoChargeMana and data.NoChargeMana > 0) then
            manaRegen = 30 / (player.MaxFireDelay + 1) * 0.25
            --if save.ManaCharge < BECKY_B.ManaRegenBuffZone then
            --    manaRegen = manaRegen *2.25
            --end
        end
        save.ManaCharge = math.min(save.ManaCharge + manaRegen, manaCap)
    end
    if save.ManaCharge > 0 and data.ManaDischarge and data.ManaDischarge > 0 then
        save.ManaCharge = math.max(save.ManaCharge -data.ManaDischarge, 0)
    end
end)


BeckyMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)

end)



BeckyMod:AddCallback(ModCallbacks.MC_POST_KNIFE_INIT, function(_, knife)
    if knife.Variant ~= BECKY_B.MagicStaffId then return end
    knife:GetSprite():Play("Idle", true)
end)

BeckyMod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, function(_, knife)
    if knife.Variant ~= BECKY_B.MagicStaffId then return end
    
    knife.PathOffset = 5
    knife.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    knife.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE

    local player = knife.SpawnerEntity and knife.SpawnerEntity:ToPlayer()
    if player == nil then return end

    local sp = knife:GetSprite()
    if not ( (sp:IsPlaying("Swing") or sp:IsPlaying("Swing2")) and sp:GetFrame() >0) then
        knife.Rotation = GetPlayerAimAngle(player)
    end
    
    knife.Position = player.Position + BECKY_B.MagicStaff_Offset:Rotated(knife.Rotation)
    knife.PositionOffset = BECKY_B.MagicStaff_PositionOffset
end)

local WEIRD_ROTATION_OFFSET = Vector(0,8)
BeckyMod:AddCallback(ModCallbacks.MC_POST_KNIFE_RENDER, function(_, knife, offset)
    if knife.Variant ~= BECKY_B.MagicStaffId then return end

    local sp = knife:GetSprite()
    local nullFrame = sp:GetNullFrame("flame")

    if nullFrame and nullFrame:IsVisible() then
        local pos = knife:GetNullOffset("flame")
        if sp.Rotation < 180 and sp.Rotation > 0 then -- fixing the nullframe pos being wrong
            pos.X = -pos.X
            pos.Y = -pos.Y
            
            local mult = 1
            if knife.SpawnerEntity:GetData().MagicStaff_SwingSide then mult = -1 end

            pos = pos + (WEIRD_ROTATION_OFFSET * mult):Rotated(sp.Rotation)
        end
        local room = game:GetRoom()
        BECKY_B.StaffFireSprite:SetFrame("flame", knife.FrameCount %4)
        BECKY_B.StaffFireSprite:Render(room:WorldToScreenPosition(knife.Position + pos + BECKY_B.MagicStaff_PositionOffset))
    end
end)

BeckyMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, eff)
    local player = eff.Parent and eff.Parent:ToPlayer()
    if player == nil or eff.Child == nil then
        if eff.Child then eff.Child:Remove() end
        eff:Remove()
        return
    end
end, BECKY_B.MagicStaffDummyId)



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