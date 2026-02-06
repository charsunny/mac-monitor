# Mac Monitor - iOS App

一个用于监控局域网 Mac 电脑运行状态的原生 iOS 应用。

## 功能特性

### 📱 Dashboard
- ✅ 横屏/竖屏自适应布局
- ✅ 6 个核心监控卡片（CPU、内存、磁盘、网络、温度、进程）
- ✅ 自动设备发现（Bonjour/mDNS）
- ✅ 设备快速切换
- ✅ 告警系统（CPU/内存超阈值）
- ✅ 实时自动刷新（5秒间隔）
- ✅ 支持 Dark Mode
- ✅ 本地通知推送

## 系统要求

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+

## 快速开始

### 1. 生成和打开项目

**方式 A: 使用自动化脚本（推荐）**

```bash
cd client/iOS/MacMonitor

# 生成 Xcode 项目
./generate_xcode_project.sh

# 打开项目
open MacMonitor.xcodeproj
```

**方式 B: 使用 Make**

```bash
cd client/iOS/MacMonitor

# 查看所有可用命令
make help

# 完整设置（安装工具 + 生成项目）
make setup

# 或者只生成项目
make generate

# 打开项目
make open
```

**方式 C: 手动创建**

如果自动化工具不可用，请参考 [XCODE_PROJECT_SETUP.md](XCODE_PROJECT_SETUP.md) 手动在 Xcode 中创建项目。

### 2. 配置项目

在 Xcode 中配置以下内容：

1. **签名和团队**
   - 选择 Target > Signing & Capabilities
   - 选择你的 Team

2. **Bundle Identifier**
   - 设置为: `com.yourname.MacMonitor`

3. **权限配置**
   - Info.plist 已包含必要的权限：
     - `NSLocalNetworkUsageDescription`: 本地网络访问
     - `NSBonjourServices`: Bonjour 服务发现

4. **部署目标**
   - 设置为 iOS 16.0 或更高

### 3. 构建和运行应用

**使用脚本:**

```bash
# 构建应用
./build_app.sh

# 运行应用（构建 + 启动模拟器）
./run_app.sh
```

**使用 Make:**

```bash
# 构建
make build

# 运行
make run

# 运行测试
make test
```

**使用 Xcode:**

1. 确保 Mac Agent 正在运行（参见根目录 README）
2. 在 Xcode 中选择目标设备（iPhone 或模拟器）
3. 点击运行按钮（⌘R）
4. 首次运行时，授予本地网络访问权限

**命令行构建:**

```bash
# Debug 版本
xcodebuild build \
  -project MacMonitor.xcodeproj \
  -scheme MacMonitor \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# Release 版本
make build-release
```

## 项目结构

```
MacMonitor/
├── MacMonitorApp.swift          # App 入口
├── ContentView.swift             # 主视图
├── MonitoringCards.swift         # 监控卡片视图
├── SettingsView.swift            # 设置界面
├── Models.swift                  # 数据模型
├── MonitorViewModel.swift        # 监控数据管理
├── DeviceDiscoveryViewModel.swift # 设备发现
├── APIClient.swift               # API 客户端
├── Info.plist                    # 应用配置
└── Assets.xcassets/              # 资源文件
```

## 架构

应用采用 **MVVM** (Model-View-ViewModel) 架构：

- **Models**: 定义数据结构（Device, SystemStatus, etc.）
- **Views**: SwiftUI 视图（ContentView, MonitoringCards, etc.）
- **ViewModels**: 业务逻辑和状态管理
  - `MonitorViewModel`: 监控数据获取和告警
  - `DeviceDiscoveryViewModel`: Bonjour 设备发现
- **APIClient**: 网络请求封装

## 技术栈

- **SwiftUI**: 声明式 UI 框架
- **Combine**: 响应式编程
- **Network Framework**: Bonjour/mDNS 设备发现
- **UserNotifications**: 本地通知
- **URLSession**: HTTP 网络请求

## 使用说明

### 设备发现

应用启动后会自动扫描本地网络中的 Mac Monitor Agent：

1. 确保 iPhone 和 Mac 在同一局域网
2. 点击顶部的天线图标查看发现的设备
3. 选择要监控的设备

### 监控视图

- **横屏模式**: 3x2 网格布局，最佳监控体验
- **竖屏模式**: 2x3 网格布局，方便单手操作
- **实时数据**: 每 5 秒自动刷新
- **告警提示**: CPU/内存超过阈值时显示横幅和推送通知

### 设置

点击右上角齿轮图标进入设置：

- 调整 CPU 告警阈值（50%-100%）
- 调整内存告警阈值（50%-100%）
- 查看系统信息

## 开发说明

### 项目文件管理

本项目使用 XcodeGen 管理项目配置，这样可以：
- 避免 `.xcodeproj` 文件冲突
- 保持项目配置的一致性
- 通过 `project.yml` 版本控制项目设置

项目配置文件：
- `project.yml` - XcodeGen 项目配置
- `generate_xcode_project.sh` - 项目生成脚本
- `build_app.sh` - 构建脚本
- `run_app.sh` - 运行脚本
- `Makefile` - Make 命令集合

### 添加新功能

1. **新增监控指标**
   - 在 `Models.swift` 中添加数据模型
   - 在 `MonitoringCards.swift` 中创建新的卡片视图
   - 在 `ContentView.swift` 的 grid 中添加卡片

2. **修改刷新间隔**
   - 在 `MonitorViewModel.swift` 的 `startAutoRefresh()` 方法中修改

3. **自定义告警规则**
   - 在 `MonitorViewModel.swift` 的 `checkAlerts()` 方法中添加逻辑

### 调试技巧

1. **无法发现设备**
   - 检查 Info.plist 权限配置
   - 确保授予了本地网络权限
   - 检查防火墙设置

2. **数据不更新**
   - 检查 API 端点是否可访问
   - 查看 Xcode Console 的错误日志
   - 确认 Agent 正在运行

## 常见问题

**Q: 为什么无法发现设备？**

A: 
1. 确保 iPhone 和 Mac 在同一局域网
2. 检查是否授予了本地网络权限
3. 某些企业网络可能阻止 mDNS

**Q: 可以监控多台 Mac 吗？**

A: 可以，点击顶部设备选择器切换不同的 Mac。

**Q: 支持远程监控吗？**

A: 目前仅支持局域网监控。远程监控需要配置端口转发或 VPN。

## 路线图

- [ ] 历史数据图表
- [ ] Widget 支持
- [ ] Apple Watch 伴侣应用
- [ ] iPad 多设备对比视图
- [ ] 自定义监控卡片

## 许可证

MIT License - 详见根目录 LICENSE 文件

## 致谢

- SwiftUI 框架
- Apple Network Framework
- Combine 框架
