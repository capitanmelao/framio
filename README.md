# 📱 Video Screenshot Pro

A professional Flutter app for iOS and Android that extracts, edits, and shares video frames with advanced features.

![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20Android-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.41.0-02569B?logo=flutter)
![License](https://img.shields.io/badge/license-MIT-green)

## ✨ Features

### Core Functionality
- 📸 **High-Quality Frame Capture** - Extract perfect moments from any video
- 🎯 **Frame-by-Frame Navigation** - Precision control with previous/next buttons
- 📊 **Quality Control** - Adjustable quality from 30% to 100%

### Premium Features
- 📦 **Batch Export** - Select and save multiple frames at once
- 🎨 **7 Professional Filters**
  - Grayscale
  - Sepia
  - Brightness (adjustable)
  - Contrast (adjustable)
  - Blur (adjustable)
  - Vintage
  - None
- ✂️ **Video Trimming** - Focus on specific video segments
- 📤 **Universal Sharing** - Export to any app or cloud service
- ⏸️ **Playback Controls** - Play, pause, and scrub through videos

### User Experience
- 🎯 Intuitive toolbar with quick access to all features
- 📊 Real-time quality indicators
- 🎨 Visual filter intensity controls
- 💾 Automatic gallery saving
- 📱 Native iOS and Android UI

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0.0 or higher
- Dart 3.0.0 or higher
- For iOS: Xcode 14+, CocoaPods
- For Android: Android Studio, Android SDK (API 21+)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/capitanmelao/video_screenshot_app.git
cd video_screenshot_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. For iOS, install CocoaPods:
```bash
cd ios
pod install
cd ..
```

4. Run the app:
```bash
flutter run
```

## 📸 Screenshots

<!-- Add your app screenshots here -->

## 🎯 How to Use

### Basic Screenshot
1. Tap **"Load Video"** to select a video from your device
2. Use the slider to navigate to your desired frame
3. Tap **"Save Frame"** to save to your gallery

### Batch Export
1. Enable **Batch Mode** (checkbox icon in toolbar)
2. Navigate to frames you want to save
3. Tap the **bookmark button** to add each frame
4. Tap **"Export All"** to save all selected frames

### Apply Filters
1. Tap the **filter icon** (🎨)
2. Choose your desired filter
3. Adjust intensity if applicable
4. All saved frames will have the filter applied

### Trim Video
1. Tap the **scissors icon** (✂️)
2. Set start and end points with sliders
3. Navigation is now limited to the selected region

### Share Frames
1. Tap the **menu icon** (⋮)
2. Select **"Share Frame"**
3. Choose your destination app

## 🛠️ Built With

- [Flutter](https://flutter.dev/) - UI framework
- [video_player](https://pub.dev/packages/video_player) - Video playback
- [image](https://pub.dev/packages/image) - Image processing and filters
- [file_picker](https://pub.dev/packages/file_picker) - File selection
- [image_gallery_saver](https://pub.dev/packages/image_gallery_saver) - Gallery saving
- [share_plus](https://pub.dev/packages/share_plus) - Sharing functionality
- [permission_handler](https://pub.dev/packages/permission_handler) - Permissions

## 📦 Project Structure

```
video_screenshot_app/
├── lib/
│   ├── main.dart              # Main app with all features
│   └── main_backup.dart       # Original simple version
├── android/                   # Android-specific files
├── ios/                       # iOS-specific files
├── FEATURES.md               # Detailed feature documentation
├── APP_STORE_GUIDE.md        # App Store submission guide
└── README.md                 # This file
```

## 🎨 Features Comparison

| Feature | Basic Apps | Mid-tier Apps | Video Screenshot Pro |
|---------|-----------|---------------|---------------------|
| Frame Capture | ✅ | ✅ | ✅ |
| Quality Control | ❌ | Basic | ✅ Full (30-100%) |
| Batch Export | ❌ | ❌ | ✅ |
| Filters | ❌ | 2-3 | ✅ 7 Professional |
| Frame Navigation | ❌ | ❌ | ✅ Previous/Next |
| Video Trimming | ❌ | ❌ | ✅ |
| Share/Cloud | Basic | ✅ | ✅ Universal |

## 🚢 Building for Production

### Android APK
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### iOS
```bash
flutter build ios --release
```
Then open `ios/Runner.xcworkspace` in Xcode to archive.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Author

**capitanmelao**
- GitHub: [@capitanmelao](https://github.com/capitanmelao)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- All the open-source package contributors
- The Flutter community

## 📞 Support

For support, please open an issue on GitHub or contact leinso@gmail.com

---

Made with ❤️ using Flutter
