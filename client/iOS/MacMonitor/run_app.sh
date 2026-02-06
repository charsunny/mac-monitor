#!/bin/bash
# 运行 iOS App
# Run iOS App

set -e

echo "🚀 Mac Monitor iOS App - 运行脚本"
echo "=================================="
echo ""

# 检查是否在 macOS 上运行
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "⚠️  警告: iOS App 只能在 macOS 上运行"
    echo "⚠️  Warning: iOS App can only be run on macOS"
    exit 1
fi

cd "$(dirname "$0")"

# 检查 Xcode 是否安装
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ 错误: 未找到 xcodebuild"
    echo "请从 App Store 安装 Xcode"
    exit 1
fi

# 检查项目文件
if [ ! -d "MacMonitor.xcodeproj" ]; then
    echo "⚠️  未找到项目文件，正在生成..."
    ./generate_xcode_project.sh
fi

# 运行选项
SCHEME="MacMonitor"
CONFIGURATION=${1:-Debug}
SIMULATOR=${2:-"iPhone 15 Pro"}

echo "📋 运行配置:"
echo "   Scheme: $SCHEME"
echo "   Configuration: $CONFIGURATION"
echo "   Simulator: $SIMULATOR"
echo ""

# 启动模拟器
echo "📱 启动模拟器: $SIMULATOR"
xcrun simctl boot "$SIMULATOR" 2>/dev/null || echo "   模拟器已在运行"
open -a Simulator

sleep 2

echo ""
echo "🔨 构建并运行应用..."
echo ""

# 构建并运行
xcodebuild build \
    -project MacMonitor.xcodeproj \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -destination "platform=iOS Simulator,name=$SIMULATOR" \
    | grep -E "^(Build|Ld|CompileSwift|▸)" || true

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo ""
    echo "✅ 应用正在运行！"
    echo "✅ App is running!"
    echo ""
    echo "💡 提示:"
    echo "   - 应用应该已在模拟器中启动"
    echo "   - 如需调试，请在 Xcode 中打开项目"
    echo ""
else
    echo ""
    echo "❌ 运行失败"
    echo "请在 Xcode 中查看详细错误"
    exit 1
fi
