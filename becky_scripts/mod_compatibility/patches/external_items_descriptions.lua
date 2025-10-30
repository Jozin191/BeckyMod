--luacheck: no max line length
-- Markdown guide https://github.com/wofsauge/External-Item-Descriptions/wiki

local loader = BeckyMod.PatchesLoader

local function EIDPatch()
	local Mod = BeckyMod
	local BECKY_EID = {}

	BECKY_EID.EID_Support = BECKY_EID

	local Item = BeckyMod.Item
	local Trinket = BeckyMod.Trinket
	local Character = BeckyMod.Character

	function BECKY_EID:ClosestPlayerTo(entity) --This seems to error for some people sooo yeah
		if not entity then return EID.player end

		if EID.ClosestPlayerTo then
			return EID:ClosestPlayerTo(entity)
		else
			return EID.player
		end
	end


	--[[
	local player_icons = Sprite()
	player_icons:Load("gfx/ui/eid_character_icons.anm2", true)

	local offsetX, offsetY = 6, 6

	EID:addIcon("Becky", "Main", 1, 16, 16, offsetX, offsetY, player_icons)

	EID.InlineIcons["Player" .. Character.BECKY.PLAYERTYPE] = EID.InlineIcons["Becky"]
	]]


	--#region Helper functions

	---@function
	function BECKY_EID:GetTranslatedString(strTable)
		local lang = EID.getLanguage() or "en_us"
		local desc = strTable[lang] or strTable["en_us"] -- default to english description if there's no translation

		if desc == '' then                            --Default to english if the corresponding translation doesn't exist and is blank
			desc = strTable["en_us"];
		end

		return desc
	end

	--#endregion

	EID._currentMod = "Becky"
	EID:setModIndicatorName("Becky")
	local CustomSprite = Sprite()
	CustomSprite:Load("gfx/ui/eid/hud_eid_becky.anm2", true)
	EID:addIcon("Becky Ghost", "BeckyIcon", 0, 16, 16, 6, 6, CustomSprite)
	EID:setModIndicatorIcon("Becky Ghost")

	local CharIcons = Sprite()
	CharIcons:Load("gfx/ui/eid/becky_icons.anm2", true)
	EID:addIcon("Becky", "Becky", 0, 16, 16, 6, 6, CharIcons)

	EID.InlineIcons["Player" .. Character.BECKY.PLAYERTYPE] = EID.InlineIcons["Becky"]

	-- Dynamic Callbacks

	local function containsFunction(tbl)
		for _, v in pairs(tbl) do
			if type(v) == "function" then
				return true
			end
		end
		return false
	end

	local DynamicDescriptions = {
		[EntityType.ENTITY_PICKUP] = {
			[PickupVariant.PICKUP_COLLECTIBLE] = {},
			[PickupVariant.PICKUP_TAROTCARD] = {},
		}
	}
	
	local DD = {} ---@class DynamicDescriptions
	
	---@param descTab table
	---@return {Func: fun(descObj: table): (string), AppendToEnd: boolean}
	function DD:CreateCallback(descTab, appendToEnd)
		return {
			Func = function(descObj)
				return table.concat(
					Mod:Map(
						descTab,
						function(val)
							if type(val) == "function" then
								local ret = val(descObj)
								if type(ret) == "table" then
									return table.concat(ret, "")
								elseif type(ret) == "string" then
									return ret
								else
									return ""
								end
							end
	
							return val or ""
						end
					),
					""
				)
			end,
			AppendToEnd = appendToEnd or false
		}
	end
	
	---@param modFunc { Func: function } | fun(descObj: table): string
	---@param type integer
	---@param variant integer
	---@param subtype integer
	---@param language string
	function DD:SetCallback(modFunc, type, variant, subtype, language)
		if not DynamicDescriptions[type] then
			DynamicDescriptions[type] = {}
		end
	
		if not DynamicDescriptions[type][variant] then
			DynamicDescriptions[type][variant] = {}
		end
	
		if not DynamicDescriptions[type][variant][subtype] then
			DynamicDescriptions[type][variant][subtype] = {}
		end
	
		if not DynamicDescriptions[type][variant][subtype][language] then
			DynamicDescriptions[type][variant][subtype][language] = modFunc
		else
			error("Description modifier already exists for " .. type .. " " .. variant .. " " .. subtype .. " " .. language,
				2)
		end
	end
	
	---@param type integer
	---@param variant integer
	---@param subtype integer
	---@param language string
	---@return {Func: fun(descObj: table): (string?), AppendToEnd: boolean}?
	function DD:GetCallback(type, variant, subtype, language)
		if not DynamicDescriptions[type] then
			return nil
		end
	
		if not DynamicDescriptions[type][variant] then
			return nil
		end
	
		if not DynamicDescriptions[type][variant][subtype] then
			return nil
		end
	
		if not DynamicDescriptions[type][variant][subtype][language] then
			return DynamicDescriptions[type][variant][subtype]
				["en_us"] -- fallback to english if no translation is available
		end
	
		return DynamicDescriptions[type][variant][subtype][language]
	end
	
	-- concat all subsequent string elements of a dynamic description
	-- into one string so we have to concat less stuff at runtime
	--
	-- this is very much a micro optimization but at worst it does nothing
	---@param desc (string | function)[] | function
	---@return (string | function)[]
	function DD:MakeMinimizedDescription(desc)
		if type(desc) == "function" then
			return { desc }
		end
	
		local out = {}
		local builder = {}
	
		for _, strOrFunc in ipairs(desc) do
			if type(strOrFunc) == "string" then
				builder[#builder + 1] = strOrFunc
			elseif type(strOrFunc) == "function" then
				out[#out + 1] = table.concat(builder, "")
				builder = {}
				out[#out + 1] = strOrFunc
			end
		end
	
		out[#out + 1] = table.concat(builder, "")
	
		return out
	end
	
	---@param desc (string | function)[] | function
	---@return boolean
	function DD:IsValidDescription(desc)
		if type(desc) == "function" then
			return true
		elseif type(desc) == "table" then
			for _, val in ipairs(desc) do
				if type(val) ~= "string" and type(val) ~= "function" then
					return false
				end
			end
		end
	
		return true
	end
	
	BECKY_EID.DynamicDescriptions = DD

	--Health related stuff on items

	if EID.HealthUpData then
		EID.HealthUpData["5.100." .. tostring(Item.COXINHA.ID)] = 1
	end
	
	if EID.HealingItemData then
		EID.HealingItemData["5.100." .. tostring(Item.COXINHA.ID)] = true
		EID.HealingItemData["5.100." .. tostring(Item.DEFILED_CHALICE.ID)] = true
	end

	--Actual Descriptions

	--[[
		DESC EXAMPLE:
		[Item.SOMETHING.ID] = { -- EN: [X] | SPA: [X] 
			en_us = {
				Name = "NAME",
				Description = {
					"LINE 1", 
					"#LINE 2"
				},
			},
		},
	]]

	-- Items

	local EID_Collectibles = {
		[Item.HAND_MADE_BIBLE.ID] = { -- EN: [X] | SPA: [X] 
			en_us = {
				Name = "Hand Made Bible",
				Description = {
					"Coolswag", 
					"#add later"
				},
			},
		},
		[Item.DREAM_BANISHER.ID] = { -- EN: [OK] | SPA: [X] 
			en_us = {
				Name = "Dream Banisher",
				Description = {
					"{{HalfBlackHeart}} +1 half Black Heart when entering a new floor",
					"#{{AngelDevilChanceSmall}} +15% Devil/Angel Room chance",
					"#{{CurseBlind}} When having a curse, gain:",
					"#↑ {{Damage}} +1.5 Damage",
					"#↑ {{Tears}} +0.5 Tears"
				},
			},
		},
		[Item.COXINHA.ID] = { -- EN: [OK] | SPA: [X] 
			en_us = {
				Name = "Coxinha",
				Description = {
					"↑ {{Heart}} +1 Health",
					"#↑ {{Speed}} +" .. Item.COXINHA.SPEED_INCREASE .. " Speed",
					"#{{HealingRed}} Heals 2 hearts",
				},
			},
		},
		[Item.SCARECROW.ID] = { -- EN: [OK] | SPA: [X] 
			en_us = {
				Name = "Scarecrow",
				Description = {
					"{{Collectible117}} Hitting tears without missing or changing the target hit summons a Dead Bird to attack enemies for the room",
					"#Can spawn multiple Dead Birds per room, up to 5"
				},
			},
		},
		[Item.NIGHT_OF_THE_SLASHER.ID] = { -- EN: [OK] | SPA: [X] 
			en_us = {
				Name = "Night of the Slasher",
				Description = {
					"{{HealingRed}} Consumes pickups close to Isaac and heals Isaac for half a heart",
					"#Consuming a Collectible fully heals Isaac and grants a {{BlackHeart}} Black Heart"
				},
			},
		},
		[Item.NULL_BOMBS.ID] = { -- EN: [OK] | SPA: [X] 
			en_us = {
				Name = "Null Bombs",
				Description = {
					"{{Bomb}} +5 Bombs",
					"#{{Collectible399}} Isaac's bombs spawn Maw Of The Void rings"
				},
			},
		},
		[Item.DEAD_SOCKET.ID] = { -- EN: [OK] | SPA: [X] 
			en_us = {
				Name = "Dead Socket",
				Description = {
					"Clearing rooms with full charge on an active item adds one ghost charge to it",
					"#{{Collectible634}} Uppon using an active, generate multiple ghosts depending on the ghost charges"
				},
			},
		},
		[Item.SINNER.ID] = { -- EN: [OK] | SPA: [X] 
			en_us = {
				Name = "Sinner",
				Description = {
					"Orbital that changes speed each rotation",
					"#The faster it is, the more damage it does"
				},
			},
		},
		[Item.DEFILED_CHALICE.ID] = { -- EN: [OK] | SPA: [X] 
			en_us = {
				Name = "Defiled Chalice",
				Description = {
					"{{HealingRed}} Heals 1 heart",
					"#Killing an enemy drops creep that damages other enemies"
				},
			},
		},
	}

	for id, collectibleDescData in pairs(EID_Collectibles) do
		for language, descData in pairs(collectibleDescData) do
			if language:match('^_') then goto continue end -- skip helper private fields
	
			local name = descData.Name
			local description = descData.Description
	
			if not DD:IsValidDescription(description) then
				Mod:Log("Invalid collectible description for " .. name .. " (" .. id .. ")", "Language: " .. language)
				goto continue
			end
	
			local minimized = DD:MakeMinimizedDescription(description)
	
			if not containsFunction(minimized) and not collectibleDescData._AppendToEnd then
				EID:addCollectible(id, table.concat(minimized, ""), name, language)
			else
				-- don't add descriptions for vanilla items that already have one
				if not EID.descriptions[language].collectibles[id] then
					EID:addCollectible(id, "", name, language) -- description only contains name/language, the actual description is generated at runtime
				end
	
				DD:SetCallback(DD:CreateCallback(minimized, collectibleDescData._AppendToEnd), EntityType.ENTITY_PICKUP,
					PickupVariant.PICKUP_COLLECTIBLE, id, language)
			end
	
			::continue::
		end
	end

	-- Trinkets

	local function getTrinketMult(descObj)
		local mult = 1
		if descObj.ObjSubType & TrinketType.TRINKET_GOLDEN_FLAG == TrinketType.TRINKET_GOLDEN_FLAG then
			mult = mult + 1
		end
		if BECKY_EID:ClosestPlayerTo(descObj.Entity):HasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX) then
			mult = mult + 1
		end
		return mult
	end

	--Reminder for myself: holy bookmark specifies "unique" item (no extra copies)

	local EID_Trinkets
	EID_Trinkets = {
		[Trinket.HOLY_BOOKMARK.ID] = { -- EN: [OK] | SPA: [X] 
			_modifier = function(descObj, line) ---@param descObj EID_DescObj
				local mult = getTrinketMult(descObj)
				local luckTxt = tostring(Trinket.HOLY_BOOKMARK.LUCK_PER_ITEM * mult)

				if mult > 1 then
					luckTxt = "{{ColorGold}}" .. luckTxt .. "{{CR}}"
				end

				return EID:SimpleReplace(line, "{1}", luckTxt, 1)
			end,

			en_us = {
				Name = "Holy Bookmark",
				Description = {
					function(descObj)
						return EID_Trinkets[Trinket.HOLY_BOOKMARK.ID]._modifier(descObj, "↑ {{Luck}} +{1} luck")
					end,
					"#{{AngelChanceSmall}} Each unique angel-related item that the player owns grants an extra +" .. Trinket.HOLY_BOOKMARK.LUCK_PER_ITEM .. " luck",
					"#Actives grant twice the luck",
				}
			},
		},
		[Trinket.DEVILZON_PRIME.ID] = {
			_modifier = function(descObj, line) ---@param descObj EID_DescObj
				local mult = getTrinketMult(descObj)
				local chanceTxt = tostring(Trinket.DEVILZON_PRIME.EXTRA_CHANCE_PER_DEAL * 2 * (1 - 0.5^mult))

				if mult > 1 then
					chanceTxt = "{{ColorGold}}" .. chanceTxt .. "{{CR}}"
				end

				return EID:SimpleReplace(line, "{1}", chanceTxt, 1)
			end,

			en_us = {
				Name = "Devilzon Prime",
				Description = {
					function(descObj)
						return EID_Trinkets[Trinket.DEVILZON_PRIME.ID]._modifier(descObj, 
							"{{DevilChanceSmall}} For every deal taken in one floor, you get +{1} deal chance in the next"
						)
					end,
				}
			}
		},
		[Trinket.CORPSE_TAG.ID] = {
			en_us = {
				Name = "Corpse Tag",
				Description = {
					"Chance to get some bone spurs when clearing a room"
				}
			}
		}
	}

	for id, trinketDescData in pairs(EID_Trinkets) do
		for language, descData in pairs(trinketDescData) do
			if language:match('^_') then goto continue end -- skip helper private fields
	
			local name = descData.Name
			local description = descData.Description
	
			if not DD:IsValidDescription(description) then
				Mod:Log("Invalid trinket description for " .. name .. " (" .. id .. ")", "Language: " .. language)
				goto continue
			end
	
			local minimized = DD:MakeMinimizedDescription(description)
	
			if not containsFunction(minimized) and not trinketDescData._AppendToEnd then
				EID:addTrinket(id, table.concat(minimized, ""), name, language)
			else
				-- don't add descriptions for vanilla trinkets that already have one
				if not EID.descriptions[language].trinkets[id] then
					EID:addTrinket(id, "", name, language) -- description only contains name/language, the actual description is generated at runtime
				end
	
				DD:SetCallback(DD:CreateCallback(minimized, trinketDescData._AppendToEnd), EntityType.ENTITY_PICKUP,
					PickupVariant.PICKUP_TRINKET, id, language)
			end
	
			::continue::
		end
	end

	-- Add Characters

	local EID_Characters
	EID_Characters = {
		[Character.BECKY.PLAYERTYPE] = { -- EN: [OK] | SPA: [X] 
			en_us = {
				Name = "Becky",
				Description = {
					"{{AngelDevilChanceSmall}} Devil and Angel deal chances and prices are swapped",
				}
			}
		}
	}

	for playerId, charDescData in pairs(EID_Characters) do
		for lang, descData in pairs(charDescData) do
			if not DD:IsValidDescription(descData.Description) or containsFunction(descData.Description) then
				Mod:Log("Invalid character description for " .. descData.Name, "Language: " .. lang)
			else
				EID:addCharacterInfo(playerId, table.concat(descData.Description, ""), descData.Name, lang)
			end
		end
	end

	EID:addDescriptionModifier(
		"Holy Bookmark Items",
		-- condition
		function(descObj)
			if not BECKY_EID:ClosestPlayerTo(descObj.Entity):HasTrinket(Trinket.HOLY_BOOKMARK.ID) then
				return false
			end
			local isActiveIn = table.indexOf(Trinket.HOLY_BOOKMARK.HolyList.Actives, descObj.ObjSubType) ~= -1
			local isCollectibleIn = table.indexOf(Trinket.HOLY_BOOKMARK.HolyList.Passives, descObj.ObjSubType) ~= -1
			return isActiveIn or isCollectibleIn
		end,
		-- modifier
		function(descObj)
			descObj.Description = descObj.Description .. '#{{Trinket' .. Trinket.HOLY_BOOKMARK.ID .. '}} {{ColorSilver}}This item contributes to Holy Bookmark'

			return descObj
		end
	)

	EID:addDescriptionModifier(
		"Becky Dynamic Description Manager",
		-- condition
		function(descObj)
			local subtype = descObj.ObjSubType
			if descObj.ObjVariant == PickupVariant.PICKUP_TRINKET then
				subtype = Mod:RemoveBitFlags(subtype, TrinketType.TRINKET_GOLDEN_FLAG)
			end

			return DD:GetCallback(descObj.ObjType, descObj.ObjVariant, subtype, EID.getLanguage() or "en_us") ~= nil
		end,
		-- modifier
		function(descObj)
			local subtype = descObj.ObjSubType
			if descObj.ObjVariant == PickupVariant.PICKUP_TRINKET then
				subtype = Mod:RemoveBitFlags(subtype, TrinketType.TRINKET_GOLDEN_FLAG)
			end

			local callback = DD:GetCallback(descObj.ObjType, descObj.ObjVariant, subtype, EID.getLanguage() or "en_us")
			local descString = callback.Func(descObj) ---@diagnostic disable-line: need-check-nil

			if callback.AppendToEnd then ---@diagnostic disable-line: need-check-nil
				descObj.Description = descObj.Description .. descString
			else
				descObj.Description = descString .. descObj.Description
			end

			return descObj
		end
	)

	--EID._currentMod = "" --So items added after this with no set mod don't display as the becky mod
end

loader:RegisterPatch("EID", EIDPatch)