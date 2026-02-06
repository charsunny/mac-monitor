# Mac Monitor Agent (Swift 实现)

一个用 Swift 编写的 macOS 系统监控 Agent，同时提供 HTTP API 服务和菜单栏客户端。

## 功能特性

### 🖥️ HTTP API 服务器
- ✅ REST API 端点
  - `GET /health` - 健康检查
  - `GET /api/info` - 系统基本信息
  - `GET /api/status` - 实时系统状态
- ✅ 使用 Hummingbird 轻量级 Web 框架
- ✅ 支持跨域访问 (CORS)
- ✅ 默认端口 8080

### 📊 系统监控功能
- CPU 使用率和核心数
- 内存使用情况和压力
- 磁盘空间使用
- 网络流量速率
- 系统运行时间
- 进程和线程数
- 电池状态（笔记本电脑）

### 📡 Bonjour/mDNS 服务
- 自动在局域网广播服务
- 服务类型：`_macmonitor._tcp.`
- 方便 iPhone Dashboard 自动发现

### 🎯 菜单栏客户端
- ✅ 常驻系统菜单栏
- ✅ 实时显示系统监控信息
- ✅ 自动刷新（5秒间隔）
- ✅ 显示以下信息：
  - CPU 使用率
  - 内存使用
  - 磁盘使用
  - 网络流量
  - 系统运行时间
  - 进程数
  - 电池状态
- ✅ 一键退出

## 系统要求

- macOS 13.0 (Ventura) 或更高版本
- Swift 5.9 或更高版本
- Xcode 15 或更高版本（开发需要）

## 安装与运行

### 方式 1: 使用 Swift Package Manager（开发）

```bash
cd agent/mac
swift build
swift run
```

### 方式 2: 编译发布版本

```bash
cd agent/mac
swift build -c release
.build/release/MacMonitorAgent
```

编译后的可执行文件位于 `.build/release/MacMonitorAgent`，可以复制到任意位置运行。

### 方式 3: 使用 Xcode

```bash
cd agent/mac
open Package.swift
```

在 Xcode 中点击运行按钮（⌘R）。

## 使用说明

### 启动 Agent

运行后会自动启动：
1. HTTP API 服务器（端口 8080）
2. Bonjour 服务（自动发现）
3. 菜单栏应用（🖥️ 图标）

```
🚀 Starting Mac Monitor Agent (Swift)...
📡 Publishing Bonjour service: YourMacName on port 8080
✅ Bonjour service published successfully: YourMacName
✅ HTTP API Server starting on http://0.0.0.0:8080
   Endpoints:
   - GET /health
   - GET /api/info
   - GET /api/status
✅ Menu bar app started
```

### 查看监控信息

**菜单栏方式：**
1. 点击菜单栏上的 🖥️ 图标
2. 查看实时系统信息
3. 信息每 5 秒自动更新

**API 方式：**

```bash
# 健康检查
curl http://localhost:8080/health

# 获取系统信息
curl http://localhost:8080/api/info

# 获取实时状态
curl http://localhost:8080/api/status
```

### 停止 Agent

- 从菜单栏点击"Quit"
- 或按 `Ctrl+C` (终端运行时)

## API 响应示例

### GET /api/status

```json
{
  "timestamp": "2026-02-06T12:00:00Z",
  "cpu": {
    "usage": 0.45,
    "coreCount": 8,
    "frequency": null,
    "temperature": null
  },
  "memory": {
    "total": 17179869184,
    "used": 8589934592,
    "free": 8589934592,
    "pressure": 0.51
  },
  "disk": {
    "total": 500000000000,
    "used": 450000000000,
    "free": 50000000000
  },
  "network": {
    "bytesIn": 125000,
    "bytesOut": 23000,
    "packetsIn": 1234567,
    "packetsOut": 987654
  },
  "temperature": null,
  "uptime": 259200,
  "processCount": 245,
  "threadCount": 0,
  "batteryLevel": 0.85,
  "isCharging": true
}
```

### GET /api/info

```json
{
  "hostname": "MacBook-Pro",
  "osVersion": "Version 14.0 (Build 23A344)",
  "model": "MacBookPro18,3",
  "architecture": "arm64"
}
```

### GET /health

```json
{
  "status": "ok"
}
```

## 架构设计

```
MacMonitorAgent
├── SystemMonitor      # 系统监控核心
│   ├── CPU 监控
│   ├── 内存监控
│   ├── 磁盘监控
│   ├── 网络监控
│   └── 电池监控
├── APIServer          # HTTP API 服务
│   └── Hummingbird 框架
├── BonjourPublisher   # mDNS 服务发布
│   └── NetService
└── MenuBarApp         # 菜单栏客户端
    └── NSStatusBar
```

## 技术栈

- **Web 框架**: [Hummingbird](https://github.com/hummingbird-project/hummingbird) 2.0+
- **系统监控**: IOKit, Darwin, Foundation
- **网络服务**: NetService (Bonjour)
- **GUI**: AppKit (NSStatusBar, NSMenu)
- **语言**: Swift 5.9+
- **平台**: macOS 13.0+

## 与 Python Agent 的对比

| 特性 | Swift Agent | Python Agent |
|-----|------------|--------------|
| 性能 | ⚡ 更快，原生编译 | 适中，解释执行 |
| 内存占用 | 💾 更低 | 较高 |
| 依赖 | 无需额外安装 | 需要 Python 和库 |
| 菜单栏客户端 | ✅ 内置 | ❌ 不支持 |
| 跨平台 | ❌ 仅 macOS | ✅ 支持多平台 |
| 开发难度 | 中等 | 简单 |

## 开发指南

### 项目结构

```
mac/
├── Package.swift              # Swift 包配置
├── Sources/
│   └── MacMonitorAgent/
│       ├── MacMonitorAgent.swift    # 主入口
│       ├── SystemMonitor.swift      # 系统监控
│       ├── APIServer.swift          # HTTP API
│       ├── BonjourPublisher.swift   # Bonjour 服务
│       └── MenuBarApp.swift         # 菜单栏应用
└── README.md
```

### 添加新功能

1. 在 `SystemMonitor.swift` 中添加监控方法
2. 在 `APIServer.swift` 中添加 API 端点
3. 在 `MenuBarApp.swift` 中添加菜单显示

### 调试

```bash
# 开发模式运行（带调试符号）
swift run

# 查看详细日志
swift run 2>&1 | tee agent.log
```

## 常见问题

### Q: 菜单栏图标不显示？
A: 确保应用有访问系统菜单栏的权限。某些安全设置可能阻止应用创建菜单栏项。

### Q: Bonjour 服务无法被发现？
A: 检查防火墙设置，确保允许端口 8080 的入站连接。同时确保设备在同一局域网内。

### Q: 网络速率显示为 0？
A: 首次调用时需要建立基线，等待 5 秒后会显示正确的速率。

### Q: 如何设置开机自启动？
A: 可以使用 launchd 或将应用添加到"系统偏好设置" > "用户与群组" > "登录项"。

## 许可证

MIT License - 详见项目根目录的 LICENSE 文件

## 贡献

欢迎提交 Issue 和 Pull Request！

## 相关链接

- [Python Agent 实现](../python-agent/)
- [iPhone Dashboard 应用](../../iOS/)
- [项目主页](../../README.md)
