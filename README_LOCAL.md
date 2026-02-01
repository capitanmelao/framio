# Video Screenshot App

A simple cross-platform mobile application for iOS and Android that allows users to load videos, scrub through frames using a slider, and save selected frames as JPG images to their photo gallery.

## Features

- Load videos from device storage
- Scrub through video frames with a smooth slider
- Preview the current frame
- Save any frame as a high-quality JPG to your photo gallery
- Clean, simple UI with Material Design
- Works on both iOS and Android

## Prerequisites

Before you begin, ensure you have the following installed:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.0.0 or higher)
- For iOS development:
  - macOS
  - Xcode 14 or higher
  - CocoaPods
- For Android development:
  - Android Studio
  - Android SDK (API level 21 or higher)

## Installation

1. Navigate to the project directory:
```bash
cd framio
```

2. Install dependencies:
```bash
flutter pub get
```

3. For iOS, install CocoaPods dependencies:
```bash
cd ios
pod install
cd ..
```

## Running the App

### Quick Start (Easy Method):

Since Flutter is now installed, you can use the provided script:

```bash
./run_app.sh
```

Or manually add Flutter to your PATH in your current terminal:
```bash
export PATH="$HOME/flutter/bin:$PATH"
```

**IMPORTANT**: To make Flutter available permanently in new terminal windows, restart your terminal or run:
```bash
source ~/.zshrc
```

### On Android:

1. Connect an Android device or start an emulator
2. Run:
```bash
export PATH="$HOME/flutter/bin:$PATH"
flutter run
```

Or simply:
```bash
./run_app.sh
```

### On iOS:

1. Connect an iOS device or start a simulator
2. Run:
```bash
export PATH="$HOME/flutter/bin:$PATH"
flutter run
```

Or simply:
```bash
./run_app.sh
```

### Other Useful Commands:

List available devices:
```bash
./run_app.sh devices
```

Build Android APK:
```bash
./run_app.sh build-apk
```

Build for iOS:
```bash
./run_app.sh build-ios
```

## Building for Production

### Android APK:
```bash
flutter build apk --release
```

The APK will be located at: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (for Google Play):
```bash
flutter build appbundle --release
```

### iOS:
```bash
flutter build ios --release
```

Then open `ios/Runner.xcworkspace` in Xcode to archive and distribute.

## Permissions

The app requires the following permissions:

### Android:
- `READ_EXTERNAL_STORAGE` - To access videos from device storage
- `WRITE_EXTERNAL_STORAGE` - To save screenshots (Android 12 and below)
- `READ_MEDIA_VIDEO` - To access videos (Android 13+)
- `READ_MEDIA_IMAGES` - To save to gallery (Android 13+)

### iOS:
- Photo Library Access - To save screenshots to the photo library
- Photo Library Usage - To access the photo library

## Usage

1. **Load a Video**: Tap the "Load Video" button to select a video from your device
2. **Select Frame**: Use the slider below the video to scrub through and find your desired frame
3. **Save Screenshot**: Tap the "Save Frame" button to save the current frame as a JPG to your photo gallery

## Dependencies

- `video_player` - Video playback functionality
- `file_picker` - Video file selection
- `image_gallery_saver` - Saving images to photo gallery
- `path_provider` - File path management
- `permission_handler` - Runtime permissions

## Troubleshooting

### iOS Issues:
- If you get permission errors, ensure Info.plist contains the required privacy descriptions
- Run `pod install` in the ios directory if you encounter build errors

### Android Issues:
- If permissions aren't working, ensure AndroidManifest.xml contains all required permissions
- For Android 13+, make sure you're using the new photo picker permissions

### General:
- Run `flutter clean` and `flutter pub get` if you encounter dependency issues
- Ensure your Flutter SDK is up to date: `flutter upgrade`

## Project Structure

```
framio/
├── lib/
│   └── main.dart          # Main application code
├── android/               # Android-specific configuration
├── ios/                   # iOS-specific configuration
├── pubspec.yaml          # Project dependencies
└── README.md             # This file
```

## License

This project is open source and available for personal and commercial use.
