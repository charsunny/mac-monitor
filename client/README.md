# Mac Monitor 客户端

这个目录包含 Mac Monitor 的所有客户端应用。

## 目录结构

```
client/
├── iOS/        # 原生 iOS 应用（推荐）
│   └── MacMonitor/
└── web/        # Web Dashboard（浏览器版）
    ├── index.html
    ├── styles.css
    └── app.js
```

## iOS 应用

原生 iOS 应用，使用 SwiftUI 构建，提供最佳的原生体验。

### 功能特性
- ✅ 原生 SwiftUI 界面，性能优异
- ✅ 横屏/竖屏自适应布局
- ✅ 6 个核心监控卡片
- ✅ 自动设备发现（Bonjour）
- ✅ 推送通知（告警提醒）
- ✅ Dark Mode 支持

### 快速开始

```bash
cd iOS/MacMonitor
open MacMonitor.xcodeproj
```

详细说明请参考 [iOS App README](iOS/MacMonitor/README.md)。

## Web Dashboard

响应式 Web 应用，可在任何浏览器中使用。

### 功能特性
- ✅ 响应式设计，适配所有设备
- ✅ 无需安装，浏览器直接访问
- ✅ 6 个核心监控卡片
- ✅ 自动设备发现
- ✅ Dark Mode 支持

### 使用方式

启动 Mac Agent 后，通过浏览器访问：
- `http://localhost:8080/` （本机）
- `http://<Mac的IP>:8080/` （局域网内其他设备）

## 客户端对比

详细的功能对比请参考 [客户端对比文档](../docs/COMPARISON.md)。

### 选择建议

- **推荐 iOS App**：主力使用、需要推送通知、长期监控
- **推荐 Web Dashboard**：快速测试、多平台访问、无需安装

两种客户端都连接到同一个 Agent 后端，数据完全一致，可以根据场景灵活选择。
