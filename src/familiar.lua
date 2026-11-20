function mod.dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. mod.dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

local favoriteIconData = {
    Scale = 0.32,
    OffsetY = 16,
    OffsetX = 50,
    Animation = "FilledHeartIcon"
}

function mod.ToggleFavoriteFamiliarCostume( screen, button )
    local selectedItem = screen.SelectedItem
    if selectedItem == nil then
        return
    end
    local IsFavorite = game.GameState.ModFamiliarCostumesFavorites[screen.OpenedFrom.Name][selectedItem.Data.Name]
    if selectedItem.Purchased then
        IsFavorite = not IsFavorite == true
        game.GameState.ModFamiliarCostumesFavorites[screen.OpenedFrom.Name][selectedItem.Data.Name] = IsFavorite
        if IsFavorite then
            game.SetAnimation({ Name = favoriteIconData.Animation, DestinationId = selectedItem.FavButtonId, Scale = favoriteIconData.Scale, OffsetY = favoriteIconData.OffsetY, OffsetX = favoriteIconData.OffsetX})
            game.SetAlpha({ Id = selectedItem.FavButtonId, Fraction = 1.0, Duration = 0.1 })
        else
            game.SetAlpha({ Id = selectedItem.FavButtonId, Fraction = 0.0, Duration = 0.1 })
        end
    end
end

function mod.ToggleRandomizeFamiliarCostume(screen, button)
    config.random = config.random == false
    if config.random then
        game.ModifyTextBox({ Id = button.Id, ColorTarget = { 1.0, 0.65, 0.00, 1.0 }, ColorDuration = 0.2 })
    else
        game.ModifyTextBox({ Id = button.Id, ColorTarget = { 0.5, 0.5, 0.5, 1.0 }, ColorDuration = 0.2 })
    end
end

function mod.MouseOffRandomButton( button )
    if config.random then
        game.ModifyTextBox({ Id = button.Id, ColorTarget = { 1.0, 0.65, 0.00, 1.0 }, ColorDuration = 0.2 })
    else
        game.ModifyTextBox({ Id = button.Id, ColorTarget = { 0.5, 0.5, 0.5, 1.0 }, ColorDuration = 0.2 })
    end
end

modutil.mod.Path.Wrap("OpenFamiliarCostumeScreen",function (base,...)
    if config.random then
        game.ScreenData.FamiliarCostumeShop.ComponentData.ActionBar.Children.RandomizeButton.TextArgs.Color = { 1.0, 0.65, 0.0, 1.0 }
    else
        game.ScreenData.FamiliarCostumeShop.ComponentData.ActionBar.Children.RandomizeButton.TextArgs.Color = { 0.5, 0.5, 0.5, 1.0 }
    end
    return base(...)
end)

modutil.mod.Path.Wrap("FamiliarCostumeShopUpdateVisibility", function (base, screen, args)
    return (function (retval)
        args = args or {}
        local components = screen.Components

        screen.ButtonIds = {}

        for index, itemName in ipairs( screen.ItemCategories[screen.OpenedFrom.Name] ) do
            local button = components[itemName.."Button"]
            if button then
                local favIcon = game.CreateScreenComponent({ Name = "BlankObstacle", Group = screen.ComponentData.DefaultGroup, Alpha = 0.0, })
                components[itemName .. "FavIcon"] = favIcon
                table.insert( button.AssociatedIds, favIcon.Id )
                game.Attach({ Id = favIcon.Id, DestinationId = button.Id, OffsetX = screen.PinOffsetX, OffsetY = game.UIData.PinIconListOffsetY })
                button.FavButtonId = favIcon.Id
                if game.GameState.ModFamiliarCostumesFavorites[screen.OpenedFrom.Name][itemName] == true then
                    game.SetAnimation({ Name = favoriteIconData.Animation, DestinationId = button.FavButtonId, Scale = favoriteIconData.Scale, OffsetY = favoriteIconData.OffsetY, OffsetX = favoriteIconData.OffsetX})
                    game.SetAlpha({ Id = favIcon.Id, Fraction = 1.0, Duration = 0.1 })
                end
            end
        end

        return retval
    end)(base(screen, args))
end)