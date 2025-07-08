# RMF Phone - Android Styled Phone for FiveM

A modern, feature-rich Android-styled phone system for FiveM servers, designed specifically for the RMF Core framework but adaptable to other frameworks.

## Features

### 📱 Core Phone Features
- **Android-style UI** with Material Design principles
- **Lock screen** with PIN protection
- **Status bar** with battery, signal, and time
- **App drawer** with customizable app grid
- **Dock** with quick access apps
- **Notification system** with lock screen notifications
- **Quick settings panel** with toggles

### 📞 Communication Apps
- **Dialer** - Make and receive calls with realistic UI
- **Messages** - Send and receive SMS/MMS with attachments
- **Contacts** - Manage your phone contacts with photos
- **Mail** - Email system for server communications

### 📸 Media Apps
- **Camera** - Take photos with in-game screenshot integration
- **Gallery** - View and manage your photos
- **Music** - Play background music (customizable)

### 🏛️ Business & RP Apps
- **Banking** - Check balance, transfer money, view transactions
- **Yellow Pages** - Post and browse classified ads
- **Services** - Quick access to server services
- **Employment** - Job listings and applications
- **Invoices** - Send and manage bills
- **Wenmo** - Quick money transfers between players

### 🏠 Lifestyle Apps
- **Houses** - Manage your properties and keys
- **Garage** - View and manage your vehicles
- **Racing** - Create and join street races
- **Crypto** - Trade cryptocurrencies

### 📱 Social Media Apps
- **Birdy** - Twitter-like social media platform
- **Instapic** - Instagram-like photo sharing
- **Trendy** - TikTok-like video sharing platform

### 🎮 Entertainment Apps
- **Casino** - Mobile gambling games
- **News** - Server news and announcements

### 👮 Law Enforcement
- **MEOS** - Police database and search system (restricted access)

### ⚙️ Utility Apps
- **Settings** - Phone configuration and preferences
- **Calculator** - Basic calculator functionality
- **Notepad** - Create and save notes
- **Maps** - GPS and location services

## Installation

### Prerequisites
- FiveM Server
- MySQL Database
- screenshot-basic resource (for camera functionality)
- mysql-async resource

### Database Setup
1. Import the `rmf_phone.sql` file into your database
2. Ensure all tables are created successfully

### Resource Installation
1. Download/clone the repository
2. Place the `rmf-phone` folder in your server's `resources` directory
3. Configure the `config.lua` file according to your server setup
4. Add `ensure rmf-phone` to your `server.cfg`
5. Configure your Discord webhook for photo uploads (optional)

### Framework Integration
The phone supports multiple frameworks. Update the `Config.Framework` setting in `config.lua`:

- `'rmf'` - RMF Core (default)
- `'qb'` - QB Core
- `'esx'` - ESX

## Configuration

### Basic Configuration
Edit `config.lua` to customize:

```lua
-- General Settings
Config.PhoneItem = 'phone'  -- Item name in your inventory
Config.BatteryDrain = true  -- Enable battery drain
Config.BatteryDrainRate = 0.5  -- Battery drain per minute

-- Keybinds
Config.Keybinds = {
    OpenPhone = 288,  -- F1 key
    TakePhoto = 176,  -- ENTER key
    AnswerCall = 176, -- ENTER key
    HangupCall = 177  -- BACKSPACE key
}
```

### Visual Customization
Modify the Android theme colors in `config.lua`:

```lua
Config.AndroidStyle = {
    Theme = {
        Primary = '#2196F3',      -- Main theme color
        PrimaryDark = '#1976D2',  -- Dark variant
        Accent = '#FF4081',       -- Accent color
        Background = '#121212',   -- Dark background
        Surface = '#1E1E1E',      -- Surface color
        Text = '#FFFFFF',         -- Primary text
        TextSecondary = '#B3B3B3' -- Secondary text
    }
}
```

### App Configuration
Enable/disable specific apps or restrict access:

```lua
-- Job Restricted Apps
Config.JobApps = {
    meos = {'police', 'sheriff', 'fbi'},  -- Police only
    employment = {'government'}            -- Government only
}
```

### Photo Integration
Set up Discord webhook for photo sharing:

```lua
Config.Photos = {
    Webhook = 'YOUR_DISCORD_WEBHOOK_URL',
    MaxSize = 10485760,  -- 10MB max file size
    AllowedFormats = {'jpg', 'jpeg', 'png', 'gif'}
}
```

## Usage

### For Players
- Press **F1** to open/close the phone
- Use **ENTER** to answer incoming calls
- Use **BACKSPACE** to decline/end calls
- Take photos with **ENTER** when in camera app
- Long press app icons for app info (future feature)

### For Server Admins

#### Commands
```
/givephone [playerid]           - Give a phone to a player
/setphonenumber [playerid] [number] - Set a player's phone number
/phonebattery [percentage]      - Set your phone battery (testing)
/testcall [number]             - Test incoming call (testing)
/testnotif [message]           - Test notification (testing)
```

