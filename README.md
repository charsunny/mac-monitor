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
├── dashboard/         # Web Dashboard（适用于 iPhone 和其他设备）
│   ├── index.html     # Dashboard 主页面
│   ├── styles.css     # 响应式样式和暗色模式
│   └── app.js         # 前端逻辑和实时数据更新
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

Agent 启动后会自动在局域网广播服务，并在 `http://localhost:8080` 提供 Web Dashboard 和 API 服务。

### 2. 访问 Dashboard

Agent 启动后，通过浏览器访问 Dashboard：

#### iPhone / iPad
1. 确保设备与 Mac 在同一局域网
2. 使用 Safari 访问 `http://<Mac的IP>:8080/`
3. 将页面旋转至横屏模式以获得最佳体验
4. 可添加到主屏幕作为 Web App

#### 桌面浏览器
直接访问 `http://localhost:8080/` 即可使用

**功能特点**：
- 🔄 自动刷新（每5秒）
- 🌓 支持深色/浅色模式切换
- 📱 响应式设计，适配各种屏幕
- 🔔 CPU/内存告警提示
- 🔍 自动设备发现与切换

## 系统架构

```
┌─────────────────┐         ┌──────────────────┐         ┌─────────────────┐
│                 │         │                  │         │                 │
│  Web Dashboard  │◄───────►│  Mac Agent       │◄───────►│  Mac System     │
│  (iPhone/浏览器) │   WiFi  │  (监控服务)       │         │  (被监控电脑)    │
│                 │         │                  │         │                 │
└─────────────────┘         └──────────────────┘         └─────────────────┘
     Bonjour 发现              HTTP REST API               系统调用
     实时监控数据                JSON 数据传输
```

## 技术栈

### Dashboard (Web 版)
- 纯原生 HTML5 / CSS3 / JavaScript
- 响应式设计，适配移动端和桌面端
- 支持 PWA（可添加到主屏幕）
- Dark Mode 支持
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
- [x] 基础 UI 框架
- [x] Python Agent 实现
- [x] Bonjour 设备发现
- [x] 核心监控功能
- [x] Web Dashboard 实现（iPhone 横屏优化）
- [x] 6 个核心监控卡片（CPU、内存、磁盘、网络、温度、进程）
- [x] 自动刷新和设备切换
- [x] 告警系统（CPU/内存超阈值）
- [x] Dark Mode 支持
- [x] 完整的单元测试套件（34个测试）
- [x] API 文档验证
- [x] 代码质量检查
- [x] 安全扫描

### Phase 2: 完善功能 🚧
- [ ] Swift Agent 完整实现
- [ ] 原生 iOS Dashboard App（可选）
- [ ] 历史数据图表
- [ ] 进程列表查看
- [ ] 本地通知推送

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
