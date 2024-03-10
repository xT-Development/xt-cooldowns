local svConfig =    require 'configs.server'
local db =          require 'server.db'

allCooldowns = {}
GlobalState.globalCooldown = false

MySQL.ready(function()
    allCooldowns = MySQL.query.await('SELECT * FROM `cooldowns`')
end)

-- Check if Cooldown is Active --
lib.callback.register('cooldowns:isActive', function(source, name)
    local cooldownID = getCooldownIDByName(name)

    if GlobalState.globalCooldown then
        return true
    end

    return (allCooldowns[cooldownID].active == 0) and false or (allCooldowns[cooldownID].active == 1) and true
end)

-- Enable Cooldown --
lib.callback.register('cooldowns:enable', function(source, name)
    local cooldownID = getCooldownIDByName(name)
    return allCooldowns[cooldownID].active == 1
end)

-- Toggle Cooldown (Returns Boolean) --
lib.callback.register('cooldowns:toggleCooldown', function(source, name)
    local callback = false
    local cooldownID = getCooldownIDByName(name)
    local lastState = allCooldowns[cooldownID].active
    local setState = (allCooldowns[cooldownID].active == 0) and 1 or (allCooldowns[cooldownID].active == 1) and 0

    allCooldowns[cooldownID].active = setState
    Wait(100)

    sendLog('Cooldown Toggled', ('**Player:** %s \n**Cooldown:** %s \n**Status:** %s'):format(GetPlayerName(source), name, setState))

    return (allCooldowns[cooldownID].active == setState)
end)

-- Toggle Global Cooldown --
lib.callback.register('xt-cooldowns:server:toggleGlobalCooldown', function(source)
    if not IsPlayerAceAllowed(source, svConfig.requiredPermission) then return end

    GlobalState.globalCooldown = not GlobalState.globalCooldown
    Wait(100)

    local txt = GlobalState.globalCooldown and 'Global Cooldown Enabled' or 'Global Cooldown Disabled'
    if GlobalState.globalCooldown then
        enableGlobalCooldown(false)
    else
        disableAllCooldowns(false)
    end

    sendLog(txt, ('**Player:** %s \n**Status:** %s'):format(GetPlayerName(source), GlobalState.globalCooldown))

    lib.notify(source, { title = txt })

    return
end)

-- Change Cooldown Length --
lib.callback.register('xt-cooldowns:server:changeCooldownLength', function(source, info)
    if not IsPlayerAceAllowed(source, svConfig.requiredPermission) then return end

    local callback = false
    local cooldownID = getCooldownIDByName(info.name)
    local oldLength = allCooldowns[cooldownID].length

    allCooldowns[cooldownID].length = info.length
    Wait(100)

    sendLog('Cooldown Length Changed', ('**Player:** %s \n**Cooldown:** %s \n**Old Length:** %s \n**New Length:** %s'):format(GetPlayerName(source), info.name, oldLength, info.length))

    return (allCooldowns[cooldownID].length == info.length)
end)

-- New Cooldown --
lib.callback.register('xt-cooldowns:server:createNewCooldown', function(source, INFO)
    if not IsPlayerAceAllowed(source, svConfig.requiredPermission) then return end
    local callback = false

    if addCooldown(INFO) then
        sendLog('Cooldown Created', ('**Player:** %s \n**Cooldown:** %s \n**Length:** %s'):format(GetPlayerName(source), INFO[1], INFO[2]))
        callback = true
    end

    return callback
end)

-- Return All Cooldowns --
lib.callback.register('xt-cooldowns:server:getAllCooldowns', function(source)
    if not IsPlayerAceAllowed(source, svConfig.requiredPermission) then return end

    return allCooldowns
end)

-- Get Cooldown Info --
lib.callback.register('xt-cooldowns:server:getCooldownInfo', function(source, name)
    if not IsPlayerAceAllowed(source, svConfig.requiredPermission) then return end

    local cooldownID = getCooldownIDByName(name)
    return allCooldowns[cooldownID]
end)

-- Command --
lib.addCommand(svConfig.Command, {
    help = 'View Active Criminal Cooldowns (Admin Only)',
    params = {},
    restricted = svConfig.requiredPermission
}, function(source, args, raw)
    TriggerClientEvent('xt-cooldowns:client:CooldownsList', source)
end)

-- Handlers --
AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    Wait(100)
    enableGlobalCooldown(true)
end)

AddEventHandler('onResourceStop', function(resource)
   if resource ~= GetCurrentResourceName() then return end
   disableAllCooldowns()
   updateCooldownsOnDB()
end)

AddEventHandler('txAdmin:events:scheduledRestart', function(eventData)
    if eventData.secondsRemaining <= (60000 * svConfig.GracePeriod) then
        enableGlobalCooldown(false)
    end
end)