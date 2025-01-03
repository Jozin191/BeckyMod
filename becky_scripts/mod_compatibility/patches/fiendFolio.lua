local loader = BeckyMod.PatchesLoader

local function FiendFolioPatch()
    local ff = FiendFolio

    BeckyMod:AppendTable(ff.ReferenceItems.Trinkets, {
		{ ID = BeckyMod.Trinket.DEVILZON_PRIME.ID, Reference = "Amazon" }
	})
end

loader:RegisterPatch("FiendFolio", FiendFolioPatch)