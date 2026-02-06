# iOS App Xcode 项目设置指南

本文档详细说明如何为 Mac Monitor iOS App 创建 Xcode 项目。

## 快速开始（推荐）

如果你在 macOS 上，推荐使用自动化脚本：

```bash
cd client/iOS/MacMonitor

# 1. 生成 Xcode 项目
./generate_xcode_project.sh

# 2. 打开项目
open MacMonitor.xcodeproj

# 或者直接构建
./build_app.sh

# 或者构建并运行
./run_app.sh
```

## 方案 A: 使用 XcodeGen（推荐）

### 1. 安装 XcodeGen

```bash
# 使用 Homebrew
brew install xcodegen

# 或使用 Mint
mint install yonaskolb/XcodeGen
```

### 2. 生成项目

```bash
cd client/iOS/MacMonitor
xcodegen generate
```

这将根据 `project.yml` 配置文件生成 `MacMonitor.xcodeproj`。

### 3. 打开并配置

```bash
open MacMonitor.xcodeproj
```

在 Xcode 中：
1. 选择项目 > Signing & Capabilities
2. 选择你的开发团队
3. 确认 Bundle ID: `com.macmonitor.MacMonitor`

## 方案 B: 手动在 Xcode 中创建

### 步骤 1: 创建新项目

1. 打开 Xcode
2. File > New > Project...
3. 选择 **iOS** > **App**
4. 点击 Next

### 步骤 2: 配置项目信息

填写以下信息：
- **Product Name**: `MacMonitor`
- **Team**: 选择你的开发团队（或使用个人团队）
- **Organization Identifier**: `com.macmonitor`
- **Bundle Identifier**: `com.macmonitor.MacMonitor` (自动生成)
- **Interface**: `SwiftUI`
- **Language**: `Swift`
- **Storage**: `None` (不需要 Core Data)
- **Include Tests**: ✓ 勾选

点击 Next，选择保存位置为 `client/iOS/MacMonitor`

### 步骤 3: 删除默认文件并添加源文件

1. **删除默认创建的文件**：
   - 删除 `ContentView.swift`（我们有自己的版本）
   - 删除 `MacMonitorApp.swift`（我们有自己的版本）
   - 保留 `Assets.xcassets`

2. **添加项目源文件**：
   
   在项目导航器中右键点击 `MacMonitor` 文件夹，选择 "Add Files to MacMonitor..."
   
   添加以下文件（从 `MacMonitor/` 目录）：
   - ✅ `MacMonitorApp.swift`
   - ✅ `ContentView.swift`
   - ✅ `MonitoringCards.swift`
   - ✅ `SettingsView.swift`
   - ✅ `Models.swift`
   - ✅ `MonitorViewModel.swift`
   - ✅ `DeviceDiscoveryViewModel.swift`
   - ✅ `APIClient.swift`
   - ✅ `Info.plist`
   
   **重要**: 勾选 "Copy items if needed" 和 "Add to targets: MacMonitor"

### 步骤 4: 配置 Info.plist

1. 在项目设置中选择 `MacMonitor` target
2. 选择 `Info` 标签页
3. 点击 `+` 添加以下权限：

#### 本地网络权限
- **Key**: `Privacy - Local Network Usage Description` (或 `NSLocalNetworkUsageDescription`)
- **Value**: `Mac Monitor 需要访问本地网络来发现和连接 Mac 设备`

#### Bonjour 服务
- **Key**: `Privacy - Bonjour Services` (或 `NSBonjourServices`)
- **Type**: Array
- 添加项目: `_macmonitor._tcp`

或者直接编辑 Info.plist XML：

```xml
<key>NSLocalNetworkUsageDescription</key>
<string>Mac Monitor 需要访问本地网络来发现和连接 Mac 设备</string>
<key>NSBonjourServices</key>
<array>
    <string>_macmonitor._tcp</string>
</array>
```

### 步骤 5: 配置项目设置

在项目设置中（选择项目名称 > Target > General）：

#### Deployment Info
- **Minimum Deployments**: iOS 16.0
- **Supported Destinations**: iPhone, iPad
- **Device Orientation**: 
  - ✓ Portrait
  - ✓ Landscape Left
  - ✓ Landscape Right
  - ✓ Upside Down (仅 iPad)

#### Signing & Capabilities
- **Automatically manage signing**: ✓ 勾选
- **Team**: 选择你的开发团队
- **Bundle Identifier**: `com.macmonitor.MacMonitor`

### 步骤 6: 配置 Assets

1. 打开 `Assets.xcassets`
2. 确保有 `AppIcon` 资源集
3. 添加 `AccentColor` 颜色集（如果需要自定义主题色）

### 步骤 7: 构建并运行

1. 选择目标设备（模拟器或真机）
   - 推荐：iPhone 15 Pro 模拟器
2. 点击运行按钮 ▶️ 或按 `⌘R`
3. 等待编译完成
4. 应用将在设备/模拟器上启动

