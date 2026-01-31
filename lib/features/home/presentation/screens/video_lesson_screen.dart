// lib/features/home/presentation/screens/video_lesson_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:grad_project/features/home/presentation/providers/home_provider.dart';
import 'package:grad_project/features/home/domain/entities/lesson_entity.dart';
import 'package:grad_project/core/navigation/app_routes.dart';
import 'dart:math' as math;

class VideoLessonScreen extends StatefulWidget {
  final String lessonId;

  const VideoLessonScreen({
    Key? key,
    required this.lessonId,
  }) : super(key: key);

  @override
  State<VideoLessonScreen> createState() => _VideoLessonScreenState();
}

class _VideoLessonScreenState extends State<VideoLessonScreen>
    with TickerProviderStateMixin {
  VideoPlayerController? _videoController;
  late AnimationController _progressController;
  late AnimationController _floatingController;
  late Animation<double> _progressAnimation;
  late Animation<double> _floatingAnimation;

  bool _isLoading = true;
  bool _hasError = false;
  bool _isPlaying = false;
  bool _showControls = true;
  bool _isCompleted = false;
  double _playbackSpeed = 1.0;
  String? _errorMessage;

  Map<String, dynamic>? _lessonData;
  List<Map<String, dynamic>> _subtitles = [];
  String _currentSubtitle = '';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadLessonData();
  }

  void _initializeAnimations() {
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _loadLessonData() async {
    try {
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      final response = await homeProvider.remoteDataSource.getVideoLessonData(widget.lessonId);

      setState(() {
        _lessonData = response;
        _subtitles = List<Map<String, dynamic>>.from(response['subtitles'] ?? []);
      });

      if (response['videoUrl'] != null) {
        await _initializeVideoPlayer(response['videoUrl']);
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _initializeVideoPlayer(String videoUrl) async {
    try {
      _videoController = VideoPlayerController.network(videoUrl);
      await _videoController!.initialize();

      _videoController!.addListener(_videoListener);

      setState(() {
        _isLoading = false;
      });

      // Auto-hide controls after 3 seconds
      _hideControlsAfterDelay();
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to load video: $e';
        _isLoading = false;
      });
    }
  }

  void _videoListener() {
    if (_videoController != null && mounted) {
      final position = _videoController!.value.position;
      final duration = _videoController!.value.duration;

      // Update progress
      if (duration.inSeconds > 0) {
        final progress = position.inSeconds / duration.inSeconds;
        _progressController.value = progress;

        // Check if video is completed (95% watched)
        if (progress >= 0.95 && !_isCompleted) {
          _onVideoCompleted();
        }
      }

      // Update subtitles
      _updateSubtitles(position);

      setState(() {
        _isPlaying = _videoController!.value.isPlaying;
      });
    }
  }

  void _updateSubtitles(Duration position) {
    final currentSeconds = position.inSeconds;

    for (final subtitle in _subtitles) {
      final start = subtitle['start'] ?? 0;
      final end = subtitle['end'] ?? 0;

      if (currentSeconds >= start && currentSeconds < end) {
        if (_currentSubtitle != subtitle['text']) {
          setState(() {
            _currentSubtitle = subtitle['text'] ?? '';
          });
        }
        return;
      }
    }

    if (_currentSubtitle.isNotEmpty) {
      setState(() {
        _currentSubtitle = '';
      });
    }
  }

  void _onVideoCompleted() {
    setState(() {
      _isCompleted = true;
    });

    // Complete lesson in backend
    _completeLesson();

    // Show completion dialog
    _showCompletionDialog();
  }

  Future<void> _completeLesson() async {
    try {
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      await homeProvider.completeLesson(widget.lessonId);
    } catch (e) {
      print('Error completing lesson: $e');
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildCompletionDialog(),
    );
  }

  Widget _buildCompletionDialog() {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.surface,
              colorScheme.surface.withOpacity(0.9),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _floatingAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + 0.1 * math.sin(_floatingAnimation.value * math.pi * 2),
                  child: Container(
                    padding: EdgeInsets.all(20.r),
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          Colors.green,
                          Colors.green.shade600,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 48.r,
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: 24.h),

            Text(
              'أحسنت! 🎉',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 12.h),

            Text(
              'لقد أكملت الدرس بنجاح',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 24.h),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 20.r,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '+100 نقطة',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.amber.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32.h),

            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: const Text('العودة للخريطة'),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushNamed(context, AppRoutes.quiz);
                    },
                    child: const Text('الاختبار'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _togglePlayPause() {
    if (_videoController != null) {
      if (_isPlaying) {
        _videoController!.pause();
      } else {
        _videoController!.play();
      }
      _showControlsTemporarily();
    }
  }

  void _showControlsTemporarily() {
    setState(() {
      _showControls = true;
    });
    _hideControlsAfterDelay();
  }

  void _hideControlsAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _changePlaybackSpeed() {
    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
    final currentIndex = speeds.indexOf(_playbackSpeed);
    final nextIndex = (currentIndex + 1) % speeds.length;

    setState(() {
      _playbackSpeed = speeds[nextIndex];
    });

    _videoController?.setPlaybackSpeed(_playbackSpeed);
    _showControlsTemporarily();
  }

  void _seekTo(Duration position) {
    _videoController?.seekTo(position);
    _showControlsTemporarily();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _progressController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingState()
            : _hasError
            ? _buildErrorState()
            : _buildVideoPlayer(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: AnimatedBuilder(
        animation: _floatingAnimation,
        builder: (context, child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.rotate(
                angle: _floatingAnimation.value * math.pi * 2,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'جاري تحميل الدرس...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64.r,
            ),
            SizedBox(height: 24.h),
            Text(
              'خطأ في تحميل الفيديو',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              _errorMessage ?? 'حدث خطأ غير متوقع',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16.sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _hasError = false;
                  _errorMessage = null;
                });
                _loadLessonData();
              },
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return _buildLoadingState();
    }

    return Stack(
      children: [
        // Video Player
        Center(
          child: AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          ),
        ),

        // Tap to show/hide controls
        GestureDetector(
          onTap: () {
            setState(() {
              _showControls = !_showControls;
            });
            if (_showControls) {
              _hideControlsAfterDelay();
            }
          },
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.transparent,
          ),
        ),

        // Top Controls
        AnimatedOpacity(
          opacity: _showControls ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Container(
            height: 80.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                ],
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 28.r,
                  ),
                ),
                Expanded(
                  child: Text(
                    _lessonData?['title'] ?? 'درس فيديو',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _changePlaybackSpeed,
                  icon: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      '${_playbackSpeed}x',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Center Play/Pause Button
        if (!_showControls && !_isPlaying)
          Center(
            child: GestureDetector(
              onTap: _togglePlayPause,
              child: Container(
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 48.r,
                ),
              ),
            ),
          ),

        // Bottom Controls
        AnimatedOpacity(
          opacity: _showControls ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 120.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Progress Bar
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: _buildProgressBar(),
                  ),

                  SizedBox(height: 16.h),

                  // Control Buttons
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            final current = _videoController!.value.position;
                            final newPosition = current - const Duration(seconds: 10);
                            _seekTo(newPosition);
                          },
                          icon: Icon(
                            Icons.replay_10,
                            color: Colors.white,
                            size: 32.r,
                          ),
                        ),

                        SizedBox(width: 32.w),

                        GestureDetector(
                          onTap: _togglePlayPause,
                          child: Container(
                            padding: EdgeInsets.all(16.r),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 32.r,
                            ),
                          ),
                        ),

                        SizedBox(width: 32.w),

                        IconButton(
                          onPressed: () {
                            final current = _videoController!.value.position;
                            final newPosition = current + const Duration(seconds: 10);
                            _seekTo(newPosition);
                          },
                          icon: Icon(
                            Icons.forward_10,
                            color: Colors.white,
                            size: 32.r,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ),

        // Subtitles
        if (_currentSubtitle.isNotEmpty)
          Positioned(
            bottom: 140.h,
            left: 16.w,
            right: 16.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                _currentSubtitle,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

        // Completion Badge
        if (_isCompleted)
          Positioned(
            top: 100.h,
            right: 16.w,
            child: AnimatedBuilder(
              animation: _floatingAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + 0.1 * math.sin(_floatingAnimation.value * math.pi * 2),
                  child: Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [Colors.green, Colors.green.shade600],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.6),
                          blurRadius: 15,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 24.r,
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildProgressBar() {
    if (_videoController == null) return const SizedBox.shrink();

    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: _videoController!,
      builder: (context, value, child) {
        final position = value.position;
        final duration = value.duration;

        return Column(
          children: [
            // Time indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(position),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                  ),
                ),
                Text(
                  _formatDuration(duration),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),

            SizedBox(height: 8.h),

            // Progress slider
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Theme.of(context).colorScheme.primary,
                inactiveTrackColor: Colors.white.withOpacity(0.3),
                thumbColor: Theme.of(context).colorScheme.primary,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.r),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 16.r),
                trackHeight: 4.h,
              ),
              child: Slider(
                value: duration.inSeconds > 0
                    ? position.inSeconds / duration.inSeconds
                    : 0.0,
                onChanged: (value) {
                  final newPosition = Duration(
                    seconds: (duration.inSeconds * value).round(),
                  );
                  _seekTo(newPosition);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}