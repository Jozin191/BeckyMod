-- cvs's (likely shit) achievement system

local mod = BeckyMod
local game = Game()

local Collectibles = {
    Items = {},
    PickupsEnt = {},
    Pickups = {},
    Trinkets = {},
    Null = {}
}


for i = 1, XMLData.GetNumEntries(XMLNode.ENTITY) do
    local entry = XMLData.GetEntryByOrder(XMLNode.ENTITY, i)
    if entry.sourceid == "3167715373" then --anixbirth specific
		local name = entry.name
		local stats = {ID = tonumber(entry.type), Var = tonumber(entry.variant), Sub = tonumber(entry.subtype)}
		for _ = 1, #entry.name do
			name = mod:removeSubstring(tostring(name), " ")
		end

		if tonumber(entry.type) == 5 then
            Collectibles.PickupsEnt[tostring(name)] = stats
		end
    end
end

for i = 1, XMLData.GetNumEntries(XMLNode.ITEM) do
    local entry = XMLData.GetEntryByOrder(XMLNode.ITEM, i)
    if entry.sourceid == "3597948673" then --becky specific
		local name = entry.name
		for _ = 1, #entry.name do
			name = mod:gsubMany(name, " ", "'", "-", "=")
		end
        if entry.type == "passive" or entry.type == "active" then
            Collectibles.Items[tostring(name)] = tonumber(entry.id)
        elseif entry.type == "familiar" then
            Collectibles.Items[tostring(name)] = tonumber(entry.id)
        elseif entry.type == "null" then
            Collectibles.Null[tostring(name)] = tonumber(entry.id)
        end
	end
end

for i = 1, XMLData.GetNumEntries(XMLNode.NULLITEM) do
    local entry = XMLData.GetEntryByOrder(XMLNode.NULLITEM, i)
    if entry.sourceid == "3597948673" then --becky specific
		local name = entry.name
		for _ = 1, #entry.name do
			name = mod:gsubMany(name, " ", "'", "-", "=")
		end
        Collectibles.Null[tostring(name)] = tonumber(entry.id)
	end
end

for i = 1, XMLData.GetNumEntries(XMLNode.TRINKET) do
    local entry = XMLData.GetEntryByOrder(XMLNode.TRINKET, i)
    if entry.sourceid == "3597948673" then --becky specific
		local name = entry.name
		for _ = 1, #entry.name do
			name = mod:removeSubstring(tostring(name), " ")
			name = mod:removeSubstring(tostring(name), "'")
		end
        Collectibles.Trinkets[tostring(name)] = tonumber(entry.id)
	end
end

for i = 1, XMLData.GetNumEntries(XMLNode.CARD) do
    local entry = XMLData.GetEntryByOrder(XMLNode.CARD, i)
    if entry.sourceid == "3597948673" then --becky specific
		local name = entry.name
		for _ = 1, #entry.name do
			name = mod:removeSubstring(tostring(name), " ")
			name = mod:removeSubstring(tostring(name), "'")
		end
        Collectibles.Pickups[tostring(name)] = tonumber(entry.id)
	end
end

