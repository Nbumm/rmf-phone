-- RMF Phone - Server Side
local RMFPhone = {}
local activeCalls = {}
local phoneData = {}

-- Initialize
Citizen.CreateThread(function()
    -- Initialize database
    InitializeDatabase()
    
    -- Load phone data for all players
    LoadAllPhoneData()
    
    -- Start battery drain timer
    StartBatteryDrain()
    
    print('^2[RMF Phone] ^7Server initialized successfully')
end)

-- Database Functions
function InitializeDatabase()
    for _, table in ipairs(Config.DatabaseTables) do
        -- Tables are created via SQL file, just ensure they exist
        MySQL.ready(function()
            print('^3[RMF Phone] ^7Database connection established')
        end)
    end
end

function LoadAllPhoneData()
    local players = GetPlayers()
    for _, playerId in ipairs(players) do
        LoadPlayerPhoneData(playerId)
    end
end

function LoadPlayerPhoneData(playerId)
    local citizenid = GetPlayerIdentifier(playerId)
    
    MySQL.Async.fetchAll('SELECT * FROM rmf_phone_users WHERE citizenid = @citizenid', {
        ['@citizenid'] = citizenid
    }, function(result)
        if result[1] then
            phoneData[playerId] = result[1]
        else
            -- Create new phone data
            CreatePlayerPhoneData(playerId, citizenid)
        end
    end)
end

function CreatePlayerPhoneData(playerId, citizenid)
    local phoneNumber = GeneratePhoneNumber()
    
    MySQL.Async.execute('INSERT INTO rmf_phone_users (citizenid, phone_number) VALUES (@citizenid, @phone_number)', {
        ['@citizenid'] = citizenid,
        ['@phone_number'] = phoneNumber
    }, function(affectedRows)
        if affectedRows > 0 then
            phoneData[playerId] = {
                citizenid = citizenid,
                phone_number = phoneNumber,
                pin_code = nil,
                battery = 100,
                wallpaper = 'default',
                ringtone = 'default',
                notification_sound = 'default',
                is_airplane_mode = 0,
                is_silent_mode = 0
            }
            
            TriggerClientEvent('rmf-phone:client:updatePhoneData', playerId, phoneData[playerId])
        end
    end)
end

function SavePlayerPhoneData(playerId)
    if phoneData[playerId] then
        local data = phoneData[playerId]
        MySQL.Async.execute([[
            UPDATE rmf_phone_users SET 
                pin_code = @pin_code,
                battery = @battery,
                wallpaper = @wallpaper,
                ringtone = @ringtone,
                notification_sound = @notification_sound,
                is_airplane_mode = @is_airplane_mode,
                is_silent_mode = @is_silent_mode
            WHERE citizenid = @citizenid
        ]], {
            ['@citizenid'] = data.citizenid,
            ['@pin_code'] = data.pin_code,
            ['@battery'] = data.battery,
            ['@wallpaper'] = data.wallpaper,
            ['@ringtone'] = data.ringtone,
            ['@notification_sound'] = data.notification_sound,
            ['@is_airplane_mode'] = data.is_airplane_mode,
            ['@is_silent_mode'] = data.is_silent_mode
        })
    end
end

-- Utility Functions
function GeneratePhoneNumber()
    local number = ""
    for i = 1, 10 do
        if i == 1 then
            number = number .. math.random(2, 9) -- First digit can't be 0 or 1
        else
            number = number .. math.random(0, 9)
        end
    end
    
    -- Check if number already exists
    local result = MySQL.Sync.fetchAll('SELECT phone_number FROM rmf_phone_users WHERE phone_number = @number', {
        ['@number'] = number
    })
    
    if #result > 0 then
        return GeneratePhoneNumber() -- Recursive call if number exists
    end
    
    return number
end

function GetPlayerByPhoneNumber(phoneNumber)
    for playerId, data in pairs(phoneData) do
        if data.phone_number == phoneNumber then
            return playerId
        end
    end
    return nil
end

