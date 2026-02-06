# Mac Monitor

<div align="center">

📱 一个用于监控局域网 Mac 电脑运行状态的 iPhone Dashboard 应用

[特性](#特性) • [快速开始](#快速开始) • [架构](#架构) • [文档](#文档)

</div>

---

## ✨ 特性

- 🖥️ **实时监控** - CPU、内存、磁盘、网络流量实时显示
- 📊 **横屏仪表盘** - 专为横屏设计的大屏监控界面
- 🔍 **自动发现** - 通过 Bonjour 自动发现局域网内的 Mac 设备
- 🔔 **智能告警** - 可配置的资源阈值告警
- 📱 **保持常亮** - 监控时屏幕保持常亮
- 🌙 **深色模式** - 完整支持深色/浅色模式
- 🔐 **局域网安全** - 仅限局域网访问，无需外网

## 🏗️ 项目结构

```
mac-monitor/
├── iOS/              # iPhone Dashboard 应用
│   └── MacMonitor/   # SwiftUI iOS App
├── agent/            # Mac 监控代理
│   ├── swift-agent/  # Swift 版本（推荐）
│   └── python-agent/ # Python 版本（备选）
└── docs/             # 项目文档
```

## 🚀 快速开始

### iOS App

#### 环境要求
- Xcode 15.0+
- iOS 16.0+
- Swift 5.9+

#### 运行步骤
```bash
cd iOS/MacMonitor
open MacMonitor.xcodeproj
# 在 Xcode 中选择目标设备并运行
```

### Mac Agent

#### Swift 版本（推荐）

```bash
cd agent/swift-agent
swift build
swift run MacMonitorAgent
```

#### Python 版本

```bash
cd agent/python-agent
pip3 install -r requirements.txt
python3 main.py
```

## 📱 界面预览

### 横屏监控仪表盘
- 2x3 网格布局展示 6 个核心指标
- 实时图表动画
- 一键切换设备

### 设备发现
- 自动扫描局域网内的 Mac
- 显示设备状态和基本信息
- 支持手动添加设备

### 告警中心
- 按严重程度分类显示
- 实时推送通知
- 可配置告警阈值

## 🛠️ 技术栈

### iOS
- **框架**: SwiftUI, Combine
- **网络**: URLSession, Network.framework
- **服务发现**: Bonjour/mDNS
- **架构**: MVVM

### Mac Agent
- **Swift**: Hummingbird (HTTP Server)
- **Python**: FastAPI + uvicorn
- **监控**: psutil, IOKit
- **服务发布**: Bonjour/Zeroconf

## 📖 文档

- [架构设计](docs/ARCHITECTURE.md)
- [API 文档](docs/API.md)
- [开发指南](docs/DEVELOPMENT.md)

## 🗺️ 开发路线图

### Phase 1: MVP ✅
- [x] iOS 基础 UI 框架
- [x] Mac Agent HTTP 服务
- [x] Bonjour 设备发现
- [x] 基础监控功能

### Phase 2: 核心功能 🚧
- [ ] 完整的 6 个监控卡片
- [ ] 设备切换功能
- [ ] 告警系统
- [ ] 屏幕常亮

### Phase 3: 增强功能 📋
- [ ] 历史数据图表
- [ ] 本地推送通知
- [ ] 设置页面
- [ ] 错误处理优化

### Phase 4: 高级功能 💡
- [ ] WebSocket 实时推送
- [ ] 进程管理
- [ ] Widget 支持
- [ ] 多设备对比视图

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 License

MIT License - 查看 [LICENSE](LICENSE) 文件了解详情

## 👨‍💻 作者

[@charsunny](https://github.com/charsunny)

---

<div align="center">
Made with ❤️ for Mac users
</div>
