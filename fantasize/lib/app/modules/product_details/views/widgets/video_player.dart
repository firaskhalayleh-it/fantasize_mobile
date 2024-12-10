// video_player_widget_product.dart
import 'package:fantasize/app/modules/product_details/controllers/video_controller.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:get/get.dart';

class VideoPlayerWidgetProduct extends StatelessWidget {
  final String videoUrl;

  VideoPlayerWidgetProduct({required this.videoUrl});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CustomVideoPlayerController>(
      init: CustomVideoPlayerController(videoUrl: videoUrl),
      builder: (controller) {
        if (!controller.isInitialized) {
          return Container(
            width: 300,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
              ),
            ),
          );
        }

        return Container(
          width: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Video Player
                AspectRatio(
                  aspectRatio: 3 / 4,
                  child: VideoPlayer(controller.videoController),
                ),

                // Play/Pause Overlay
                AnimatedOpacity(
                  opacity:
                      controller.videoController.value.isPlaying ? 0.0 : 1.0,
                  duration: Duration(milliseconds: 300),
                  child: GestureDetector(
                    onTap: controller.onTapVideo,
                    child: Container(
                        color: Colors
                            .transparent, // Make it transparent to allow taps
                        child: Stack(alignment: Alignment.center, children: [
                          AspectRatio(
                            aspectRatio: 3 / 4,
                            child: VideoPlayer(controller.videoController),
                          ),
                        ])),
                  ),
                ),

                // Progress Indicator
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: AnimatedOpacity(
                    opacity:
                        controller.videoController.value.isPlaying ? 0.0 : 1.0,
                    duration: Duration(milliseconds: 300),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black54,
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: VideoProgressIndicator(
                        controller.videoController,
                        allowScrubbing: true,
                        colors: VideoProgressColors(
                          playedColor: Colors.redAccent,
                          bufferedColor: Colors.white.withOpacity(0.5),
                          backgroundColor: Colors.white.withOpacity(0.2),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