function GetPlayerIdentifier(playerId)
    -- This will depend on your framework
    if Config.Framework == 'rmf' then
        return exports['rmf-core']:GetPlayerIdentifier(playerId)
    elseif Config.Framework == 'qb' then
        local Player = QBCore.Functions.GetPlayer(playerId)
        return Player.PlayerData.citizenid
    elseif Config.Framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(playerId)
        return xPlayer.identifier
    end
    
    -- Default fallback
    local identifiers = GetPlayerIdentifiers(playerId)
    for _, id in pairs(identifiers) do
        if string.find(id, "license:") then
            return id
        end
    end
    return nil
end

-- Call System
function StartCall(caller, receiver)
    local callId = #activeCalls + 1
    local callData = {
        id = callId,
        caller = caller,
        receiver = receiver,
        startTime = os.time(),
        status = 'ringing'
    }
    
    activeCalls[callId] = callData
    
    -- Get caller info
    local callerData = phoneData[caller]
    local callerInfo = {
        id = callId,
        name = GetPlayerName(caller),
        number = callerData.phone_number,
        avatar = nil
    }
    
    -- Send call to receiver
    TriggerClientEvent('rmf-phone:client:receiveCall', receiver, callerInfo)
    
    -- Add call to history
    AddCallToHistory(caller, callerData.phone_number, phoneData[receiver].phone_number, 'outgoing')
    AddCallToHistory(receiver, callerData.phone_number, phoneData[receiver].phone_number, 'incoming')
    
    return callId
end

function AnswerCall(callId, playerId)
    local call = activeCalls[callId]
    if call and call.receiver == playerId then
        call.status = 'active'
        call.answerTime = os.time()
        
        TriggerClientEvent('rmf-phone:client:callAnswered', call.caller)
        TriggerClientEvent('rmf-phone:client:callAnswered', call.receiver)
    end
end

function EndCall(callId)
    local call = activeCalls[callId]
    if call then
        local duration = 0
        if call.answerTime then
            duration = os.time() - call.answerTime
        end
        
        -- Update call history with duration
        UpdateCallHistory(call.caller, call.receiver, duration)
        
        -- Notify both players
        TriggerClientEvent('rmf-phone:client:endCall', call.caller)
        TriggerClientEvent('rmf-phone:client:endCall', call.receiver)
        
        activeCalls[callId] = nil
    end
end

function AddCallToHistory(playerId, caller, receiver, callType)
    local citizenid = GetPlayerIdentifier(playerId)
    
    MySQL.Async.execute('INSERT INTO rmf_phone_calls (citizenid, caller, receiver, call_type) VALUES (@citizenid, @caller, @receiver, @call_type)', {
        ['@citizenid'] = citizenid,
        ['@caller'] = caller,
        ['@receiver'] = receiver,
        ['@call_type'] = callType
    })
end

function UpdateCallHistory(caller, receiver, duration)
    local callerCitizenId = GetPlayerIdentifier(caller)
    local receiverCitizenId = GetPlayerIdentifier(receiver)
    
    -- Update both caller and receiver history
    MySQL.Async.execute('UPDATE rmf_phone_calls SET duration = @duration WHERE citizenid = @citizenid AND caller = @caller AND receiver = @receiver ORDER BY created_at DESC LIMIT 1', {
        ['@duration'] = duration,
        ['@citizenid'] = callerCitizenId,
        ['@caller'] = phoneData[caller].phone_number,
        ['@receiver'] = phoneData[receiver].phone_number
    })
    
    MySQL.Async.execute('UPDATE rmf_phone_calls SET duration = @duration WHERE citizenid = @citizenid AND caller = @caller AND receiver = @receiver ORDER BY created_at DESC LIMIT 1', {
        ['@duration'] = duration,
        ['@citizenid'] = receiverCitizenId,
        ['@caller'] = phoneData[caller].phone_number,
        ['@receiver'] = phoneData[receiver].phone_number
    })
end

