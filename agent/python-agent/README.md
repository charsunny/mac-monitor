# Mac Monitor Agent (Python)

Python 实现的 Mac 系统监控 Agent。

## 功能特性

- ✅ 系统资源监控（CPU、内存、磁盘、网络）
- ✅ REST API 接口
- ✅ Bonjour/mDNS 服务发布
- ✅ 跨平台支持（macOS、Linux）

## 安装依赖

```bash
pip install -r requirements.txt
```

## 运行

```bash
python3 main.py
```

Agent 将在 `http://0.0.0.0:8080` 启动并自动通过 Bonjour 广播服务。

## API 端点

- `GET /api/status` - 获取系统实时状态
- `GET /api/info` - 获取系统基本信息
- `GET /health` - 健康检查

## 示例请求

```bash
curl http://localhost:8080/api/status
```

## 作为后台服务运行

### macOS (使用 launchd)

创建文件 `~/Library/LaunchAgents/com.macmonitor.agent.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.macmonitor.agent</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/python3</string>
        <string>/path/to/main.py</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
```

加载服务：
```bash
launchctl load ~/Library/LaunchAgents/com.macmonitor.agent.plist
```

## 开发说明

- `main.py` - 程序入口
- `system_monitor.py` - 系统监控核心逻辑
- `api_server.py` - FastAPI 服务器
- `bonjour_service.py` - Bonjour/mDNS 服务发布

## 许可证

MIT
