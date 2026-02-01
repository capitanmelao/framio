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
      title: 'Video Screenshot Pro',
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
                value: _trimStart,
                min: 0.0,
                max: _trimEnd - 0.05,
                onChanged: (value) {
                  setState(() {
                    _trimStart = value;
                  });
                  this.setState(() {});
                },
              ),
              const SizedBox(height: 16),
              Text('End: ${(_trimEnd * 100).toStringAsFixed(0)}%'),
              Slider(
                value: _trimEnd,
                min: _trimStart + 0.05,
                max: 1.0,
                onChanged: (value) {
                  setState(() {
                    _trimEnd = value;
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
        title: const Text('Video Screenshot Pro'),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('GIF creation coming soon! Select multiple frames in batch mode.'),
                    ),
                  );
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
          // Status bar
          if (_batchMode)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.deepPurple.shade100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Batch Mode: ${_selectedFrames.length} frames selected',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (_selectedFrames.isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: _exportBatch,
                      icon: const Icon(Icons.download, size: 16),
                      label: const Text('Export All'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                ],
              ),
            ),
          if (_selectedFilter != FilterType.none)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.orange.shade100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter: ${_selectedFilter.toString().split('.').last.toUpperCase()}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedFilter = FilterType.none;
                      });
                    },
                    child: const Text('Clear Filter'),
                  ),
                ],
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
          // Frame navigation controls
          if (_controller != null && _controller!.value.isInitialized)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.grey[200],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous),
                    onPressed: _previousFrame,
                    tooltip: 'Previous Frame',
                  ),
                  IconButton(
                    icon: Icon(
                      _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
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
                  IconButton(
                    icon: const Icon(Icons.skip_next),
                    onPressed: _nextFrame,
                    tooltip: 'Next Frame',
                  ),
                  if (_batchMode)
                    IconButton(
                      icon: Icon(
                        _selectedFrames.contains(_currentPosition)
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        color: _selectedFrames.contains(_currentPosition)
                            ? Colors.deepPurple
                            : null,
                      ),
                      onPressed: _addFrameToBatch,
                      tooltip: 'Add to Batch',
                    ),
                ],
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
                    min: _trimMode ? _trimStart : 0.0,
                    max: _trimMode ? _trimEnd : 1.0,
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
