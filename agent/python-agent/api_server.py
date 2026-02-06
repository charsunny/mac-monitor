from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from system_monitor import SystemMonitor
import platform

def create_app():
    app = FastAPI(
        title="Mac Monitor Agent",
        description="System monitoring agent for Mac computers",
        version="1.0.0"
    )
    
    monitor = SystemMonitor()
    
    # 允许跨域
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_methods=["*"],
        allow_headers=["*"],
    )
    
    @app.get("/api/status")
    async def get_status():
        """获取系统实时状态"""
        return monitor.get_status()
    
    @app.get("/api/info")
    async def get_info():
        """获取系统基本信息"""
        uname = platform.uname()
        return {
            "hostname": uname.node,
            "osVersion": f"{uname.system} {uname.release}",
            "model": uname.machine,
            "architecture": platform.machine()
        }
    
    @app.get("/health")
    async def health_check():
        """健康检查"""
        return {"status": "ok"}
    
    return app