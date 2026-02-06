#!/bin/bash
# 生成 iOS App Xcode 项目
# Generate iOS App Xcode Project

set -e

echo "🎯 Mac Monitor iOS App - Xcode 项目生成器"
echo "============================================"
echo ""

# 检查是否在 macOS 上运行
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "⚠️  警告: 此脚本需要在 macOS 上运行"
    echo "⚠️  Warning: This script must be run on macOS"
    echo ""
    echo "请在 Mac 电脑上执行此脚本，或参考 XCODE_PROJECT_SETUP.md 手动创建项目"
    echo "Please run this script on a Mac, or refer to XCODE_PROJECT_SETUP.md for manual setup"
    exit 1
fi

cd "$(dirname "$0")"

echo "📁 当前目录: $(pwd)"
echo ""

# 方案1: 使用 xcodegen (推荐)
if command -v xcodegen &> /dev/null; then
    echo "✅ 找到 xcodegen，使用它生成项目..."
    echo ""
    
    xcodegen generate
    
    if [ -d "MacMonitor.xcodeproj" ]; then
        echo ""
        echo "✅ 成功生成 Xcode 项目！"
        echo "✅ Successfully generated Xcode project!"
        echo ""
        echo "📦 项目位置: MacMonitor.xcodeproj"
        echo ""
        echo "🚀 下一步:"
        echo "   1. 打开项目: open MacMonitor.xcodeproj"
        echo "   2. 在 Xcode 中配置你的开发团队（Signing & Capabilities）"
        echo "   3. 选择目标设备（模拟器或真机）"
        echo "   4. 点击运行按钮 (⌘R)"
        echo ""
        exit 0
    else
        echo "❌ 项目生成失败"
        exit 1
    fi
else
    echo "ℹ️  未找到 xcodegen"
    echo ""
    echo "正在尝试安装 xcodegen..."
    echo "Installing xcodegen..."
    echo ""
    
    # 尝试使用 Homebrew 安装
    if command -v brew &> /dev/null; then
        echo "使用 Homebrew 安装 xcodegen..."
        brew install xcodegen
        
        echo ""
        echo "✅ xcodegen 安装完成，正在生成项目..."
        xcodegen generate
        
        if [ -d "MacMonitor.xcodeproj" ]; then
            echo ""
            echo "✅ 成功生成 Xcode 项目！"
            echo ""
            echo "🚀 运行: open MacMonitor.xcodeproj"
            exit 0
        fi
    else
        echo "❌ 未找到 Homebrew"
        echo ""
        echo "请选择以下方式之一:"
        echo ""
        echo "方案 A: 安装 xcodegen (推荐)"
        echo "  1. 安装 Homebrew (如果还没有):"
        echo "     /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        echo ""
        echo "  2. 安装 xcodegen:"
        echo "     brew install xcodegen"
        echo ""
        echo "  3. 重新运行此脚本:"
        echo "     ./generate_xcode_project.sh"
        echo ""
        echo "方案 B: 使用 swift package 生成"
        echo "  ./build_app.sh"
        echo ""
        echo "方案 C: 手动创建项目"
        echo "  参考 XCODE_PROJECT_SETUP.md"
        echo ""
        exit 1
    fi
fi
