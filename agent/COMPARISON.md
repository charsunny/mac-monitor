# Mac Agent 实现对比

本项目提供了 Mac Monitor Agent 的两种实现：Swift 版本和 Python 版本。两者都提供了完整的系统监控功能，但各有特点。

## 功能对比

| 功能 | Swift Agent | Python Agent |
|-----|------------|--------------|
| **HTTP API 服务** | ✅ 支持 | ✅ 支持 |
| **系统监控** | | |
| - CPU 使用率 | ✅ 原生 API | ✅ psutil |
| - 内存使用 | ✅ 原生 API | ✅ psutil |
| - 磁盘使用 | ✅ 原生 API | ✅ psutil |
| - 网络流量 | ✅ 原生 API | ✅ psutil |
| - 进程数 | ✅ 支持 | ✅ 支持 |
| - 电池状态 | ✅ 支持 | ✅ 支持 |
| **Bonjour/mDNS** | ✅ NetService | ✅ zeroconf |
| **菜单栏客户端** | ✅ 内置 | ❌ 不支持 |
| **API 端点** | | |
| - GET /health | ✅ | ✅ |
| - GET /api/info | ✅ | ✅ |
| - GET /api/status | ✅ | ✅ |

## 性能对比

| 指标 | Swift Agent | Python Agent |
|-----|------------|--------------|
| **启动时间** | ⚡ 极快 (~100ms) | 🐌 较慢 (~1s) |
| **内存占用** | 💾 低 (~20-30 MB) | 💾 中等 (~50-80 MB) |
| **CPU 占用** | ⚡ 极低 | ⚡ 低 |
| **响应延迟** | ⚡ 极快 | 🐌 稍慢 |
| **二进制大小** | 📦 中等 (~55 MB) | 📦 小 (<1 MB + 依赖) |

## 使用场景建议

### 推荐使用 Swift Agent 的场景：
1. ✅ **长期运行**：需要 Agent 长期常驻系统
2. ✅ **菜单栏集成**：需要在菜单栏显示实时监控信息
3. ✅ **性能优先**：对性能和资源占用有较高要求
4. ✅ **原生体验**：希望获得原生 macOS 应用体验
5. ✅ **单一可执行文件**：不想安装 Python 和依赖包

### 推荐使用 Python Agent 的场景：
1. ✅ **快速开发**：需要快速修改和定制功能
2. ✅ **跨平台**：需要在 Linux/Windows 上也能运行
3. ✅ **临时测试**：只是临时测试或开发用
4. ✅ **已有 Python 环境**：系统已经安装了 Python
5. ✅ **易于调试**：Python 代码更容易调试和理解

## 技术栈对比

### Swift Agent
- **语言**: Swift 5.9+
- **Web 框架**: Hummingbird 2.0
- **系统监控**: IOKit, Darwin, Foundation
- **网络服务**: NetService (Bonjour)
- **GUI**: AppKit (NSStatusBar, NSMenu)
- **平台**: macOS 13.0+
- **构建工具**: Swift Package Manager

### Python Agent
- **语言**: Python 3.9+
- **Web 框架**: FastAPI
- **系统监控**: psutil
- **网络服务**: zeroconf
- **GUI**: 不支持
- **平台**: macOS, Linux, Windows
- **包管理**: pip

## API 兼容性

两个实现的 API 完全兼容，返回相同格式的 JSON 数据。你可以在不修改客户端代码的情况下切换使用。

### 示例响应格式（两者相同）

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
  "threadCount": 1432,
  "batteryLevel": 0.85,
  "isCharging": true
}
```

## 安装与运行

### Swift Agent

```bash
cd agent/swift-agent

# 开发模式
./run.sh run

# 或直接使用 Swift 命令
swift run

# 编译发布版本
./run.sh --release build
```

### Python Agent

```bash
cd agent/python-agent

# 安装依赖
pip install -r requirements.txt

# 运行
python3 main.py
```

## 总结

- **生产环境推荐**: Swift Agent（性能更好，菜单栏集成，原生体验）
- **开发/测试推荐**: Python Agent（快速部署，易于调试）
- **长期运行推荐**: Swift Agent（资源占用低，更稳定）
- **跨平台需求**: Python Agent（支持多平台）

两种实现都经过充分测试，可以根据具体需求选择使用。在生产环境中，我们推荐使用 Swift Agent 以获得最佳性能和用户体验。
