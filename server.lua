local QBCore = exports['qb-core']:GetCoreObject()


-- Register the callback

QBCore.Functions.CreateCallback('nt_drugdelivery_checksplayer', function(source, cb)
    local player = QBCore.Functions.GetPlayer(source)
    local identifier = player.PlayerData.citizenid

    MySQL.Async.fetchScalar('SELECT 1 FROM nt_drugdelivery_players WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    }, function(result)
        if result then
            cb(true)
        else
            cb(false)
        end
    end)
end)


QBCore.Functions.CreateCallback('nt_drugdelivery_checks_task', function(source, cb)
    local player = QBCore.Functions.GetPlayer(source)
    local identifier = player.PlayerData.citizenid

    MySQL.Async.fetchScalar('SELECT 1 FROM nt_drugdelivery_players WHERE task_completed = @task_completed', {
        ['@task_completed'] = 0
    }, function(result)
        if result then
            cb(true)
        else
            cb(false)
        end
    end)
end)

QBCore.Functions.CreateCallback('nt_drugdelivery_addplayer', function(source, cb)
    local player = QBCore.Functions.GetPlayer(source)
    local identifier = player.PlayerData.citizenid

    MySQL.Async.execute('INSERT INTO nt_drugdelivery_players (identifier, task_completed) VALUES (@identifier, @task_completed)', {
        ['@identifier'] = identifier,
        ['@task_completed'] = false
    }, function(rowsChanged)
        cb(false)
    end)
end)

QBCore.Functions.CreateCallback('nt_drugdelivery_task_completed', function(source, cb)
    local player = QBCore.Functions.GetPlayer(source)
    local identifier = player.PlayerData.citizenid

    MySQL.Async.fetchScalar('SELECT 1 FROM nt_drugdelivery_players WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    }, function(result)
        if result then
            MySQL.Async.execute('UPDATE nt_drugdelivery_players SET task_completed = true WHERE identifier = @identifier', {
                ['@identifier'] = identifier
            }, function(rowsChanged)
                if rowsChanged > 0 then
                    cb(true)
                else
                    cb(false)
                end
            end)
        else
            cb(false)
        end
    end)
end)

QBCore.Functions.CreateCallback('nt_drugdelivery_getcoords', function(source, cb)
    MySQL.Async.fetchAll('SELECT x, y, z, id FROM nt_drugdelivery_location ORDER BY RAND() LIMIT 1', {}, function(result)
        if result[1] then
            local x = result[1].x
            local y = result[1].y
            local z = result[1].z
            local id = result[1].id
            cb(result)
        else
            cb(nil)
        end
    end)
end)

QBCore.Functions.CreateCallback('nt_drugdelivery_getcoords_all', function(source, cb)
    MySQL.Async.fetchAll('SELECT x, y, z, id FROM nt_drugdelivery_location', {}, function(result)
        if result[1] then
            local x = result[1].x
            local y = result[1].y
            local z = result[1].z
            local id = result[1].id
            cb(result)
        else
            cb(nil)
        end
    end)
end)

-- Add command
RegisterCommand(Config.addcords, function (source, args, raw)
    local player = source
    local playerCoords = GetEntityCoords(GetPlayerPed(player))
    local x, y, z = playerCoords.x, playerCoords.y, playerCoords.z
    local hasPerms = QBCore.Functions.HasPermission(player, 'God')
    if hasPerms then
        MySQL.Async.execute('INSERT INTO nt_drugdelivery_location (x, y, z) VALUES (@x, @y, @z)', {
            ['@x'] = x,
            ['@y'] = y,
            ['@z'] = z
        }, function(affectedRows)
            TriggerClientEvent('ox_lib:notify', player, { title = 'SYSTEM - DRUG LOCATION', type = 'success', description = 'Du tilføjede dine coords til databasen!',duration= 7000,  position = 'center-right' })
        end)
    end
end)

QBCore.Functions.CreateCallback('nt_druglocation_remove', function(source, cb, id)
    MySQL.Async.execute('DELETE FROM nt_drugdelivery_location WHERE id = @id', {
        ['@id'] = id
    }, function(affectedRows)
        if affectedRows > 0 then
            cb(true)
        else
            cb(false)
        end
    end)
end)


-- Give Player Money

RegisterNetEvent("nt_drugdelivery_deliverd", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local money = math.random(25, 1800) * 1000
    Player.Functions.AddMoney("cash", money)
    sendToDiscord(7730498, "Drug Delivery", "Player: ".. Player.. "\nModtog: ".. money .. "DDK", "Lavet af Notepad")
    TriggerClientEvent('ox_lib:notify', src, { title = 'Martin', type = 'success', description = 'Tak fordi du afleveret stofferne! Her for du '..money..' DDK for at klare jobbet!',duration= 7000,  position = 'center-right' })
end)


-- Discord webhook
function sendLogs(color, name, message, footer)
    local embed = {
          {
              ["color"] = color,
              ["title"] = "**".. name .."**",
              ["description"] = message,
              ["footer"] = {
                  ["text"] = footer,
              },
          }
      }
  
    PerformHttpRequest(Config.Logs, function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
end