BeckyMod.ACHIEVEMENT = {
    { 
		ID = "DEVILZON_PRIME",
		Note = {"devilzon", "prime"},
		Trinket = Collectibles.Trinkets.DevilzonPrime,
		Tooltip = {"beat", "moms heart", "on hard", "as becky"},
		CompletionMark = {Isaac.GetPlayerTypeByName("Becky", false), "Mom's Heart"},
		Tags = {"Becky", "Mom's Heart"}
	},
	{ 
		ID = "SINNER",
		Note = {"sinner"},
		Item = Collectibles.Items.Sinner,
		Tooltip = {"beat", "satan", "on hard", "as becky"},
		CompletionMark = {Isaac.GetPlayerTypeByName("Becky", false), "Satan"},
		Tags = {"Becky", "Satan"}
	},
	{ 
		ID = "DREAM_BANISHER",
		Note = {"dream", "banisher"},
		Item = Collectibles.Items.DreamBanisher,
		Tooltip = {"beat", "isaac", "on hard", "as becky"},
		CompletionMark = {Isaac.GetPlayerTypeByName("Becky", false), "Isaac"},
		Tags = {"Becky", "Isaac"}
	},
	{ 
		ID = "DEAD_SOCKET",
		Note = {"dead", "socket"},
		Item = Isaac.GetItemIdByName("Dead Socket"),
		Tooltip = {"beat", "hush", "on hard", "as becky"},
		CompletionMark = {Isaac.GetPlayerTypeByName("Becky", false), "Hush"},
		Tags = {"Becky", "Hush"}
	},
		{ 
		ID = "COXINHA",
		Note = {"coxinha"},
		Item = Isaac.GetItemIdByName("Coxinha"),
		Tooltip = {"beat", "ultra greed", "on greed", "as becky"},
		CompletionMark = {Isaac.GetPlayerTypeByName("Becky", false), "Ultra Greed"},
		Tags = {"Becky", "Ultra Greed"}
	},
	{ 
		ID = "CORPSE_TAG",
		Note = {"corpse", "tag"},
		Trinket = Isaac.GetTrinketIdByName("Corpse Tag"),
		Tooltip = {"beat", "ultra greed", "on greedier", "as becky"},
		CompletionMark = {Isaac.GetPlayerTypeByName("Becky", false), "Ultra Greed"},
		Tags = {"Becky", "Ultra Greed"}
	},
	{ 
		ID = "SCARECROW",
		Note = {"scarecrow"},
		Item = Isaac.GetItemIdByName("Scarecrow"),
		Tooltip = {"beat", "mother", "on hard", "as becky"},
		CompletionMark = {Isaac.GetPlayerTypeByName("Becky", false), "Mother"},
		Tags = {"Becky", "Mother"}
	},
	{ 
		ID = "DEAD_BATTERY",
		Note = {"dead", "battery"},
		Item = Collectibles.PickupsEnt.DeadBattery,
		Tooltip = {"beat", "mother", "on hard", "as becky"},
		CompletionMark = {Isaac.GetPlayerTypeByName("Becky", false), "Mega Satan"},
		Tags = {"Becky", "Mother"}
	},
	{
		ID = "NIGHT_OF_THE_SLASHER",
		Note = {"night", "of", "the", "slasher"},
		Item = Isaac.GetItemIdByName("Night of the Slasher"),
		Tooltip = {"beat", "boss rush", "on hard", "as becky"},
		CompletionMark = {Isaac.GetPlayerTypeByName("Becky", false), "Boss Rush"},
		Tags = {"Becky", "Boss Rush"}
	},
	{ 
		ID = "DEFILED_CHALICE",
		Note = {"defiled", "chalice"},
		Item = Isaac.GetItemIdByName("Defiled Chalice"),
		Tooltip = {"beat", "lamb", "on hard", "as becky"},
		CompletionMark = {Isaac.GetPlayerTypeByName("Becky", false), "Lamb"},
		Tags = {"Becky", "Lamb"}
	},
	{ 
		ID = "HOLY_BOOKMARK",
		Note = {"holy", "bookmark"},
		Trinket = Isaac.GetTrinketIdByName("Holy Bookmark"),
		Tooltip = {"beat", "???", "on hard", "as becky"},
		CompletionMark = {Isaac.GetPlayerTypeByName("Becky", false), "???"},
		Tags = {"Becky", "???"}
	},
	{ 
		ID = "BUTCHERS",
		Note = {"butcher's", "cookbook"},
		Item = Isaac.GetItemIdByName("Butcher's Cookbook"),
		Tooltip = {"beat", "dellirium", "on hard", "as becky"},
		CompletionMark = {Isaac.GetPlayerTypeByName("Becky", false), "Dellirium"},
		Tags = {"Becky", "Dellirium"}
	},
	{ 
		ID = "NULL_BOMBS",
		Note = {"null", "bombs"},
		Item = Isaac.GetItemIdByName("Null Bombs"),
		Tooltip = {"beat", "beast", "on hard", "as becky"},
		CompletionMark = {Isaac.GetPlayerTypeByName("Becky", false), "Beast"},
		Tags = {"Becky", "Beast"}
	},
	{ 
		ID = "GHOST_AMULET",
		Note = {"ghost", "amulet"},
		Item = Isaac.GetItemIdByName("Ghost Amulet"),
		Tooltip = {"beat", "all", "on hard", "as becky"},
		CompletionMark = {Isaac.GetPlayerTypeByName("Becky", false), "All"},
		Tags = {"Becky", "All"}
	},
}

-- setting it up reminiscent of Fiend Folio (except for the dss ig)