-- Message System
function SendMessage(sender, receiver, message, attachments)
    local senderCitizenId = GetPlayerIdentifier(sender)
    local receiverPlayer = GetPlayerByPhoneNumber(receiver)
    
    if receiverPlayer then
        local receiverCitizenId = GetPlayerIdentifier(receiverPlayer)
        
        -- Save message to database
        MySQL.Async.execute('INSERT INTO rmf_phone_messages (citizenid, sender, receiver, message, attachments) VALUES (@citizenid, @sender, @receiver, @message, @attachments)', {
            ['@citizenid'] = receiverCitizenId,
            ['@sender'] = phoneData[sender].phone_number,
            ['@receiver'] = receiver,
            ['@message'] = message,
            ['@attachments'] = json.encode(attachments or {})
        })
        
        -- Also save for sender
        MySQL.Async.execute('INSERT INTO rmf_phone_messages (citizenid, sender, receiver, message, attachments) VALUES (@citizenid, @sender, @receiver, @message, @attachments)', {
            ['@citizenid'] = senderCitizenId,
            ['@sender'] = phoneData[sender].phone_number,
            ['@receiver'] = receiver,
            ['@message'] = message,
            ['@attachments'] = json.encode(attachments or {})
        })
        
        -- Send notification to receiver
        local notification = {
            title = 'New Message',
            message = message,
            icon = 'message',
            timestamp = os.time() * 1000
        }
        
        TriggerClientEvent('rmf-phone:client:addNotification', receiverPlayer, notification)
        
        return true
    end
    
    return false
end

-- Contact System
function AddContact(playerId, name, number, photo)
    local citizenid = GetPlayerIdentifier(playerId)
    
    MySQL.Async.execute('INSERT INTO rmf_phone_contacts (citizenid, name, number, photo) VALUES (@citizenid, @name, @number, @photo)', {
        ['@citizenid'] = citizenid,
        ['@name'] = name,
        ['@number'] = number,
        ['@photo'] = photo
    })
end

function GetContacts(playerId)
    local citizenid = GetPlayerIdentifier(playerId)
    
    MySQL.Async.fetchAll('SELECT * FROM rmf_phone_contacts WHERE citizenid = @citizenid ORDER BY name ASC', {
        ['@citizenid'] = citizenid
    }, function(result)
        TriggerClientEvent('rmf-phone:client:receiveContacts', playerId, result)
    end)
end

-- Photo System
function AddPhoto(playerId, url, caption, location)
    local citizenid = GetPlayerIdentifier(playerId)
    
    MySQL.Async.execute('INSERT INTO rmf_phone_photos (citizenid, url, caption, location) VALUES (@citizenid, @url, @caption, @location)', {
        ['@citizenid'] = citizenid,
        ['@url'] = url,
        ['@caption'] = caption or '',
        ['@location'] = location or ''
    })
end

-- Battery System
function StartBatteryDrain()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(60000) -- Every minute
            
            for playerId, data in pairs(phoneData) do
                if Config.BatteryDrain then
                    -- Drain battery based on usage and settings
                    local drainRate = Config.BatteryDrainRate
                    
                    data.battery = math.max(0, data.battery - drainRate)
                    
                    TriggerClientEvent('rmf-phone:client:updateBattery', playerId, data.battery)
                    
                    -- Save updated battery
                    SavePlayerPhoneData(playerId)
                end
            end
        end
    end)
end

-- App System
function LoadAppContent(playerId, appName)
    local content = ""
    
    -- Generate content based on app
    if appName == 'dialer' then
        content = GenerateDialerContent(playerId)
    elseif appName == 'messages' then
        content = GenerateMessagesContent(playerId)
    elseif appName == 'contacts' then
        content = GenerateContactsContent(playerId)
    elseif appName == 'camera' then
        content = GenerateCameraContent(playerId)
    elseif appName == 'gallery' then
        content = GenerateGalleryContent(playerId)
    elseif appName == 'settings' then
        content = GenerateSettingsContent(playerId)
    elseif appName == 'calculator' then
        content = GenerateCalculatorContent(playerId)
    elseif appName == 'notepad' then
        content = GenerateNotepadContent(playerId)
    elseif appName == 'banking' then
        content = GenerateBankingContent(playerId)
    elseif appName == 'birdy' then
        content = GenerateBirdyContent(playerId)
    elseif appName == 'instapic' then
        content = GenerateInstapicContent(playerId)
    elseif appName == 'yellowpages' then
        content = GenerateYellowPagesContent(playerId)
    elseif appName == 'garage' then
        content = GenerateGarageContent(playerId)
    elseif appName == 'crypto' then
        content = GenerateCryptoContent(playerId)
    elseif appName == 'racing' then
        content = GenerateRacingContent(playerId)
    elseif appName == 'houses' then
        content = GenerateHousesContent(playerId)
    elseif appName == 'meos' then
        content = GenerateMEOSContent(playerId)
    elseif appName == 'employment' then
        content = GenerateEmploymentContent(playerId)
    elseif appName == 'invoices' then
        content = GenerateInvoicesContent(playerId)
    elseif appName == 'wenmo' then
        content = GenerateWenmoContent(playerId)
    elseif appName == 'news' then
        content = GenerateNewsContent(playerId)
    elseif appName == 'casino' then
        content = GenerateCasinoContent(playerId)
    else
        content = '<div class="app-placeholder">App content not implemented yet</div>'
    end
    
    TriggerClientEvent('rmf-phone:client:sendAppContent', playerId, appName, content)
