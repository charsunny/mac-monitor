#!/usr/bin/env python3
"""
Tests for Bonjour Service
"""
import unittest
import time
from bonjour_service import BonjourPublisher


class TestBonjourService(unittest.TestCase):
    """Test cases for Bonjour Service"""
    
    def test_bonjour_initialization(self):
        """Test Bonjour service initialization"""
        bonjour = BonjourPublisher(port=8080)
        
        # Check that object is created
        self.assertIsNotNone(bonjour)
        self.assertEqual(bonjour.port, 8080)
        self.assertIsNone(bonjour.zeroconf)
        self.assertIsNone(bonjour.info)
    
    def test_bonjour_start_stop(self):
        """Test starting and stopping Bonjour service"""
        bonjour = BonjourPublisher(port=8081)
        
        try:
            # Start service
            bonjour.start()
            
            # Give it time to initialize
            time.sleep(0.5)
            
            # Check that service is started
            self.assertIsNotNone(bonjour.zeroconf)
            self.assertIsNotNone(bonjour.info)
            
            # Verify service info
            self.assertEqual(bonjour.info.port, 8081)
            self.assertEqual(bonjour.info.type, "_macmonitor._tcp.local.")
            
            # Check properties
            self.assertIn(b"version", bonjour.info.properties)
            self.assertIn(b"platform", bonjour.info.properties)
            
        finally:
            # Stop service
            bonjour.stop()
            
            # Give it time to cleanup
            time.sleep(0.5)
    
    def test_bonjour_custom_port(self):
        """Test Bonjour service with custom port"""
        custom_port = 9090
        bonjour = BonjourPublisher(port=custom_port)
        
        try:
            bonjour.start()
            time.sleep(0.5)
            
            # Verify port
            self.assertEqual(bonjour.info.port, custom_port)
            
        finally:
            bonjour.stop()
            time.sleep(0.5)
    
    def test_bonjour_properties(self):
        """Test Bonjour service properties"""
        bonjour = BonjourPublisher(port=8082)
        
        try:
            bonjour.start()
            time.sleep(0.5)
            
            # Check properties
            properties = bonjour.info.properties
            self.assertIn(b"version", properties)
            self.assertIn(b"platform", properties)
            
            # Verify values
            self.assertEqual(properties[b"version"], b"1.0")
            self.assertEqual(properties[b"platform"], b"python")
            
        finally:
            bonjour.stop()
            time.sleep(0.5)
    
    def test_bonjour_multiple_instances(self):
        """Test that multiple Bonjour instances can be created on different ports"""
        bonjour1 = BonjourPublisher(port=8083)
        bonjour2 = BonjourPublisher(port=8084)
        
        try:
            bonjour1.start()
            time.sleep(0.3)
            bonjour2.start()
            time.sleep(0.3)
            
            # Both should be running
            self.assertIsNotNone(bonjour1.zeroconf)
            self.assertIsNotNone(bonjour2.zeroconf)
            
            # Ports should be different
            self.assertEqual(bonjour1.info.port, 8083)
            self.assertEqual(bonjour2.info.port, 8084)
            
        finally:
            bonjour1.stop()
            bonjour2.stop()
            time.sleep(0.5)
    
    def test_bonjour_stop_without_start(self):
        """Test that stopping without starting doesn't crash"""
        bonjour = BonjourPublisher(port=8085)
        
        # This should not raise an exception
        try:
            bonjour.stop()
        except Exception as e:
            self.fail(f"stop() raised exception: {e}")


if __name__ == "__main__":
    unittest.main()
