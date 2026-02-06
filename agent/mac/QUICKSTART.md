# 快速开始指南 - Swift Mac Agent

## 系统要求

- macOS 13.0 (Ventura) 或更高版本
- Xcode 15.0 或更高版本（开发需要）
- 或者 Swift 5.9+ 命令行工具

## 安装 Swift（如果未安装）

如果你的 Mac 上还没有安装 Xcode 或 Swift：

### 选项 1: 安装 Xcode（推荐）
```bash
# 从 App Store 安装 Xcode
# 或者使用命令行
xcode-select --install
```

### 选项 2: 安装 Swift Toolchain
访问 https://swift.org/download/ 下载最新的 Swift toolchain

## 快速开始

### 1. 克隆仓库

```bash
git clone https://github.com/charsunny/mac-monitor.git
cd mac-monitor/agent/mac
```

### 2. 运行 Agent

最简单的方式是使用提供的脚本：

```bash
./run.sh run
```

或者直接使用 Swift 命令：

```bash
swift run
```

### 3. 验证运行

Agent 启动后会显示：

```
🚀 Starting Mac Monitor Agent (Swift)...
📡 Publishing Bonjour service: YourMacName on port 8080
✅ Bonjour service published successfully: YourMacName
✅ HTTP API Server starting on http://0.0.0.0:8080
   Endpoints:
   - GET /health
   - GET /api/info
   - GET /api/status
✅ Menu bar app started
```

### 4. 测试 API

在另一个终端窗口中：

```bash
# 健康检查
curl http://localhost:8080/health

# 获取系统信息
curl http://localhost:8080/api/info

# 获取实时状态
curl http://localhost:8080/api/status | python3 -m json.tool
```

### 5. 查看菜单栏

点击菜单栏右上角的 🖥️ 图标，即可看到实时监控信息。

## 编译发布版本

如果你想要编译一个优化的发布版本：

```bash
# 使用脚本
./run.sh --release build

# 运行编译后的可执行文件
.build/release/MacMonitorAgent
```

发布版本会有更好的性能和更小的内存占用。

## 常见问题

### Q: 菜单栏图标没有显示？

**A:** 确保你在 macOS 上运行。菜单栏功能只在 macOS 上可用。

### Q: 编译失败？

**A:** 检查 Swift 版本：
```bash
swift --version
# 应该显示 5.9 或更高版本
```

### Q: Bonjour 服务无法被发现？

**A:** 
1. 检查防火墙设置
2. 确保允许端口 8080 的入站连接
3. 确保设备在同一局域网内

### Q: 如何更改端口？

**A:** 编辑 `Sources/MacMonitorAgent/MacMonitorAgent.swift`，修改：
```swift
let port = 8080  // 改为你想要的端口
```

### Q: 如何后台运行？

**A:** 使用 nohup 或 &：
```bash
nohup .build/release/MacMonitorAgent > agent.log 2>&1 &
```

或者创建 launchd 服务（高级用户）。

## 停止 Agent

### 从菜单栏退出
点击菜单栏图标，选择 "Quit"

### 从命令行退出
按 `Ctrl+C`

### 终止后台进程
```bash
# 查找进程
ps aux | grep MacMonitorAgent

# 终止进程（使用上面找到的 PID）
kill <PID>
```

## 开机自启动（可选）

### 使用登录项

1. 打开"系统偏好设置" > "用户与群组"
2. 选择你的用户
3. 点击"登录项"标签
4. 点击 "+" 添加 MacMonitorAgent 可执行文件

### 使用 launchd（高级）

创建 `~/Library/LaunchAgents/com.macmonitor.agent.plist`：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.macmonitor.agent</string>
    <key>ProgramArguments</key>
    <array>
        <string>/path/to/MacMonitorAgent</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
```

加载服务：
```bash
launchctl load ~/Library/LaunchAgents/com.macmonitor.agent.plist
```

## 更新

```bash
cd mac-monitor
git pull
cd agent/mac
swift build --clean
./run.sh run
```

## 卸载

```bash
# 停止服务
kill $(ps aux | grep MacMonitorAgent | grep -v grep | awk '{print $2}')

# 删除代码
rm -rf ~/path/to/mac-monitor

# 如果配置了 launchd
launchctl unload ~/Library/LaunchAgents/com.macmonitor.agent.plist
rm ~/Library/LaunchAgents/com.macmonitor.agent.plist
```

## 获取帮助

- 📖 查看 [README.md](README.md) 了解详细功能
- 📝 查看 [IMPLEMENTATION.md](IMPLEMENTATION.md) 了解技术细节
- 🔍 查看 [../COMPARISON.md](../COMPARISON.md) 对比 Swift 和 Python 版本
- 🐛 提交 Issue: https://github.com/charsunny/mac-monitor/issues

## 下一步

- 配置 iPhone Dashboard 连接到此 Agent
- 查看实时监控数据
- 根据需要自定义监控参数

享受使用 Mac Monitor！🎉
