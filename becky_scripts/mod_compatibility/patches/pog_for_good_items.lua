local function pogFunc()
	Poglite:AddPogCostume(
		"Becky Pog",
		BeckyMod.Character.BECKY.PLAYERTYPE,
		Isaac.GetCostumeIdByPath("gfx/characters/costumes/pog/becky_pog.anm2")
	)
	Poglite:AddPogCostume(
		"Tainted Becky Pog",
		BeckyMod.Character.BECKY_B.PLAYERTYPE,
		Isaac.GetCostumeIdByPath("gfx/characters/costumes/pog/becky_pogb.anm2")
	)

	Poglite:AddPogCostume(
		"Sofia Pog",
		BeckyMod.Character.SOFIA.PLAYERTYPE,
		Isaac.GetCostumeIdByPath("gfx/characters/costumes/pog/sofia_pog.anm2")
	)
end

BeckyMod.PatchesLoader:RegisterPatch("Poglite", pogFunc)
