local SPELL_COST = 14.28571428
local VINE_VAR = Isaac.GetEntityVariantByName("Spell Vine")
local game = BeckyMod.Game
local NONO_FLAGS = (EntityFlag.FLAG_NO_QUERY | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_ICE_FROZEN)

local function TableFilter(ent)
    if ent:ToNPC() ~= nil and ent:GetEntityFlags() & NONO_FLAGS == 0 and ent:CanShutDoors() and ent:IsActiveEnemy() and ent:IsVulnerableEnemy() then return true end
    return false
end

BeckyMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, eff)
	local sp = eff:GetSprite()
	if sp:IsPlaying("Disappear") then return
	elseif sp:IsFinished("Disappear") then
		eff:Remove()
		return
	elseif eff.FrameCount <= 1 then
		eff.DepthOffset = 10
		sp:Play("Appear", true)
		return
	elseif sp:IsPlaying("Appear") then return
	end

	if eff.Timeout == 0 then
		if eff.Target then
            local targetData = BeckyMod.GetEntData(eff.Target)
            targetData.GrabbedByVine = (targetData.GrabbedByVine or 0) -1
			targetData.VineSprite = nil
        end
		sp:Play("Disappear", true)
		return
	end

    local effData = BeckyMod.GetEntData(eff)
	if eff.Target then
		local ent = eff.Target
		local grabTime = effData.MinWaitTime
		
		if grabTime and game:GetFrameCount() > grabTime  then
			if ent.Position:Distance(eff.Position) > 60 then
                local targetData = BeckyMod.GetEntData(eff.Target)
                targetData.GrabbedByVine = (targetData.GrabbedByVine or 0) -1
				targetData.VineSprite = nil

				sp:Play("Disappear", true)
				eff.Timeout = 0
				return
			end
		end

		ent.Position = BeckyMod:Lerp(ent.Position, eff.Position, 0.1)

		if eff:IsFrame(5, 0) and ent:IsVulnerableEnemy() then
			local dmg = eff.CollisionDamage
			ent:TakeDamage(dmg, 0, EntityRef(eff), 0)
		end
	else
		target = Isaac.FindInRadius(eff.Position, 20, EntityPartition.ENEMY)[1]

		if target then
			if target.HitPoints <= 0 or not target:IsActiveEnemy() or not target:CanShutDoors() or not target.Visible then
				if not sp:IsPlaying("Idle") then
					sp:Play("Idle", true)
				end
				return
			end
			eff.Target = target
            
            local targetData = BeckyMod.GetEntData(target)
            targetData.GrabbedByVine = (targetData.GrabbedByVine or 0) +1
            targetData.VineSprite = Sprite("gfx/beckyMagic/vines.anm2", true)
			targetData.VineSprite:Play("Grab", true)
            
			sp:Play("GrabNull", true)
			eff.Timeout = 90

			effData.MinWaitTime = game:GetFrameCount() + 10
		elseif not sp:IsPlaying("Idle") then
			sp:Play("Idle", true)
		end
	end
end, VINE_VAR)

BeckyMod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
    local npcData = BeckyMod.GetEntData(npc)
	local amount = npcData.GrabbedByVine
	if amount == nil or amount <= 0 then return end
	npc.Velocity = npc.Velocity * (0.985 ^ math.max(amount, 7))
    if npcData.VineSprite then
        npcData.VineSprite.Scale = Vector(npc.Size /10, 1)
        npcData.VineSprite:Update()
    end
end)

BeckyMod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, function(_, npc, offset)
    local npcData = BeckyMod.GetEntData(npc)
	local amount = npcData.GrabbedByVine
	if amount == nil or amount <= 0 then return end

    if npcData.VineSprite then
        local renderPos
        if game:GetRoom():GetRenderMode() == RenderMode.RENDER_WATER_REFLECT then
            renderPos = Isaac.WorldToRenderPosition(npc.Position + npc.PositionOffset) + offset
        else
            renderPos = Isaac.WorldToScreen(npc.Position + npc.PositionOffset)
        end

	    npcData.VineSprite:Render(renderPos)
    end
end)

local DummyRNG = RNG()
local function fun(player)
    local seed = Random()
    if seed == 0 then seed = 10 end
    DummyRNG:SetSeed(seed, 20)
    local entityList = BeckyMod:ShuffleTable( BeckyMod:FilterList(Isaac.GetRoomEntities(), TableFilter), DummyRNG )

    local save = BeckyMod:RunSave(player)
    local spawnAmount = math.min(save.ManaCharge // SPELL_COST, #entityList)
    save.ManaCharge = save.ManaCharge - SPELL_COST *spawnAmount
    for i=1, spawnAmount do
        local ent = entityList[i]
        local vine = Isaac.Spawn(1000, VINE_VAR, 0, ent.Position, Vector.Zero, player)
        BeckyMod.GetEntData(vine).NoGrantMana = true
    end
end

local function canSelectFun(player, manaLeft)
    return manaLeft >= SPELL_COST
end

return {
    BeckyMod.Spells.SpellType.VINE,
    Func = fun,
    CanSelect = canSelectFun,
    Cost = 0,
    Frame = 99
}
