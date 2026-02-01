# 📹 How to Add Videos to iOS Simulator

## Method 1: Drag & Drop (Easiest)

1. **Find a video file** on your Mac (any .mp4, .mov, .m4v file)
2. **Drag the video file** directly onto the iOS Simulator window
3. The video will automatically be saved to the **Photos app** in the simulator
4. Now you can open your Video Screenshot app and load the video!

---

## Method 2: Use Safari in Simulator

1. **Open Safari** in the iOS Simulator
2. Go to a website with a video (like a sample video site)
3. **Long press** on the video
4. Select **"Save Video"** or **"Add to Photos"**
5. The video will be saved to the Photos app

---

## Method 3: Command Line (Quick)

Use this command to add a video from your Mac to the simulator:

```bash
# Replace VIDEO_FILE.mp4 with your actual video file path
xcrun simctl addmedia booted ~/Downloads/VIDEO_FILE.mp4
```

Or if you don't have a video, download a sample:

```bash
# Download a sample video
curl -o ~/Downloads/sample-video.mp4 https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4

# Add it to the simulator
xcrun simctl addmedia booted ~/Downloads/sample-video.mp4
```

---

## Method 4: Record a Video in Simulator

1. **Open Camera app** in the simulator
2. Switch to **Video mode**
3. **Record a short video**
4. The video will be saved to Photos
5. Use it to test your app!

---

## Quick Test - Let me add a sample video for you!

I can download a sample video and add it to your simulator right now.
