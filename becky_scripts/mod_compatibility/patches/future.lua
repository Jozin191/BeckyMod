local Mod = BeckyMod
local loader = BeckyMod.PatchesLoader

local function futurePatch()
    TheFuture.ModdedCharacterDialogue["Becky"] = {
            "Huh... i don't remember seeing you in the bible...",
            "I guess you can go in.",
            "As long as your buddy stops bouncing on my uvula...",
            "...",
            "...what? i do have an uvula"
    }
	TheFuture.ModdedCharacterDialogue["Sofia"] = {
			"...",
			"you like... need a band aid?",
			"you might need several ones tho...",
			"maybe you'll find some in here..."
	}
	TheFuture.ModdedTaintedCharacterDialogue["Becky"] = {
			"what are you?...",
			"a wizard? oh, i see i see",
			"i know a place you surely like",
			"is pretty magical if i say so"
	}
end

loader:RegisterPatch("TheFuture", futurePatch)