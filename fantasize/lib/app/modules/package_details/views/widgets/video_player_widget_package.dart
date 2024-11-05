import 'package:fantasize/app/modules/package_details/controllers/custom_video_controller_package.dart';
import 'package:fantasize/app/modules/product_details/controllers/video_controller.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:get/get.dart';

class VideoPlayerWidgetPackage extends StatelessWidget {
  final String videoUrl;

  VideoPlayerWidgetPackage({required this.videoUrl});

  @override
  Widget build(BuildContext context) {
    // Use GetBuilder to bind the CustomVideoPlayerController to the widget
    return GetBuilder<CustomVideoControllerPackage>(
      init: CustomVideoControllerPackage(videoUrl: videoUrl),
      builder: (controller) {
        if (!controller.isInitialized) {
          return Center(
              child:
                  CircularProgressIndicator()); // Show a loader while the video is initializing
        }
        return GestureDetector(
          onTap: () {
            controller.togglePlayPause(); // Toggle play/pause on tap
          },
          child: AspectRatio(
            aspectRatio: 3 / 4,
            child: VideoPlayer(controller.videoController),
          ),
        );
      },
    );
  }
}
