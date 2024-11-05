import 'package:video_player/video_player.dart';
import 'package:get/get.dart';

class CustomVideoControllerPackage extends GetxController {
  late VideoPlayerController videoController;
  final String videoUrl;

  CustomVideoControllerPackage({required this.videoUrl});

  @override
  void onInit() {
    super.onInit();
    videoController = VideoPlayerController.network('$videoUrl')
      ..initialize().then((_) {
        videoController.play(); // Autoplay the video after initialization
        update(); // Update the UI after initialization
      });
  }

  @override
  void onClose() {
    videoController.dispose(); // Dispose the controller when not needed
    super.onClose();
  }

  void togglePlayPause() {
    if (videoController.value.isPlaying) {
      videoController.pause();
    } else {
      videoController.play();
    }
    update(); // Update the UI after play/pause action
  }

  bool get isInitialized => videoController.value.isInitialized;
  bool get isPlaying => videoController.value.isPlaying;
}
