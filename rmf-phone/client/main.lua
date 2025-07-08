-- RMF Phone - Client Side
local RMFPhone = {}
local isPhoneOpen = false
local isPhoneDisabled = false
local phoneObject = nil
local currentApp = nil
local phoneAnimation = {
    dict = "cellphone@",
    name = "cellphone_text_read_base"
}
local currentCall = nil
local phoneData = {
    battery = 100,
    signal = 4,
    wifi = true,
    airplane = false,
    silent = false,
    pinCode = nil,
    wallpaper = 'default'
}

-- Initialize
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        -- Check if player has phone item
        if not isPhoneDisabled then
            -- Phone controls
            if IsControlJustPressed(0, Config.Keybinds.OpenPhone) then
                TogglePhone()
            end
            
            -- Call controls during active call
            if currentCall then
                if IsControlJustPressed(0, Config.Keybinds.AnswerCall) then
                    AnswerCall()
                elseif IsControlJustPressed(0, Config.Keybinds.HangupCall) then
                    EndCall()
                end
            end
        end
        
        -- Camera controls when camera app is open
        if isPhoneOpen and currentApp == 'camera' then
            HandleCameraControls()
        end
    end
end)

-- Battery drain
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000) -- Check every minute
        
        if Config.BatteryDrain then
            if isPhoneOpen then
                phoneData.battery = math.max(0, phoneData.battery - Config.BatteryDrainRate)
                
                if phoneData.battery <= 0 then
                    ClosePhone()
                    ShowNotification('Phone battery dead!')
                end
                
                UpdatePhoneBattery()
            end
        end
    end
end)

-- Phone Functions
function TogglePhone()
    if not HasPhoneItem() then
        ShowNotification('You don\'t have a phone!')
        return
    end
    
    if phoneData.battery <= 0 then
        ShowNotification('Phone battery is dead!')
        return
    end
    
    if isPhoneOpen then
        ClosePhone()
    else
        OpenPhone()
    end
end

function OpenPhone()
    if isPhoneDisabled then return end
    
    isPhoneOpen = true
    
    -- Start phone animation
    StartPhoneAnimation()
    
    -- Create phone prop
    CreatePhoneProp()
    
    -- Open NUI
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'show'
    })
    
    -- Send phone data to UI
    SendPhoneData()
    
    -- Disable controls
    DisablePhoneControls()
    
    TriggerEvent('rmf-phone:client:phoneOpened')
end

function ClosePhone()
    if not isPhoneOpen then return end
    
    isPhoneOpen = false
    
    -- Stop phone animation
    StopPhoneAnimation()
    
    -- Remove phone prop
    RemovePhoneProp()
    
    -- Close NUI
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'hide'
    })
    
    -- Enable controls
    EnablePhoneControls()
    
    TriggerEvent('rmf-phone:client:phoneClosed')
end

function StartPhoneAnimation()
    local ped = PlayerPedId()
    
    RequestAnimDict(phoneAnimation.dict)
    while not HasAnimDictLoaded(phoneAnimation.dict) do
        Citizen.Wait(0)
    end
    
    TaskPlayAnim(ped, phoneAnimation.dict, phoneAnimation.name, 8.0, -8.0, -1, 50, 0, false, false, false)
end

function StopPhoneAnimation()
    local ped = PlayerPedId()
    StopAnimTask(ped, phoneAnimation.dict, phoneAnimation.name, 1.0)
end

