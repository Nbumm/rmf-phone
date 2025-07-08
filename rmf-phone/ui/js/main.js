/**
 * RMF Phone - Main JavaScript Controller
 * Handles phone functionality, screen management, and user interactions
 */

class RMFPhone {
    constructor() {
        this.currentScreen = 'lock-screen';
        this.isLocked = true;
        this.pinCode = '';
        this.enteredPin = '';
        this.phoneData = {
            battery: 100,
            signal: 4,
            wifi: true,
            airplane: false,
            silent: false,
            contacts: [],
            messages: [],
            calls: [],
            photos: [],
            notes: []
        };
        this.activeCall = null;
        this.callTimer = null;
        this.currentApp = null;
        this.notifications = [];
        
        this.init();
    }

    init() {
        this.setupEventListeners();
        this.updateTime();
        this.updateStatusBar();
        this.loadApps();
        this.startTimeUpdater();
        this.requestPhoneData();
        
        // Initialize with lock screen
        this.showScreen('lock-screen');
    }

    setupEventListeners() {
        // Lock screen unlock button
        document.getElementById('unlock-button').addEventListener('click', () => {
            this.unlockPhone();
        });

        // PIN keypad
        document.querySelectorAll('.pin-key').forEach(key => {
            key.addEventListener('click', (e) => {
                const number = e.target.dataset.number;
                const action = e.target.dataset.action;
                
                if (number) {
                    this.enterPin(number);
                } else if (action === 'backspace') {
                    this.removePin();
                }
            });
        });

        // Navigation buttons
        document.getElementById('back-nav').addEventListener('click', () => {
            this.goBack();
        });

        document.getElementById('home-nav').addEventListener('click', () => {
            this.goHome();
        });

        document.getElementById('recent-nav').addEventListener('click', () => {
            this.showRecentApps();
        });

        // App back button
        document.getElementById('back-button').addEventListener('click', () => {
            this.closeApp();
        });

        // Call controls
        document.getElementById('answer-call').addEventListener('click', () => {
            this.answerCall();
        });

        document.getElementById('decline-call').addEventListener('click', () => {
            this.declineCall();
        });

        document.getElementById('end-call').addEventListener('click', () => {
            this.endCall();
        });

        // Dock apps
        document.querySelectorAll('.dock-app').forEach(app => {
            app.addEventListener('click', (e) => {
                const appName = e.currentTarget.dataset.app;
                this.openApp(appName);
            });
        });

        // Status bar interactions
        document.getElementById('status-bar').addEventListener('click', (e) => {
            if (e.target.closest('.status-right')) {
                this.toggleQuickSettings();
            } else {
                this.toggleNotifications();
            }
        });

        // Quick settings
        document.querySelectorAll('.quick-setting').forEach(setting => {
            setting.addEventListener('click', (e) => {
                const settingType = e.currentTarget.dataset.setting;
                this.toggleSetting(settingType);
            });
        });

        // Search functionality
        const searchInput = document.querySelector('.search-bar input');
        searchInput.addEventListener('input', (e) => {
            this.searchApps(e.target.value);
        });

        // Forgot PIN
        document.getElementById('forgot-pin').addEventListener('click', () => {
            this.resetPin();
        });

        // Clear notifications
        document.getElementById('clear-notifications').addEventListener('click', () => {
            this.clearNotifications();
        });

        // Lock shortcuts
        document.querySelectorAll('.lock-shortcut').forEach(shortcut => {
            shortcut.addEventListener('click', (e) => {
                const app = e.currentTarget.dataset.app;
                if (!this.isLocked) {
                    this.openApp(app);
                }
            });
        });

        // Window events
        window.addEventListener('message', (event) => {
            this.handleMessage(event.data);
        });

        // Keyboard events
        document.addEventListener('keydown', (e) => {
            this.handleKeyPress(e);
        });
    }

    // Screen Management
    showScreen(screenId) {
        document.querySelectorAll('.screen').forEach(screen => {
            screen.classList.remove('active');
        });
        
        const targetScreen = document.getElementById(screenId);
        if (targetScreen) {
            targetScreen.classList.add('active');
            this.currentScreen = screenId;
        }
    }

