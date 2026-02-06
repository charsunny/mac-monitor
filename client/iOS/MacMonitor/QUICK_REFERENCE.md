# iOS App 快速参考 / iOS App Quick Reference

## 🚀 快速开始 / Quick Start

```bash
cd client/iOS/MacMonitor

# 完整设置（仅需运行一次）
make setup

# 或分步执行
make generate  # 生成 Xcode 项目
make open      # 打开 Xcode
make build     # 构建应用
make run       # 运行应用
```

## 📋 常用命令 / Common Commands

### 使用 Make（推荐）

| 命令 | 说明 | Command | Description |
|------|------|---------|-------------|
| `make help` | 显示帮助 | Show help | |
| `make setup` | 完整设置 | Full setup | Install tools + generate project |
| `make generate` | 生成项目 | Generate project | Create .xcodeproj from project.yml |
| `make open` | 打开项目 | Open project | Open in Xcode |
| `make build` | 构建 Debug | Build Debug | |
| `make build-release` | 构建 Release | Build Release | |
| `make run` | 运行应用 | Run app | Build + launch simulator |
| `make test` | 运行测试 | Run tests | |
| `make clean` | 清理构建 | Clean build | |
| `make clean-all` | 完全清理 | Full clean | Remove .xcodeproj too |
| `make info` | 项目信息 | Project info | |
| `make simulators` | 列出模拟器 | List simulators | |

### 使用脚本

```bash
# 生成项目
./generate_xcode_project.sh

# 构建（Debug）
./build_app.sh

# 构建（Release）
./build_app.sh Release

# 运行
./run_app.sh

# 指定模拟器
./run_app.sh Debug "iPhone 15 Pro"
```

### 使用 xcodebuild（手动）

```bash
# 生成项目
xcodegen generate

# 构建
xcodebuild build \
  -project MacMonitor.xcodeproj \
  -scheme MacMonitor \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# 运行测试
xcodebuild test \
  -project MacMonitor.xcodeproj \
  -scheme MacMonitor \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# 清理
xcodebuild clean \
  -project MacMonitor.xcodeproj \
  -scheme MacMonitor
```

## 📁 项目结构 / Project Structure

```
MacMonitor/
├── project.yml                    # XcodeGen 配置
├── generate_xcode_project.sh     # 项目生成脚本
├── build_app.sh                  # 构建脚本
├── run_app.sh                    # 运行脚本
├── Makefile                      # Make 命令
├── .gitignore                    # Git 忽略规则
├── MacMonitor/                   # 源代码目录
│   ├── MacMonitorApp.swift      # App 入口
│   ├── ContentView.swift         # 主视图
│   ├── MonitoringCards.swift    # 监控卡片
│   ├── SettingsView.swift       # 设置视图
│   ├── Models.swift              # 数据模型
│   ├── MonitorViewModel.swift   # 监控 ViewModel
│   ├── DeviceDiscoveryViewModel.swift  # 设备发现
│   ├── APIClient.swift           # API 客户端
│   ├── Info.plist                # 应用配置
│   └── Assets.xcassets/          # 资源文件
├── Tests/                        # 测试代码
│   └── MacMonitorTests/
│       └── ModelsTests.swift
├── README.md                     # 项目说明
├── XCODE_GUIDE.md               # Xcode 使用指南
└── XCODE_PROJECT_SETUP.md       # 详细设置指南
```

## 🛠️ 工具要求 / Tool Requirements

### 必需 / Required
- **macOS**: 13.0+ (Ventura)
- **Xcode**: 15.0+
- **Swift**: 5.9+

### 推荐 / Recommended
- **Homebrew**: 包管理器
- **xcodegen**: 项目生成工具

安装推荐工具：
```bash
# 安装 Homebrew（如果还没有）
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 安装 xcodegen
brew install xcodegen

# 或使用 make 一键安装
make install-tools
```

## ⚙️ 配置 / Configuration

