import 'package:video_player/video_player.dart';
import 'package:get/get.dart';
import 'package:fantasize/app/global/strings.dart';

class CustomVideoPlayerController extends GetxController {
  late VideoPlayerController videoController;
  final String videoUrl;
  var isVisible = false.obs;

  CustomVideoPlayerController({required this.videoUrl});

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
      isVisible.value = true;
    } else {
      videoController.play();
      isVisible.value = false;
    }
    update(); // Update the UI after play/pause action
  }

  void onTapVideo() {
    isVisible.value = !isVisible.value;
    togglePlayPause();
    update();
  }

  bool get isInitialized => videoController.value.isInitialized;
  bool get isPlaying => videoController.value.isPlaying;
}