# 🚀 Quick Start Guide - Video Screenshot App

## ✅ Setup is COMPLETE!

The project is fully configured and ready to run. Here's how to use it:

---

## 📱 Running on Your iPhone (Recommended)

Your iPhone is detected! Just need one quick setup step:

### Enable Developer Mode (One-time setup):
1. On your iPhone, go to **Settings**
2. Navigate to **Privacy & Security**
3. Scroll down to **Developer Mode**
4. Toggle it **ON**
5. Your iPhone will restart
6. After restart, confirm Developer Mode

### Then Run the App:
```bash
cd /Users/carlos/App/video_screenshot_app
./run_app.sh
```

When prompted, select your iPhone from the list!

---

## 🖥️ Running on macOS (Instant - No Setup Needed)

You can test the app RIGHT NOW on your Mac:

```bash
cd /Users/carlos/App/video_screenshot_app
./run_app.sh
```

When prompted, select **macOS** from the device list.

---

## 🌐 Running in Chrome Browser

```bash
cd /Users/carlos/App/video_screenshot_app
export PATH="$HOME/flutter/bin:$PATH"
flutter run -d chrome
```

---

## 🎯 How to Use the App

1. **Load Video**: Tap "Load Video" button to select a video from your device
2. **Scrub Frame**: Use the slider to find the exact frame you want to capture
3. **Save Screenshot**: Tap "Save Frame" to save the current frame as JPG to your photo gallery

---

## 📦 Building for Distribution

### Build Android APK:
```bash
./run_app.sh build-apk
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### Build for iOS:
```bash
./run_app.sh build-ios
```
Then open `ios/Runner.xcworkspace` in Xcode to archive and upload to App Store.

---

## 🔧 Troubleshooting

### "Command not found: flutter"
Run this in your terminal:
```bash
source ~/.zshrc
```

Or restart your terminal window.

### "No devices found"
- **For iPhone**: Enable Developer Mode (see above)
- **For Android**: Install Android Studio and create an emulator
- **For Mac**: Should work automatically - select "macOS" when prompted

### App won't install on iPhone
1. Make sure your iPhone is unlocked
2. If prompted on iPhone, tap "Trust This Computer"
3. Enable Developer Mode in Settings → Privacy & Security

---

## 🎉 You're All Set!

The app is ready to use. Try it on your Mac right now with:

```bash
cd /Users/carlos/App/video_screenshot_app
./run_app.sh
```

Enjoy capturing video screenshots! 📸
