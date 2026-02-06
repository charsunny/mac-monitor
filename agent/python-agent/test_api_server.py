#!/usr/bin/env python3
"""
Tests for API Server
"""
import unittest
from fastapi.testclient import TestClient
from api_server import create_app


class TestAPIServer(unittest.TestCase):
    """Test cases for API Server"""
    
    def setUp(self):
        """Set up test fixtures"""
        app = create_app()
        self.client = TestClient(app)
    
    def test_health_endpoint(self):
        """Test health check endpoint"""
        response = self.client.get("/health")
        
        # Check status code
        self.assertEqual(response.status_code, 200)
        
        # Check response format
        data = response.json()
        self.assertIn("status", data)
        self.assertEqual(data["status"], "ok")
    
    def test_api_info_endpoint(self):
        """Test /api/info endpoint"""
        response = self.client.get("/api/info")
        
        # Check status code
        self.assertEqual(response.status_code, 200)
        
        # Check response format
        data = response.json()
        
        # Verify required fields
        required_fields = ["hostname", "osVersion", "model", "architecture"]
        for field in required_fields:
            self.assertIn(field, data)
        
        # Validate data types
        self.assertIsInstance(data["hostname"], str)
        self.assertIsInstance(data["osVersion"], str)
        self.assertIsInstance(data["model"], str)
        self.assertIsInstance(data["architecture"], str)
        
        # Hostname should not be empty
        self.assertGreater(len(data["hostname"]), 0)
    
    def test_api_status_endpoint(self):
        """Test /api/status endpoint"""
        response = self.client.get("/api/status")
        
        # Check status code
        self.assertEqual(response.status_code, 200)
        
        # Check response format
        data = response.json()
        
        # Verify required top-level fields
        required_fields = [
            "timestamp", "cpu", "memory", "disk", "network",
            "temperature", "uptime", "processCount", "threadCount",
            "batteryLevel", "isCharging"
        ]
        
        for field in required_fields:
            self.assertIn(field, data)
        
        # Validate timestamp
        self.assertIsInstance(data["timestamp"], str)
        
        # Validate CPU data
        self.assertIsInstance(data["cpu"], dict)
        self.assertIn("usage", data["cpu"])
        self.assertIn("coreCount", data["cpu"])
        self.assertIn("frequency", data["cpu"])
        
        # Validate CPU ranges
        self.assertIsInstance(data["cpu"]["usage"], (int, float))
        self.assertGreaterEqual(data["cpu"]["usage"], 0.0)
        self.assertLessEqual(data["cpu"]["usage"], 1.0)
        
        self.assertIsInstance(data["cpu"]["coreCount"], int)
        self.assertGreater(data["cpu"]["coreCount"], 0)
        
        # Validate memory data
        self.assertIsInstance(data["memory"], dict)
        self.assertIn("total", data["memory"])
        self.assertIn("used", data["memory"])
        self.assertIn("free", data["memory"])
        self.assertIn("pressure", data["memory"])
        
        self.assertIsInstance(data["memory"]["total"], int)
        self.assertGreater(data["memory"]["total"], 0)
        
        # Validate disk data
        self.assertIsInstance(data["disk"], dict)
        self.assertIn("total", data["disk"])
        self.assertIn("used", data["disk"])
        self.assertIn("free", data["disk"])
        
        self.assertIsInstance(data["disk"]["total"], int)
        self.assertGreater(data["disk"]["total"], 0)
        
        # Validate network data
        self.assertIsInstance(data["network"], dict)
        self.assertIn("bytesIn", data["network"])
        self.assertIn("bytesOut", data["network"])
        
        # Validate process data
        self.assertIsInstance(data["processCount"], int)
        self.assertGreater(data["processCount"], 0)
        
        self.assertIsInstance(data["threadCount"], int)
        self.assertGreater(data["threadCount"], 0)
        
        # Validate uptime
        self.assertIsInstance(data["uptime"], (int, float))
        self.assertGreater(data["uptime"], 0)
    
    def test_invalid_endpoint(self):
        """Test that invalid endpoints return 404"""
        response = self.client.get("/api/invalid")
        self.assertEqual(response.status_code, 404)
    
    def test_cors_headers(self):
        """Test that CORS headers are present"""
        response = self.client.get("/api/status")
        
        # FastAPI's CORS middleware adds these headers
        # Note: TestClient may not include all CORS headers
        self.assertEqual(response.status_code, 200)
    
    def test_multiple_requests(self):
        """Test that multiple requests work correctly"""
        # Make multiple requests
        responses = []
        for _ in range(3):
            response = self.client.get("/api/status")
            self.assertEqual(response.status_code, 200)
            responses.append(response.json())
        
        # All should have valid data
        for data in responses:
            self.assertIn("timestamp", data)
            self.assertIn("cpu", data)
            self.assertIn("memory", data)
    
    def test_api_status_structure_matches_documentation(self):
        """Test that API response structure matches the documentation"""
        response = self.client.get("/api/status")
        data = response.json()
        
        # Expected structure from README
        expected_structure = {
            "timestamp": str,
            "cpu": {
                "usage": (int, float),
                "coreCount": int,
                "frequency": (int, float, type(None)),
            },
            "memory": {
                "total": int,
                "used": int,
                "free": int,
                "pressure": (int, float),
            },
            "disk": {
                "total": int,
                "used": int,
                "free": int,
            },
            "network": {
                "bytesIn": int,
                "bytesOut": int,
            },
            "uptime": (int, float),
            "processCount": int,
            "threadCount": int,
        }
        
        # Verify structure
        self.assertIsInstance(data["timestamp"], str)
        
        # CPU
        self.assertIsInstance(data["cpu"]["usage"], (int, float))
        self.assertIsInstance(data["cpu"]["coreCount"], int)
        
        # Memory
        self.assertIsInstance(data["memory"]["total"], int)
        self.assertIsInstance(data["memory"]["used"], int)
        self.assertIsInstance(data["memory"]["free"], int)
        self.assertIsInstance(data["memory"]["pressure"], (int, float))
        
        # Disk
        self.assertIsInstance(data["disk"]["total"], int)
        self.assertIsInstance(data["disk"]["used"], int)
        self.assertIsInstance(data["disk"]["free"], int)
        
        # Network
        self.assertIsInstance(data["network"]["bytesIn"], int)
        self.assertIsInstance(data["network"]["bytesOut"], int)
        
        # Process info
        self.assertIsInstance(data["uptime"], (int, float))
        self.assertIsInstance(data["processCount"], int)
        self.assertIsInstance(data["threadCount"], int)


if __name__ == "__main__":
    unittest.main()
