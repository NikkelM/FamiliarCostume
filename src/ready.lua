CosmeticsAPI.RegisterCrossroadsPackages({ _PLUGIN.guid .. "zerp-Familiar_Costume_Randomizer" })
CosmeticsAPI.RegisterAlwaysLoadedPackages({ _PLUGIN.guid .. "zerp-Familiar_Costume_RandomizerSkins" })

function mod.GetUnlockedFamiliarCostumes(costumeList)
    local unlockedCostumes = {}
    for _, costume in ipairs(costumeList) do
        if game.GameState.WorldUpgrades[costume] then
            table.insert(unlockedCostumes,costume)
        end
    end
    return unlockedCostumes
end

function mod.GetFavorites(costumeList, currentFamiliar)
    local favorites = mod.GetOrCreateFamiliarCostumeFavorites(currentFamiliar)
    local favoriteCostume = {}
    for _, costume in ipairs(costumeList) do
        if favorites[costume] then
            table.insert(favoriteCostume,costume)
        end
    end
    return favoriteCostume
end

modutil.mod.Path.Wrap("StartNewRun", function(base, prevRun, args)
    local retValue = base(prevRun,args)
    if game.GameState == nil then
        return retValue
    end

    if config.random then
        local currentFamiliar = game.GameState.EquippedFamiliar
        local costumeList = game.ScreenData.FamiliarCostumeShop.ItemCategories[currentFamiliar]
        if costumeList ~= nil then
            local favoriteList = mod.GetFavorites(costumeList, currentFamiliar)
            local randomCostume
            if #favoriteList > 0 then
                randomCostume = game.GetRandomArrayValue(favoriteList)
            else
                randomCostume = game.GetRandomArrayValue(mod.GetUnlockedFamiliarCostumes(costumeList))
            end

            if randomCostume ~= nil then
                CosmeticsAPI.SelectFamiliarCostume(currentFamiliar, randomCostume)
            end
        end
    end
    return retValue
end)

modutil.mod.Path.Wrap("MouseOverFamiliarCostumeItem", function (base, button)
    base(button)
    local screen = button.Screen
	if screen.Closing then
		return
	end
    if button.Purchased then
        game.SetAlpha({ Id = screen.Components.FavoriteButton.Id, Fraction = 1.0, Duration = 0.1 })
    else
        game.SetAlpha({ Id = screen.Components.FavoriteButton.Id, Fraction = 0.0, Duration = 0.1 })
    end
end)

modutil.mod.Path.Wrap("MouseOffFamiliarCostumeItem", function (base, button)
    base(button)
    local screen = button.Screen
	if screen.Closing then
		return
	end
    game.SetAlpha({ Id = screen.Components.FavoriteButton.Id, Fraction = 0.0, Duration = 0.1 })
end)
