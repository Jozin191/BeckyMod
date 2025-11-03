---@diagnostic disable:undefined-global
local loader = BeckyMod.PatchesLoader

local function FuturePatch()
    if TheFuture then
        TheFuture.ModdedCharacterDialogue["Becky"] = {
            "Huh... i don't remember seeing you in the bible...",
            "I guess you can go in.",
            "As long as your buddy stops bouncing on my uvula...",
            "...",
            "...what? i do have an uvula"
        }
    end
end
loader:RegisterPatch("Future", FuturePatch)