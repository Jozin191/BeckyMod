--I swear Epiphany has everything at this point -Tibu

local Mod = BeckyMod
local loader = {
	Patches = {},
	AppliedPatches = false,
}

Mod.PatchesLoader = loader

function loader:RegisterPatch(mod, patchFunc)
	table.insert(loader.Patches, { Mod = mod, PatchFunc = patchFunc, Loaded = false })
	--Isaac.DebugString(Dump({ Mod = mod, PatchFunc = patchFunc, Loaded = false }))
end

---@function
function loader:ApplyPatches()
	for _, patch in pairs(loader.Patches) do
		-- check if mod reference is valid by getting it by name from the table of globals
		-- we cannot directly pass the mod reference to RegisterPatch
		-- and then check for it because that mod reference will be nil
		-- if that mod is loaded after ours
		local modExists
		if type(patch.Mod) == "function" then
			modExists = patch.Mod()
		else
			modExists = _G[patch.Mod]
		end

		if modExists and not patch.Loaded then
			patch.PatchFunc()
			patch.Loaded = true

            --Thing from epiphany (?
			Mod:DebugLog(table.concat({ "Loaded", tostring(patch.Mod), "patch" }, " "))
		end
	end

	loader.AppliedPatches = true
end

local root = "becky_scripts.mod_compatibility.patches"

local patches = {
    "external_items_descriptions",
    "custom_items",
    "epiphany",
}

for _, fileName in ipairs(patches) do
    include(root .. '.' .. fileName)
end

-- This has to be done after all mods are loaded
-- Because otherwise mods that are loaded after Becky will not be detected
Mod:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, CallbackPriority.LATE, loader.ApplyPatches)

Mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
	if not loader.AppliedPatches then
		loader:ApplyPatches()
	end
end)