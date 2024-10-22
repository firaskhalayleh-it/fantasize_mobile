import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import '../../controllers/explore_controller.dart';
import 'package:get/get.dart';

class VideoPlayerWidget extends StatelessWidget {
  final int videoIndex;

  VideoPlayerWidget({required this.videoIndex});

  @override
  Widget build(BuildContext context) {
    final ExploreController controller = Get.find<ExploreController>();

    return FutureBuilder(
      future: controller.initializeVideoController(videoIndex),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading video: ${snapshot.error}',
              style: TextStyle(color: Colors.white),
            ),
          );
        } else {
          final videoController = controller.videoControllers[videoIndex];

        if(videoController == null) { return Center(child: Center(
            child: Text('Error loading video', style: TextStyle(color: Colors.white)
        ))); }
          if (videoController.value.isInitialized) {
            final chewieController = ChewieController(
              videoPlayerController: videoController,
              autoPlay: true,
              looping: true,
            );

            return AspectRatio(
              aspectRatio: MediaQuery.of(context).size.aspectRatio/0.9,
              child: Chewie(controller: chewieController),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        }
      },
    );
  }
}
