#!/bin/bash

# Mac Monitor Swift Agent - Build and Run Script

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Check if we're on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo "⚠️  Warning: This agent is optimized for macOS."
    echo "   Menu bar features will not be available on $(uname)."
    echo ""
fi

# Parse command line arguments
BUILD_TYPE="debug"
COMMAND="run"

while [[ $# -gt 0 ]]; do
    case $1 in
        --release)
            BUILD_TYPE="release"
            shift
            ;;
        build)
            COMMAND="build"
            shift
            ;;
        run)
            COMMAND="run"
            shift
            ;;
        clean)
            COMMAND="clean"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--release] [build|run|clean]"
            exit 1
            ;;
    esac
done

case $COMMAND in
    build)
        echo "🔨 Building Mac Monitor Agent ($BUILD_TYPE)..."
        if [ "$BUILD_TYPE" == "release" ]; then
            swift build -c release
            echo "✅ Build complete! Executable: .build/release/MacMonitorAgent"
        else
            swift build
            echo "✅ Build complete! Executable: .build/debug/MacMonitorAgent"
        fi
        ;;
    
    run)
        echo "🚀 Building and running Mac Monitor Agent ($BUILD_TYPE)..."
        if [ "$BUILD_TYPE" == "release" ]; then
            swift run -c release
        else
            swift run
        fi
        ;;
    
    clean)
        echo "🧹 Cleaning build artifacts..."
        swift package clean
        echo "✅ Clean complete!"
        ;;
esac
