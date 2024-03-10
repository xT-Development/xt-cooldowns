-- New Cooldown Input --
local function newCooldownInput()
    local input = lib.inputDialog('Create New Cooldown', {
        { type = 'input', label = 'Cooldown Name' },
        { type = 'number', label = 'Cooldown Length' },
    })
    if not input then return end
    local addedCooldown = lib.callback.await('xt-cooldowns:server:createNewCooldown', false, input)
    if addedCooldown then
        lib.notify({ title = 'Cooldown Created', description = ('%s: Length: %s'):format(input[1], input[2]), type = 'success' })
    end
end

local function cooldownControls(info)
    lib.registerContext({
        id = 'cooldowns_edit_menu',
        title = ('Edit Cooldown: %s'):format(info.name),
        menu = 'cooldowns_menu',
        options = {
            {
                title = 'Toggle Cooldown',
                icon = 'fas fa-toggle-off',
                onSelect = function()
                    local toggled = lib.callback.await('cooldowns:toggleCooldown', false, info.name)
                    if toggled then
                        local txt = (info.active == 0) and 'Enabled' or 'Disabled'
                        lib.notify({ title = ('%s %s'):format(txt, info.name), type = 'success' })
                    end
                end
            },
            {
                title = 'Edit Cooldown Length',
                icon = 'fas fa-stopwatch',
                onSelect = function()
                    local newLength = lib.inputDialog('Change Cooldown Length', {
                        { type = 'number', label = 'Number input', required = true },
                    })
                    if not newLength then return end
                    local info = { name = info.name, length = newLength[1] }
                    local changedLenght = lib.callback.await('xt-cooldowns:server:changeCooldownLength', false, info)
                    if changedLenght then
                        lib.notify({ title = 'Changed Cooldown Length', description = ('%s %s'):format(info.name, newLength[1]), type = 'success' })
                    end
                end
            }
        }
    })
    lib.showContext('cooldowns_edit_menu')
end

-- View All Cooldowns + Create New Cooldown --
RegisterNetEvent('xt-cooldowns:client:CooldownsList', function()
    local MainMenu = {}
    local getCooldowns = lib.callback.await('xt-cooldowns:server:getAllCooldowns', false)

    if not getCooldowns[1] then
        MainMenu[#MainMenu+1] = {
            title = 'NO COOLDOWNS FOUND',
            icon = 'fas fa-ban'
        }
    else
        for x = 1, #getCooldowns do
            local Info = getCooldowns[x]
            local active = 'False'
            if Info.active == 1 then active = 'True' end
            MainMenu[#MainMenu+1] = {
                title = Info.name,
                icon = (Info.active == 1) and 'fas fa-check' or 'fas fa-xmark',
                iconColor = Info.active == 1 and '#00FF00' or '#FF0000',
                description = ('Length: %s'):format(Info.length),
                onSelect = function()
                    cooldownControls(Info)
                end
            }
        end
    end

    MainMenu[#MainMenu+1] = {
        title = ('%s Global Cooldown'):format(GlobalState.globalCooldown and 'Disable' or 'Enable'),
        icon = 'fas fa-cross',
        iconColor = GlobalState.globalCooldown and '#00FF00' or '#FF0000',
        onSelect = function()
            lib.callback.await('xt-cooldowns:server:toggleGlobalCooldown', false)
        end
    }

    MainMenu[#MainMenu+1] = {
        title = 'Create New Cooldown',
        icon = 'plus',
        onSelect = function()
            newCooldownInput()
        end
    }

    lib.registerContext({
        id = 'cooldowns_menu',
        title = 'Cooldowns',
        options = MainMenu
    })
    lib.showContext('cooldowns_menu')
end)