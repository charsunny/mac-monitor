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

## 测试

项目包含完整的单元测试，覆盖所有核心功能。

### 运行所有测试

```bash
python3 run_tests.py
```

或者使用 unittest：

```bash
python3 -m unittest discover -s . -p "test_*.py" -v
```

### 运行单个测试文件

```bash
# 测试系统监控
python3 -m unittest test_system_monitor.py -v

# 测试 API 服务器
python3 -m unittest test_api_server.py -v

# 测试 Bonjour 服务
python3 -m unittest test_bonjour_service.py -v
```

### 测试覆盖

- **test_system_monitor.py** - 系统监控核心功能测试
  - CPU、内存、磁盘、网络信息获取
  - 进程和线程统计
  - 电池信息（如适用）
  - 完整状态数据结构验证

- **test_api_server.py** - API 服务器测试
  - 所有 REST API 端点（/health, /api/info, /api/status）
  - 响应格式验证
  - 数据结构与文档一致性检查
  - CORS 支持

- **test_bonjour_service.py** - Bonjour/mDNS 服务测试
  - 服务发布和注销
  - 多实例支持
  - 服务属性验证

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