-- chorse:
--- add a init for achievements
--- add a unlock function (for achievement)
--- add a check function
--- add a callback replacement function (for things)


local BeckyAchmnts = {}

local players = {
	BECKY = Isaac.GetPlayerTypeByName("Becky", false)
}

for i = 1, #BeckyMod.ACHIEVEMENT do
	local ach = BeckyMod.ACHIEVEMENT[i]

	BeckyAchmnts[i] = ach

	if ach.Item then
		BeckyAchmnts["ITEM_" .. string.upper(ach.ID)] = i
	elseif ach.Trinket then
		BeckyAchmnts["TRINKET_" .. string.upper(ach.ID)] = i
	elseif ach.Player then
		BeckyAchmnts["PLAYER_" .. string.upper(ach.ID)] = i
	end

end

function BeckyAchmnts:Setup()

	if mod.SaveManager.GetSettingsSave().lockall == 2 then
		BeckyMod.TEMPORARYUNLOCK = true
	else
		BeckyMod.TEMPORARYUNLOCK = false
	end

	local save = mod.SaveManager.GetPersistentSave()
	save.BeckyModAchievements = save.BeckyModAchievements or {}

	for i = 1, #BeckyAchmnts do

			local name = tostring(BeckyAchmnts[i].ID)

			--[[if BeckyAchmnts[i].Item then
				if save.BeckyModAchievements[name].Item and save.BeckyModAchievements[name] then
				end
			elseif BeckyAchmnts[i].Trinket then
			elseif BeckyAchmnts[i].Player then
			end]]

			save.BeckyModAchievements[name] = save.BeckyModAchievements[name] or {}

			for na, player in pairs(players) do
				local correctedName = string.lower(tostring(na))
				local highNum = string.upper(string.sub(correctedName,1,1))
				correctedName = highNum  .. string.sub(correctedName, 2, string.len(correctedName)) --fixing

				if mod:CheckTableContents(BeckyAchmnts[i].Tags, tostring(correctedName)) then
					save["Unlock" .. BeckyAchmnts[i]["Tags"][1]] = BeckyAchmnts[i]["Tags"][2]
				end	
			end
		

			local itemSave = save.BeckyModAchievements[name]
			
			if itemSave.Locked == nil then
				itemSave.Locked = true
			elseif itemSave.Locked then
				if BeckyMod.TEMPORARYUNLOCK then
					itemSave.TempLock = true
					itemSave.Locked = false
				end
			elseif itemSave.TempLock == true and not BeckyMod.TEMPORARYUNLOCK then
				itemSave.Locked = true
			end

	end
end

function BeckyAchmnts:Unlock(ID, shouldShowNote)
	local save = mod.SaveManager.GetPersistentSave()
	local ach = BeckyAchmnts[ID]
	shouldShowNote = shouldShowNote or false
	if tonumber(ach) then
		ach = BeckyAchmnts[ach]
	end

	if not save.BeckyModAchievements then
		error("Save has not been set up yet!")
	end

	if not ach or not ID or not ach.ID then
		error("ID or Achievement Given was a nil value!")
	end

	if BeckyAchmnts:IsUnlocked(ID) then return end

	if shouldShowNote then
		mod.QueueAchievementNote("gfx/ui/achievement/achievement_" .. string.lower(ach.ID) ..".png")
	end

	save.BeckyModAchievements[ach.ID].Locked = false
	save.BeckyModAchievements[ach.ID].TempLock = false
end

function BeckyAchmnts:IsUnlocked(ID)
	local save = mod.SaveManager.GetPersistentSave()
	local ach = BeckyAchmnts[ID]
	if tonumber(ach) then
		ach = BeckyAchmnts[ach]
	elseif not ach and save.BeckyModAchievements[ID] then
		return save.BeckyModAchievements[ID].Locked == false
	end

	if not save.BeckyModAchievements then
		error("Save has not been set up yet!")
	end

	if not ach or not ID or not ach.ID then
		error("ID or Achievement Given was a nil value!")
	end

	return save.BeckyModAchievements[ach.ID].Locked == false
end

function BeckyAchmnts.RemoveLockedCollectiblesFromPool()
	local pool = Game():GetItemPool()
	for i = 1, #BeckyAchmnts do
		if BeckyAchmnts[i].Item and 
		not BeckyAchmnts:IsUnlocked("ITEM_" .. BeckyAchmnts[i].ID) then
			pool:RemoveCollectible(BeckyAchmnts[i].Item)
		end
	end
