import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Framio',
      debugShowCheckedModeBanner: false, // Remove DEBUG banner
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A90E2),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A90E2),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
      ),
      themeMode: ThemeMode.system, // Adapt to system theme
      home: const VideoScreenshotPage(),
    );
  }
}

class VideoScreenshotPage extends StatefulWidget {
  const VideoScreenshotPage({super.key});

  @override
  State<VideoScreenshotPage> createState() => _VideoScreenshotPageState();
}

enum FilterType {
  none,
  grayscale,
  sepia,
  vintage,
  brightness,
  contrast,
  blur
}

class _VideoScreenshotPageState extends State<VideoScreenshotPage> {
  VideoPlayerController? _controller;
  bool _isLoading = false;
  String? _videoPath;
  double _currentPosition = 0.0;
  int _imageQuality = 95;
  final GlobalKey _videoKey = GlobalKey();

  // Batch export
  List<double> _selectedFrames = [];
  bool _batchMode = false;

  // Filters
  FilterType _selectedFilter = FilterType.none;
  double _filterIntensity = 1.0;

  // Trim marks
  double _trimStart = 0.0;
  double _trimEnd = 1.0;
  bool _trimMode = false;

  // GIF creation
  double _gifStart = 0.0;
  double _gifEnd = 0.2; // Default 20% of video
  bool _isCreatingGif = false;

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
          _trimStart = 0.0;
          _trimEnd = 1.0;
          _selectedFrames.clear();
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

  // Frame-by-frame navigation
  Future<void> _nextFrame() async {
    if (_controller != null && _controller!.value.isInitialized) {
      final duration = _controller!.value.duration;
      final frameRate = 30; // Approximate frame rate
      final frameDuration = duration.inMilliseconds / (duration.inSeconds * frameRate);
      final currentMs = _currentPosition * duration.inMilliseconds;
      final newPosition = (currentMs + frameDuration) / duration.inMilliseconds;

      if (newPosition < 1.0) {
        await _seekToPosition(newPosition);
      }
    }
  }

  Future<void> _previousFrame() async {
    if (_controller != null && _controller!.value.isInitialized) {
      final duration = _controller!.value.duration;
      final frameRate = 30;
      final frameDuration = duration.inMilliseconds / (duration.inSeconds * frameRate);
      final currentMs = _currentPosition * duration.inMilliseconds;
      final newPosition = (currentMs - frameDuration) / duration.inMilliseconds;

      if (newPosition > 0.0) {
        await _seekToPosition(newPosition);
      }
    }
  }

