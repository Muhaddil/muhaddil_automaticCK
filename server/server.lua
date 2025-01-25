if Config.FrameWork == "esx" then
    ESX = exports['es_extended']:getSharedObject()
elseif Config.FrameWork == "qb" then
    QBCore = exports['qb-core']:GetCoreObject()
end

function DebugPrint(...)
    if Config.DebugMode then
        print(...)
    end
end

if Config.FrameWork == "esx" then
    AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
        UpdateLastLogin(xPlayer.getIdentifier())
    end)
elseif Config.FrameWork == "qb" then
    RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
        local player = QBCore.Functions.GetPlayerData()
        UpdateLastLogin(player.citizenid)
    end)
end

function UpdateLastLogin(identifier)
    local currentDate = os.date("%Y-%m-%d %H:%M:%S")
    MySQL.Async.execute('UPDATE users SET last_login = @last_login WHERE identifier = @identifier', {
        ['@last_login'] = currentDate,
        ['@identifier'] = identifier
    }, function(rowsChanged)
        if rowsChanged > 0 then
            DebugPrint('Last login updated for player: ' .. identifier)
        end
    end)
end

-- AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
--     local currentDate = os.date("%Y-%m-%d %H:%M:%S") -- Fecha actual formateada
--     MySQL.Async.execute('UPDATE users SET last_login = @last_login WHERE identifier = @identifier', {
--         ['@last_login'] = currentDate,
--         ['@identifier'] = xPlayer.getIdentifier()
--     }, function(rowsChanged)
--         if rowsChanged > 0 then
--             DebugPrint('Last login updated for player: ' .. xPlayer.getIdentifier())
--         end
--     end)
-- end)

function deleteTables(table, column, identifier)
    local sql = string.format('DELETE FROM `%s` WHERE `%s`=@identifier', table, column)
    MySQL.Async.execute(sql, {
        ['@identifier'] = identifier,
    }, function(rowsChanged)
        if rowsChanged > 0 then
            DebugPrint('Successfully deleted data for identifier: ' .. identifier)
        end
    end)
end

function doCharacterKill(identifier)
    for _, data in ipairs(Config.Tables) do
        deleteTables(data.table, data.column, identifier)
    end
end

function checkInactivePlayers()
    local inactivityDateTime = GetInactivityDateTime()
    print("Checking players inactive since: " .. inactivityDateTime)

    local inactiveUsers = GetInactiveUsers(inactivityDateTime)
    print("• Found " .. #inactiveUsers .. " inactive users")

    for _, user in ipairs(inactiveUsers) do
        print("  + Performing CK for player: " .. user.identifier)
        doCharacterKill(user.identifier)
    end
end

function GetInactiveUsers(inactivityDateTime)
    local users = MySQL.query.await(
        'SELECT `identifier`, `last_login` FROM `users` WHERE `last_login` <= ?',
        { inactivityDateTime }
    )

    for _, user in ipairs(users) do
        local lastLoginDate = os.date("%Y-%m-%d %H:%M:%S", math.floor(user.last_login / 1000))
        DebugPrint(string.format("Inactive user found: %s, last login: %s", user.identifier, lastLoginDate))
    end

    return users
end

function GetInactivityDateTime()
    local currentTimestamp = os.time()

    local inactivityTimestamp = currentTimestamp - (Config.AutomaticCKTrigger * 24 * 60 * 60)

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

local function getCronExpression(intervalInMinutes)
    if intervalInMinutes < 1 then
        error('El intervalo debe ser un valor positivo.')
    elseif intervalInMinutes <= 59 then
        return string.format("*/%d * * * *", intervalInMinutes)
    else
        local hours = math.floor(intervalInMinutes / 60)
        local minutes = intervalInMinutes % 60
        
        if minutes == 0 then
            return string.format("0 */%d * * *", hours)
        else
            return string.format("%d */%d * * *", minutes, hours)
        end
    end
end

local cronExpression = getCronExpression(Config.CheckAutomatically)
DebugPrint('Cron expression: ' .. cronExpression)
lib.cron.new(cronExpression, function()
    print('=== AUTOMATIC CK TRIGGERED ===')
    checkInactivePlayers()
end)