--luacheck: no max line length
-- Markdown guide https://github.com/wofsauge/External-Item-Descriptions/wiki

--if not EID then return end

local loader = BeckyMod.PatchesLoader
local synergiesFun = include("becky_scripts.mod_compatibility.patches.eid_ghost_amulet_synergies")
local spellsEIDFun = include("becky_scripts.mod_compatibility.patches.eid_t_becky_spells")

local function EIDPatch()
	local Mod = BeckyMod
	local BECKY_EID = {}

	BECKY_EID.EID_Support = BECKY_EID

	local Item = BeckyMod.Item
	local Trinket = BeckyMod.Trinket
	local Character = BeckyMod.Character
	local Pickup = BeckyMod.Pickup

	function BECKY_EID:ClosestPlayerTo(entity) --This seems to error for some people sooo yeah
		if not entity then return EID.player end

		if EID.ClosestPlayerTo then
			return EID:ClosestPlayerTo(entity)
		else
			return EID.player
		end
	end


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
	--EID:addIcon("Tainted Becky", "Tainted Becky", 0, 16, 16, 6, 6, CharIcons)

	EID.InlineIcons["Player" .. Character.BECKY.PLAYERTYPE] = EID.InlineIcons["Becky"]
	EID.InlineIcons["Player" .. Character.BECKY_B.PLAYERTYPE] = EID.InlineIcons["Becky"] --EID.InlineIcons["Tainted Becky"]

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

	local EID_Collectibles
	EID_Collectibles = {--[[
		[Item.HAND_MADE_BIBLE.ID] = { -- EN: [X] | SPA: [X] 
			en_us = {
				Name = "Hand Made Bible",
				Description = {
					"Coolswag", 
					"#add later"
				},
			},
		},]]
		[Item.GHOST_AMULET.ID] = { -- EN: [OK] | SPA: [X] 
			en_us = {
				Name = "Ghost Amulet",
				Description = {
					"Isaac's tears are replaced with a controllable familiar",
					"#{{Damage}} The damage it does depends on Isaac's damage and tear rate"
				},
			},
			spa = {
				Name = "Amuleto Fantasmal",
				Description = {
					"Las lágrimas de Isaac son sustituidas por un familiar que controla",
					"#{{Damage}} El daño que hace depende en el daño y lágrimas de Isaac"
				}
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
			spa = {
				Name = "Rompesueños",
				Description = {
					"{{HalfBlackHeart}} +1 medio Corazón Negro al ir a un nuevo piso",
					"#{{AngelDevilChanceSmall}} +15% de probabilidad de salas de Ángel/Diablo",
					"#{{CurseBlind}} Mientras tengas una maldición:",
					"#↑ {{Damage}} +1.5 Daño",
					"#↑ {{Tears}} +0.5 Lágrimas"
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
			spa = {
				Name = "Coxinha",
				Description = {
					"↑ {{Heart}} +1 de Vida",
					"#↑ {{Speed}} +" .. Item.COXINHA.SPEED_INCREASE .. " Velocidad",
					"#{{HealingRed}} Cura 2 corazones",
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
			spa = {
				Name = "Espantapájaros",
				Description = {
					"{{Collectible117}} Acertale a un enemigo sin fallar o cambiar de objetivo, invocará un Ave Muerta a atacar enemigos por el cuarto",
					"#Puede invocar hastá 5 Ave Muertas"
				},
			},
		},
		[Item.BUTCHERS_COOKBOOK.ID] = { -- EN: [OK] | SPA: [X] 
			en_us = {
				Name = "Butcher's Cookbook",
				Description = {
					"When used Spawns a Sawblade"
				},
			},
			spa = {
				Name = "Recetario de carnicero",
				Description = {
					"Genera una sierra"
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
			spa = {
				Name = "Noche de los Asesinos",
				Description = {
					"{{HealingRed}} Consume un recolectable próximos a Isaac y lo cura por medio corazón",
					"#Consumir un Objeto cura totalmente a Isaac y le dá un {{BlackHeart}} Corazón Negro"
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
			spa = {
				Name = "Bombas Nulas",
				Description = {
					"{{Bomb}} +5 Bombas",
					"#{{Collectible399}} Las bombas de Isaac generan un láser de Fauces del Vacío alrededor de ellas"
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
			spa = {
				Name = "Enchufe Roto",
				Description = {
					"Limpiar un cuarto con el objeto activo totalmete cargado, agrega una carga fantasma",
					"#{{Collectible634}} Al usar la activa, generará un fantasma por cada carga fantasma que la activa tenga"
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
			spa = {
				Name = "Pecador",
				Description = {
					"Un orbital que cambia de velocidad por cada rotación que completa",
					"#Cuanto mas rapido va, más daño hace"
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
			spa = {
				Name = "Cáliz Profanado",
				Description = {
					"{{HealingRed}} Cura 1 corazón",
					"#Matar a un enemigo genera un fluido rojo que daña a otros enemigos"
				},
			},
		},

		[Item.UNDEAD_HAND.ID] = { -- EN: [OK] | SPA: [X] 
			en_us = {
				Name = "Undead Hand",
				Description = {
					"On use, if enemies are present",
					"#Spawns a familiar that chases enemies and dealing contact damage",
					"#The familiar can take damage, going down if its hp goes to zero",
					"#The familiar gets up again after 10 seconds",
					"#Enemies killed by the familiar, have a 13% to spawn this familiar"
				},
			},
			spa = {
				Name = "Mano No Muerta",
				Description = {
					"Al usarlo, si hay enemigos presentes",
					"#Genera un familiar que persigue enemigos e infligiendo daño por contacto",
					"#El familiar puede ser dañado, cayendo si su vida llega a cero",
					"#El familiar se vuelve a levantar despues de 10 segundos",
					"#Enemigos matados por el familiar, tienen un 13% de generar a este familiar"
				},
			},
		},
		[Item.MAGIC_STAFF.ID] = { -- EN: [OK] | SPA: [X]
			en_us = {
				Name = "Magic Staff",
				Description = {
					"On use, lets Isaac select 1 of 4 spells",
					"#This spells change between uses",
				},
			},
			spa = {
				Name = "Bastón Mágico",
				Description = {
					"Al usarlo, deja a Isaac elegir 1 de los 4 hechizos",
					"#Estos hechizos cambian entre cada uso",
				},
			},
		},
		[Item.MAGIC_STAFF.TAINTED_BECKY_ID] = { -- EN: [X] | SPA: [X] 
			_modifier = function(descObj)
				local desc = "{{ColorYellow}}Current spells:{{CR}}"

				for idx, spell in ipairs(BeckyMod.Spells:GetSpells(EID.player)) do
					if spell ~= BeckyMod.Spells.SpellType.NULL then
						desc = desc .."#"..BeckyMod.Spells:GetSpellEIDDesc(spell)
					end
				end
				return desc
			end,
			en_us = {
				Name = "Magic Staff",
				Description = {
					function(descObj) return EID_Collectibles[Item.MAGIC_STAFF.TAINTED_BECKY_ID]._modifier(descObj) end,
				},
			},
			spa = {
				Name = "Bastón Mágico",
				Description = {
					function(descObj) return EID_Collectibles[Item.MAGIC_STAFF.TAINTED_BECKY_ID]._modifier(descObj) end,
				},
			},
		},

		[Item.POUL.ID] = { -- EN: [OK] | SPA: [X]
			_BFFSMod = function(descObj, line)
				if not BECKY_EID:ClosestPlayerTo(descObj.Entity):HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then return end
				return "#{{Colletible".. CollectibleType.COLLECTIBLE_BFFS .."}} "..line
			end,
			en_us = {
				Name = "Poul",
				Description = {
					"Spawns a familiar that moves around picking rocks and throwing it to enemies",
					"#Pickups tinted rocks and throws it to Isaac if no enemy is present",
					function(descObj) return EID_Collectibles[Item.POUL.ID]._BFFSMod(descObj, "The familiar can pick up various rocks at the same time") end,
				},
			},
			spa = {
				Name = "Poul",
				Description = {
					"Genera un familiar que se mueve por el cuarto agarrando piedras y lanzándolas a los enemigos",
					"#Agarrar piedras marcadas y las lanza a Isaac si no hay enemigos presentes",
					function(descObj) return EID_Collectibles[Item.POUL.ID]._BFFSMod(descObj, "El familiar puede agarrar varias piedras al mismo tiempo") end,
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
						return EID_Trinkets[Trinket.HOLY_BOOKMARK.ID]._modifier(descObj, "↑ {{Luck}} +{1} Luck")
					end,
					"#{{AngelChanceSmall}} Each unique angel-related item that Isaac owns grants an extra +" .. Trinket.HOLY_BOOKMARK.LUCK_PER_ITEM .. " luck",
					"#Actives grant twice the luck",
				}
			},
			spa = {
				Name = "Marcapáginas Sagrado",
				Description = {
					function(descObj)
						return EID_Trinkets[Trinket.HOLY_BOOKMARK.ID]._modifier(descObj, "↑ {{Luck}} +{1} Suerte")
					end,
					"#{{AngelChanceSmall}} Cada objeto relacionado a los ángeles que Isaac posea le dará +" .. Trinket.HOLY_BOOKMARK.LUCK_PER_ITEM .. " suerte",
					"#Activas dan el doble de suerte",
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
							"{{DevilChanceSmall}} For every deal taken in one floor, Isaac gets +{1} deal chance in the next floor"
						)
					end,
				}
			},
			spa = {
				Name = "Diablon Prime",
				Description = {
					function(descObj)
						return EID_Trinkets[Trinket.DEVILZON_PRIME.ID]._modifier(descObj, 
							"{{DevilChanceSmall}} Por cada pacto tomado en el piso, Isaac obtiene +{1} de encontrar la sala de pacto en la siguiente piso"
						)
					end,
				}
			},
		},
		[Trinket.CORPSE_TAG.ID] = {
			en_us = {
				Name = "Corpse Tag",
				Description = {
					"Chance to get some bone spurs when clearing a room"
				}
			},
			spa = {
				Name = "Etiqueta de Cadáver",
				Description = {
					"Limpiar un cuarto puede que de unas espuelas de huesos"
				}
			},
		},
		[Trinket.SANGUINE_FEATHER.ID] = {
			en_us = {
				Name = "Sanguine Feather",
				Description = {
					"Has a 33% chance of giving flight after receiving damage for the room"
				}
			},
			spa = {
				Name = "Pluma Sangrienta",
				Description = {
					"Tiene un 33% de probabilidad de dar vuelo por el cuarto al recibir daño"
				}
			},
		},

		[Trinket.ALARM_CLOCK.ID] = {
			_modifier = function(descObj, line) ---@param descObj EID_DescObj
				local mult = getTrinketMult(descObj)
				local chanceTxt = tostring((1-(19/20)^mult) *100)

				if mult > 1 then
					chanceTxt = "{{ColorGold}}" .. chanceTxt .. "{{CR}}"
				end

				return EID:SimpleReplace(line, "{1}", chanceTxt, 1)
			end,

			en_us = {
				Name = "Alarm Clock",
				Description = {
					"Upon clearing a room",
					function(descObj)
						return EID_Trinkets[Trinket.ALARM_CLOCK.ID]._modifier(descObj, 
							"#{{Timer}} -{1} seconds of the game timer"
						)
					end,
				}
			},
			spa = {
				Name = "Despertador",
				Description = {
					"Al limpiar un cuarto",
					function(descObj)
						return EID_Trinkets[Trinket.ALARM_CLOCK.ID]._modifier(descObj, 
							"#{{Timer}} -{1} segundos en el tiempo del juego"
						)
					end,
				}
			},
		},
		[Trinket.BUG_SPRAY.ID] = {
			_modifier = function(descObj, line) ---@param descObj EID_DescObj
				local mult = getTrinketMult(descObj)
				local chanceTxt = tostring(0.36 *mult *100)

				if mult > 1 then
					chanceTxt = "{{ColorGold}}" .. chanceTxt .. "{{CR}}"
				end

				return EID:SimpleReplace(line, "{1}", chanceTxt, 1)
			end,

			en_us = {
				Name = "Bug Spray",
				Description = {
					function(descObj)
						return EID_Trinkets[Trinket.BUG_SPRAY.ID]._modifier(descObj, 
							"Flies and spider type enemies take {1}% more damage"
						)
					end,
				}
			},
			spa = {
				Name = "Repelente de Insectos",
				Description = {
					function(descObj)
						return EID_Trinkets[Trinket.BUG_SPRAY.ID]._modifier(descObj, 
							"Enemigos del tipo mosca o aracnido reciben {1}% más daño"
						)
					end,
				}
			}
		},
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

	-- Cards

	local EID_Cards
	EID_Cards = {
		[Pickup.RIPPED_CARD.ID] = {
			_metadata = {2, false},

			_modifier = function(descObj, line, replace)
				if BECKY_EID:ClosestPlayerTo(descObj.Entity):HasCollectible(CollectibleType.COLLECTIBLE_TAROT_CLOTH) then
					return replace
				end

				return line
			end,

			en_us = {
				Name = "Ripped Card",
				Description = {
					"Activates a random ",
					function(descObj)
						return EID_Cards[Pickup.RIPPED_CARD.ID]._modifier(descObj,
							"but weaker version of a tarot card",
							"{{ColorShinyPurple}}tarot card{{CR}}"
						)
					end,
					"#This card is more likely to spawn while holding it"
				}
			},
			spa = {
				Name = "Carta Partida",
				Description = {
					"Activa el efecto ",
					function(descObj)
						return EID_Cards[Pickup.RIPPED_CARD.ID]._modifier(descObj,
							"debil de una carta tarot",
							"de una {{ColorShinyPurple}}carta tarot{{CR}}"
						)
					end,
					"#Es más probable que esta carta vuelva a aparecer mientras Isaac lo sostenga"
				}
			},
		},
		[Pickup.RIPPED_CARD.ID2] = {
			_metadata = {4, false},

			_modifier = function(descObj, line, replace)
				if BECKY_EID:ClosestPlayerTo(descObj.Entity):HasCollectible(CollectibleType.COLLECTIBLE_TAROT_CLOTH) then
					return replace
				end

				return line
			end,

			en_us = {
				Name = "Patched Card",
				Description = {
					"Activates 2 random ",
					function(descObj)
						return EID_Cards[Pickup.RIPPED_CARD.ID2]._modifier(descObj,
							"but weaker version of the tarot cards",
							"{{ColorShinyPurple}}tarot cards{{CR}}")
					end,
					"#Ripped Card is more likely to spawn while holding this"
				}
			},
			spa = {
				Name = "Carta Parcheada",
				Description = {
					"Activa 2 efectos ",
					function(descObj)
						return EID_Cards[Pickup.RIPPED_CARD.ID2]._modifier(descObj,
							"debiles de unas cartas tarot",
							"{{ColorShinyPurple}}cartas tarot{{CR}}")
					end,
					"#Es mas probable que Carta Partida vuelva a aparecer mientras Isaac lo sostenga"
				}
			},
		},
		[Pickup.SOUL_OF_BECKY.ID] = {
			_metadata = {2, true},
			--[[
			_modifier = function(descObj)
				if BECKY_EID:ClosestPlayerTo(descObj.Entity):HasCollectible(CollectibleType.COLLECTIBLE_TAROT_CLOTH) then
					return "Activates 2 random {{ColorShinyPurple}}tarot card{{CR}}"
				end

				return "Activates 2 random but weaker version of a tarot card"
			end,]]

			en_us = {
				Name = "Soul of Becky",
				Description = {
					"Forces Isaac to select 1 of 4 spells"
				}
			},
			spa = {
				Name = "Alma de Becky",
				Description = {
					"Obliga a Isaac a elegir 1 de los 4 hechizos"
				}
			},
		},
	}

	for id, cardDescData in pairs(EID_Cards) do
		for language, descData in pairs(cardDescData) do
			if language:match('^_') then goto continue end -- skip helper private fields

			local name = descData.Name
			local description = descData.Description

			if not DD:IsValidDescription(description) then
				Mod:Log("Invalid card description for " .. name .. " (" .. id .. ")", "Language: " .. language)
				goto continue
			end

			local minimized = DD:MakeMinimizedDescription(description)

			if not containsFunction(minimized) and not cardDescData._AppendToEnd then
				EID:addCard(id, table.concat(minimized, ""), name, language)
			else
				-- don't add descriptions for vanilla cards that already have one
				if not EID.descriptions[language].cards[id] then
					EID:addCard(id, "", name, language) -- description only contains name/language, the actual description is generated at runtime
				end

				DD:SetCallback(DD:CreateCallback(minimized, cardDescData._AppendToEnd), EntityType.ENTITY_PICKUP,
					PickupVariant.PICKUP_TAROTCARD, id, language)
			end

			::continue::
		end

		local metadata = cardDescData._metadata
		if metadata then
			EID:addCardMetadata(id, metadata[1], metadata[2])
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
			},
			spa = {
				Name = "Becky",
				Description = {
					"{{AngelDevilChanceSmall}} Los pactos del Diablo y Angel estan invertidos",
				}
			},
		},
		[Character.BECKY_B.PLAYERTYPE] = { -- EN: [OK] | SPA: [X] 
			en_us = {
				Name = "Tainted Becky",
				Description = {
					"{{AngelDevilChanceSmall}} Devil and Angel deal chances and prices are swapped",
				}
			},
			spa = {
				Name = "Becky Corrupta",
				Description = {
					"{{AngelDevilChanceSmall}} Los pactos del Diablo y Angel estan invertidos",
				}
			},
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
	

	EID:addBirthright(Character.BECKY.PLAYERTYPE, "The Ghost's range becomes unlimited", "Becky", "en_us")
	EID:addBirthright(Character.BECKY.PLAYERTYPE, "El Fantasma tiene rango ilimitado", "Becky", "spa")
	EID:addBirthright(Character.BECKY_B.PLAYERTYPE, "Shopkeepers will now sell spells to Tainted Becky", "Tainted Becky", "en_us")
	EID:addBirthright(Character.BECKY_B.PLAYERTYPE, "Tenderos ahora le venderan hechizos a Becky Corrupta", "Becky Corrupta", "spa")

	local BeckyDeals = {
		{
			Ids = "5.350."..TrinketType.TRINKET_DEVILS_CROWN,
			Desc = {
				en_us = "{{ColorSilver}}The deals in the treasure room cost money instead of health{{CR}}",
				spa = "{{ColorSilver}}Los tratos en la sala del tesoro costara dinero envez de vida{{CR}}",
			}
		},
		{
			Ids = CollectibleType.COLLECTIBLE_SATANIC_BIBLE,
			Desc = {
				en_us = "{{ColorSilver}}The deals in the boss room cost money instead of health{{CR}}",
				spa = "{{ColorSilver}}Los tratos en la sala del jefe costara dinero envez de vida{{CR}}",
			}
		},
		{
			Ids = CollectibleType.COLLECTIBLE_STAIRWAY,
			Desc = {
				en_us = "{{ColorSilver}}The angel shop cost health instead of money{{CR}}",
				spa = "{{ColorSilver}}La tienda del ángel costara vida envez de dinero{{CR}}",
			}
		},
	}

	for _, data in ipairs(BeckyDeals) do
		for leng, desc in pairs(data.Desc) do
			EID:addPlayerCondition(data.Ids, Character.BECKY.PLAYERTYPE, desc, nil, leng, nil, true)
		end
	end
	if EID.TaintedToRegularID then
		EID.TaintedToRegularID[Character.BECKY_B.PLAYERTYPE] = Character.BECKY.PLAYERTYPE
	end

	if Epiphany then
		local BrokenHaloDesc = {
			en_us = "{{ColorSilver}}The devil deals in the room will cost money instead of health{{CR}}",
			spa = "{{ColorSilver}}Los tratos del diablo costara dinero envez de vida{{CR}}",
		}
		for leng, desc in pairs(BrokenHaloDesc) do
			EID:addPlayerCondition(Epiphany.Item.BROKEN_HALO.ID, Character.BECKY.PLAYERTYPE, desc, nil, leng, nil, true)
		end
	end


	local EID_ENT_DESC
	EID_ENT_DESC = {
		_modifier = function(descObj)
			local player = BECKY_EID:ClosestPlayerTo(descObj.Entity)
			local spell = BeckyMod.Spells:GetDealSpellFromPlayer(player)
			if BeckyMod.Level():GetCurses() & LevelCurse.CURSE_OF_BLIND >0 then
				spell = BeckyMod.Spells.SpellType.NULL
			end
			return BeckyMod.Spells:GetSpellEIDDesc(spell)
		end,
		en_us = {
			Name = "Spell Deal Entity",
			Description = {
				"{{Player".. Character.BECKY_B.PLAYERTYPE .."}} {{ColorSilver}}Tainted Becky{{CR}}",
				"#", function(descObj) return EID_ENT_DESC._modifier(descObj) end,
			}
		},
		spa = {
			Name = "Spell Deal Entity",
			Description = {
				"{{Player".. Character.BECKY_B.PLAYERTYPE .."}} {{ColorSilver}}Becky Corrupta{{CR}}",
				"#", function(descObj) return EID_ENT_DESC._modifier(descObj) end,
			}
		},
	}
	for language, descData in pairs(EID_ENT_DESC) do
		if language:match('^_') then goto continue end -- skip helper private fields

		local name = descData.Name
		local description = descData.Description

		if not DD:IsValidDescription(description) then
			Mod:Log("Invalid card description for Spell Deal (" .. BeckyMod.Spells.ENTITIES.EID_ENT.Type..".".. BeckyMod.Spells.ENTITIES.EID_ENT.Variant.. ")", "Language: " .. language)
			goto continue
		end

		local minimized = DD:MakeMinimizedDescription(description)

		if not containsFunction(minimized) then
			EID:addEntity(BeckyMod.Spells.ENTITIES.EID_ENT.Type, BeckyMod.Spells.ENTITIES.EID_ENT.Variant, 0, "Spell Deal", table.concat(minimized, ""), language)
		else
			if not EID.descriptions[language].custom[BeckyMod.Spells.ENTITIES.EID_ENT.Type .. "." .. BeckyMod.Spells.ENTITIES.EID_ENT.Variant .. "." .. 0] then
				EID:addEntity(BeckyMod.Spells.ENTITIES.EID_ENT.Type, BeckyMod.Spells.ENTITIES.EID_ENT.Variant, 0, "Spell Deal", "", language)
			end

			DD:SetCallback(DD:CreateCallback(minimized, false), BeckyMod.Spells.ENTITIES.EID_ENT.Type,
			BeckyMod.Spells.ENTITIES.EID_ENT.Variant, 0, language)
		end

		::continue::
	end


	synergiesFun()
	spellsEIDFun()

	
	--EID._currentMod = "" --So items added after this with no set mod don't display as the becky mod
end

loader:RegisterPatch("EID", EIDPatch)