  Future<Uint8List?> _captureFrame() async {
    try {
      RenderRepaintBoundary? boundary = _videoKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        throw Exception('Unable to capture frame');
      }

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

  // Apply filters to image
  Future<Uint8List> _applyFilter(Uint8List imageBytes) async {
    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) return imageBytes;

    switch (_selectedFilter) {
      case FilterType.grayscale:
        image = img.grayscale(image);
        break;
      case FilterType.sepia:
        image = img.sepia(image);
        break;
      case FilterType.brightness:
        image = img.adjustColor(image, brightness: _filterIntensity);
        break;
      case FilterType.contrast:
        image = img.adjustColor(image, contrast: _filterIntensity);
        break;
      case FilterType.blur:
        image = img.gaussianBlur(image, radius: (_filterIntensity * 10).toInt());
        break;
      default:
        break;
    }

    return Uint8List.fromList(img.encodeJpg(image, quality: _imageQuality));
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

      // Apply filter if selected
      final processedBytes = await _applyFilter(imageBytes);

      final result = await ImageGallerySaver.saveImage(
        processedBytes,
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

  // Batch export
  void _toggleBatchMode() {
    setState(() {
      _batchMode = !_batchMode;
      if (!_batchMode) {
        _selectedFrames.clear();
      }
    });
  }

  void _addFrameToBatch() {
    if (!_selectedFrames.contains(_currentPosition)) {
      setState(() {
        _selectedFrames.add(_currentPosition);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Frame added (${_selectedFrames.length} total)'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _exportBatch() async {
    if (_selectedFrames.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No frames selected')),
      );
      return;
    }

    await _requestPermissions();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Exporting ${_selectedFrames.length} frames...'),
          ],
        ),
      ),
    );

    try {
      for (int i = 0; i < _selectedFrames.length; i++) {
        await _seekToPosition(_selectedFrames[i]);
        await Future.delayed(const Duration(milliseconds: 200));

        final imageBytes = await _captureFrame();
        if (imageBytes != null) {
          final processedBytes = await _applyFilter(imageBytes);
          await ImageGallerySaver.saveImage(
            processedBytes,
            quality: _imageQuality,
            name: 'batch_${i + 1}_${DateTime.now().millisecondsSinceEpoch}',
          );
        }
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_selectedFrames.length} frames exported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _selectedFrames.clear();
          _batchMode = false;
        });
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting batch: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Share screenshot
  Future<void> _shareScreenshot() async {
    try {
      final imageBytes = await _captureFrame();
      if (imageBytes == null) return;

      final processedBytes = await _applyFilter(imageBytes);
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/screenshot_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await file.writeAsBytes(processedBytes);

      await Share.shareXFiles([XFile(file.path)], text: 'Check out this video frame!');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing: $e')),
        );
      }
    }
  }

  // Show filter dialog
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apply Filter'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<FilterType>(
                value: _selectedFilter,
                isExpanded: true,
                items: FilterType.values.map((filter) {
                  return DropdownMenuItem(
                    value: filter,
                    child: Text(filter.toString().split('.').last.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  this.setState(() {});
                },
              ),
              if (_selectedFilter != FilterType.none &&
                  _selectedFilter != FilterType.grayscale &&
                  _selectedFilter != FilterType.sepia) ...[
                const SizedBox(height: 16),
                Text('Intensity: ${_filterIntensity.toStringAsFixed(1)}'),
                Slider(
                  value: _filterIntensity,
                  min: 0.0,
                  max: 2.0,
                  onChanged: (value) {
                    setState(() {
                      _filterIntensity = value;
                    });
                    this.setState(() {});
                  },
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedFilter = FilterType.none;
                _filterIntensity = 1.0;
              });
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  // Show trim dialog
  void _showTrimDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Trim Video Region'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Start: ${(_trimStart * 100).toStringAsFixed(0)}%'),
              Slider(
                value: _trimStart.clamp(0.0, (_trimEnd - 0.05).clamp(0.0, 1.0)),
                min: 0.0,
                max: (_trimEnd - 0.05).clamp(0.0, 1.0),
                onChanged: (value) {
                  setState(() {
                    _trimStart = value.clamp(0.0, (_trimEnd - 0.05).clamp(0.0, 1.0));
                  });
                  this.setState(() {});
                },
              ),
              const SizedBox(height: 16),
              Text('End: ${(_trimEnd * 100).toStringAsFixed(0)}%'),
              Slider(
                value: _trimEnd.clamp((_trimStart + 0.05).clamp(0.0, 1.0), 1.0),
                min: (_trimStart + 0.05).clamp(0.0, 1.0),
                max: 1.0,
                onChanged: (value) {
                  setState(() {
                    _trimEnd = value.clamp((_trimStart + 0.05).clamp(0.0, 1.0), 1.0);
                  });
                  this.setState(() {});
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _trimStart = 0.0;
                _trimEnd = 1.0;
              });
              Navigator.pop(context);
            },
            child: const Text('Reset'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _trimMode = true;
                // Adjust current position if outside trim range
                if (_currentPosition < _trimStart) {
                  _currentPosition = _trimStart;
                  _seekToPosition(_trimStart);
                } else if (_currentPosition > _trimEnd) {
                  _currentPosition = _trimEnd;
                  _seekToPosition(_trimEnd);
                }
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Trim region set. Navigation limited to selected region.'),
                ),
              );
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showGifCreatorDialog() {
    if (_controller == null || !_controller!.value.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please load a video first')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.gif_box, color: Color(0xFF4A90E2)),
            SizedBox(width: 8),
            Text('Create GIF'),
          ],
        ),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select the video range for your GIF',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              // iOS-style range selector
              Container(
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    // Selected range overlay
                    Positioned(
                      left: _gifStart * MediaQuery.of(context).size.width * 0.6,
                      width: (_gifEnd - _gifStart) * MediaQuery.of(context).size.width * 0.6,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFF4C430), // Yellow
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4C430).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Start: ${(_gifStart * _controller!.value.duration.inSeconds).toStringAsFixed(1)}s',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'End: ${(_gifEnd * _controller!.value.duration.inSeconds).toStringAsFixed(1)}s',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Duration: ${((_gifEnd - _gifStart) * _controller!.value.duration.inSeconds).toStringAsFixed(1)}s',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: (_gifEnd - _gifStart) * _controller!.value.duration.inSeconds > 5
                          ? Colors.orange
                          : Colors.green,
                    ),
                  ),
                  Text(
                    '~${(((_gifEnd - _gifStart) * _controller!.value.duration.inSeconds) * 10).toInt()} frames',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.start, size: 16, color: Color(0xFF4A90E2)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Slider(
                      value: _gifStart.clamp(0.0, (_gifEnd - 0.1).clamp(0.0, 1.0)),
                      min: 0.0,
                      max: (_gifEnd - 0.1).clamp(0.0, 1.0),
                      activeColor: const Color(0xFFF4C430),
                      onChanged: (value) {
                        setState(() {
                          _gifStart = value.clamp(0.0, (_gifEnd - 0.1).clamp(0.0, 1.0));
                        });
                        this.setState(() {});
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.stop, size: 16, color: Color(0xFF4A90E2)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Slider(
                      value: _gifEnd.clamp((_gifStart + 0.1).clamp(0.0, 1.0), 1.0),
                      min: (_gifStart + 0.1).clamp(0.0, 1.0),
                      max: 1.0,
                      activeColor: const Color(0xFFF4C430),
                      onChanged: (value) {
                        setState(() {
                          _gifEnd = value.clamp((_gifStart + 0.1).clamp(0.0, 1.0), 1.0);
                        });
                        this.setState(() {});
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if ((_gifEnd - _gifStart) * _controller!.value.duration.inSeconds > 5)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange, width: 1),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber, size: 16, color: Colors.orange),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Long GIFs may take time to create and result in large files',
                          style: TextStyle(fontSize: 11, color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _createGif();
            },
            icon: const Icon(Icons.gif_box),
            label: const Text('Create GIF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A90E2),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createGif() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    setState(() {
      _isCreatingGif = true;
    });

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              SizedBox(width: 16),
              Text('Creating GIF... This may take a moment'),
            ],
          ),
          duration: Duration(seconds: 30),
        ),
      );

      final duration = _controller!.value.duration;
      final startTime = duration * _gifStart;
      final endTime = duration * _gifEnd;
      final frameDuration = const Duration(milliseconds: 100); // 10 fps

      List<img.Image> frames = [];

      // Capture frames
      for (var time = startTime; time <= endTime; time += frameDuration) {
        await _controller!.seekTo(time);
        await Future.delayed(const Duration(milliseconds: 100)); // Wait for frame to load

        final boundary = _videoKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
        if (boundary != null) {
          final image = await boundary.toImage(pixelRatio: 0.5); // Lower resolution for GIF
          final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
          if (byteData != null) {
            final pngBytes = byteData.buffer.asUint8List();
            final decodedImage = img.decodeImage(pngBytes);
            if (decodedImage != null) {
              frames.add(decodedImage);
            }
          }
        }

        if (frames.length >= 50) break; // Limit to 50 frames max
      }

      if (frames.isEmpty) {
        throw Exception('No frames captured');
      }

      // Create animated GIF
      final gif = img.GifEncoder();

      for (var frame in frames) {
        gif.addFrame(frame, duration: 10); // 100ms per frame = 10fps
      }

      final gifData = gif.finish();
      if (gifData == null || gifData.isEmpty) {
        throw Exception('Failed to encode GIF');
      }

      // Save GIF to gallery
      final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(gifData),
        quality: 100,
        name: 'framio_gif_${DateTime.now().millisecondsSinceEpoch}',
        isReturnImagePathOfIOS: true,
      );

      setState(() {
        _isCreatingGif = false;
      });

      if (result['isSuccess'] == true || result['filePath'] != null) {
        final sizeInMB = (gifData.length / 1024 / 1024).toStringAsFixed(2);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('GIF created! ${frames.length} frames, $sizeInMB MB'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        throw Exception('Failed to save GIF to gallery');
      }
    } catch (e) {
      setState(() {
        _isCreatingGif = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating GIF: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.white.withOpacity(0.3),
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
                    width: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
        title: Text(
          'Framio',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        actions: [
          if (_controller != null && _controller!.value.isInitialized) ...[
            IconButton(
              icon: Icon(_batchMode ? Icons.check_box : Icons.check_box_outline_blank),
              onPressed: _toggleBatchMode,
              tooltip: 'Batch Mode',
            ),
            IconButton(
              icon: const Icon(Icons.filter_vintage),
              onPressed: _showFilterDialog,
              tooltip: 'Filters',
            ),
            IconButton(
              icon: const Icon(Icons.content_cut),
              onPressed: _showTrimDialog,
              tooltip: 'Trim',
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'share') {
                  _shareScreenshot();
                } else if (value == 'gif') {
                  _showGifCreatorDialog();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.share),
                      SizedBox(width: 8),
                      Text('Share Frame'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'gif',
                  child: Row(
                    children: [
                      Icon(Icons.gif),
                      SizedBox(width: 8),
                      Text('Create GIF'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Status bars with glassmorphism
          if (_batchMode)
            ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                      ? const Color(0xFF6366F1).withOpacity(0.2)
                      : const Color(0xFF6366F1).withOpacity(0.15),
                    border: Border(
                      bottom: BorderSide(
                        color: const Color(0xFF6366F1).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.collections,
                            size: 18,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_selectedFrames.length} frames selected',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      if (_selectedFrames.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withOpacity(0.8),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _exportBatch,
                                  borderRadius: BorderRadius.circular(20),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.download, size: 16, color: Colors.white),
                                        SizedBox(width: 6),
                                        Text(
                                          'Export All',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          if (_selectedFilter != FilterType.none)
            ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                      ? const Color(0xFFF59E0B).withOpacity(0.2)
                      : const Color(0xFFF59E0B).withOpacity(0.15),
                    border: Border(
                      bottom: BorderSide(
                        color: const Color(0xFFF59E0B).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.filter_vintage,
                            size: 18,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _selectedFilter.toString().split('.').last.toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedFilter = FilterType.none;
                          });
                        },
                        child: Text(
                          'Clear',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
          // Frame navigation controls with glassmorphism
          if (_controller != null && _controller!.value.isInitialized)
            ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark
                      ? Colors.black.withOpacity(0.3)
                      : Colors.white.withOpacity(0.5),
                    border: Border(
                      top: BorderSide(
                        color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.1),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.skip_previous_rounded,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        onPressed: _previousFrame,
                        tooltip: 'Previous Frame',
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF4A90E2),
                              const Color(0xFF4A90E2).withOpacity(0.8),
                            ],
                          ),
                        ),
                        child: IconButton(
                          icon: Icon(
                            _controller!.value.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () {
                            setState(() {
                              if (_controller!.value.isPlaying) {
                                _controller!.pause();
                              } else {
                                _controller!.play();
                              }
                            });
                          },
                          tooltip: 'Play/Pause',
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          Icons.skip_next_rounded,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        onPressed: _nextFrame,
                        tooltip: 'Next Frame',
                      ),
                      if (_batchMode) ...[
                        const SizedBox(width: 16),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _selectedFrames.contains(_currentPosition)
                              ? const Color(0xFF6366F1)
                              : Colors.transparent,
                            border: Border.all(
                              color: const Color(0xFF6366F1),
                              width: 2,
                            ),
                          ),
                          child: IconButton(
                            icon: Icon(
                              _selectedFrames.contains(_currentPosition)
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_border_rounded,
                              color: _selectedFrames.contains(_currentPosition)
                                  ? Colors.white
                                  : const Color(0xFF6366F1),
                            ),
                            onPressed: _addFrameToBatch,
                            tooltip: 'Add to Batch',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          if (_controller != null && _controller!.value.isInitialized)
            ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark
                      ? Colors.black.withOpacity(0.3)
                      : Colors.white.withOpacity(0.5),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(
                              _controller!.value.duration * _currentPosition,
                            ),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          Text(
                            _formatDuration(_controller!.value.duration),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                          activeTrackColor: const Color(0xFF4A90E2),
                          inactiveTrackColor: isDark
                            ? Colors.white.withOpacity(0.2)
                            : Colors.black.withOpacity(0.1),
                          thumbColor: const Color(0xFF4A90E2),
                          overlayColor: const Color(0xFF4A90E2).withOpacity(0.2),
                        ),
                        child: Slider(
                          value: _currentPosition.clamp(
                            _trimMode ? _trimStart : 0.0,
                            _trimMode ? _trimEnd : 1.0,
                          ),
                          min: _trimMode ? _trimStart : 0.0,
                          max: _trimMode ? _trimEnd : 1.0,
                          onChanged: (value) {
                            _seekToPosition(value);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.white.withOpacity(0.5),
                  border: Border(
                    top: BorderSide(
                      color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.1),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Image Quality:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: _imageQuality >= 90
                                ? const Color(0xFF10B981).withOpacity(0.2)
                                : _imageQuality >= 70
                                    ? const Color(0xFFF59E0B).withOpacity(0.2)
                                    : const Color(0xFFEF4444).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_imageQuality}%',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _imageQuality >= 90
                                  ? const Color(0xFF10B981)
                                  : _imageQuality >= 70
                                      ? const Color(0xFFF59E0B)
                                      : const Color(0xFFEF4444),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                        activeTrackColor: _imageQuality >= 90
                            ? const Color(0xFF10B981)
                            : _imageQuality >= 70
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFFEF4444),
                        inactiveTrackColor: isDark
                          ? Colors.white.withOpacity(0.2)
                          : Colors.black.withOpacity(0.1),
                        thumbColor: _imageQuality >= 90
                            ? const Color(0xFF10B981)
                            : _imageQuality >= 70
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFFEF4444),
                        overlayColor: (_imageQuality >= 90
                            ? const Color(0xFF10B981)
                            : _imageQuality >= 70
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFFEF4444)).withOpacity(0.2),
                      ),
                      child: Slider(
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
                    ),
                    Text(
                      _imageQuality >= 90
                          ? 'High Quality (Large file)'
                          : _imageQuality >= 70
                              ? 'Medium Quality (Balanced)'
                              : 'Low Quality (Small file)',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF4A90E2).withOpacity(0.8),
                              const Color(0xFF4A90E2).withOpacity(0.6),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _pickVideo,
                            borderRadius: BorderRadius.circular(16),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.video_library_rounded, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'Load Video',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _controller != null && _controller!.value.isInitialized
                              ? [
                                  const Color(0xFF6366F1).withOpacity(0.8),
                                  const Color(0xFF8B5CF6).withOpacity(0.6),
                                ]
                              : [
                                  Colors.grey.withOpacity(0.3),
                                  Colors.grey.withOpacity(0.2),
                                ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _controller != null && _controller!.value.isInitialized
                                ? _saveScreenshot
                                : null,
                            borderRadius: BorderRadius.circular(16),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt_rounded, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'Save Frame',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
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
