Config = {}

-- General Settings
Config.PhoneItem = 'phone'
Config.BatteryDrain = true
Config.BatteryDrainRate = 0.5 -- Percentage per minute
Config.MaxContacts = 50
Config.MaxMessages = 100
Config.MaxCallHistory = 50
Config.MaxPhotos = 50

-- Android Style Settings
Config.AndroidStyle = {
    StatusBarHeight = 24,
    NavigationBarHeight = 48,
    AppIconSize = 60,
    AppLabelSize = 12,
    Theme = {
        Primary = '#2196F3',
        PrimaryDark = '#1976D2',
        Accent = '#FF4081',
        Background = '#121212',
        Surface = '#1E1E1E',
        Text = '#FFFFFF',
        TextSecondary = '#B3B3B3'
    }
}

-- Default Apps Configuration
Config.DefaultApps = {
    {name = 'Phone', icon = 'phone', app = 'dialer', color = '#4CAF50'},
    {name = 'Messages', icon = 'message', app = 'messages', color = '#2196F3'},
    {name = 'Contacts', icon = 'contacts', app = 'contacts', color = '#FF9800'},
    {name = 'Camera', icon = 'camera_alt', app = 'camera', color = '#9C27B0'},
    {name = 'Gallery', icon = 'photo_library', app = 'gallery', color = '#E91E63'},
    {name = 'Settings', icon = 'settings', app = 'settings', color = '#607D8B'},
    {name = 'Calculator', icon = 'calculate', app = 'calculator', color = '#795548'},
    {name = 'Notepad', icon = 'note_add', app = 'notepad', color = '#FFEB3B'},
    {name = 'Music', icon = 'music_note', app = 'music', color = '#FF5722'},
    {name = 'Bank', icon = 'account_balance', app = 'banking', color = '#4CAF50'},
    {name = 'Mail', icon = 'mail', app = 'mail', color = '#2196F3'},
    {name = 'Maps', icon = 'map', app = 'maps', color = '#4CAF50'},
    {name = 'Birdy', icon = 'flutter_dash', app = 'birdy', color = '#1DA1F2'},
    {name = 'Instapic', icon = 'photo_camera', app = 'instapic', color = '#E4405F'},
    {name = 'Trendy', icon = 'videocam', app = 'trendy', color = '#000000'},
    {name = 'YellowPages', icon = 'business', app = 'yellowpages', color = '#FFEB3B'},
    {name = 'Garage', icon = 'directions_car', app = 'garage', color = '#9E9E9E'},
    {name = 'Crypto', icon = 'currency_bitcoin', app = 'crypto', color = '#FF9800'},
    {name = 'Racing', icon = 'sports_motorsports', app = 'racing', color = '#F44336'},
    {name = 'Services', icon = 'build', app = 'services', color = '#607D8B'},
    {name = 'Houses', icon = 'home', app = 'houses', color = '#795548'},
    {name = 'MEOS', icon = 'security', app = 'meos', color = '#3F51B5'},
    {name = 'Employment', icon = 'work', app = 'employment', color = '#009688'},
    {name = 'Invoices', icon = 'receipt', app = 'invoices', color = '#FF5722'},
    {name = 'Wenmo', icon = 'payments', app = 'wenmo', color = '#4CAF50'},
    {name = 'News', icon = 'newspaper', app = 'news', color = '#607D8B'},
    {name = 'Casino', icon = 'casino', app = 'casino', color = '#F44336'}
}

-- Keybinds
Config.Keybinds = {
    OpenPhone = 288, -- F1
    TakePhoto = 176, -- ENTER (when camera is open)
    AnswerCall = 176, -- ENTER
    HangupCall = 177, -- BACKSPACE
    ToggleCursor = 19 -- LEFT ALT
}

-- Phone Models
Config.PhoneModels = {
    ['phone'] = {
        model = 'prop_phone_ing',
        animation = {
            dict = 'cellphone@',
            name = 'cellphone_text_read_base'
        }
    }
}

-- Database Tables
Config.DatabaseTables = {
    'rmf_phone_contacts',
    'rmf_phone_messages',
    'rmf_phone_calls',
    'rmf_phone_photos',
    'rmf_phone_notes',
    'rmf_phone_tweets',
    'rmf_phone_instapic',
    'rmf_phone_trendy',
    'rmf_phone_yellowpages',
    'rmf_phone_crypto',
    'rmf_phone_racing',
    'rmf_phone_houses',
    'rmf_phone_vehicles',
    'rmf_phone_invoices',
    'rmf_phone_wenmo',
    'rmf_phone_news',
    'rmf_phone_casino',
    'rmf_phone_meos'
}

-- Security Settings
Config.Security = {
    EnablePinCode = true,
    MaxFailedAttempts = 3,
    LockoutTime = 300, -- 5 minutes
    RequirePinForSensitiveApps = true,
    SensitiveApps = {'banking', 'meos', 'crypto'}
}

-- Photo Settings
Config.Photos = {
    Webhook = '', -- Discord webhook for photos
    MaxSize = 10485760, -- 10MB
    AllowedFormats = {'jpg', 'jpeg', 'png', 'gif'},
    StoragePath = 'photos/'
}

-- Banking Settings
Config.Banking = {
    EnableTransfers = true,
    TransferFee = 0.01, -- 1%
    MaxTransferAmount = 100000,
    MinTransferAmount = 1
}

-- Social Media Settings
Config.SocialMedia = {
    Birdy = {
        MaxTweetLength = 280,
        AllowImages = true,
        AllowVideos = false,
        VerifiedBadge = true
    },
    Instapic = {
        MaxCaptionLength = 2200,
        RequireImage = true,
        AllowVideos = true
    },
    Trendy = {
        MaxVideoLength = 60, -- seconds
        MaxCaptionLength = 150,
        AllowSounds = true
    }
}

-- Emergency Services
Config.Emergency = {
    Police = '911',
    Ambulance = '911',
    Fire = '911',
    AutoGPS = true -- Automatically send GPS when calling emergency
}

-- Job Restricted Apps
Config.JobApps = {
    meos = {'police', 'sheriff', 'fbi'},
    employment = {'government'}
}

-- Framework Settings
Config.Framework = 'rmf' -- Change this based on your framework

-- Debug Mode
Config.Debug = false