#### Exports

**Client Exports:**
```lua
-- Check if phone is open
local isOpen = exports['rmf-phone']:IsPhoneOpen()

-- Open/close phone programmatically
exports['rmf-phone']:OpenPhone()
exports['rmf-phone']:ClosePhone()

-- Add notification
exports['rmf-phone']:AddNotification({
    title = 'Test',
    message = 'Hello World',
    icon = 'notifications'
})

-- Check if player has phone
local hasPhone = exports['rmf-phone']:HasPhoneItem()
```

**Server Exports:**
```lua
-- Get player's phone number
local phoneNumber = exports['rmf-phone']:GetPlayerPhoneNumber(playerId)

-- Get player by phone number
local playerId = exports['rmf-phone']:GetPlayerByPhoneNumber('5551234567')

-- Send notification to player
exports['rmf-phone']:SendNotification(playerId, {
    title = 'Server',
    message = 'Welcome to the server!',
    icon = 'info'
})

-- Send message between players
exports['rmf-phone']:SendMessage(senderId, receiverNumber, message, attachments)
```

### Integration Examples

#### Banking Integration
```lua
-- Update player's bank balance in phone
TriggerClientEvent('rmf-phone:client:updateBankBalance', playerId, newBalance)

-- Send payment notification
exports['rmf-phone']:SendNotification(playerId, {
    title = 'Bank Transfer',
    message = '$' .. amount .. ' received from ' .. senderName,
    icon = 'account_balance'
})
```

#### Job Integration
```lua
-- Send job-specific notification
if GetPlayerJob(playerId) == 'police' then
    exports['rmf-phone']:SendNotification(playerId, {
        title = 'MEOS Alert',
        message = 'New APB issued',
        icon = 'security'
    })
end
```

## Development

### Adding Custom Apps
1. Create app content generator in `server/main.lua`
2. Add app configuration to `config.lua`
3. Create app-specific CSS in `ui/css/apps.css`
4. Add app logic in `ui/js/main.js`

### Example Custom App:
```lua
-- In server/main.lua
function GenerateCustomAppContent(playerId)
    return [[
        <div class="custom-app">
            <h1>My Custom App</h1>
            <p>This is a custom app!</p>
        </div>
    ]]
end

-- In config.lua
{name = 'Custom', icon = 'apps', app = 'custom', color = '#9C27B0'}
```

### Framework Adaptation
To adapt for other frameworks, modify the `GetPlayerIdentifier` function in `server/main.lua` and inventory integration in `client/main.lua`.

## Dependencies

### Required
- **mysql-async** - Database operations
- **screenshot-basic** - Camera functionality

### Recommended
- **InteractSound** - Ringtone and notification sounds
- **rmf-core** or **qb-core** or **es_extended** - Framework integration

## Troubleshooting

### Common Issues

**Phone won't open:**
- Check if player has phone item in inventory
- Verify database connection
- Check console for errors

**Photos not uploading:**
- Verify Discord webhook URL
- Check screenshot-basic resource
- Ensure proper permissions

**Apps not loading:**
- Check server console for Lua errors
- Verify database tables exist
- Check NUI callback registration

**Battery draining too fast:**
- Adjust `Config.BatteryDrainRate` in config
- Check if battery drain is enabled

### Debug Mode
Enable debug mode in config for detailed logging:
```lua
Config.Debug = true
```

## Performance

### Optimization Tips
- Use database indexes for phone numbers and citizen IDs
- Implement caching for frequently accessed data
- Limit notification history to prevent memory leaks
- Optimize image sizes for gallery app

### Resource Usage
- **Client**: ~0.01ms average
- **Server**: ~0.005ms average
- **Memory**: ~15-20MB client, ~5-10MB server

## Support

### Documentation
- [Configuration Guide](docs/configuration.md)
- [API Reference](docs/api.md)
- [Custom Apps Tutorial](docs/custom-apps.md)

### Community
- Discord: [RMF Community](https://discord.gg/rmf)
- Issues: [GitHub Issues](https://github.com/rmf-scripts/rmf-phone/issues)

### Contributing
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Credits

### Development Team
- **RMF Development Team** - Core development
- **Community Contributors** - Feature requests and bug reports

### Inspiration
- **LB Phone** - Original inspiration and feature reference
- **Android Material Design** - UI/UX design principles
- **FiveM Community** - Feedback and suggestions

### Special Thanks
- **LB Scripts** - For the original phone concept
- **QBCore Community** - Framework integration ideas
- **FiveM Developers** - Platform and tools

## Changelog

### Version 1.0.0
- Initial release
- Android-styled UI
- All core apps implemented
- Multi-framework support
- Comprehensive configuration system

---

**Made with ❤️ for the FiveM community**