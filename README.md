# Mac Monitor 🖥️📱

一个用于监控局域网 Mac 电脑运行状态的 iPhone Dashboard 应用系统。

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Platform](https://img.shields.io/badge/platform-iOS%2016%2B%20%7C%20macOS%2013%2B-lightgrey.svg)

## 项目简介

Mac Monitor 是一个完整的系统监控解决方案，包含：
- **iPhone Dashboard App** - 横屏全屏监控仪表盘
- **Mac Agent** - 轻量级系统监控服务（Swift & Python 双实现）

通过 Bonjour/mDNS 自动发现局域网内的 Mac 设备，实时显示系统资源使用情况。

## 功能特性

### 📱 iPhone Dashboard
- ✅ 横屏单页面设计，适合放置在桌面常亮显示
- ✅ 6 个核心监控卡片（CPU、内存、磁盘、网络、温度、进程）
- ✅ 自动设备发现（Bonjour）
- ✅ 设备快速切换
- ✅ 告警系统（CPU/内存超阈值）
- ✅ 实时自动刷新（5秒间隔）
- ✅ 支持 Dark Mode

### 🖥️ Mac Agent
- ✅ REST API 服务
- ✅ 系统资源监控（CPU、内存、磁盘、网络）
- ✅ Bonjour 服务自动发布
- ✅ 跨平台（提供 Swift 和 Python 两种实现）
- ✅ 轻量级，低资源占用

## 项目结构

```
mac-monitor/
├── iOS/              # iPhone Dashboard 应用
│   └── MacMonitor/   # SwiftUI 项目
├── agent/            # Mac 监控 Agent
│   ├── swift-agent/  # Swift 实现（推荐）
│   └── python-agent/ # Python 实现
└── docs/             # 文档
```

## 快速开始

### 1. 启动 Mac Agent

#### 方式 A: Python 版本（推荐快速测试）

```bash
cd agent/python-agent
pip install -r requirements.txt
python3 main.py
```

#### 方式 B: Swift 版本

```bash
cd agent/swift-agent
swift build
swift run
```

Agent 启动后会自动在局域网广播服务。

### 2. 运行 iOS App

1. 使用 Xcode 打开 `iOS/MacMonitor/MacMonitor.xcodeproj`
2. 选择目标设备（iPhone 或模拟器）
3. 点击运行（⌘R）

**注意**: 需要授予本地网络访问权限才能发现设备。

## 系统架构

```
┌─────────────────┐         ┌──────────────────┐         ┌─────────────────┐
│                 │         │                  │         │                 │
│  iPhone App     │◄───────►│  Mac Agent       │◄───────►│  Mac System     │
│  (Dashboard)    │   WiFi  │  (监控服务)       │         │  (被监控电脑)    │
│                 │         │                  │         │                 │
└─────────────────┘         └──────────────────┘         └─────────────────┘
     Bonjour 发现              HTTP REST API               系统调用
     实时监控数据                JSON 数据传输
```

## 技术栈

### iPhone App
- SwiftUI & Combine
- Network Framework (Bonjour)
- MVVM 架构
- iOS 16.0+

### Mac Agent
**Swift 版本:**
- Hummingbird Web Framework
- Foundation & IOKit
- macOS 13.0+

**Python 版本:**
- FastAPI
- psutil
- zeroconf
- Python 3.9+

## API 文档

### 端点

- `GET /api/status` - 获取系统实时状态
- `GET /api/info` - 获取系统基本信息
- `GET /health` - 健康检查

### 示例响应

```json
{
  "timestamp": "2026-02-06T12:00:00Z",
  "cpu": {
    "usage": 0.45,
    "coreCount": 8,
    "frequency": 3.2
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
    "bytesIn": 12500000,
    "bytesOut": 2300000
  },
  "uptime": 259200,
  "processCount": 245,
  "threadCount": 1432
}
```

## 开发路线图

### Phase 1: MVP ✅ (当前)
- [x] 基础 UI 框架
- [x] Python Agent 实现
- [x] Bonjour 设备发现
- [x] 核心监控功能

### Phase 2: 完善功能 🚧
- [ ] Swift Agent 完整实现
- [ ] 历史数据图表
- [ ] 进程列表查看
- [ ] 本地通知推送

### Phase 3: 高级功能 📋
- [ ] WebSocket 实时推送
- [ ] 多设备对比视图
- [ ] Widget 支持
- [ ] 远程控制功能

## 截图

（占位 - 待添加实际截图）

## 贡献指南

欢迎贡献代码！请参考以下步骤：

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

## 作者

[@charsunny](https://github.com/charsunny)

## 致谢

- [Hummingbird](https://github.com/hummingbird-project/hummingbird) - Swift Web 框架
- [FastAPI](https://fastapi.tiangolo.com/) - Python Web 框架
- [psutil](https://github.com/giampaolo/psutil) - 系统监控库

---

⭐️ 如果觉得有用，请给个 Star！
