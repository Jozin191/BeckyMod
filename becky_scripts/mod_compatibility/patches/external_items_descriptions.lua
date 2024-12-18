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

	--EID._currentMod = "" --So items added after this with no set mod don't display as the becky mod
end

loader:RegisterPatch("EID", EIDPatch)