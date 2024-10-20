import 'package:chewie/chewie.dart';
import 'package:fantasize/app/data/models/video_model.dart';
import 'package:fantasize/app/global/strings.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ExploreController extends GetxController {
  var videos = <VideoModel>[].obs;
  var isLoading = true.obs;

  // Make the videoControllers list nullable
  var videoControllers = <VideoPlayerController?>[].obs;
  var chewieControllers = <ChewieController?>[].obs; // Chewie Controllers

  // Track liked state for each video
  var likedVideos = <bool>[].obs;

  // Track heart animation visibility
  var showHeartAnimation = <bool>[].obs;

  int? previousIndex; // Track the previous video index

  @override
  void onInit() {
    super.onInit();
    fetchVideos();
  }

  // Fetch videos from the API without initializing controllers upfront
  void fetchVideos() async {
    try {
      isLoading(true);
      var response =
          await http.get(Uri.parse('${Strings().apiUrl}/explore'));

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        var videoList = jsonData['videoPaths'] as List;
        videos.value =
            videoList.map((video) => VideoModel.fromJson(video)).toList();

        // Initialize empty controllers and other states as null
        videoControllers.value = List.generate(videos.length, (_) => null);
        likedVideos.value =
            List.generate(videos.length, (_) => false); // Initially not liked
        showHeartAnimation.value = List.generate(
            videos.length, (_) => false); // No animation by default
      }
    } finally {
      isLoading(false);
    }
  }

  // Initialize the video controller lazily when needed
  Future<void> initializeVideoController(int index) async {
    if (videoControllers[index] == null ||
        !videoControllers[index]!.value.isInitialized) {
      try {
        final videoUrl = Uri.parse(
            '${Strings().resourceUrl}/${videos[index].videoPath}');
        final controller = VideoPlayerController.networkUrl(videoUrl);

        await controller.initialize();
        controller.setLooping(true);
        controller.play(); // Start playing the video

        videoControllers[index] = controller; // Save the controller
      } catch (e) {
        print("Error initializing video: $e");
      }
    } else {
      // If already initialized, just play the video
      videoControllers[index]!.play();
    }
  }

  // Dispose video controllers when they go offscreen
  void disposeVideoController(int index) {
    if (videoControllers[index] != null) {
      videoControllers[index]!.dispose();
      videoControllers[index] = null;
    }
  }

  // Pause the video at the given index
  void pauseVideo(int index) {
    if (videoControllers[index] != null &&
        videoControllers[index]!.value.isInitialized) {
      videoControllers[index]!.pause();
    }
  }

  // Handle pausing of the adjacent videos (previous and next)
  void handleVideoSwitch(int index) {
    // Pause the previous video if available
    if (previousIndex != null && previousIndex != index) {
      pauseVideo(previousIndex!);
    }

    // Pause the next video if it's initialized and active
    if (index + 1 < videoControllers.length &&
        videoControllers[index + 1] != null) {
      pauseVideo(index + 1);
    }

    // Pause the previous video if it's initialized and active
    if (index - 1 >= 0 && videoControllers[index - 1] != null) {
      pauseVideo(index - 1);
    }

    // Play the current video
    initializeVideoController(index);

    // Update the previous index
    previousIndex = index;
  }

  // Like a video (toggle liked state and show heart animation)
  void likeVideo(int index) {
    likedVideos[index] = !likedVideos[index];

    // Show heart animation for a short period
    showHeartAnimation[index] = true;
    Future.delayed(Duration(seconds: 1), () {
      showHeartAnimation[index] = false;
    });
  }

  // Check if the video is liked
  bool isLiked(int index) {
    if (index < 0 || index >= likedVideos.length) {
      return false;
    }
    return likedVideos[index];
  }

  // Navigate to product or package page
  void goToProductOrPackagePage(int index) {
    final video = videos[index];
    if (video.productId != null) {
      // Navigate to the product page
      //Get.toNamed('/product', arguments: video.productId);
    } else if (video.packageId != null) {
      // Navigate to the package page
      ///Get.toNamed('/package', arguments: video.packageId);
    } else {
      print('No product or package associated with this video.');
    }
  }

  @override
  void onClose() {
    // Dispose of all video controllers when the view is closed
    for (var controller in videoControllers) {
      if (controller != null) {
        controller.dispose();
      }
    }
    disableAllControllers();

    super.onClose();
  }

 
  void disableAllControllers() {
     if(videoControllers.length == 0  && chewieControllers.length == 0){ 
      Get.offAllNamed('/home');
    
  }
    for (var index = 0; index < videoControllers.length; index++) {
      // Pause and dispose VideoPlayerController
      if (videoControllers[index] != null &&
          videoControllers[index]!.value.isInitialized) {
        videoControllers[index]!.pause();
        videoControllers[index]!.dispose();
        videoControllers[index] = null; // Release memory
      }
  
      
    }
  }
}