    unlockPhone() {
        if (this.phoneData.pinCode && this.phoneData.pinCode !== '') {
            this.showScreen('pin-screen');
        } else {
            this.isLocked = false;
            this.showScreen('home-screen');
        }
    }

    lockPhone() {
        this.isLocked = true;
        this.currentApp = null;
        this.showScreen('lock-screen');
        this.sendMessage('phone:lock');
    }

    // PIN Management
    enterPin(number) {
        if (this.enteredPin.length < 4) {
            this.enteredPin += number;
            this.updatePinDots();
            
            if (this.enteredPin.length === 4) {
                this.verifyPin();
            }
        }
    }

    removePin() {
        this.enteredPin = this.enteredPin.slice(0, -1);
        this.updatePinDots();
    }

    updatePinDots() {
        const dots = document.querySelectorAll('.pin-dot');
        dots.forEach((dot, index) => {
            if (index < this.enteredPin.length) {
                dot.classList.add('filled');
            } else {
                dot.classList.remove('filled');
            }
        });
    }

    verifyPin() {
        if (this.enteredPin === this.phoneData.pinCode) {
            this.isLocked = false;
            this.enteredPin = '';
            this.updatePinDots();
            this.showScreen('home-screen');
        } else {
            this.showPinError();
            this.enteredPin = '';
            this.updatePinDots();
        }
    }

    showPinError() {
        const pinContainer = document.querySelector('.pin-container');
        pinContainer.style.animation = 'shake 0.5s ease-in-out';
        setTimeout(() => {
            pinContainer.style.animation = '';
        }, 500);
    }

    resetPin() {
        this.sendMessage('phone:resetPin');
    }

    // App Management
    loadApps() {
        const appGrid = document.getElementById('app-grid');
        appGrid.innerHTML = '';

        const defaultApps = [
            {name: 'Phone', icon: 'phone', app: 'dialer', color: '#4CAF50'},
            {name: 'Messages', icon: 'message', app: 'messages', color: '#2196F3'},
            {name: 'Contacts', icon: 'contacts', app: 'contacts', color: '#FF9800'},
            {name: 'Camera', icon: 'camera_alt', app: 'camera', color: '#9C27B0'},
            {name: 'Gallery', icon: 'photo_library', app: 'gallery', color: '#E91E63'},
            {name: 'Settings', icon: 'settings', app: 'settings', color: '#607D8B'},
            {name: 'Calculator', icon: 'calculate', app: 'calculator', color: '#795548'},
            {name: 'Notepad', icon: 'note_add', app: 'notepad', color: '#FFEB3B'},
            {name: 'Music', icon: 'music_note', app: 'music', color: '#FF5722'},
            {name: 'Bank', icon: 'account_balance', app: 'banking', color: '#4CAF50'},
            {name: 'Mail', icon: 'mail', app: 'mail', color: '#2196F3'},
            {name: 'Maps', icon: 'map', app: 'maps', color: '#4CAF50'},
            {name: 'Birdy', icon: 'flutter_dash', app: 'birdy', color: '#1DA1F2'},
            {name: 'Instapic', icon: 'photo_camera', app: 'instapic', color: '#E4405F'},
            {name: 'Trendy', icon: 'videocam', app: 'trendy', color: '#000000'},
            {name: 'YellowPages', icon: 'business', app: 'yellowpages', color: '#FFEB3B'},
            {name: 'Garage', icon: 'directions_car', app: 'garage', color: '#9E9E9E'},
            {name: 'Crypto', icon: 'currency_bitcoin', app: 'crypto', color: '#FF9800'},
            {name: 'Racing', icon: 'sports_motorsports', app: 'racing', color: '#F44336'},
            {name: 'Services', icon: 'build', app: 'services', color: '#607D8B'},
            {name: 'Houses', icon: 'home', app: 'houses', color: '#795548'},
            {name: 'MEOS', icon: 'security', app: 'meos', color: '#3F51B5'},
            {name: 'Employment', icon: 'work', app: 'employment', color: '#009688'},
            {name: 'Invoices', icon: 'receipt', app: 'invoices', color: '#FF5722'},
            {name: 'Wenmo', icon: 'payments', app: 'wenmo', color: '#4CAF50'},
            {name: 'News', icon: 'newspaper', app: 'news', color: '#607D8B'},
            {name: 'Casino', icon: 'casino', app: 'casino', color: '#F44336'}
        ];

        defaultApps.forEach(app => {
            const appElement = this.createAppElement(app);
            appGrid.appendChild(appElement);
        });
    }

