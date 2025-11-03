---@diagnostic disable: undefined-global


if not UniqueItemsAPI then return end
BeckyMod:AddCallback(UniqueItemsAPI.Callbacks.LOAD_UNIQUE_ITEMS, function()
    local PLAYER_BECKY = BeckyMod.Enums.PlayerType.BECKY
    UniqueItemsAPI.RegisterMod("BeckyMod")
    UniqueItemsAPI.RegisterCharacter("Becky", false, "Becky")

    UniqueItemsAPI.AssignUniqueObject({ --Mr Dolly Custom Sprite
        PlayerType = PLAYER_BECKY,
        ObjectID = CollectibleType.COLLECTIBLE_MR_DOLLY,
        SpritePath = {"gfx_becky_custom/Mr_Dolly_Becky.png"}
    }, UniqueItemsAPI.ObjectType.COLLECTIBLE)

    UniqueItemsAPI.AssignUniqueObject({ --Birthright Custom Sprite
        PlayerType = PLAYER_BECKY,
        ObjectID = CollectibleType.COLLECTIBLE_BIRTHRIGHT,
        SpritePath = {"gfx_becky_custom/beckybirthright.png"}
    }, UniqueItemsAPI.ObjectType.COLLECTIBLE)
end)