end

-- App Content Generators (Basic implementations)
function GenerateDialerContent(playerId)
    return [[
        <div class="dialer-app">
            <div class="dialer-display">
                <input type="text" id="dialer-number" placeholder="Enter number..." readonly>
            </div>
            <div class="dialer-keypad">
                <div class="dialer-row">
                    <button class="dialer-key" data-number="1">1</button>
                    <button class="dialer-key" data-number="2">2<span>ABC</span></button>
                    <button class="dialer-key" data-number="3">3<span>DEF</span></button>
                </div>
                <div class="dialer-row">
                    <button class="dialer-key" data-number="4">4<span>GHI</span></button>
                    <button class="dialer-key" data-number="5">5<span>JKL</span></button>
                    <button class="dialer-key" data-number="6">6<span>MNO</span></button>
                </div>
                <div class="dialer-row">
                    <button class="dialer-key" data-number="7">7<span>PQRS</span></button>
                    <button class="dialer-key" data-number="8">8<span>TUV</span></button>
                    <button class="dialer-key" data-number="9">9<span>WXYZ</span></button>
                </div>
                <div class="dialer-row">
                    <button class="dialer-key" data-number="*">*</button>
                    <button class="dialer-key" data-number="0">0<span>+</span></button>
                    <button class="dialer-key" data-number="#">#</button>
                </div>
            </div>
            <div class="dialer-actions">
                <button class="dialer-call-button">
                    <span class="material-icons">call</span>
                </button>
            </div>
        </div>
    ]]
end

function GenerateMessagesContent(playerId)
    return [[
        <div class="messages-app">
            <div class="messages-list">
                <div class="message-thread" data-number="555-0123">
                    <div class="thread-avatar">
                        <span class="material-icons">person</span>
                    </div>
                    <div class="thread-info">
                        <div class="thread-name">John Doe</div>
                        <div class="thread-preview">Hey, how are you?</div>
                    </div>
                    <div class="thread-time">2:30 PM</div>
                </div>
            </div>
            <button class="compose-button">
                <span class="material-icons">add</span>
            </button>
        </div>
    ]]
end

function GenerateContactsContent(playerId)
    return [[
        <div class="contacts-app">
            <div class="contacts-search">
                <input type="text" placeholder="Search contacts...">
            </div>
            <div class="contacts-list">
                <div class="contact-item">
                    <div class="contact-avatar">
                        <span class="material-icons">person</span>
                    </div>
                    <div class="contact-info">
                        <div class="contact-name">John Doe</div>
                        <div class="contact-number">555-0123</div>
                    </div>
                </div>
            </div>
            <button class="add-contact-button">
                <span class="material-icons">person_add</span>
            </button>
        </div>
    ]]
end

function GenerateCameraContent(playerId)
    return [[
        <div class="camera-app">
            <div class="camera-viewfinder">
                <div class="camera-overlay">
                    <div class="camera-controls-top">
                        <button class="camera-flash">
                            <span class="material-icons">flash_off</span>
                        </button>
                        <button class="camera-flip">
                            <span class="material-icons">flip_camera_android</span>
                        </button>
                    </div>
                    <div class="camera-controls-bottom">
                        <button class="camera-gallery">
                            <span class="material-icons">photo_library</span>
                        </button>
                        <button class="camera-capture">
                            <span class="material-icons">camera</span>
                        </button>
                        <button class="camera-video">
                            <span class="material-icons">videocam</span>
                        </button>
                    </div>
                </div>
            </div>
        </div>
    ]]
end

-- Add more content generators for other apps...

