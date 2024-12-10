import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import '../../controllers/explore_controller.dart';
import 'package:get/get.dart';

class VideoPlayerWidget extends StatefulWidget {
  final int videoIndex;

  const VideoPlayerWidget({
    Key? key,
    required this.videoIndex,
  }) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  final ExploreController controller = Get.find<ExploreController>();
  ChewieController? chewieController;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void dispose() {
    _disposeChewieController();
    super.dispose();
  }

  void _disposeChewieController() {
    chewieController?.dispose();
    chewieController = null;
  }

  Future<void> _initializePlayer() async {
    try {
      setState(() => _isInitializing = true);
      await controller.initializeVideoController(widget.videoIndex);
      
      final videoController = controller.videoControllers[widget.videoIndex];
      
      if (!mounted) return;

      if (videoController != null && videoController.value.isInitialized) {
        await Future.delayed(const Duration(milliseconds: 100));
        
        chewieController = ChewieController(
          videoPlayerController: videoController,
          autoPlay: true,
          looping: true,
          showControls: false,
          startAt: Duration.zero,
          aspectRatio: videoController.value.aspectRatio,
          errorBuilder: (context, errorMessage) {
            return _buildErrorWidget(errorMessage);
          },
        );

        if (mounted) {
          setState(() => _isInitializing = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isInitializing = false);
      }
      _handleError('Error initializing video: $e');
    }
  }

  void _handleError(String message) {
    print(message); // Consider using proper logging
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildErrorWidget(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.white.withOpacity(0.7),
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load video',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _initializePlayer,
            child: const Text(
              'Retry',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 2,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading video...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return _buildLoadingWidget();
    }

    if (chewieController == null || 
        !chewieController!.videoPlayerController.value.isInitialized) {
      return _buildErrorWidget('Video not initialized');
    }

    return Container(
      color: Colors.black,
      child: Center(
        child: AspectRatio(
          aspectRatio: chewieController!.videoPlayerController.value.aspectRatio,
          child: Chewie(controller: chewieController!),
        ),
      ),
    );
  }
}