// Dashboard Application
class MacMonitorDashboard {
    constructor() {
        this.currentDevice = null;
        this.devices = new Map();
        this.refreshInterval = 5000; // 5 seconds
        this.autoRefreshTimer = null;
        this.cpuThreshold = 80;
        this.memThreshold = 80;
        this.lastAlertTime = 0;
        this.alertCooldown = 30000; // 30 seconds between alerts

        this.init();
    }

    init() {
        this.loadSettings();
        this.setupEventListeners();
        this.detectDarkMode();
        this.startDeviceDiscovery();
        this.startAutoRefresh();
    }

    loadSettings() {
        const cpuThreshold = localStorage.getItem('cpuThreshold');
        const memThreshold = localStorage.getItem('memThreshold');
        const savedDevice = localStorage.getItem('selectedDevice');

        if (cpuThreshold) this.cpuThreshold = parseInt(cpuThreshold);
        if (memThreshold) this.memThreshold = parseInt(memThreshold);
        if (savedDevice) {
            try {
                this.currentDevice = JSON.parse(savedDevice);
            } catch (e) {
                console.error('Failed to parse saved device', e);
            }
        }
    }

    saveSettings() {
        localStorage.setItem('cpuThreshold', this.cpuThreshold);
        localStorage.setItem('memThreshold', this.memThreshold);
        if (this.currentDevice) {
            localStorage.setItem('selectedDevice', JSON.stringify(this.currentDevice));
        }
    }

    setupEventListeners() {
        // Dark mode toggle
        document.getElementById('darkModeToggle').addEventListener('click', () => {
            this.toggleDarkMode();
        });

        // Refresh button
        document.getElementById('refreshBtn').addEventListener('click', () => {
            this.refreshData();
        });

        // Device selector
        document.getElementById('deviceSelector').addEventListener('change', (e) => {
            const deviceId = e.target.value;
            if (deviceId && this.devices.has(deviceId)) {
                this.selectDevice(this.devices.get(deviceId));
            }
        });

        // Alert dismiss
        document.getElementById('dismissAlert').addEventListener('click', () => {
            this.hideAlert();
        });

        // Settings (if implemented)
        const cpuThresholdInput = document.getElementById('cpuThreshold');
        const memThresholdInput = document.getElementById('memThreshold');
        
        if (cpuThresholdInput) {
            cpuThresholdInput.value = this.cpuThreshold;
            cpuThresholdInput.addEventListener('change', (e) => {
                this.cpuThreshold = parseInt(e.target.value);
                this.saveSettings();
            });
        }

        if (memThresholdInput) {
            memThresholdInput.value = this.memThreshold;
            memThresholdInput.addEventListener('change', (e) => {
                this.memThreshold = parseInt(e.target.value);
                this.saveSettings();
            });
        }
    }

