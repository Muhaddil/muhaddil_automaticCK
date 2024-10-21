Config = {}

Config.AutomaticCKTrigger = 90 -- Player has to not join the server for this ammount of days for the automatic CK to work on its player
Config.CheckAutomatically = 3  -- Checks automatically every 3 hours if there is a player that needs a CK.

Config.DebugMode = false -- Enables the DebugMode (extra prints)
Config.AutoVersionChecker = true

Config.Tables = { -- Add tables here
    {
        table = 'addon_account_data',
        column = 'owner',
    },
    {
        table = 'owned_vehicles',
        column = 'owner',
    },
    {
        table = 'billing',
        column = 'identifier',
    },
    {
        table = 'addon_inventory_items',
        column = 'owner',
    },
    {
        table = 'user_licenses',
        column = 'owner',
    },
    {
        table = 'users',
        column = 'identifier',
    },
    {
        table = 'datastore_data',
        column = 'owner',
    },
}
