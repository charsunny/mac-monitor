# 如何在 Xcode 中打开和运行 iOS 项目

## 方法一：使用 Xcode 打开目录（推荐）

### 步骤：

1. **打开 Xcode**
   - 从 Launchpad 或 Applications 文件夹启动 Xcode

2. **打开项目文件夹**
   ```
   File > Open...
   ```
   或者直接使用命令行：
   ```bash
   cd iOS/MacMonitor
   open MacMonitor.xcodeproj
   ```
   
   如果没有 `.xcodeproj` 文件，直接选择 `iOS/MacMonitor/MacMonitor` 文件夹

3. **等待 Xcode 加载项目**
   - Xcode 会自动识别所有 Swift 文件
   - 可能需要几秒钟来索引项目

4. **配置签名**
   - 点击项目导航器中的项目名称
   - 选择 "Signing & Capabilities" 标签页
   - 在 "Team" 下拉菜单中选择你的 Apple Developer 账号
   - 如果没有账号，可以使用免费的个人团队（需要 Apple ID）

5. **选择运行目标**
   - 在工具栏顶部选择一个模拟器（如 iPhone 15 Pro）
   - 或连接真机设备

6. **运行项目**
   - 点击播放按钮 ▶️ 或按 `⌘R`
   - 等待编译和安装完成

## 方法二：从零创建 Xcode 项目

如果遇到问题，可以创建新项目并添加文件：

1. **创建新项目**
   ```
   File > New > Project...
   iOS > App
   ```

2. **配置项目**
   - Product Name: `MacMonitor`
   - Team: 选择你的团队
   - Organization Identifier: `com.yourname`
   - Interface: `SwiftUI`
   - Language: `Swift`
   - 取消勾选 "Use Core Data" 和 "Include Tests"

3. **添加源文件**
   - 将以下文件拖入项目：
     - MacMonitorApp.swift
     - ContentView.swift
     - MonitoringCards.swift
     - SettingsView.swift
     - Models.swift
     - MonitorViewModel.swift
     - DeviceDiscoveryViewModel.swift
     - APIClient.swift
   
4. **配置 Info.plist**
   - 在项目设置中找到 "Info" 标签页
   - 添加以下权限：
     - `NSLocalNetworkUsageDescription`: "Mac Monitor 需要访问本地网络来发现和连接 Mac 设备"
     - `NSBonjourServices`: 添加 `_macmonitor._tcp`

5. **设置支持的方向**
   - 在 "Deployment Info" 中
   - 勾选 Landscape Left, Landscape Right 和 Portrait

## 常见问题

### Q: 提示 "Unable to open document"？
A: 确保所有 Swift 文件都在正确的位置，或者尝试方法二从零创建项目。

### Q: 编译错误 "Cannot find type 'Device'"？
A: 确保所有源文件都已添加到项目 Target 中。在项目导航器中选择文件，检查右侧面板的 "Target Membership"。

### Q: 模拟器中看不到设备？
A: 
- 确保 Python Agent 正在运行
- 模拟器和 Mac 默认在同一网络，应该能发现 localhost
- 检查控制台日志查看错误信息

### Q: 真机运行提示签名错误？
A:
- 需要有效的 Apple Developer 账号
- 或使用免费的个人开发者证书（需要 Apple ID）
- 在设置中配置正确的 Team

### Q: 运行时崩溃？
A:
- 检查 Info.plist 是否正确配置权限
- 查看 Xcode Console 的错误日志
- 确保 iOS 部署目标设置为 16.0+

## 项目要求

- **macOS**: 13.0+ (Ventura)
- **Xcode**: 15.0+
- **iOS Target**: 16.0+
- **Swift**: 5.9+

## 测试建议

1. **首先在模拟器测试**
   - 更快的迭代周期
   - 不需要证书配置
   - 自动连接到 localhost

2. **然后在真机测试**
   - 测试推送通知
   - 验证 Bonjour 发现
   - 检查性能表现

## 需要帮助？

参考项目 README 或查看 Xcode 文档：
- [Xcode 官方文档](https://developer.apple.com/xcode/)
- [SwiftUI 教程](https://developer.apple.com/tutorials/swiftui)