## 方案 C: 使用 Swift Package Manager

虽然 Swift Package Manager 主要用于库，但也可以用于简单的应用开发：

```bash
cd client/iOS/MacMonitor

# 使用 swift package 生成 Xcode 项目
swift package generate-xcodeproj

# 打开生成的项目
open MacMonitor.xcodeproj
```

**注意**: 这种方式生成的项目可能需要额外配置，因为 SPM 主要面向库开发。

## 验证项目配置

### 检查清单

构建前，确认以下设置：

- [ ] 所有源文件都已添加到项目
- [ ] Info.plist 包含必要的权限
- [ ] Bundle Identifier 正确设置
- [ ] 开发团队已选择
- [ ] Deployment Target 设置为 iOS 16.0+
- [ ] 支持的设备方向已配置

### 常见问题排查

#### 1. 编译错误 "Cannot find type 'XXX' in scope"

**原因**: 文件未添加到 target

**解决**:
1. 在项目导航器中选择该文件
2. 在右侧 File Inspector 中
3. 检查 "Target Membership"
4. 确保 `MacMonitor` 已勾选

#### 2. 运行时崩溃 "This app has crashed because it attempted to access privacy-sensitive data"

**原因**: Info.plist 缺少必要权限

**解决**:
按照步骤 4 添加所有必需的权限描述

#### 3. 无法发现设备

**原因**: 
- 权限未授予
- Mac Agent 未运行
- 网络不通

**解决**:
1. 确保授予了本地网络访问权限
2. 检查 Mac Agent 是否在运行: `lsof -i :8080`
3. 确保 iPhone 和 Mac 在同一网络

#### 4. 签名错误

**原因**: 未选择开发团队或 Bundle ID 冲突

**解决**:
1. 在 Signing & Capabilities 中选择团队
2. 更改 Bundle Identifier 为唯一值
3. 如使用免费账号，可能需要连接设备并信任证书

## 构建配置

### Debug 配置（开发）

```bash
# 使用脚本
./build_app.sh Debug

# 或手动
xcodebuild build \
  -project MacMonitor.xcodeproj \
  -scheme MacMonitor \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

### Release 配置（发布）

```bash
# 使用脚本
./build_app.sh Release

# 或手动
xcodebuild build \
  -project MacMonitor.xcodeproj \
  -scheme MacMonitor \
  -configuration Release \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

### 构建到真机

```bash
xcodebuild build \
  -project MacMonitor.xcodeproj \
  -scheme MacMonitor \
  -configuration Debug \
  -destination 'platform=iOS,name=Your iPhone Name'
```

## 测试

### 运行单元测试

```bash
# 命令行
xcodebuild test \
  -project MacMonitor.xcodeproj \
  -scheme MacMonitor \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# 或在 Xcode 中
# 按 ⌘U 运行所有测试
```

## 分发

### 创建 Archive

1. 在 Xcode 中：Product > Archive
2. 等待构建完成
3. 在 Organizer 中管理归档

### 导出 IPA

1. 在 Organizer 中选择归档
2. 点击 "Distribute App"
3. 选择分发方式：
   - Development
   - Ad Hoc
   - App Store Connect

## 工具和资源

### 推荐工具

- **XcodeGen**: 从 YAML 配置生成项目
  - 安装: `brew install xcodegen`
  - 文档: https://github.com/yonaskolb/XcodeGen

- **SwiftLint**: 代码风格检查
  - 安装: `brew install swiftlint`
  - 配置: 在项目根目录添加 `.swiftlint.yml`

- **fastlane**: 自动化构建和部署
  - 安装: `brew install fastlane`
  - 文档: https://fastlane.tools

### 有用的命令

```bash
# 列出所有可用的模拟器
xcrun simctl list devices

# 启动特定模拟器
xcrun simctl boot "iPhone 15 Pro"

# 安装 app 到模拟器
xcrun simctl install booted path/to/app.app

# 清理构建缓存
rm -rf ~/Library/Developer/Xcode/DerivedData

# 查看项目信息
xcodebuild -list -project MacMonitor.xcodeproj
```

## 下一步

项目创建完成后：

1. **运行应用**: 按 ⌘R
2. **测试功能**: 确保能发现和连接到 Mac Agent
3. **调试**: 使用 Xcode 的调试工具
4. **优化**: 根据需要调整 UI 和性能

## 需要帮助？

- 查看主 README: `../../README.md`
- 查看 iOS App README: `README.md`
- 查看 Xcode 指南: `XCODE_GUIDE.md`
- Apple 文档: https://developer.apple.com/documentation/
- Stack Overflow: https://stackoverflow.com/questions/tagged/xcode+swiftui

---

**提示**: 如果遇到任何问题，建议使用自动化脚本（方案 A）而不是手动配置。自动化脚本确保配置一致性并减少人为错误。
