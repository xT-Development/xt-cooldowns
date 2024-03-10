local svConfig = require 'configs.server'

local db = {}

function db.updateCooldownOnDB(cooldownInfo)
    local cooldownExist = MySQL.query.await('SELECT * FROM cooldowns WHERE name = ?', { cooldownInfo.name })
    if not cooldownExist and not cooldownExist[1] then return end

    local UPDATE_COOLDOWN = 'UPDATE cooldowns SET length = ? WHERE name = ?'
    return MySQL.update.await(UPDATE_COOLDOWN, { cooldownInfo.length, cooldownInfo.name })
end

return db