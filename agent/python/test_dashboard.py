import unittest
import os
from fastapi.testclient import TestClient
from api_server import create_app


class TestDashboard(unittest.TestCase):
    """Test suite for Dashboard integration"""
    
    def setUp(self):
        """Set up test client"""
        self.app = create_app()
        self.client = TestClient(self.app)
    
    def test_dashboard_root_accessible(self):
        """Test that dashboard root page is accessible"""
        response = self.client.get("/")
        self.assertEqual(response.status_code, 200)
        self.assertIn("text/html", response.headers["content-type"])
        self.assertIn("Mac Monitor Dashboard", response.text)
    
    def test_dashboard_html_contains_required_elements(self):
        """Test that dashboard HTML contains all required elements"""
        response = self.client.get("/")
        html = response.text
        
        # Check for 6 monitoring cards
        self.assertIn("💻 CPU", html)
        self.assertIn("🧠 内存", html)
        self.assertIn("💾 磁盘", html)
        self.assertIn("🌐 网络", html)
        self.assertIn("🌡️ 温度", html)
        self.assertIn("⚙️ 进程", html)
        
        # Check for device selector
        self.assertIn("deviceSelector", html)
        
        # Check for dark mode toggle
        self.assertIn("darkModeToggle", html)
        
        # Check for auto-refresh indicator
        self.assertIn("自动刷新", html)
    
    def test_dashboard_css_accessible(self):
        """Test that dashboard CSS file is accessible"""
        response = self.client.get("/dashboard/styles.css")
        self.assertEqual(response.status_code, 200)
        self.assertIn("css", response.headers["content-type"].lower())
        self.assertIn("dark-mode", response.text)
    
    def test_dashboard_js_accessible(self):
        """Test that dashboard JavaScript file is accessible"""
        response = self.client.get("/dashboard/app.js")
        self.assertEqual(response.status_code, 200)
        self.assertIn("javascript", response.headers["content-type"].lower())
        self.assertIn("MacMonitorDashboard", response.text)
    
    def test_dashboard_integrates_with_api(self):
        """Test that dashboard can access API endpoints"""
        # Test that API endpoints are accessible
        status_response = self.client.get("/api/status")
        self.assertEqual(status_response.status_code, 200)
        
        info_response = self.client.get("/api/info")
        self.assertEqual(info_response.status_code, 200)
        
        # Dashboard should be able to fetch this data
        dashboard_response = self.client.get("/")
        self.assertEqual(dashboard_response.status_code, 200)


if __name__ == '__main__':
    unittest.main()