end

-- setup for completion marks...

function BeckyAchmnts.AddEntitiesToUnlocks(npc, player, ID)
	local save = mod.SaveManager.GetPersistentSave()

	if not tonumber(ID) then
		ID = BeckyAchmnts[ID]
	end
	if not tonumber(ID) then
		error("Gave invalid variable to ACHIEVEMENT slot!")
	end

	local ach = BeckyAchmnts[ID]

	if not npc.Type and tonumber(npc[1]) then
		npc = {Type = npc[1], Variant = (npc[2] or 0), SubType = (npc[3] or 0)}
	elseif not npc.Type then
		error("Gave invalid variable to NPC Slot!")
	end

	if not player then
		error("Gave invalid to PLAYER slot!")
	end

	local correctedName = string.lower(tostring(player))
	local highNum = string.upper(string.sub(correctedName,1,1))
	correctedName = highNum  .. string.sub(correctedName, 2, string.len(correctedName)) --fixing

	if mod:CheckTableContents(ach.Tags, tostring(correctedName)) then
		mod:NestVariable(save, ID, "Unlock" .. correctedName , tostring(npc.Type),  tostring(npc.Variant))
	end	
end

function BeckyAchmnts.UnlockToEntityKill(npc)
	local save = mod.SaveManager.GetPersistentSave()

	for i = 1, game:GetNumPlayers() do
		local player = Isaac.GetPlayer()
		local correctedName = string.lower(tostring(player:GetName()))
		local highNum = string.upper(string.sub(correctedName,1,1))
		correctedName = highNum  .. string.sub(correctedName, 2, string.len(correctedName)) --fixing

		local unlock = mod:GetNestedVariable(save, "Unlock" .. correctedName , tostring(npc.Type),  tostring(npc.Variant))

		if unlock and not BeckyAchmnts:IsUnlocked(unlock) then
			BeckyAchmnts:Unlock(unlock, true)
		end
	end
end


-- thanks ff for giantbook manager --------------------------------------------------------------------------------------------------------------------------
local paused
local pausedAt
local pauseDuration = 0
local forceUnpause
local justForcedUnpause

function mod.PauseGame(frames, force)
	if game:GetRoom():GetBossID() ~= 54 or force then -- Intentionally fail achievement note pauses on Lamb, since it breaks the Victory Lap menu super hard
		for _, projectile in pairs(Isaac.FindByType(9)) do
			projectile:Remove()

			local poof = Isaac.Spawn(1000, 15, 0, projectile.Position, Vector.Zero, nil)
			poof.SpriteScale = Vector.One * 0.75
		end

		for _, pillar in pairs(Isaac.FindByType(951, 1)) do
			pillar:Kill()
			pillar:Remove()
		end

		pausedAt = pausedAt or game:GetFrameCount()
		pauseDuration = pauseDuration + frames
		paused = true

		Isaac.GetPlayer():UseActiveItem(CollectibleType.COLLECTIBLE_PAUSE, UseFlag.USE_NOANIM)
	end
end

local achievementSprite = Sprite()
local achievementUpdate = false
local renderAchievement = false

achievementSprite:Load("gfx/ui/achievement/_becky_achievement.anm2", true)

local achievementNoteQueue = {}
function mod.QueueAchievementNote(gfx)
	table.insert(achievementNoteQueue, gfx)
end

function mod.PlayAchievementNote(gfx)
	if Options.DisplayPopups then
		mod.PauseGame(41)

		achievementSprite:ReplaceSpritesheet(2, gfx)
		achievementSprite:LoadGraphics()
		achievementSprite:Play("Idle", true)

		achievementUpdate = false
		renderAchievement = true

		SFXManager():Play(SoundEffect.SOUND_CHOIR_UNLOCK)
	end
end

function mod.IsPlayingAchievementNote()
	return renderAchievement
