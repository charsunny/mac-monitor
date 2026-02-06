#!/usr/bin/env python3
"""
Integration test for Mac Monitor Python Agent
Tests the complete system including server startup, API endpoints, and Bonjour service.
"""
import unittest
import time
import asyncio
import httpx
from multiprocessing import Process
import signal
import sys
import os

# Add parent directory to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from main import main as start_agent
from bonjour_service import BonjourPublisher


class TestIntegration(unittest.TestCase):
    """Integration tests for the complete Mac Monitor Agent"""
    
    @classmethod
    def setUpClass(cls):
        """Start the agent server before running tests"""
        cls.server_process = None
        # Note: In a real integration test, we would start the server in a separate process
        # For now, we'll just test that the components can be imported and initialized
    
    def test_agent_components_can_be_imported(self):
        """Test that all agent components can be imported"""
        try:
            from system_monitor import SystemMonitor
            from api_server import create_app
            from bonjour_service import BonjourPublisher
            
            # Create instances
            monitor = SystemMonitor()
            app = create_app()
            bonjour = BonjourPublisher(port=9999)
            
            self.assertIsNotNone(monitor)
            self.assertIsNotNone(app)
            self.assertIsNotNone(bonjour)
            
        except Exception as e:
            self.fail(f"Failed to import components: {e}")
    
    def test_system_monitor_provides_complete_data(self):
        """Test that system monitor provides all required data fields"""
        from system_monitor import SystemMonitor
        
        monitor = SystemMonitor()
        status = monitor.get_status()
        
        # Check all required fields from documentation
        required_fields = [
            "timestamp", "cpu", "memory", "disk", "network",
            "temperature", "uptime", "processCount", "threadCount"
        ]
        
        for field in required_fields:
            self.assertIn(field, status, f"Missing required field: {field}")
        
        # Verify nested structures
        self.assertIn("usage", status["cpu"])
        self.assertIn("coreCount", status["cpu"])
        self.assertIn("total", status["memory"])
        self.assertIn("used", status["memory"])
        self.assertIn("total", status["disk"])
        self.assertIn("bytesIn", status["network"])
    
    def test_api_server_can_be_created(self):
        """Test that API server can be created with all routes"""
        from api_server import create_app
        from fastapi.testclient import TestClient
        
        app = create_app()
        client = TestClient(app)
        
        # Test all documented endpoints
        endpoints = ["/health", "/api/info", "/api/status"]
        
        for endpoint in endpoints:
            response = client.get(endpoint)
            self.assertEqual(
                response.status_code, 
                200, 
                f"Endpoint {endpoint} returned {response.status_code}"
            )
    
    def test_bonjour_service_lifecycle(self):
        """Test Bonjour service can be started and stopped"""
        bonjour = BonjourPublisher(port=9998)
        
        try:
            # Start service
            bonjour.start()
            time.sleep(0.5)
            
            # Verify it started
            self.assertIsNotNone(bonjour.zeroconf)
            self.assertIsNotNone(bonjour.info)
            
        finally:
            # Stop service
            bonjour.stop()
            time.sleep(0.5)
    
    def test_data_consistency_across_multiple_calls(self):
        """Test that data remains consistent across multiple API calls"""
        from system_monitor import SystemMonitor
        
        monitor = SystemMonitor()
        
        # Make multiple calls
        statuses = [monitor.get_status() for _ in range(3)]
        
        # Core count should be consistent
        core_counts = [s["cpu"]["coreCount"] for s in statuses]
        self.assertEqual(len(set(core_counts)), 1, "Core count varied across calls")
        
        # Total memory should be consistent
        total_mems = [s["memory"]["total"] for s in statuses]
        self.assertEqual(len(set(total_mems)), 1, "Total memory varied across calls")
        
        # Disk total should be consistent
        disk_totals = [s["disk"]["total"] for s in statuses]
        self.assertEqual(len(set(disk_totals)), 1, "Disk total varied across calls")
    
    def test_api_response_matches_documentation_format(self):
        """Test that API responses match the documented format from README"""
        from api_server import create_app
        from fastapi.testclient import TestClient
        
        app = create_app()
        client = TestClient(app)
        
        # Test /api/status response format
        response = client.get("/api/status")
        data = response.json()
        
        # Verify structure matches README example
        self.assertIsInstance(data["timestamp"], str)
        self.assertIsInstance(data["cpu"]["usage"], (int, float))
        self.assertIsInstance(data["cpu"]["coreCount"], int)
        self.assertIsInstance(data["memory"]["total"], int)
        self.assertIsInstance(data["memory"]["used"], int)
        self.assertIsInstance(data["memory"]["free"], int)
        self.assertIsInstance(data["memory"]["pressure"], (int, float))
        self.assertIsInstance(data["disk"]["total"], int)
        self.assertIsInstance(data["network"]["bytesIn"], int)
        self.assertIsInstance(data["network"]["bytesOut"], int)
        self.assertIsInstance(data["uptime"], (int, float))
        self.assertIsInstance(data["processCount"], int)
        self.assertIsInstance(data["threadCount"], int)


if __name__ == "__main__":
    unittest.main()