### 修改 Bundle ID

编辑 `project.yml`:

```yaml
options:
  bundleIdPrefix: com.yourcompany  # 修改这里

settings:
  base:
    PRODUCT_BUNDLE_IDENTIFIER: com.yourcompany.MacMonitor  # 修改这里
```

### 修改版本号

编辑 `project.yml`:

```yaml
settings:
  base:
    MARKETING_VERSION: "1.0.0"      # 应用版本
    CURRENT_PROJECT_VERSION: "1"    # 构建版本
```

### 修改部署目标

编辑 `project.yml`:

```yaml
options:
  deploymentTarget:
    iOS: "16.0"  # 最低 iOS 版本
```

## 🐛 故障排查 / Troubleshooting

### 问题：命令找不到 xcodegen

```bash
# 安装 xcodegen
brew install xcodegen

# 或使用
make install-tools
```

### 问题：构建失败 - 签名错误

1. 打开 Xcode: `make open`
2. 选择项目 > Signing & Capabilities
3. 选择你的开发团队
4. 或修改 Bundle ID 为唯一值

### 问题：无法发现设备

1. 确保 Mac Agent 正在运行:
   ```bash
   cd ../../agent/python
   python3 main.py
   ```

2. 检查权限：设置 > MacMonitor > 本地网络

3. 检查网络：iPhone 和 Mac 在同一 Wi-Fi

### 问题：模拟器无法启动

```bash
# 列出可用的模拟器
make simulators

# 重启模拟器服务
killall Simulator
open -a Simulator
```

### 问题：Xcode 版本太旧

```bash
# 检查 Xcode 版本
xcodebuild -version

# 需要 Xcode 15.0+
# 从 App Store 更新 Xcode
```

## 📚 相关文档 / Documentation

- **README.md** - 项目介绍和功能说明
- **XCODE_GUIDE.md** - Xcode 使用指南
- **XCODE_PROJECT_SETUP.md** - 详细的项目设置步骤
- **project.yml** - 项目配置文件（带注释）

## 💡 提示 / Tips

### 快速重新生成项目

```bash
make clean-all  # 删除旧项目
make generate   # 生成新项目
```

### 切换构建配置

```bash
# Debug（开发）
./build_app.sh Debug

# Release（发布）
./build_app.sh Release
```

### 查看模拟器设备

```bash
xcrun simctl list devices
```

### 查看项目构建设置

```bash
xcodebuild -showBuildSettings \
  -project MacMonitor.xcodeproj \
  -scheme MacMonitor
```

### 清理 Xcode 缓存

```bash
# 清理 DerivedData
rm -rf ~/Library/Developer/Xcode/DerivedData

# 清理项目
make clean
```

## 🔄 工作流程 / Workflow

### 首次设置

```bash
cd client/iOS/MacMonitor
make setup          # 安装工具 + 生成项目
make open           # 在 Xcode 中配置签名
make build          # 构建
make run            # 运行
```

### 日常开发

```bash
# 方式 1: 使用 Xcode
make open
# 在 Xcode 中编辑代码并运行 (⌘R)

# 方式 2: 使用命令行
# 编辑代码...
make build          # 构建
make run            # 运行
```

### 更新项目配置

```bash
# 修改 project.yml
vim project.yml

# 重新生成项目
make clean-all
make generate
```

### 发布

```bash
# 构建 Release 版本
make build-release

# 或在 Xcode 中
# Product > Archive
```

## 🎯 下一步 / Next Steps

1. ✅ 生成项目: `make generate`
2. ✅ 配置签名: `make open`（在 Xcode 中）
3. ✅ 启动 Mac Agent: `cd ../../agent/python && python3 main.py`
4. ✅ 运行应用: `make run`
5. ✅ 测试功能: 检查设备发现和监控数据

---

**需要帮助？** 查看 [XCODE_PROJECT_SETUP.md](XCODE_PROJECT_SETUP.md) 获取详细说明。