    createAppElement(app) {
        const appItem = document.createElement('div');
        appItem.className = 'app-item';
        appItem.dataset.app = app.app;
        
        appItem.innerHTML = `
            <div class="app-icon" style="background-color: ${app.color};">
                <span class="material-icons">${app.icon}</span>
            </div>
            <div class="app-label">${app.name}</div>
        `;
        
        appItem.addEventListener('click', () => {
            this.openApp(app.app);
        });
        
        return appItem;
    }

    openApp(appName) {
        if (this.isLocked && !['camera', 'dialer'].includes(appName)) {
            return;
        }

        this.currentApp = appName;
        this.showScreen('app-container');
        
        document.getElementById('app-title').textContent = this.getAppTitle(appName);
        
        // Load app content
        this.loadAppContent(appName);
        
        this.sendMessage('phone:openApp', { app: appName });
    }

    getAppTitle(appName) {
        const titles = {
            dialer: 'Phone',
            messages: 'Messages',
            contacts: 'Contacts',
            camera: 'Camera',
            gallery: 'Gallery',
            settings: 'Settings',
            calculator: 'Calculator',
            notepad: 'Notepad',
            music: 'Music',
            banking: 'Bank',
            mail: 'Mail',
            maps: 'Maps',
            birdy: 'Birdy',
            instapic: 'Instapic',
            trendy: 'Trendy',
            yellowpages: 'Yellow Pages',
            garage: 'Garage',
            crypto: 'Crypto',
            racing: 'Racing',
            services: 'Services',
            houses: 'Houses',
            meos: 'MEOS',
            employment: 'Employment',
            invoices: 'Invoices',
            wenmo: 'Wenmo',
            news: 'News',
            casino: 'Casino'
        };
        return titles[appName] || 'App';
    }

    loadAppContent(appName) {
        const appContent = document.getElementById('app-content');
        appContent.innerHTML = '<div class="loading">Loading...</div>';
        
        // Request app content from server
        this.sendMessage('phone:loadApp', { app: appName });
    }

    closeApp() {
        this.currentApp = null;
        this.showScreen('home-screen');
    }

    searchApps(query) {
        const apps = document.querySelectorAll('.app-item');
        apps.forEach(app => {
            const label = app.querySelector('.app-label').textContent.toLowerCase();
            if (label.includes(query.toLowerCase())) {
                app.style.display = 'flex';
            } else {
                app.style.display = 'none';
            }
        });
    }

    // Navigation
    goBack() {
        if (this.currentApp) {
            this.closeApp();
        } else if (this.currentScreen !== 'home-screen' && !this.isLocked) {
            this.showScreen('home-screen');
        }
    }

    goHome() {
        if (!this.isLocked) {
            this.showScreen('home-screen');
            this.currentApp = null;
        }
    }

    showRecentApps() {
        // TODO: Implement recent apps screen
        console.log('Recent apps not implemented yet');
    }

    // Call Management
    receiveCall(callerData) {
        this.activeCall = {
            ...callerData,
            startTime: Date.now(),
            status: 'incoming'
        };
        
        document.getElementById('caller-name').textContent = callerData.name || 'Unknown';
        document.getElementById('caller-number').textContent = callerData.number || '';
        
        if (callerData.avatar) {
            document.getElementById('caller-avatar').innerHTML = `<img src="${callerData.avatar}" alt="Avatar">`;
        }
        
        this.showScreen('call-screen');
        this.playRingtone();
    }

    answerCall() {
        if (this.activeCall) {
            this.activeCall.status = 'active';
            this.showScreen('active-call-screen');
            this.stopRingtone();
            this.startCallTimer();
            
            document.getElementById('active-caller-name').textContent = this.activeCall.name || 'Unknown';
            
            this.sendMessage('phone:answerCall', { callId: this.activeCall.id });
        }
    }

    declineCall() {
        if (this.activeCall) {
            this.stopRingtone();
            this.activeCall = null;
            this.showScreen(this.isLocked ? 'lock-screen' : 'home-screen');
            
            this.sendMessage('phone:declineCall', { callId: this.activeCall?.id });
        }
    }

