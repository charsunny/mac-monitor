#!/bin/bash
# 构建 iOS App
# Build iOS App

set -e

echo "🏗️  Mac Monitor iOS App - 构建脚本"
echo "===================================="
echo ""

# 检查是否在 macOS 上运行
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "⚠️  警告: iOS App 只能在 macOS 上构建"
    echo "⚠️  Warning: iOS App can only be built on macOS"
    echo ""
    echo "请在安装了 Xcode 的 Mac 电脑上运行此脚本"
    echo "Please run this script on a Mac with Xcode installed"
    exit 1
fi

cd "$(dirname "$0")"

echo "📁 当前目录: $(pwd)"
echo ""

# 检查 Xcode 是否安装
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ 错误: 未找到 xcodebuild"
    echo "❌ Error: xcodebuild not found"
    echo ""
    echo "请从 App Store 安装 Xcode"
    echo "Please install Xcode from the App Store"
    exit 1
fi

echo "✅ Xcode 版本:"
xcodebuild -version
echo ""

# 检查项目文件
if [ ! -d "MacMonitor.xcodeproj" ]; then
    echo "⚠️  未找到 MacMonitor.xcodeproj"
    echo ""
    echo "正在生成项目..."
    ./generate_xcode_project.sh
    echo ""
fi

# 构建选项
SCHEME="MacMonitor"
CONFIGURATION=${1:-Debug}  # 默认 Debug，可以传 Release
DESTINATION=${2:-"platform=iOS Simulator,name=iPhone 15 Pro"}

echo "📋 构建配置:"
echo "   Scheme: $SCHEME"
echo "   Configuration: $CONFIGURATION"
echo "   Destination: $DESTINATION"
echo ""

# 清理之前的构建
echo "🧹 清理之前的构建..."
xcodebuild clean \
    -project MacMonitor.xcodeproj \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    > /dev/null 2>&1 || true

echo ""
echo "🔨 开始构建..."
echo ""

# 构建项目
xcodebuild build \
    -project MacMonitor.xcodeproj \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -destination "$DESTINATION" \
    -quiet \
    | tee build.log

BUILD_RESULT=$?

echo ""
if [ $BUILD_RESULT -eq 0 ]; then
    echo "✅ 构建成功！"
    echo "✅ Build succeeded!"
    echo ""
    echo "📦 构建日志已保存到: build.log"
    echo ""
    echo "🚀 运行应用:"
    echo "   方式 1: 在 Xcode 中打开项目并点击运行 (⌘R)"
    echo "   方式 2: 使用命令行运行模拟器:"
    echo "          ./run_app.sh"
    echo ""
else
    echo "❌ 构建失败"
    echo "❌ Build failed"
    echo ""
    echo "请查看 build.log 了解详细错误信息"
    echo "Please check build.log for detailed error information"
    echo ""
    exit 1
fi
