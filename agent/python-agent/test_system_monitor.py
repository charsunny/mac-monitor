#!/usr/bin/env python3
"""
Tests for SystemMonitor class
"""
import unittest
import time
from system_monitor import SystemMonitor


class TestSystemMonitor(unittest.TestCase):
    """Test cases for SystemMonitor"""
    
    def setUp(self):
        """Set up test fixtures"""
        self.monitor = SystemMonitor()
    
    def test_get_cpu_info(self):
        """Test CPU information retrieval"""
        cpu_info = self.monitor.get_cpu_info()
        
        # Check that all required fields are present
        self.assertIn("usage", cpu_info)
        self.assertIn("coreCount", cpu_info)
        self.assertIn("frequency", cpu_info)
        self.assertIn("temperature", cpu_info)
        
        # Validate data types and ranges
        self.assertIsInstance(cpu_info["usage"], float)
        self.assertGreaterEqual(cpu_info["usage"], 0.0)
        self.assertLessEqual(cpu_info["usage"], 1.0)
        
        self.assertIsInstance(cpu_info["coreCount"], int)
        self.assertGreater(cpu_info["coreCount"], 0)
        
        # Frequency can be None or a positive float
        if cpu_info["frequency"] is not None:
            self.assertIsInstance(cpu_info["frequency"], float)
            self.assertGreater(cpu_info["frequency"], 0)
    
    def test_get_memory_info(self):
        """Test memory information retrieval"""
        mem_info = self.monitor.get_memory_info()
        
        # Check that all required fields are present
        self.assertIn("total", mem_info)
        self.assertIn("used", mem_info)
        self.assertIn("free", mem_info)
        self.assertIn("pressure", mem_info)
        
        # Validate data types and ranges
        self.assertIsInstance(mem_info["total"], int)
        self.assertGreater(mem_info["total"], 0)
        
        self.assertIsInstance(mem_info["used"], int)
        self.assertGreaterEqual(mem_info["used"], 0)
        
        self.assertIsInstance(mem_info["free"], int)
        self.assertGreaterEqual(mem_info["free"], 0)
        
        self.assertIsInstance(mem_info["pressure"], float)
        self.assertGreaterEqual(mem_info["pressure"], 0.0)
        self.assertLessEqual(mem_info["pressure"], 1.0)
        
        # Check that used + free <= total (approximately)
        self.assertLessEqual(mem_info["used"], mem_info["total"])
    
    def test_get_disk_info(self):
        """Test disk information retrieval"""
        disk_info = self.monitor.get_disk_info()
        
        # Check that all required fields are present
        self.assertIn("total", disk_info)
        self.assertIn("used", disk_info)
        self.assertIn("free", disk_info)
        
        # Validate data types and ranges
        self.assertIsInstance(disk_info["total"], int)
        self.assertGreater(disk_info["total"], 0)
        
        self.assertIsInstance(disk_info["used"], int)
        self.assertGreaterEqual(disk_info["used"], 0)
        
        self.assertIsInstance(disk_info["free"], int)
        self.assertGreaterEqual(disk_info["free"], 0)
        
        # Check that used + free == total (approximately)
        self.assertAlmostEqual(
            disk_info["used"] + disk_info["free"], 
            disk_info["total"],
            delta=disk_info["total"] * 0.01  # Allow 1% tolerance
        )
    
    def test_get_network_info(self):
        """Test network information retrieval"""
        # First call initializes the counters
        net_info_1 = self.monitor.get_network_info()
        
        # Sleep briefly to allow network activity
        time.sleep(0.1)
        
        # Second call should show rate calculation
        net_info_2 = self.monitor.get_network_info()
        
        # Check that all required fields are present
        for net_info in [net_info_1, net_info_2]:
            self.assertIn("bytesIn", net_info)
            self.assertIn("bytesOut", net_info)
            self.assertIn("packetsIn", net_info)
            self.assertIn("packetsOut", net_info)
            
            # Validate data types
            self.assertIsInstance(net_info["bytesIn"], int)
            self.assertIsInstance(net_info["bytesOut"], int)
            self.assertIsInstance(net_info["packetsIn"], int)
            self.assertIsInstance(net_info["packetsOut"], int)
            
            # Validate ranges (should be non-negative)
            self.assertGreaterEqual(net_info["bytesIn"], 0)
            self.assertGreaterEqual(net_info["bytesOut"], 0)
            self.assertGreaterEqual(net_info["packetsIn"], 0)
            self.assertGreaterEqual(net_info["packetsOut"], 0)
    
    def test_get_uptime(self):
        """Test uptime retrieval"""
        uptime = self.monitor.get_uptime()
        
        # Validate data type and range
        self.assertIsInstance(uptime, float)
        self.assertGreater(uptime, 0)
        
        # Uptime should be less than a year in seconds (reasonable check)
        self.assertLess(uptime, 365 * 24 * 3600)
    
    def test_get_process_info(self):
        """Test process information retrieval"""
        proc_info = self.monitor.get_process_info()
        
        # Check that all required fields are present
        self.assertIn("processCount", proc_info)
        self.assertIn("threadCount", proc_info)
        
        # Validate data types and ranges
        self.assertIsInstance(proc_info["processCount"], int)
        self.assertGreater(proc_info["processCount"], 0)
        
        self.assertIsInstance(proc_info["threadCount"], int)
        self.assertGreater(proc_info["threadCount"], 0)
        
        # Thread count should be at least as many as process count
        self.assertGreaterEqual(proc_info["threadCount"], proc_info["processCount"])
    
    def test_get_battery_info(self):
        """Test battery information retrieval"""
        battery_info = self.monitor.get_battery_info()
        
        # Check that all required fields are present
        self.assertIn("level", battery_info)
        self.assertIn("isCharging", battery_info)
        
        # Battery info might be None on systems without battery
        if battery_info["level"] is not None:
            self.assertIsInstance(battery_info["level"], float)
            self.assertGreaterEqual(battery_info["level"], 0.0)
            self.assertLessEqual(battery_info["level"], 1.0)
        
        if battery_info["isCharging"] is not None:
            self.assertIsInstance(battery_info["isCharging"], bool)
    
    def test_get_status(self):
        """Test complete status retrieval"""
        status = self.monitor.get_status()
        
        # Check that all required fields are present
        required_fields = [
            "timestamp", "cpu", "memory", "disk", "network",
            "temperature", "uptime", "processCount", "threadCount",
            "batteryLevel", "isCharging"
        ]
        
        for field in required_fields:
            self.assertIn(field, status)
        
        # Validate timestamp format
        self.assertIsInstance(status["timestamp"], str)
        self.assertIn("T", status["timestamp"])  # ISO format has 'T' separator
        
        # Validate nested structures
        self.assertIsInstance(status["cpu"], dict)
        self.assertIsInstance(status["memory"], dict)
        self.assertIsInstance(status["disk"], dict)
        self.assertIsInstance(status["network"], dict)
        
        # Validate individual fields
        self.assertIsInstance(status["uptime"], float)
        self.assertIsInstance(status["processCount"], int)
        self.assertIsInstance(status["threadCount"], int)
    
    def test_get_cpu_temperature(self):
        """Test CPU temperature retrieval"""
        temp = self.monitor.get_cpu_temperature()
        
        # Temperature can be None on systems without sensor access
        if temp is not None:
            self.assertIsInstance(temp, float)
            # Reasonable temperature range: -40 to 150 Celsius
            self.assertGreater(temp, -40)
            self.assertLess(temp, 150)
    
    def test_multiple_status_calls(self):
        """Test that multiple status calls work correctly"""
        status1 = self.monitor.get_status()
        time.sleep(0.1)
        status2 = self.monitor.get_status()
        
        # Both calls should succeed
        self.assertIsNotNone(status1)
        self.assertIsNotNone(status2)
        
        # Timestamps should be different
        self.assertNotEqual(status1["timestamp"], status2["timestamp"])
        
        # Core count should remain the same
        self.assertEqual(status1["cpu"]["coreCount"], status2["cpu"]["coreCount"])


if __name__ == "__main__":
    unittest.main()