    endCall() {
        if (this.activeCall) {
            this.stopCallTimer();
            this.activeCall = null;
            this.showScreen(this.isLocked ? 'lock-screen' : 'home-screen');
            
            this.sendMessage('phone:endCall');
        }
    }

    startCallTimer() {
        let duration = 0;
        this.callTimer = setInterval(() => {
            duration++;
            const minutes = Math.floor(duration / 60).toString().padStart(2, '0');
            const seconds = (duration % 60).toString().padStart(2, '0');
            document.getElementById('active-call-duration').textContent = `${minutes}:${seconds}`;
        }, 1000);
    }

    stopCallTimer() {
        if (this.callTimer) {
            clearInterval(this.callTimer);
            this.callTimer = null;
        }
    }

    // Audio
    playRingtone() {
        // TODO: Implement ringtone playback
    }

    stopRingtone() {
        // TODO: Stop ringtone playback
    }

    // Time and Status
    updateTime() {
        const now = new Date();
        const timeString = now.toLocaleTimeString('en-US', { 
            hour: '2-digit', 
            minute: '2-digit',
            hour12: false 
        });
        
        document.getElementById('time').textContent = timeString;
        document.getElementById('lock-time-display').textContent = timeString;
        
        const dateString = now.toLocaleDateString('en-US', {
            weekday: 'long',
            month: 'long',
            day: 'numeric'
        });
        document.getElementById('lock-date-display').textContent = dateString;
    }

    updateStatusBar() {
        // Battery
        document.getElementById('battery-percentage').textContent = `${this.phoneData.battery}%`;
        
        const batteryIcon = document.getElementById('battery-icon');
        if (this.phoneData.battery > 75) {
            batteryIcon.textContent = 'battery_full';
        } else if (this.phoneData.battery > 50) {
            batteryIcon.textContent = 'battery_std';
        } else if (this.phoneData.battery > 25) {
            batteryIcon.textContent = 'battery_low';
        } else {
            batteryIcon.textContent = 'battery_alert';
        }
        
        // Signal
        const signalIcon = document.getElementById('signal-icon');
        const signalStrength = this.phoneData.signal;
        signalIcon.textContent = `signal_cellular_${signalStrength}_bar`;
        
        // WiFi
        const wifiIcon = document.getElementById('wifi-icon');
        wifiIcon.style.display = this.phoneData.wifi ? 'inline' : 'none';
    }

    startTimeUpdater() {
        setInterval(() => {
            this.updateTime();
        }, 1000);
    }

    // Notifications
    addNotification(notification) {
        this.notifications.unshift(notification);
        this.updateNotificationDisplay();
        this.showNotificationPopup(notification);
    }

    updateNotificationDisplay() {
        const notificationList = document.getElementById('notification-list');
        notificationList.innerHTML = '';
        
        this.notifications.forEach(notification => {
            const notifElement = this.createNotificationElement(notification);
            notificationList.appendChild(notifElement);
        });
        
        // Update lock screen notifications
        const lockNotifications = document.getElementById('lock-notifications');
        lockNotifications.innerHTML = '';
        
        this.notifications.slice(0, 3).forEach(notification => {
            const lockNotifElement = this.createLockNotificationElement(notification);
            lockNotifications.appendChild(lockNotifElement);
        });
    }

    createNotificationElement(notification) {
        const element = document.createElement('div');
        element.className = 'notification-item';
        element.innerHTML = `
            <div class="notification-icon">
                <span class="material-icons">${notification.icon || 'notifications'}</span>
            </div>
            <div class="notification-content">
                <div class="notification-title">${notification.title}</div>
                <div class="notification-message">${notification.message}</div>
                <div class="notification-time">${this.formatTime(notification.timestamp)}</div>
            </div>
        `;
        return element;
    }

    createLockNotificationElement(notification) {
        const element = document.createElement('div');
        element.className = 'lock-notification-item';
        element.innerHTML = `
            <div class="lock-notification-content">
                <span class="lock-notification-title">${notification.title}</span>
                <span class="lock-notification-message">${notification.message}</span>
            </div>
        `;
        return element;
    }

    showNotificationPopup(notification) {
        // TODO: Implement notification popup
    }