-- Event Handlers
RegisterNetEvent('rmf-phone:server:loadApp')
AddEventHandler('rmf-phone:server:loadApp', function(appName)
    local src = source
    LoadAppContent(src, appName)
end)

RegisterNetEvent('rmf-phone:server:makeCall')
AddEventHandler('rmf-phone:server:makeCall', function(phoneNumber)
    local src = source
    local receiverPlayer = GetPlayerByPhoneNumber(phoneNumber)
    
    if receiverPlayer then
        StartCall(src, receiverPlayer)
    end
end)

RegisterNetEvent('rmf-phone:server:answerCall')
AddEventHandler('rmf-phone:server:answerCall', function(callId)
    local src = source
    AnswerCall(callId, src)
end)

RegisterNetEvent('rmf-phone:server:endCall')
AddEventHandler('rmf-phone:server:endCall', function(callId)
    EndCall(callId)
end)

RegisterNetEvent('rmf-phone:server:sendMessage')
AddEventHandler('rmf-phone:server:sendMessage', function(receiver, message, attachments)
    local src = source
    SendMessage(src, receiver, message, attachments)
end)

RegisterNetEvent('rmf-phone:server:addContact')
AddEventHandler('rmf-phone:server:addContact', function(name, number, photo)
    local src = source
    AddContact(src, name, number, photo)
end)

RegisterNetEvent('rmf-phone:server:addPhoto')
AddEventHandler('rmf-phone:server:addPhoto', function(url, caption, location)
    local src = source
    AddPhoto(src, url, caption, location)
end)

RegisterNetEvent('rmf-phone:server:updateSetting')
AddEventHandler('rmf-phone:server:updateSetting', function(setting, value)
    local src = source
    if phoneData[src] then
        phoneData[src][setting] = value
        SavePlayerPhoneData(src)
    end
end)

RegisterNetEvent('rmf-phone:server:resetPin')
AddEventHandler('rmf-phone:server:resetPin', function()
    local src = source
    if phoneData[src] then
        phoneData[src].pin_code = nil
        SavePlayerPhoneData(src)
        TriggerClientEvent('rmf-phone:client:updatePhoneData', src, phoneData[src])
    end
end)

-- Player Events
AddEventHandler('playerConnecting', function()
    local src = source
    Citizen.Wait(1000) -- Wait for player to fully connect
    LoadPlayerPhoneData(src)
end)

AddEventHandler('playerDropped', function()
    local src = source
    if phoneData[src] then
        SavePlayerPhoneData(src)
        phoneData[src] = nil
    end
end)

-- Exports
exports('GetPlayerPhoneNumber', function(playerId)
    if phoneData[playerId] then
        return phoneData[playerId].phone_number
    end
    return nil
end)

exports('GetPlayerByPhoneNumber', function(phoneNumber)
    return GetPlayerByPhoneNumber(phoneNumber)
end)

exports('SendNotification', function(playerId, notification)
    TriggerClientEvent('rmf-phone:client:addNotification', playerId, notification)
end)

exports('SendMessage', function(sender, receiver, message, attachments)
    return SendMessage(sender, receiver, message, attachments)
end)

-- Commands
RegisterCommand('givephone', function(source, args, rawCommand)
    local src = source
    if src == 0 or IsPlayerAceAllowed(src, 'rmf-phone.admin') then
        local targetId = tonumber(args[1])
        if targetId and GetPlayerPing(targetId) > 0 then
            LoadPlayerPhoneData(targetId)
            print('^2[RMF Phone] ^7Phone given to player ' .. targetId)
        end
    end
end, true)

RegisterCommand('setphonenumber', function(source, args, rawCommand)
    local src = source
    if src == 0 or IsPlayerAceAllowed(src, 'rmf-phone.admin') then
        local targetId = tonumber(args[1])
        local newNumber = args[2]
        
        if targetId and newNumber and GetPlayerPing(targetId) > 0 then
            if phoneData[targetId] then
                phoneData[targetId].phone_number = newNumber
                SavePlayerPhoneData(targetId)
                TriggerClientEvent('rmf-phone:client:updatePhoneData', targetId, phoneData[targetId])
                print('^2[RMF Phone] ^7Phone number set to ' .. newNumber .. ' for player ' .. targetId)
            end
        end
    end
end, true)