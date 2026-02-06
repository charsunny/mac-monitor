# Mac Monitor 🖥️📱

一个用于监控局域网 Mac 电脑运行状态的 iPhone Dashboard 应用系统。

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Platform](https://img.shields.io/badge/platform-iOS%2016%2B%20%7C%20macOS%2013%2B-lightgrey.svg)

## 项目简介

Mac Monitor 是一个完整的系统监控解决方案，包含：
- **原生 iOS App** - SwiftUI 构建的原生应用（推荐）
- **Web Dashboard** - 可在浏览器中使用的响应式网页版
- **Mac Agent** - 轻量级系统监控服务（Python 实现）

通过 Bonjour/mDNS 自动发现局域网内的 Mac 设备，实时显示系统资源使用情况。

## 功能特性

### 📱 iPhone App（原生 iOS）
- ✅ SwiftUI 原生应用，性能优异
- ✅ 横屏/竖屏自适应布局
- ✅ 6 个核心监控卡片（CPU、内存、磁盘、网络、温度、进程）
- ✅ 自动设备发现（Bonjour/Network Framework）
- ✅ 设备快速切换
- ✅ 告警系统（CPU/内存超阈值）
- ✅ 实时自动刷新（5秒间隔）
- ✅ 支持 Dark Mode
- ✅ 本地推送通知

### 🌐 Web Dashboard
- ✅ 响应式设计，适配所有设备
- ✅ 无需安装，浏览器直接访问
- ✅ 横屏单页面设计，适合桌面常亮显示
- ✅ 6 个核心监控卡片
- ✅ 自动设备发现
- ✅ 告警系统
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
├── iOS/               # 原生 iOS 应用（推荐）
│   └── MacMonitor/    # SwiftUI 项目
│       ├── MacMonitorApp.swift
│       ├── ContentView.swift
│       ├── MonitoringCards.swift
│       ├── Models.swift
│       ├── ViewModels/
│       └── README.md
├── dashboard/         # Web Dashboard（浏览器版）
│   ├── index.html
│   ├── styles.css
│   └── app.js
├── agent/            # Mac 监控 Agent
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

Agent 启动后会自动在局域网广播服务，并在 `http://localhost:8080` 提供 Web Dashboard 和 API 服务。

### 2. 使用 Dashboard

有两种方式访问 Mac Monitor：

#### 方式 A: 原生 iOS App（推荐）

1. 使用 Xcode 打开项目：
   ```bash
   cd iOS/MacMonitor
   open MacMonitor.xcodeproj
   ```
   或在 Xcode 中：File > Open，选择 `iOS/MacMonitor` 目录

2. 配置签名：
   - 选择 Target > Signing & Capabilities
   - 选择你的 Team

3. 运行应用：
   - 选择目标设备（iPhone 或模拟器）
   - 点击运行（⌘R）
   - 首次运行时授予本地网络权限

详细说明请参考 [iOS App README](iOS/MacMonitor/README.md)

#### 方式 B: Web Dashboard

Agent 启动后，通过浏览器访问：

**iPhone / iPad**
1. 确保设备与 Mac 在同一局域网
2. 使用 Safari 访问 `http://<Mac的IP>:8080/`
3. 将页面旋转至横屏模式以获得最佳体验
4. 可添加到主屏幕作为 Web App

**桌面浏览器**
直接访问 `http://localhost:8080/` 即可使用

## 系统架构

```
┌─────────────────┐         ┌──────────────────┐         ┌─────────────────┐
│                 │         │                  │         │                 │
│  iOS App /      │◄───────►│  Mac Agent       │◄───────►│  Mac System     │
│  Web Dashboard  │   WiFi  │  (监控服务)       │         │  (被监控电脑)    │
│                 │         │                  │         │                 │
└─────────────────┘         └──────────────────┘         └─────────────────┘
     Bonjour 发现              HTTP REST API               系统调用
     实时监控数据                JSON 数据传输
```

## 技术栈

## 技术栈

### iOS App（原生版）
- SwiftUI & Combine
- Network Framework（Bonjour 设备发现）
- UserNotifications（本地推送）
- MVVM 架构
- iOS 16.0+

### Dashboard (Web 版)
- 纯原生 HTML5 / CSS3 / JavaScript
- 响应式设计，适配移动端和桌面端
- 支持 PWA（可添加到主屏幕）
- Dark Mode 支持

### Mac Agent
**Python 版本（当前使用）:**
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

## 测试

Python Agent 包含完整的测试套件，确保所有功能按预期工作。

### 运行测试

```bash
cd agent/python-agent
python3 run_tests.py
```

### 测试覆盖

- **34 个单元测试** 覆盖所有核心功能：
  - 系统监控（CPU、内存、磁盘、网络）
  - REST API 端点
  - Bonjour/mDNS 服务
  - Dashboard 集成测试
  - 数据一致性验证
  - API 响应格式验证

详细测试说明请参考 [Python Agent README](agent/python-agent/README.md)。

## 开发路线图

### Phase 1: MVP ✅ (已完成)
- [x] Python Agent 实现
- [x] Bonjour 设备发现
- [x] 核心监控功能
- [x] Web Dashboard 实现（iPhone 横屏优化）
- [x] **原生 iOS App 实现（SwiftUI）**
- [x] 6 个核心监控卡片（CPU、内存、磁盘、网络、温度、进程）
- [x] 自动刷新和设备切换
- [x] 告警系统（CPU/内存超阈值）
- [x] Dark Mode 支持
- [x] 本地通知推送（iOS App）
- [x] 完整的单元测试套件（34个测试）
- [x] API 文档验证
- [x] 代码质量检查
- [x] 安全扫描

### Phase 2: 完善功能 🚧
- [ ] 历史数据图表
- [ ] 进程列表查看
- [ ] Widget 支持（iOS 14+）
- [ ] Apple Watch 伴侣应用

### Phase 3: 高级功能 📋
- [ ] WebSocket 实时推送
- [ ] 多设备对比视图
- [ ] Widget 支持
- [ ] 远程控制功能

## 截图

### 浅色模式
![Dashboard Light Mode](https://github.com/user-attachments/assets/ded64b14-7407-4e91-8736-365fac3fced0)

### 深色模式
![Dashboard Dark Mode](https://github.com/user-attachments/assets/54de8fe7-7334-4673-bf96-bfd381dcd095)

### iPhone 横屏视图
![iPhone Landscape](https://github.com/user-attachments/assets/16f317fe-e718-418d-8441-56d8f2a2cc88)

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