    clearNotifications() {
        this.notifications = [];
        this.updateNotificationDisplay();
        this.sendMessage('phone:clearNotifications');
    }

    toggleNotifications() {
        const panel = document.getElementById('notification-panel');
        panel.classList.toggle('active');
    }

    toggleQuickSettings() {
        const panel = document.getElementById('quick-settings-panel');
        panel.classList.toggle('active');
    }

    toggleSetting(settingType) {
        const setting = document.querySelector(`[data-setting="${settingType}"]`);
        setting.classList.toggle('active');
        
        switch (settingType) {
            case 'wifi':
                this.phoneData.wifi = !this.phoneData.wifi;
                break;
            case 'airplane':
                this.phoneData.airplane = !this.phoneData.airplane;
                break;
            case 'silent':
                this.phoneData.silent = !this.phoneData.silent;
                break;
        }
        
        this.updateStatusBar();
        this.sendMessage('phone:toggleSetting', { setting: settingType, value: this.phoneData[settingType] });
    }

    // Utility Methods
    formatTime(timestamp) {
        const date = new Date(timestamp);
        const now = new Date();
        const diffMs = now - date;
        const diffMins = Math.floor(diffMs / 60000);
        
        if (diffMins < 1) return 'Just now';
        if (diffMins < 60) return `${diffMins}m ago`;
        if (diffMins < 1440) return `${Math.floor(diffMins / 60)}h ago`;
        return date.toLocaleDateString();
    }

    sendMessage(action, data = {}) {
        fetch(`https://${GetParentResourceName()}/${action}`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(data)
        });
    }

    handleMessage(data) {
        switch (data.action) {
            case 'show':
                document.body.style.display = 'block';
                break;
            case 'hide':
                document.body.style.display = 'none';
                break;
            case 'updatePhoneData':
                this.updatePhoneData(data.phoneData);
                break;
            case 'receiveCall':
                this.receiveCall(data.callData);
                break;
            case 'endCall':
                this.endCall();
                break;
            case 'addNotification':
                this.addNotification(data.notification);
                break;
            case 'loadAppContent':
                this.displayAppContent(data.appName, data.content);
                break;
            case 'updateBattery':
                this.phoneData.battery = data.battery;
                this.updateStatusBar();
                break;
        }
    }

    updatePhoneData(phoneData) {
        this.phoneData = { ...this.phoneData, ...phoneData };
        this.updateStatusBar();
    }

    displayAppContent(appName, content) {
        const appContent = document.getElementById('app-content');
        appContent.innerHTML = content;
        
        // Setup app-specific event listeners
        this.setupAppEventListeners(appName);
    }

    setupAppEventListeners(appName) {
        // This will be extended for each app
        switch (appName) {
            case 'dialer':
                this.setupDialerListeners();
                break;
            case 'messages':
                this.setupMessagesListeners();
                break;
            // Add more apps as needed
        }
    }

    setupDialerListeners() {
        // Dialer keypad
        document.querySelectorAll('.dialer-key').forEach(key => {
            key.addEventListener('click', (e) => {
                const number = e.target.dataset.number;
                this.dialNumber(number);
            });
        });
        
        // Call button
        const callButton = document.querySelector('.dialer-call-button');
        if (callButton) {
            callButton.addEventListener('click', () => {
                this.makeCall();
            });
        }
    }

    setupMessagesListeners() {
        // Message sending
        const sendButton = document.querySelector('.message-send-button');
        if (sendButton) {
            sendButton.addEventListener('click', () => {
                this.sendMessage();
            });
        }
    }

    dialNumber(number) {
        // TODO: Implement dialer number entry
    }

    makeCall() {
        // TODO: Implement making calls
    }

    handleKeyPress(e) {
        // Handle keyboard shortcuts
        if (e.key === 'Escape') {
            if (this.currentApp) {
                this.closeApp();
            } else {
                this.goHome();
            }
        }
    }

    requestPhoneData() {
        this.sendMessage('phone:requestData');
    }
}

// Initialize phone when page loads
document.addEventListener('DOMContentLoaded', () => {
    window.phone = new RMFPhone();
});

// Close phone when clicking outside (for development)
document.addEventListener('click', (e) => {
    if (e.target === document.body) {
        window.phone?.sendMessage('phone:close');
    }
});