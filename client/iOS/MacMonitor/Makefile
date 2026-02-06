# Makefile for Mac Monitor iOS App
# 
# 使用方法 / Usage:
#   make generate  - 生成 Xcode 项目
#   make build     - 构建应用
#   make run       - 运行应用
#   make test      - 运行测试
#   make clean     - 清理构建
#   make help      - 显示帮助

.PHONY: help generate build run test clean install-tools open

# 默认目标
.DEFAULT_GOAL := help

# 项目配置
PROJECT_NAME = MacMonitor
SCHEME = MacMonitor
CONFIGURATION = Debug
SIMULATOR = iPhone 15 Pro

# 颜色输出
GREEN = \033[0;32m
YELLOW = \033[0;33m
RED = \033[0;31m
NC = \033[0m # No Color

help: ## 显示此帮助信息
	@echo "$(GREEN)Mac Monitor iOS App - Makefile$(NC)"
	@echo ""
	@echo "$(YELLOW)可用命令:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)环境要求:$(NC)"
	@echo "  - macOS"
	@echo "  - Xcode 15.0+"
	@echo "  - xcodegen (可选，用于生成项目)"
	@echo ""

check-macos: ## 检查是否在 macOS 上运行
	@if [ "$$(uname)" != "Darwin" ]; then \
		echo "$(RED)错误: 此操作需要在 macOS 上运行$(NC)"; \
		exit 1; \
	fi

install-tools: check-macos ## 安装必要的工具
	@echo "$(GREEN)安装开发工具...$(NC)"
	@if ! command -v brew &> /dev/null; then \
		echo "$(YELLOW)安装 Homebrew...$(NC)"; \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
	fi
	@if ! command -v xcodegen &> /dev/null; then \
		echo "$(YELLOW)安装 xcodegen...$(NC)"; \
		brew install xcodegen; \
	fi
	@echo "$(GREEN)✓ 工具安装完成$(NC)"

generate: check-macos ## 生成 Xcode 项目
	@echo "$(GREEN)生成 Xcode 项目...$(NC)"
	@./generate_xcode_project.sh
	@echo "$(GREEN)✓ 项目生成完成$(NC)"

open: check-macos ## 打开 Xcode 项目
	@if [ ! -d "$(PROJECT_NAME).xcodeproj" ]; then \
		echo "$(YELLOW)项目文件不存在，正在生成...$(NC)"; \
		$(MAKE) generate; \
	fi
	@echo "$(GREEN)打开 Xcode 项目...$(NC)"
	@open $(PROJECT_NAME).xcodeproj

build: check-macos ## 构建应用
	@echo "$(GREEN)构建应用...$(NC)"
	@./build_app.sh $(CONFIGURATION)

run: check-macos ## 运行应用
	@echo "$(GREEN)运行应用...$(NC)"
	@./run_app.sh

test: check-macos ## 运行测试
	@if [ ! -d "$(PROJECT_NAME).xcodeproj" ]; then \
		echo "$(YELLOW)项目文件不存在，正在生成...$(NC)"; \
		$(MAKE) generate; \
	fi
	@echo "$(GREEN)运行测试...$(NC)"
	@xcodebuild test \
		-project $(PROJECT_NAME).xcodeproj \
		-scheme $(SCHEME) \
		-destination 'platform=iOS Simulator,name=$(SIMULATOR)' \
		| grep -E "^Test|passed|failed" || true
	@echo "$(GREEN)✓ 测试完成$(NC)"

clean: check-macos ## 清理构建文件
	@echo "$(GREEN)清理构建文件...$(NC)"
	@if [ -d "$(PROJECT_NAME).xcodeproj" ]; then \
		xcodebuild clean \
			-project $(PROJECT_NAME).xcodeproj \
			-scheme $(SCHEME) \
			-configuration $(CONFIGURATION) \
			> /dev/null 2>&1 || true; \
	fi
	@rm -rf build/ DerivedData/ *.log
	@echo "$(GREEN)✓ 清理完成$(NC)"

clean-all: clean ## 清理所有文件（包括项目文件）
	@echo "$(YELLOW)删除生成的项目文件...$(NC)"
	@rm -rf $(PROJECT_NAME).xcodeproj
	@echo "$(GREEN)✓ 完全清理完成$(NC)"

info: check-macos ## 显示项目信息
	@echo "$(GREEN)项目信息:$(NC)"
	@echo "  项目名称: $(PROJECT_NAME)"
	@echo "  Scheme: $(SCHEME)"
	@echo "  配置: $(CONFIGURATION)"
	@echo "  模拟器: $(SIMULATOR)"
	@echo ""
	@if command -v xcodebuild &> /dev/null; then \
		echo "$(GREEN)Xcode 版本:$(NC)"; \
		xcodebuild -version; \
	else \
		echo "$(RED)未安装 Xcode$(NC)"; \
	fi
	@echo ""
	@if [ -d "$(PROJECT_NAME).xcodeproj" ]; then \
		echo "$(GREEN)✓ 项目文件已生成$(NC)"; \
	else \
		echo "$(YELLOW)✗ 项目文件未生成，运行 'make generate'$(NC)"; \
	fi

setup: install-tools generate ## 完整设置（安装工具 + 生成项目）
	@echo "$(GREEN)✓ 设置完成！$(NC)"
	@echo ""
	@echo "$(YELLOW)下一步:$(NC)"
	@echo "  1. 运行 'make open' 打开 Xcode"
	@echo "  2. 配置签名和团队"
	@echo "  3. 运行 'make build' 构建应用"
	@echo "  4. 运行 'make run' 运行应用"
	@echo ""

# 快捷命令别名
gen: generate ## generate 的别名

# Release 构建
build-release: check-macos ## 构建 Release 版本
	@echo "$(GREEN)构建 Release 版本...$(NC)"
	@./build_app.sh Release

# 显示可用的模拟器
simulators: check-macos ## 列出可用的模拟器
	@echo "$(GREEN)可用的模拟器:$(NC)"
	@xcrun simctl list devices | grep -E "iPhone|iPad" | grep -v "unavailable"
