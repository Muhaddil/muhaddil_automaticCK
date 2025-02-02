Config = {}

Config.FrameWork = 'esx' -- esx or qb

Config.AutomaticCKTrigger = 90 -- Player has to not join the server for this ammount of days for the automatic CK to work on its player
Config.CheckAutomatically = 120  -- Checks automatically every X minutes if there is a player that needs a CK.

Config.DebugMode = false -- Enables the DebugMode (extra prints)
Config.AutoVersionChecker = true -- Checks automatically for a new version of the script

Config.Tables = {
    { table = 'addon_account_data', column = 'owner' },
    { table = 'owned_vehicles', column = 'owner' },
    { table = 'billing', column = 'identifier' },
    { table = 'addon_inventory_items', column = 'owner' },
    { table = 'user_licenses', column = 'owner' },
    { table = 'users', column = 'identifier' },
    { table = 'datastore_data', column = 'owner' },
    { table = 'player_outfits', column = 'citizenid' },
}