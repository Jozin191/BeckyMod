local loader = BeckyMod.PatchesLoader

local function FiendFolioPatch()
  local ff = FiendFolio

  BeckyMod:AppendTable(ff.ReferenceItems.Trinkets, {
  { ID = BeckyMod.Trinket.DEVILZON_PRIME.ID, Reference = "Amazon" }
  })

  ff:AddStackableItems({
    BeckyMod.Item.SINNER.ID,
    BeckyMod.Item.POUL.ID,
    BeckyMod.Item.GHOST_AMULET.ID,
    BeckyMod.Item.COXINHA.ID,
  })

  BeckyMod.Trinket.BUG_SPRAY:AddFlySpiderEntity(666,160) -- honeydrop
  BeckyMod.Trinket.BUG_SPRAY:AddFlySpiderEntity(180,20) -- buster
  BeckyMod.Trinket.BUG_SPRAY:AddFlySpiderEntity(180,240) -- ghostbuster
end

loader:RegisterPatch("FiendFolio", FiendFolioPatch)