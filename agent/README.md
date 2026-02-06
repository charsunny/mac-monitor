# Mac Monitor Agent

这个目录包含 Mac Monitor 的监控 Agent 服务端实现。提供两种实现方式：Swift 和 Python。

## 目录结构

```
agent/
├── mac/        # Swift 实现（macOS 专属，推荐生产环境）
│   ├── Package.swift
│   └── Sources/
└── python/     # Python 实现（跨平台，推荐开发测试）
    ├── main.py
    ├── api_server.py
    └── requirements.txt
```

## Swift Agent (mac/)

使用 Swift 语言开发的原生 macOS 监控 Agent，性能优异，资源占用低。

### 特性
- ✅ 原生 macOS API（IOKit, Darwin）
- ✅ Hummingbird 2.0 Web 框架
- ✅ 菜单栏客户端（实时监控）
- ✅ Bonjour 服务发布
- ✅ 极低资源占用（~20-30 MB）

### 快速开始

```bash
cd mac
swift build
swift run
```

详细说明请参考 [Swift Agent README](mac/README.md)。

## Python Agent (python/)

使用 Python 开发的跨平台监控 Agent，易于开发和调试。

### 特性
- ✅ FastAPI Web 框架
- ✅ psutil 系统监控
- ✅ zeroconf Bonjour 服务
- ✅ 跨平台（macOS, Linux, Windows）
- ✅ 完整的测试套件（34个测试）

### 快速开始

```bash
cd python
pip install -r requirements.txt
python3 main.py
```

详细说明请参考 [Python Agent README](python/README.md)。

## Agent 对比

详细的功能和性能对比请参考 [Agent 对比文档](COMPARISON.md)。

### 选择建议

- **推荐 Swift Agent**：生产环境、长期运行、菜单栏集成、性能优先
- **推荐 Python Agent**：开发测试、跨平台需求、快速定制、易于调试

## API 文档

两种实现提供完全相同的 API 端点：

- `GET /api/status` - 获取系统实时状态
- `GET /api/info` - 获取系统基本信息
- `GET /health` - 健康检查

API 完全兼容，客户端可以无缝切换使用。

## 自动服务发现

两种 Agent 都支持 Bonjour/mDNS 自动服务发现，客户端应用可以自动发现局域网内的监控 Agent。

服务类型：`_macmonitor._tcp`
默认端口：`8080`
