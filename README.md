# 📱 Framio

**Professional video frame editor for iOS and Android**

Extract, edit, and share perfect moments from any video with advanced filters and batch export.

![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20Android-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.41.0-02569B?logo=flutter)
![License](https://img.shields.io/badge/license-MIT-green)

---

## ✨ Features

### 🎯 Core Functionality
- **High-Quality Frame Capture** - Extract perfect moments at up to 100% quality
- **Frame-by-Frame Navigation** - Precision control with previous/next buttons
- **Adjustable Quality** - Choose from 30% to 100% compression
- **Instant Gallery Save** - Automatically saves to your photo library

### 🎨 Premium Features
- **📦 Batch Export** - Select and save multiple frames at once
- **🎨 7 Professional Filters**
  - Grayscale - Classic black & white
  - Sepia - Vintage warm tone
  - Brightness - Adjustable light levels
  - Contrast - Enhanced detail
  - Blur - Artistic gaussian blur
  - Vintage - Retro film look
  - None - Original quality
- **✂️ Video Trimming** - Focus on specific video segments
- **📤 Universal Sharing** - Export to any app or cloud service
- **⏯️ Playback Controls** - Play, pause, and scrub smoothly

### 💎 User Experience
- Intuitive toolbar with quick feature access
- Real-time quality indicators
- Visual filter intensity controls
- Status bars for batch mode and active filters
- Native iOS and Android UI
- Smooth 30fps video playback

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0.0 or higher
- Dart 3.0.0 or higher
- **For iOS:** Xcode 14+, CocoaPods
- **For Android:** Android Studio, Android SDK (API 21+)

### Installation

1. **Clone the repository:**
```bash
git clone https://github.com/capitanmelao/framio.git
cd framio
```

2. **Install dependencies:**
```bash
flutter pub get
```

3. **For iOS, install CocoaPods:**
```bash
cd ios
pod install
cd ..
```

4. **Run the app:**
```bash
flutter run
```

---

## 🎯 How to Use

### Basic Frame Capture
1. Tap **"Load Video"** to select a video
2. Use the slider to navigate to your frame
3. Tap **"Save Frame"** to save to gallery

### Batch Export
1. Enable **Batch Mode** (checkbox icon)
2. Navigate and tap **bookmark** for each frame
3. Tap **"Export All"** to save all frames

### Apply Filters
1. Tap the **filter icon** (🎨)
2. Choose your filter
3. Adjust intensity (if applicable)
4. All frames will have the filter applied

### Trim Video
1. Tap the **scissors icon** (✂️)
2. Set start and end points
3. Navigation limited to that region

### Share Frames
1. Tap the **menu** (⋮)
2. Select **"Share Frame"**
3. Choose destination app

---

## 🛠️ Built With

- [Flutter](https://flutter.dev/) - Cross-platform UI framework
- [video_player](https://pub.dev/packages/video_player) - Video playback & frame control
- [image](https://pub.dev/packages/image) - Image processing & filters
- [file_picker](https://pub.dev/packages/file_picker) - Video file selection
- [image_gallery_saver](https://pub.dev/packages/image_gallery_saver) - Photo library integration
- [share_plus](https://pub.dev/packages/share_plus) - Universal sharing
- [permission_handler](https://pub.dev/packages/permission_handler) - Runtime permissions

---

## 📦 Project Structure

```
framio/
├── lib/
│   ├── main.dart              # Main app with all features
│   └── main_backup.dart       # Original simple version (backup)
├── android/                   # Android platform files
├── ios/                       # iOS platform files
├── FEATURES.md                # Detailed feature documentation
├── APP_STORE_GUIDE.md         # App Store submission guide
└── README.md                  # This file
```

---

## 🎨 Feature Comparison

| Feature | Basic Apps | Mid-tier Apps | **Framio** |
|---------|-----------|---------------|------------|
| Frame Capture | ✅ | ✅ | ✅ |
| Quality Control | ❌ | Basic | ✅ Full (30-100%) |
| Batch Export | ❌ | ❌ | ✅ |
| Filters | ❌ | 2-3 | ✅ 7 Professional |
| Frame Navigation | ❌ | ❌ | ✅ Precision Controls |
| Video Trimming | ❌ | ❌ | ✅ |
| Share/Cloud | Basic | ✅ | ✅ Universal |

---

## 🚢 Building for Production

### Android APK
```bash
flutter build apk --release
```
📦 Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (for Google Play)
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```
Then open `ios/Runner.xcworkspace` in Xcode to archive and distribute.

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 👨‍💻 Author

**capitanmelao**
- GitHub: [@capitanmelao](https://github.com/capitanmelao)
- Email: leinso@gmail.com

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- All open-source package contributors
- The Flutter community for support and inspiration

---

## 📞 Support

For issues, questions, or feature requests:
- 🐛 [Open an issue](https://github.com/capitanmelao/framio/issues)
- 📧 Email: leinso@gmail.com

---

## 🎯 Roadmap

- [ ] GIF creation from selected frames
- [ ] More filters (HDR, Vintage, Film grain)
- [ ] Video speed control
- [ ] Timestamp overlay
- [ ] Custom watermarks
- [ ] Side-by-side comparison mode
- [ ] Cloud backup integration

---

<div align="center">

**Made with ❤️ using Flutter**

[⭐ Star this repo](https://github.com/capitanmelao/framio) if you find it useful!

</div>