function CreatePhoneProp()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    
    RequestModel(GetHashKey(Config.PhoneModels[Config.PhoneItem].model))
    while not HasModelLoaded(GetHashKey(Config.PhoneModels[Config.PhoneItem].model)) do
        Citizen.Wait(0)
    end
    
    phoneObject = CreateObject(GetHashKey(Config.PhoneModels[Config.PhoneItem].model), coords.x, coords.y, coords.z, true, true, false)
    AttachEntityToEntity(phoneObject, ped, GetPedBoneIndex(ped, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
end

function RemovePhoneProp()
    if phoneObject then
        DeleteEntity(phoneObject)
        phoneObject = nil
    end
end

function DisablePhoneControls()
    Citizen.CreateThread(function()
        while isPhoneOpen do
            Citizen.Wait(0)
            
            DisableControlAction(0, 1, true) -- Camera
            DisableControlAction(0, 2, true) -- Camera
            DisableControlAction(0, 24, true) -- Attack
            DisableControlAction(0, 25, true) -- Aim
            DisableControlAction(0, 47, true) -- Weapon wheel
            DisableControlAction(0, 58, true) -- Weapon wheel
            DisableControlAction(0, 263, true) -- Melee Attack 1
            DisableControlAction(0, 264, true) -- Melee Attack 2
            DisableControlAction(0, 257, true) -- Attack 2
            DisableControlAction(0, 140, true) -- Melee Attack Light
            DisableControlAction(0, 141, true) -- Melee Attack Heavy
            DisableControlAction(0, 142, true) -- Melee Attack Alternate
            DisableControlAction(0, 143, true) -- Melee Block
            DisableControlAction(0, 75, true) -- Exit Vehicle
            DisableControlAction(27, 75, true) -- Exit Vehicle
        end
    end)
end

function EnablePhoneControls()
    -- Controls are automatically re-enabled when the loop ends
end

-- Inventory Integration
function HasPhoneItem()
    -- This will depend on your inventory system
    -- Example implementations for different frameworks:
    
    if Config.Framework == 'rmf' then
        -- RMF Core implementation
        return exports['rmf-core']:hasItem(Config.PhoneItem)
    elseif Config.Framework == 'qb' then
        -- QB Core implementation
        local Player = QBCore.Functions.GetPlayerData()
        local items = Player.items
        for k, v in pairs(items) do
            if v.name == Config.PhoneItem then
                return true
            end
        end
        return false
    elseif Config.Framework == 'esx' then
        -- ESX implementation
        ESX.TriggerServerCallback('rmf-phone:server:hasPhone', function(hasPhone)
            return hasPhone
        end)
    end
    
    return true -- Default to true for testing
end

-- Camera App Functions
function HandleCameraControls()
    if IsControlJustPressed(0, Config.Keybinds.TakePhoto) then
        TakePhoto()
    end
    
    if IsControlJustPressed(0, 200) then -- Arrow up
        FlipCamera()
    end
end

function TakePhoto()
    ClosePhone()
    
    Citizen.Wait(200)
    
    -- Take screenshot
    exports['screenshot-basic']:requestScreenshotUpload(Config.Photos.Webhook, 'files[]', function(data)
        local resp = json.decode(data)
        if resp and resp.attachments and resp.attachments[1] and resp.attachments[1].url then
            TriggerServerEvent('rmf-phone:server:addPhoto', resp.attachments[1].url)
        end
    end)
    
    OpenPhone()
end

function FlipCamera()
    -- Camera flip logic would go here
    ShowNotification('Camera flipped')
end

-- Call Functions
function ReceiveCall(callData)
    currentCall = callData
    
    if isPhoneOpen then
        SendNUIMessage({
            action = 'receiveCall',
            callData = callData
        })
    else
        -- Show incoming call notification/screen
        ShowIncomingCallScreen(callData)
    end
    
    PlayRingtone()
end

function AnswerCall()
    if currentCall then
        StopRingtone()
        TriggerServerEvent('rmf-phone:server:answerCall', currentCall.id)
        
        SendNUIMessage({
            action = 'answerCall'
        })
    end
end

function EndCall()
    if currentCall then
        StopRingtone()
        TriggerServerEvent('rmf-phone:server:endCall', currentCall.id)
        currentCall = nil
        
        SendNUIMessage({
            action = 'endCall'
        })
    end
end

function ShowIncomingCallScreen(callData)
    -- Create a temporary phone screen for incoming calls
    OpenPhone()
    SendNUIMessage({
        action = 'receiveCall',
        callData = callData
    })
end

function PlayRingtone()
    -- Play ringtone sound
    TriggerEvent('InteractSound_CL:PlayOnOne', 'phone_ringtone', 0.5)
end

function StopRingtone()
    -- Stop ringtone sound
    TriggerEvent('InteractSound_CL:StopOnOne', 'phone_ringtone')
end

-- Notification Functions
function ShowNotification(message, type)
    type = type or 'info'
    
    -- Send to phone UI if open
    if isPhoneOpen then
        SendNUIMessage({
            action = 'addNotification',
            notification = {
                title = 'Phone',
                message = message,
                type = type,
                timestamp = GetGameTimer()
            }
        })
    end
    
    -- Also show game notification
    SetNotificationTextEntry('STRING')
    AddTextComponentString(message)
    DrawNotification(false, false)
end

function AddPhoneNotification(data)
    SendNUIMessage({
        action = 'addNotification',
        notification = data
    })
end

-- Data Functions
function SendPhoneData()
    SendNUIMessage({
        action = 'updatePhoneData',
        phoneData = phoneData
    })
end

function UpdatePhoneBattery()
    SendNUIMessage({
        action = 'updateBattery',
        battery = phoneData.battery
    })
end

-- NUI Callbacks
RegisterNUICallback('phone:close', function(data, cb)
    ClosePhone()
    cb('ok')
end)

RegisterNUICallback('phone:requestData', function(data, cb)
    SendPhoneData()
    cb('ok')
end)

RegisterNUICallback('phone:openApp', function(data, cb)
    currentApp = data.app
    TriggerEvent('rmf-phone:client:appOpened', data.app)
    cb('ok')
end)

RegisterNUICallback('phone:loadApp', function(data, cb)
    TriggerServerEvent('rmf-phone:server:loadApp', data.app)
    cb('ok')
end)

RegisterNUICallback('phone:lock', function(data, cb)
    ClosePhone()
    cb('ok')
end)

RegisterNUICallback('phone:resetPin', function(data, cb)
    TriggerServerEvent('rmf-phone:server:resetPin')
    cb('ok')
end)

RegisterNUICallback('phone:answerCall', function(data, cb)
    AnswerCall()
    cb('ok')
end)

RegisterNUICallback('phone:declineCall', function(data, cb)
    EndCall()
    cb('ok')
end)

RegisterNUICallback('phone:endCall', function(data, cb)
    EndCall()
    cb('ok')
end)

RegisterNUICallback('phone:clearNotifications', function(data, cb)
    TriggerServerEvent('rmf-phone:server:clearNotifications')
    cb('ok')
end)

RegisterNUICallback('phone:toggleSetting', function(data, cb)
    phoneData[data.setting] = data.value
    TriggerServerEvent('rmf-phone:server:updateSetting', data.setting, data.value)
    cb('ok')
end)

-- Server Events
RegisterNetEvent('rmf-phone:client:receiveCall')
AddEventHandler('rmf-phone:client:receiveCall', function(callData)
    ReceiveCall(callData)
end)

RegisterNetEvent('rmf-phone:client:endCall')
AddEventHandler('rmf-phone:client:endCall', function()
    EndCall()
end)

RegisterNetEvent('rmf-phone:client:addNotification')
AddEventHandler('rmf-phone:client:addNotification', function(notification)
    AddPhoneNotification(notification)
end)

RegisterNetEvent('rmf-phone:client:updatePhoneData')
AddEventHandler('rmf-phone:client:updatePhoneData', function(data)
    phoneData = data
    SendPhoneData()
end)

RegisterNetEvent('rmf-phone:client:sendAppContent')
AddEventHandler('rmf-phone:client:sendAppContent', function(appName, content)
    SendNUIMessage({
        action = 'loadAppContent',
        appName = appName,
        content = content
    })
end)

RegisterNetEvent('rmf-phone:client:updateBattery')
AddEventHandler('rmf-phone:client:updateBattery', function(battery)
    phoneData.battery = battery
    UpdatePhoneBattery()
end)

RegisterNetEvent('rmf-phone:client:disablePhone')
AddEventHandler('rmf-phone:client:disablePhone', function(disabled)
    isPhoneDisabled = disabled
    if disabled and isPhoneOpen then
        ClosePhone()
    end
end)

-- Exports
exports('IsPhoneOpen', function()
    return isPhoneOpen
end)

exports('OpenPhone', function()
    OpenPhone()
end)

exports('ClosePhone', function()
    ClosePhone()
end)

exports('AddNotification', function(notification)
    AddPhoneNotification(notification)
end)

exports('HasPhoneItem', function()
    return HasPhoneItem()
end)

exports('GetPhoneData', function()
    return phoneData
end)

-- Commands for testing/admin
RegisterCommand('phone', function()
    TogglePhone()
end)

RegisterCommand('phonebattery', function(source, args)
    if args[1] then
        local battery = tonumber(args[1])
        if battery and battery >= 0 and battery <= 100 then
            phoneData.battery = battery
            UpdatePhoneBattery()
        end
    end
end)

RegisterCommand('testcall', function(source, args)
    if args[1] then
        ReceiveCall({
            id = 1,
            name = 'Test Caller',
            number = args[1],
            avatar = nil
        })
    end
end)

RegisterCommand('testnotif', function(source, args)
    local message = table.concat(args, ' ') or 'Test notification'
    AddPhoneNotification({
        title = 'Test',
        message = message,
        icon = 'notifications',
        timestamp = GetGameTimer()
    })
end)

-- Cleanup
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if isPhoneOpen then
            ClosePhone()
        end
        
        if phoneObject then
            DeleteEntity(phoneObject)
        end
    end
end)