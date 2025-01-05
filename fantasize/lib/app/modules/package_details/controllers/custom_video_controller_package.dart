import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class CustomVideoControllerPackage extends GetxController {
  late VideoPlayerController videoController;
  final String videoUrl;
  var isVisible = false.obs;
  var isDisposed = false.obs;

  CustomVideoControllerPackage({required this.videoUrl});

  @override
  void onInit() {
    super.onInit();
    initializeVideo();
  }

  Future<void> initializeVideo() async {
    videoController = VideoPlayerController.network(videoUrl);
    try {
      await videoController.initialize();
      if (!isDisposed.value) {
        videoController.play();
        update();
      }
    } catch (e) {
      print('Error initializing video: $e');
    }
  }

  @override
  void onClose() {
    cleanupVideo();
    super.onClose();
  }

  void cleanupVideo() {
    isDisposed.value = true;
    if (videoController.value.isPlaying) {
      videoController.pause();
    }
    videoController.dispose();
  }

  // Add this method to handle page changes
  void handleDelete() {
    cleanupVideo();
    super.onClose();
  }

  void togglePlayPause() {
    if (isDisposed.value) return;
    
    if (videoController.value.isPlaying) {
      videoController.pause();
      isVisible.value = true;
    } else {
      videoController.play();
      isVisible.value = false;
    }
    update();
  }

  void onTapVideo() {
    if (isDisposed.value) return;
    
    isVisible.value = !isVisible.value;
    togglePlayPause();
    update();
  }

  bool get isInitialized => !isDisposed.value && videoController.value.isInitialized;
  bool get isPlaying => !isDisposed.value && videoController.value.isPlaying;
}