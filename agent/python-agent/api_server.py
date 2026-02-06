from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from system_monitor import SystemMonitor
import platform
import os

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
    
    # 获取 dashboard 目录路径
    current_dir = os.path.dirname(os.path.abspath(__file__))
    dashboard_dir = os.path.join(os.path.dirname(current_dir), 'dashboard')
    
    # 如果 dashboard 目录不存在（比如在 agent/python-agent 目录下运行），尝试上一级目录
    if not os.path.exists(dashboard_dir):
        dashboard_dir = os.path.join(os.path.dirname(os.path.dirname(current_dir)), 'dashboard')
    
    # 挂载静态文件目录
    if os.path.exists(dashboard_dir):
        app.mount("/dashboard", StaticFiles(directory=dashboard_dir), name="dashboard")
        
        @app.get("/")
        async def serve_dashboard():
            """提供 Dashboard 主页"""
            index_path = os.path.join(dashboard_dir, "index.html")
            if os.path.exists(index_path):
                return FileResponse(index_path)
            return {"message": "Dashboard not found"}
    else:
        print(f"⚠️  Warning: Dashboard directory not found at {dashboard_dir}")
    
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