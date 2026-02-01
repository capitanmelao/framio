#!/bin/bash

# Add Flutter to PATH
export PATH="$HOME/flutter/bin:$PATH"

# Navigate to project directory
cd "$(dirname "$0")"

echo "🚀 Starting Video Screenshot App..."
echo ""
echo "Available commands:"
echo "  1. Run app on connected device"
echo "  2. List available devices"
echo "  3. Build APK for Android"
echo "  4. Build for iOS"
echo ""

# Check if argument provided
if [ "$1" == "devices" ]; then
    flutter devices
elif [ "$1" == "build-apk" ]; then
    flutter build apk --release
    echo "✅ APK built at: build/app/outputs/flutter-apk/app-release.apk"
elif [ "$1" == "build-ios" ]; then
    flutter build ios --release
    echo "✅ iOS build complete. Open ios/Runner.xcworkspace in Xcode to archive."
else
    # Default: run the app
    flutter run
fi
