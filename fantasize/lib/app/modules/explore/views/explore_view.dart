import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'widgets/video_player_widget.dart';
import '../controllers/explore_controller.dart';

class ExploreView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ExploreController controller = Get.find<ExploreController>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.videos.isEmpty) {
          return Center(
              child: Text('No videos available',
                  style: TextStyle(color: Colors.white)));
        }

        // Ensure lists are initialized and have correct lengths
        if (controller.videoControllers.length != controller.videos.length ||
            controller.likedVideos.length != controller.videos.length ||
            controller.showHeartAnimation.length != controller.videos.length) {
          return Center(child: CircularProgressIndicator());
        }

        // PageView for full-screen vertical video scrolling
        return PageView.builder(
          scrollDirection: Axis.vertical,
          itemCount: controller.videos.length,
          onPageChanged: (index) {
            // Handle switching videos (play current, pause previous and adjacent videos)
            controller.handleVideoSwitch(index);
          },
          itemBuilder: (context, index) {
            // Ensure index is within bounds
            if (index >= controller.videos.length ||
                index >= controller.likedVideos.length ||
                index >= controller.showHeartAnimation.length) {
              return Center(
                child: Text('Error loading video',
                    style: TextStyle(color: Colors.white)),
              );
            }

            // Wrap video in a Stack to overlay buttons and like icon
            return GestureDetector(
              onDoubleTap: () {
                // Handle like on double tap within the video area
                controller.likeVideo(index);
              },
              child: Stack(
                children: [
                  // Video player
                  VideoPlayerWidget(videoIndex: index),

                  // Overlay UI elements
                  Positioned(
                    right: 15,
                    bottom: 80,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Heart icon for liking the video
                        GestureDetector(
                          onTap: () {
                            controller.likeVideo(index);
                          },
                          child: Icon(
                            controller.isLiked(index)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: controller.isLiked(index)
                                ? Colors.red
                                : Colors.white,
                            size: 35,
                          ),
                        ),
                        SizedBox(height: 20),

                        // Button to go to product or package page
                        IconButton(
                          icon: Icon(Icons.shopping_cart_outlined,
                              color: Colors.white, size: 35),
                          onPressed: () {
                            // Navigate to product or package page
                            controller.goToProductOrPackagePage(index);
                          },
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),

                  // Double-tap like gesture covering the whole page
                  if (controller.showHeartAnimation[index])
                    Center(
                      child: Icon(
                        Icons.favorite,
                        color: Colors.red.withOpacity(0.9),
                        size: 100,
                      ),
                    ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
  