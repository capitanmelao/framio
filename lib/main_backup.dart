import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Screenshot',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const VideoScreenshotPage(),
    );
  }
}

class VideoScreenshotPage extends StatefulWidget {
  const VideoScreenshotPage({super.key});

  @override
  State<VideoScreenshotPage> createState() => _VideoScreenshotPageState();
}

class _VideoScreenshotPageState extends State<VideoScreenshotPage> {
  VideoPlayerController? _controller;
  bool _isLoading = false;
  String? _videoPath;
  double _currentPosition = 0.0;
  int _imageQuality = 95; // Quality from 0-100
  final GlobalKey _videoKey = GlobalKey();

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (status.isDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Storage permission is required to save images'),
            ),
          );
        }
      }
    } else if (Platform.isIOS) {
      final status = await Permission.photos.request();
      if (status.isDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photos permission is required to save images'),
            ),
          );
        }
      }
    }
  }

  Future<void> _pickVideo() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _isLoading = true;
        });

        _controller?.dispose();

        _videoPath = result.files.single.path!;
        _controller = VideoPlayerController.file(File(_videoPath!));

        await _controller!.initialize();
        await _controller!.setLooping(false);
        await _controller!.pause();

        setState(() {
          _isLoading = false;
          _currentPosition = 0.0;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading video: $e')),
        );
      }
    }
  }

  Future<void> _seekToPosition(double position) async {
    if (_controller != null && _controller!.value.isInitialized) {
      final duration = _controller!.value.duration;
      final seekPosition = duration * position;
      await _controller!.seekTo(seekPosition);
      setState(() {
        _currentPosition = position;
      });
    }
  }

  Future<Uint8List?> _captureFrame() async {
    try {
      // Find the RenderRepaintBoundary
      RenderRepaintBoundary? boundary = _videoKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        throw Exception('Unable to capture frame');
      }

      // Capture the image
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('Failed to convert image to bytes');
      }

      return byteData.buffer.asUint8List();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error capturing frame: $e')),
        );
      }
      return null;
    }
  }

  Future<void> _saveScreenshot() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please load a video first')),
      );
      return;
    }

    await _requestPermissions();

    try {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(width: 16),
                Text('Saving screenshot...'),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }

      final imageBytes = await _captureFrame();

      if (imageBytes == null) {
        throw Exception('Failed to capture frame');
      }

      // Save to gallery with user-defined quality
      final result = await ImageGallerySaver.saveImage(
        imageBytes,
        quality: _imageQuality,
        name: 'video_screenshot_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (mounted) {
        if (result['isSuccess'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Screenshot saved to gallery!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw Exception('Failed to save image');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving screenshot: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Video Screenshot'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : _controller != null && _controller!.value.isInitialized
                      ? RepaintBoundary(
                          key: _videoKey,
                          child: AspectRatio(
                            aspectRatio: _controller!.value.aspectRatio,
                            child: VideoPlayer(_controller!),
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.video_library,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No video loaded',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap the button below to select a video',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
            ),
          ),
          if (_controller != null && _controller!.value.isInitialized)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey[100],
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(
                          _controller!.value.duration * _currentPosition,
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        _formatDuration(_controller!.value.duration),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  Slider(
                    value: _currentPosition,
                    min: 0.0,
                    max: 1.0,
                    onChanged: (value) {
                      _seekToPosition(value);
                    },
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[50],
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Image Quality:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${_imageQuality}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _imageQuality >= 90
                            ? Colors.green
                            : _imageQuality >= 70
                                ? Colors.orange
                                : Colors.red,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _imageQuality.toDouble(),
                  min: 30,
                  max: 100,
                  divisions: 70,
                  label: '$_imageQuality%',
                  onChanged: (value) {
                    setState(() {
                      _imageQuality = value.round();
                    });
                  },
                ),
                Text(
                  _imageQuality >= 90
                      ? 'High Quality (Large file)'
                      : _imageQuality >= 70
                          ? 'Medium Quality (Balanced)'
                          : 'Low Quality (Small file)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickVideo,
                    icon: const Icon(Icons.video_library),
                    label: const Text('Load Video'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _controller != null &&
                            _controller!.value.isInitialized
                        ? _saveScreenshot
                        : null,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Save Frame'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
