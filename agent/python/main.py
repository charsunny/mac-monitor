#!/usr/bin/env python3
import asyncio
import signal
from api_server import create_app
from bonjour_service import BonjourPublisher

async def main():
    print("Starting Mac Monitor Agent (Python)...")
    
    # 启动 Bonjour 服务
    bonjour = BonjourPublisher(port=8080)
    bonjour.start()
    
    # 启动 API 服务器
    app = create_app()
    
    import uvicorn
    config = uvicorn.Config(app, host="0.0.0.0", port=8080, log_level="info")
    server = uvicorn.Server(config)
    
    print("✅ Mac Monitor Agent started on http://0.0.0.0:8080")
    print("✅ Bonjour service published")
    
    try:
        await server.serve()
    except KeyboardInterrupt:
        print("\nShutting down...")
        bonjour.stop()

if __name__ == "__main__":
    asyncio.run(main())
