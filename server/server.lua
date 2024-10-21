ESX = exports['es_extended']:getSharedObject()

function DebugPrint(...)
    if Config.DebugMode then
        print(...)
    end
end

AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
    local currentDate = os.date("%Y-%m-%d %H:%M:%S") -- Fecha actual formateada
    MySQL.Async.execute('UPDATE users SET last_login = @last_login WHERE identifier = @identifier', {
        ['@last_login'] = currentDate,
        ['@identifier'] = xPlayer.getIdentifier()
    }, function(rowsChanged)
        if rowsChanged > 0 then
            DebugPrint('Last login updated for player: ' .. xPlayer.getIdentifier())
        end
    end)
end)

function deleteTables(table, column, identifier)
    local sql = string.format('DELETE FROM `%s` WHERE `%s`=@identifier', table, column)
    MySQL.Sync.execute(sql, {
        ['@identifier'] = identifier,
    })
end

function doCharacterKill(identifier)
    for _, data in pairs(Config.Tables) do
        deleteTables(data.table, data.column, identifier)
    end
end

function checkInactivePlayers()
    local inactivityDateTime = GetInactivityDateTime()
    DebugPrint("Checking players inactive since: " .. inactivityDateTime)

    local inactiveUsers = GetInactiveUsers(inactivityDateTime) 
    DebugPrint("• Found " .. #inactiveUsers .. " inactive users")

    for _, user in ipairs(inactiveUsers) do
        print("  + Performing CK for player: " .. user.identifier)
        doCharacterKill(user.identifier)
    end
end

function GetInactiveUsers(inactivityDateTime)
    return MySQL.query.await(
        'SELECT `identifier`, `last_login` FROM `users` WHERE `last_login` <= ?', 
        { inactivityDateTime }
    )
end

function GetInactivityDateTime()
    local currentTimestamp = os.date("*t", os.time())
    currentTimestamp.day = currentTimestamp.day - Config.AutomaticCKTrigger

    if currentTimestamp.day <= 0 then
        currentTimestamp.month = currentTimestamp.month - 1
        if currentTimestamp.month <= 0 then
            currentTimestamp.month = 12
            currentTimestamp.year = currentTimestamp.year - 1
        end
        currentTimestamp.day = 30
    end

    local inactivityTimestamp = os.time(currentTimestamp)
    return os.date("%Y-%m-%d %H:%M:%S", inactivityTimestamp)
end

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end

    MySQL.ready(function()
        Wait(1000)
        print('=== AUTOMATIC CK TRIGGERED ON RESOURCE START ===')
        checkInactivePlayers()
    end)
end)

Citizen.CreateThread(function()
    local hoursInMilliseconds = Config.CheckAutomatically * 60 * 60 * 1000
    while true do
        Citizen.Wait(hoursInMilliseconds)
        print('=== AUTOMATIC CK TRIGGERED ===')
        checkInactivePlayers()
    end
end)