end

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
	local player = Isaac.GetPlayer()
	if not renderAchievement and #achievementNoteQueue > 0 
	and (not DeadSeaScrollsMenu or (not DeadSeaScrollsMenu.IsOpen() and (not DeadSeaScrollsMenu.QueuedMenus or #DeadSeaScrollsMenu.QueuedMenus == 0))) 
	and player.ControlsEnabled and player.ControlsCooldown == 0 then
		mod.PlayAchievementNote(achievementNoteQueue[1])
		table.remove(achievementNoteQueue, 1)
	end
end)

local function doRender()
	if renderAchievement then
		if achievementUpdate then
			achievementSprite:Update()
		end
		achievementUpdate = not achievementUpdate
	
		local position = game:GetRoom():GetRenderSurfaceTopLeft() * 2 + Vector(442,286) / 2
		achievementSprite:Render(position - Vector(20, 0), Vector.Zero, Vector.Zero)

		if achievementSprite:IsFinished() then
			renderAchievement = false
		end
	end
end

if StageAPI then
	mod:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, function(_, shaderName) -- Hijack the existance of the StageAPI shader to render over the hud
		if shaderName == "StageAPI-RenderAboveHUD" then
			doRender()
		end
	end)
else
	mod:AddCallback(ModCallbacks.MC_POST_RENDER, doRender)
end

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
	justForcedUnpause = nil
	if pausedAt and pausedAt + pauseDuration < game:GetFrameCount() then
		paused = false
		pausedAt = nil
		pauseDuration = 0

		forceUnpause = true
	end

	local save = mod.SaveManager.GetPersistentSave()
end)

for hook = InputHook.IS_ACTION_PRESSED, InputHook.IS_ACTION_TRIGGERED do
	mod:AddCallback(ModCallbacks.MC_INPUT_ACTION, function(_, entity, hook, action)
		if paused and action ~= ButtonAction.ACTION_CONSOLE then
			return false
		end
	end, hook)
end

mod:AddCallback(ModCallbacks.MC_INPUT_ACTION, function(_, entity, hook, action)
	if paused and action ~= ButtonAction.ACTION_CONSOLE then
		return 0
	elseif forceUnpause and action == ButtonAction.ACTION_SHOOTDOWN then
		forceUnpause = false
		justForcedUnpause = true
		return 0.75
	end
end, InputHook.GET_ACTION_VALUE)

-- ok done thanking ----------------------------------------------------------------------------------------------------------------------

BeckyMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_, continuing)
	BeckyAchmnts:Setup()
	BeckyAchmnts.RemoveLockedCollectiblesFromPool()
end)

BeckyMod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, function(_, npc)
	BeckyAchmnts.UnlockToEntityKill(npc)
end)

BeckyMod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
	local save = mod.SaveManager.GetPersistentSave()

	local entTab = {
		{{78, 1}, "Becky", BeckyAchmnts.TRINKET_DEVILZON_PRIME},
		{{78, 0}, "Becky", BeckyAchmnts.TRINKET_DEVILZON_PRIME},
		{{84, 10}, "Becky", BeckyAchmnts.ITEM_SINNER},
		{{102, 0}, "Becky", BeckyAchmnts.ITEM_DREAM_BANISHER},
		{{407, 0}, "Becky", BeckyAchmnts.ITEM_DEAD_SOCKET},
		{{406, 0}, "Becky", BeckyAchmnts.ITEM_COXINHA},
		{{406, 1}, "Becky", BeckyAchmnts.TRINKET_CORPSE_TAG},
		{{912, 10}, "Becky", BeckyAchmnts.ITEM_SCARECROW},
		--{{275, 0}, "Becky", BeckyAchmnts.PICKUP_DEAD_BATTERY},
	--{{275, 0}, "Becky", BeckyAchmnts.ITEM_NIGHT_OF_THE_SLASHER},
		{{273, 0}, "Becky", BeckyAchmnts.ITEM_DEFILED_CHALICE},
		{{102, 1}, "Becky", BeckyAchmnts.TRINKET_HOLY_BOOKMARK},
		{{412, 0}, "Becky", BeckyAchmnts.ITEM_BUTCHERS},
		{{951, 0}, "Becky", BeckyAchmnts.ITEM_NULL_BOMBS},
	--{{951, 0}, "Becky", BeckyAchmnts.ITEM_GHOST_AMULET},
	}

	for _, v in ipairs(entTab) do
		local ach = mod:GetNestedVariable(save, "Unlock" .. v[2], v[1][1], v[1][2])
		if ach == false then
			BeckyAchmnts.AddEntitiesToUnlocks(v[1], v[2], v[3])
		end
	end
end)

return BeckyAchmnts
