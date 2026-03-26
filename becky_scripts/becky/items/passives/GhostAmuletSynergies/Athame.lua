-- ---@param fam EntityFamiliar
-- ---@param enemy EntityNPC
-- BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_KILL_ENEMY, function(_, fam, enemy)
--     local player = fam.Player

--     if not player then return end
--     if not player:HasCollectible(CollectibleType.COLLECTIBLE_ATHAME) then return end

--     local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_ATHAME)
--     local formula = math.min(1, 0.25 + (0.025 * player.Luck))

--     if rng:RandomFloat() > formula then return end

--     -- local voidring = player:SpawnMawOfVoid(30)
--     -- voidring.Position = fam.Position
-- end)