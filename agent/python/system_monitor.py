import psutil
import platform
import time
from datetime import datetime

class SystemMonitor:
    def __init__(self):
        # 初始化网络计数器
        self.last_net_io = psutil.net_io_counters()
        self.last_time = time.time()
    
    def get_cpu_info(self):
        cpu_freq = psutil.cpu_freq()
        return {
            "usage": psutil.cpu_percent(interval=0.5) / 100.0,
            "coreCount": psutil.cpu_count(),
            "frequency": cpu_freq.current / 1000 if cpu_freq else None,
            "temperature": self.get_cpu_temperature()
        }
    
    def get_memory_info(self):
        mem = psutil.virtual_memory()
        return {
            "total": mem.total,
            "used": mem.used,
            "free": mem.available,
            "pressure": mem.percent / 100.0
        }
    
    def get_disk_info(self):
        disk = psutil.disk_usage('/')
        return {
            "total": disk.total,
            "used": disk.used,
            "free": disk.free
        }
    
    def get_network_info(self):
        net_io = psutil.net_io_counters()
        current_time = time.time()
        
        # 计算速率
        time_delta = current_time - self.last_time
        bytes_in_rate = (net_io.bytes_recv - self.last_net_io.bytes_recv) / time_delta if time_delta > 0 else 0
        bytes_out_rate = (net_io.bytes_sent - self.last_net_io.bytes_sent) / time_delta if time_delta > 0 else 0
        
        self.last_net_io = net_io
        self.last_time = current_time
        
        return {
            "bytesIn": int(bytes_in_rate),
            "bytesOut": int(bytes_out_rate),
            "packetsIn": net_io.packets_recv,
            "packetsOut": net_io.packets_sent
        }
    
    def get_uptime(self):
        return time.time() - psutil.boot_time()
    
    def get_process_info(self):
        processes = list(psutil.process_iter(['num_threads']))
        thread_count = sum(p.info['num_threads'] for p in processes if p.info['num_threads'])
        return {
            "processCount": len(processes),
            "threadCount": thread_count
        }
    
    def get_cpu_temperature(self):
        # macOS 上获取温度比较复杂，返回 None
        # 需要使用 SMC 或第三方工具
        try:
            if hasattr(psutil, "sensors_temperatures"):
                temps = psutil.sensors_temperatures()
                if temps:
                    for name, entries in temps.items():
                        if entries:
                            return entries[0].current
        except Exception:
            pass
        return None
    
    def get_battery_info(self):
        try:
            battery = psutil.sensors_battery()
            if battery:
                return {
                    "level": battery.percent / 100.0,
                    "isCharging": battery.power_plugged
                }
        except Exception:
            pass
        return {"level": None, "isCharging": None}
    
    def get_status(self):
        cpu_info = self.get_cpu_info()
        memory_info = self.get_memory_info()
        disk_info = self.get_disk_info()
        network_info = self.get_network_info()
        process_info = self.get_process_info()
        battery_info = self.get_battery_info()
        
        return {
            "timestamp": datetime.now().isoformat(),
            "cpu": cpu_info,
            "memory": memory_info,
            "disk": disk_info,
            "network": network_info,
            "temperature": cpu_info.get("temperature"),
            "uptime": self.get_uptime(),
            "processCount": process_info["processCount"],
            "threadCount": process_info["threadCount"],
            "batteryLevel": battery_info["level"],
            "isCharging": battery_info["isCharging"]
        }