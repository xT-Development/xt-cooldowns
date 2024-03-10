local db =          require 'server.db'
local svConfig =    require 'configs.server'

-- Server Debug --
function svDebug(txt)
    if svConfig.Debug then
        print(txt)
    end
end

-- Send Discord Log --
function sendLog(title, message)
    local Webhook = svConfig.Webhook
    local WebhookTitle = title
    local embed = { { ['title'] = WebhookTitle, ['description'] = message } }
    PerformHttpRequest(Webhook, function() end, 'POST', json.encode({ username = 'Logs', embeds = embed }), { ['Content-Type'] = 'application/json' })
end

-- Get Cooldown ID By Name --
function getCooldownIDByName(name)
    local callback = nil
    for x = 1, #allCooldowns do
        if allCooldowns[x].name == name then
            callback = x
            break
        end
    end
    return callback
end

-- Countdown Grace Period & Reset All --
function globalCooldownCountdown()
    GlobalState.globalCooldown = true

    svDebug('Grace Period Enabled | All Cooldowns Active')

    Wait(svConfig.GracePeriod * 60000)
    disableAllCooldowns(true)
end

-- Enables All Cooldowns for Grace Period / Global Cooldown --
function enableGlobalCooldown(startup)
    for x = 1, #allCooldowns do
        local cooldownID = getCooldownIDByName(allCooldowns[x].name)
        allCooldowns[cooldownID].active = 1
        svDebug(('Cooldown Enabled: %s'):format(allCooldowns[x].name))
    end

    if startup then
        globalCooldownCountdown()
    end
end

-- Disable All Cooldowns --
function disableAllCooldowns(startup)
    for x = 1, #allCooldowns do
        local cooldownID = getCooldownIDByName(allCooldowns[x].name)
        allCooldowns[cooldownID].active = 0
        svDebug(('Cooldown Disabled: %s'):format(allCooldowns[x].name))
    end
    GlobalState.globalCooldown = false

    if startup then
        svDebug('Grace Period Disabled | All Cooldowns Disabled')
    end
end

-- Adds New Cooldown --
function addCooldown(INFO)
    local callback = false
    local id = MySQL.insert.await('INSERT INTO `cooldowns` (name, length, active) VALUES (?, ?, ?)', { INFO[1], INFO[2], 0 })
    Wait(100)

    if id then
        callback = true

        allCooldowns[#allCooldowns+1] = {
            name = INFO[1],
            length = INFO[2],
            active = 0
        }
    end

    return callback
end

-- Update Database on Resource Stop --
function updateCooldownsOnDB()
    for cooldownID in pairs(allCooldowns) do
        db.updateCooldownOnDB(allCooldowns[cooldownID])
    end
end