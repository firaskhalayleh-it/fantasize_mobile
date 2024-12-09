import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import '../../controllers/explore_controller.dart';
import 'package:get/get.dart';

class VideoPlayerWidget extends StatefulWidget {
  final int videoIndex;

  VideoPlayerWidget({required this.videoIndex});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  final ExploreController controller = Get.find<ExploreController>();
  ChewieController? chewieController;

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  @override
  void dispose() {
    chewieController?.dispose();
    super.dispose();
  }

  Future<void> initializePlayer() async {
    await controller.initializeVideoController(widget.videoIndex);

    final videoController = controller.videoControllers[widget.videoIndex];

    if (videoController != null && videoController.value.isInitialized) {
      // Ensure the video is buffered before playback starts
      await Future.delayed(
          Duration(milliseconds: 100)); // Small delay for buffering

      chewieController = ChewieController(
        videoPlayerController: videoController,
        autoPlay: true,
        looping: false,
        showControls: false,
        startAt: Duration.zero, // Ensure the video starts at the beginning
      );

      if (mounted) {
        setState(() {}); // Refresh UI after initializing ChewieController
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (chewieController != null &&
        chewieController!.videoPlayerController.value.isInitialized) {
      return AspectRatio(
        aspectRatio: chewieController!.videoPlayerController.value.aspectRatio,
        child: Chewie(controller: chewieController!),
      );
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }
}
