lib.locale()
local function getPlayerData(source)
    local identifier = GetPlayerIdentifiers(source)[1]:match("([^:]+)$")
    local foodExp = MySQL.single.await("SELECT `foodExp` FROM `users` WHERE `identifier` = @identifier", {
        ['@identifier'] = identifier
    })

    if not foodExp then return 0 end
    return foodExp.foodExp
end

local function calculateData(xp)
    local levels = FS.levels
    
    for _,v in pairs(levels) do
        if xp < v.xp then
            return {
                level = v.level - 1,
                nextLevel = v.level,
                xpToNextLevel = v.xp - xp,
                rewardMultiplier = FS.levels[v.level - 1].rewardmultiplier,
                levelPercentage = math.floor((xp / v.xp) * 100),
            }
        end
    end
end

ESX.RegisterServerCallback('fs-fooddelivery:server:getPlayerLevelData', function(source, cb)
    local foodExp = getPlayerData(source)
    local calculatedLevel = calculateData(foodExp)

    cb(calculatedLevel)
end)

local function logToDiscord(message)
    local discordWebhook = FS.discordWebhook
    local discordInfo = {
        ["color"] = "8602074",
        ["type"] = "rich",
        ["title"] = "[Fusion scripts]",
        ["description"] = message,
        ["footer"] = {
            ["text"] = "Fusion scripts",
        },
    }
    PerformHttpRequest(discordWebhook, function(err, text, headers) end, 'POST', json.encode({embeds = {discordInfo}}), { ['Content-Type'] = 'application/json' })
end


RegisterNetEvent('fs-fooddelivery:server:deliverFood')
AddEventHandler('fs-fooddelivery:server:deliverFood', function(currentdel)
    local source = source
    local foodExp = getPlayerData(source)
    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    print('currentdel', currentdel)
    if not currentdel then return end
    print(currentdel.x, currentdel.y, currentdel.z)
    local dist = #(playerCoords - vector3(currentdel.x, currentdel.y, currentdel.z))
    if dist < 3.0 then
        if source then
            local reward = {
                xp = math.random(FS.rewardPerDelivery.xp.min, FS.rewardPerDelivery.xp.max),
                money = math.random(FS.rewardPerDelivery.money.min, FS.rewardPerDelivery.money.max) * calculateData(foodExp).rewardMultiplier
            }

            local newFoodExp = foodExp + reward.xp

            local identifier = GetPlayerIdentifiers(source)[1]:match("([^:]+)$")
            MySQL.Async.execute("UPDATE `users` SET `foodExp` = @foodExp WHERE `identifier` = @identifier", {
                ['@foodExp'] = newFoodExp,
                ['@identifier'] = identifier
            })

            exports.ox_inventory:AddItem(source, FS.moneyItem, reward.money)
            TriggerClientEvent('ox_lib:notify', source, 'success', locale('delivery_complete', reward.xp, reward.money))
            local logmsg = 'Player: ' .. GetPlayerName(source) .. ' has delivered food and received ' .. reward.xp .. ' xp and $' .. reward.money
            logToDiscord(logmsg)
        end
    else
        logToDiscord('Player: ' .. GetPlayerName(source) .. ' tried to deliver food without being at the delivery point')
    end
end)