    detectDarkMode() {
        const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
        const savedMode = localStorage.getItem('darkMode');

        if (savedMode === 'true' || (savedMode === null && prefersDark)) {
            document.body.classList.add('dark-mode');
            document.getElementById('darkModeToggle').textContent = '☀️';
        }

        // Listen for system preference changes
        window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (e) => {
            if (localStorage.getItem('darkMode') === null) {
                if (e.matches) {
                    document.body.classList.add('dark-mode');
                    document.getElementById('darkModeToggle').textContent = '☀️';
                } else {
                    document.body.classList.remove('dark-mode');
                    document.getElementById('darkModeToggle').textContent = '🌙';
                }
            }
        });
    }

    toggleDarkMode() {
        document.body.classList.toggle('dark-mode');
        const isDark = document.body.classList.contains('dark-mode');
        localStorage.setItem('darkMode', isDark);
        document.getElementById('darkModeToggle').textContent = isDark ? '☀️' : '🌙';
    }

    async startDeviceDiscovery() {
        // Simulate device discovery using Bonjour/mDNS
        // In a real implementation, this would use the Bonjour browser API
        
        // For now, try to discover devices on the local network
        // We'll try common ports and localhost first
        const possibleHosts = [
            { name: 'localhost', host: 'localhost', port: 8080 },
            { name: '127.0.0.1', host: '127.0.0.1', port: 8080 }
        ];

        // Try to discover devices
        for (const deviceInfo of possibleHosts) {
            try {
                const url = `http://${deviceInfo.host}:${deviceInfo.port}/api/info`;
                const response = await fetch(url);
                if (response.ok) {
                    const info = await response.json();
                    const device = {
                        id: `${deviceInfo.host}:${deviceInfo.port}`,
                        name: info.hostname || deviceInfo.name,
                        host: deviceInfo.host,
                        port: deviceInfo.port,
                        info: info
                    };
                    this.devices.set(device.id, device);
                }
            } catch (e) {
                // Device not available
                console.log(`Device ${deviceInfo.host}:${deviceInfo.port} not available`);
            }
        }

        this.updateDeviceSelector();

        // Auto-select first device if none selected
        if (!this.currentDevice && this.devices.size > 0) {
            const firstDevice = this.devices.values().next().value;
            this.selectDevice(firstDevice);
        }
    }

    updateDeviceSelector() {
        const selector = document.getElementById('deviceSelector');
        selector.innerHTML = '';

        if (this.devices.size === 0) {
            const option = document.createElement('option');
            option.value = '';
            option.textContent = '未发现设备';
            selector.appendChild(option);
        } else {
            this.devices.forEach((device) => {
                const option = document.createElement('option');
                option.value = device.id;
                option.textContent = `${device.name} (${device.host})`;
                if (this.currentDevice && this.currentDevice.id === device.id) {
                    option.selected = true;
                }
                selector.appendChild(option);
            });
        }
    }

    selectDevice(device) {
        this.currentDevice = device;
        this.saveSettings();
        this.updateDeviceInfo();
        this.refreshData();
    }

    updateDeviceInfo() {
        if (this.currentDevice) {
            document.getElementById('deviceName').textContent = this.currentDevice.name;
            document.getElementById('connectionStatus').classList.remove('disconnected');
        } else {
            document.getElementById('deviceName').textContent = '未连接';
            document.getElementById('connectionStatus').classList.add('disconnected');
        }
    }

    async refreshData() {
        if (!this.currentDevice) {
            return;
        }

        try {
            const url = `http://${this.currentDevice.host}:${this.currentDevice.port}/api/status`;
            const response = await fetch(url);
            
            if (!response.ok) {
                throw new Error('Failed to fetch data');
            }

            const data = await response.json();
            this.updateUI(data);
            this.checkAlerts(data);
            this.updateConnectionStatus(true);
        } catch (error) {
            console.error('Error fetching data:', error);
            this.updateConnectionStatus(false);
        }
    }

    updateUI(data) {
        const now = new Date().toLocaleTimeString('zh-CN');

        // CPU
        if (data.cpu) {
            const cpuUsage = Math.max(0, Math.min(100, (data.cpu.usage * 100))).toFixed(1);
            document.getElementById('cpuUsage').textContent = `${cpuUsage}%`;
            document.getElementById('cpuCores').textContent = data.cpu.coreCount || '--';
            document.getElementById('cpuFreq').textContent = data.cpu.frequency ? 
                `${data.cpu.frequency.toFixed(1)} GHz` : '--';
            document.getElementById('cpuUpdate').textContent = now;

            const progress = document.getElementById('cpuProgress');
            progress.style.width = `${cpuUsage}%`;
            this.updateProgressColor(progress, cpuUsage);
            this.updateMetricColor(document.getElementById('cpuUsage'), cpuUsage);
        }

        // Memory
        if (data.memory) {
            const memUsage = Math.max(0, Math.min(100, (data.memory.pressure * 100))).toFixed(1);
            document.getElementById('memUsage').textContent = `${memUsage}%`;
            document.getElementById('memUsed').textContent = this.formatBytes(data.memory.used);
            document.getElementById('memTotal').textContent = this.formatBytes(data.memory.total);
            document.getElementById('memUpdate').textContent = now;

            const progress = document.getElementById('memProgress');
            progress.style.width = `${memUsage}%`;
            this.updateProgressColor(progress, memUsage);
            this.updateMetricColor(document.getElementById('memUsage'), memUsage);
        }

        // Disk
        if (data.disk) {
            const diskUsage = data.disk.total > 0 ? 
                Math.max(0, Math.min(100, ((data.disk.used / data.disk.total) * 100))).toFixed(1) : 
                '0.0';
            document.getElementById('diskUsage').textContent = `${diskUsage}%`;
            document.getElementById('diskUsed').textContent = this.formatBytes(data.disk.used);
            document.getElementById('diskFree').textContent = this.formatBytes(data.disk.free);
            document.getElementById('diskUpdate').textContent = now;

            const progress = document.getElementById('diskProgress');
            progress.style.width = `${diskUsage}%`;
            this.updateProgressColor(progress, diskUsage);
            this.updateMetricColor(document.getElementById('diskUsage'), diskUsage);
        }

        // Network
        if (data.network) {
            document.getElementById('netDownload').textContent = this.formatBytesPerSec(data.network.bytesIn);
            document.getElementById('netUpload').textContent = this.formatBytesPerSec(data.network.bytesOut);
            document.getElementById('netPacketsIn').textContent = this.formatNumber(data.network.packetsIn);
            document.getElementById('netPacketsOut').textContent = this.formatNumber(data.network.packetsOut);
            document.getElementById('netUpdate').textContent = now;
        }

        // Temperature
        const temp = data.temperature || data.cpu?.temperature;
        document.getElementById('temperature').textContent = temp ? 
            `${temp.toFixed(1)}°C` : 'N/A';
        
        const batteryLevel = data.batteryLevel;
        document.getElementById('batteryLevel').textContent = batteryLevel != null ? 
            `${(batteryLevel * 100).toFixed(0)}%` : 'N/A';
        
        const isCharging = data.isCharging;
        document.getElementById('chargingStatus').textContent = 
            isCharging == null ? 'N/A' : (isCharging ? '充电中' : '未充电');
        
        document.getElementById('tempUpdate').textContent = now;

        // Process
        document.getElementById('processCount').textContent = data.processCount || '--';
        document.getElementById('threadCount').textContent = data.threadCount || '--';
        document.getElementById('uptime').textContent = this.formatUptime(data.uptime);
        document.getElementById('procUpdate').textContent = now;

        // Update last refresh time
        document.getElementById('lastRefresh').textContent = `最后更新: ${now}`;
    }

    updateProgressColor(element, value) {
        element.classList.remove('warning', 'danger');
        if (value >= 90) {
            element.classList.add('danger');
        } else if (value >= 70) {
            element.classList.add('warning');
        }
    }

    updateMetricColor(element, value) {
        element.classList.remove('warning', 'danger');
        if (value >= 90) {
            element.classList.add('danger');
        } else if (value >= 70) {
            element.classList.add('warning');
        }
    }

    checkAlerts(data) {
        const now = Date.now();
        if (now - this.lastAlertTime < this.alertCooldown) {
            return; // Don't spam alerts
        }

        const alerts = [];

        // Check CPU
        if (data.cpu && data.cpu.usage * 100 >= this.cpuThreshold) {
            alerts.push(`CPU 使用率过高: ${(data.cpu.usage * 100).toFixed(1)}%`);
        }

        // Check Memory
        if (data.memory && data.memory.pressure * 100 >= this.memThreshold) {
            alerts.push(`内存使用率过高: ${(data.memory.pressure * 100).toFixed(1)}%`);
        }

        if (alerts.length > 0) {
            this.showAlert(alerts.join(' | '));
            this.lastAlertTime = now;

            // Request notification permission and show notification
            if ('Notification' in window && Notification.permission === 'granted') {
                new Notification('Mac Monitor 告警', {
                    body: alerts.join('\n'),
                    icon: '🖥️'
                });
            }
        }
    }

    showAlert(message) {
        const banner = document.getElementById('alertBanner');
        const messageEl = document.getElementById('alertMessage');
        
        messageEl.textContent = message;
        banner.classList.remove('hidden');
        
        // Auto-hide after 10 seconds
        setTimeout(() => {
            this.hideAlert();
        }, 10000);
    }

    hideAlert() {
        document.getElementById('alertBanner').classList.add('hidden');
    }

    updateConnectionStatus(connected) {
        const status = document.getElementById('connectionStatus');
        if (connected) {
            status.classList.remove('disconnected');
        } else {
            status.classList.add('disconnected');
        }
    }

    startAutoRefresh() {
        // Initial refresh
        this.refreshData();

        // Set up auto-refresh
        this.autoRefreshTimer = setInterval(() => {
            this.refreshData();
        }, this.refreshInterval);
    }

    stopAutoRefresh() {
        if (this.autoRefreshTimer) {
            clearInterval(this.autoRefreshTimer);
            this.autoRefreshTimer = null;
        }
    }

    // Utility functions
    formatBytes(bytes) {
        if (!bytes || bytes === 0) return '0 B';
        const k = 1024;
        const sizes = ['B', 'KB', 'MB', 'GB', 'TB'];
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        return `${(bytes / Math.pow(k, i)).toFixed(1)} ${sizes[i]}`;
    }

    formatBytesPerSec(bytes) {
        if (!bytes || bytes === 0) return '0 B/s';
        const k = 1024;
        const sizes = ['B/s', 'KB/s', 'MB/s', 'GB/s'];
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        return `${(bytes / Math.pow(k, i)).toFixed(1)} ${sizes[i]}`;
    }

    formatNumber(num) {
        if (!num) return '0';
        return num.toLocaleString('zh-CN');
    }

    formatUptime(seconds) {
        if (!seconds) return '--';
        
        const days = Math.floor(seconds / 86400);
        const hours = Math.floor((seconds % 86400) / 3600);
        const minutes = Math.floor((seconds % 3600) / 60);

        if (days > 0) {
            return `${days}天 ${hours}时`;
        } else if (hours > 0) {
            return `${hours}时 ${minutes}分`;
        } else {
            return `${minutes}分`;
        }
    }
}

// Request notification permission on load
if ('Notification' in window && Notification.permission === 'default') {
    Notification.requestPermission();
}

// Initialize the dashboard when DOM is ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
        window.dashboard = new MacMonitorDashboard();
    });
} else {
    window.dashboard = new MacMonitorDashboard();
}
