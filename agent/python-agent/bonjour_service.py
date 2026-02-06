from zeroconf import ServiceInfo, Zeroconf
import socket

class BonjourPublisher:
    def __init__(self, port):
        self.port = port
        self.zeroconf = None
        self.info = None
    
    def start(self):
        """启动 Bonjour 服务发布 / Start Bonjour service publishing"""
        try:
            self.zeroconf = Zeroconf()
            
            hostname = socket.gethostname()
            
            # 获取本机 IP 地址 / Get local IP address
            s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            try:
                s.connect(("8.8.8.8", 80))
                ip_address = s.getsockname()[0]
            except Exception:
                ip_address = "127.0.0.1"
            finally:
                s.close()
            
            # 注册服务
            self.info = ServiceInfo(
                "_macmonitor._tcp.local.",
                f"{hostname}._macmonitor._tcp.local.",
                addresses=[socket.inet_aton(ip_address)],
                port=self.port,
                properties={
                    "version": "1.0",
                    "platform": "python"
                },
                server=f"{hostname}.local."
            )
            
            self.zeroconf.register_service(self.info)
            print(f"✅ Bonjour service published: {hostname} at {ip_address}:{self.port}")
        except Exception as e:
            print(f"❌ Failed to publish Bonjour service: {e}")
    
    def stop(self):
        """停止 Bonjour 服务 / Stop Bonjour service"""
        if self.zeroconf and self.info:
            self.zeroconf.unregister_service(self.info)
            self.zeroconf.close()
            print("Bonjour service stopped")
