import 'package:chewie/chewie.dart';
import 'package:fantasize/app/data/models/video_model.dart';
import 'package:fantasize/app/global/strings.dart';
import 'package:fantasize/app/modules/favorites/controllers/favorites_controller.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class ExploreController extends GetxController {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  var videos = <VideoModel>[].obs;
  var isLoading = true.obs;

  // Initialize the lists with empty values to avoid null issues
  RxList<VideoPlayerController?> videoControllers =
      RxList<VideoPlayerController?>([]);
  RxList<bool> likedVideos = RxList<bool>([]);
  RxList<bool> showHeartAnimation = RxList<bool>([]);

  // Separate lists to track liked states for products and packages
  RxList<bool> likedProducts = RxList<bool>([]);
  RxList<bool> likedPackages = RxList<bool>([]);

  int? previousIndex; // Track the previous video index

  @override
  void onInit() {
    super.onInit();
    fetchVideos();
    checkIfLikedForAllVideos();
  }

  // Fetch videos from the API and initialize controllers
  Future<void> fetchVideos() async {
    try {
      isLoading(true);
      var response =
          await http.get(Uri.parse('${Strings().exploreUrl}/videos'));

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        var videoList = jsonData['videoPaths'] as List;
        videos.value =
            videoList.map((video) => VideoModel.fromJson(video)).toList();

        // Initialize lists with default values
        videoControllers.value =
            List<VideoPlayerController?>.filled(videos.length, null);
        likedVideos.value = List<bool>.filled(videos.length, false);
        showHeartAnimation.value = List<bool>.filled(videos.length, false);

        // Initialize separate lists for products and packages
        likedProducts.value = List<bool>.filled(videos.length, false);
        likedPackages.value = List<bool>.filled(videos.length, false);

        // Check liked status for all videos
        await checkIfLikedForAllVideos();
      } else {
        Get.snackbar('Error', 'Failed to fetch videos');
      }
    } catch (e) {
      print("Error fetching videos: $e");
      Get.snackbar('Error', 'An error occurred while fetching videos');
    } finally {
      isLoading(false);
    }
  }

  // Initialize the video controller lazily when needed
  Future<void> initializeVideoController(int index) async {
    if (videoControllers[index] == null ||
        !(videoControllers[index]?.value.isInitialized ?? false)) {
      try {
        final videoUrl =
            Uri.parse('${Strings().resourceUrl}/${videos[index].videoPath}');
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
      videoControllers[index]?.play();
    }
  }

  // Dispose video controllers when they go offscreen
  void disposeVideoController(int index) {
    if (videoControllers[index] != null) {
      videoControllers[index]?.pause();
      videoControllers[index]?.dispose();
      videoControllers[index] = null;
    }
  }

  // Pause the video at the given index
  void pauseVideo(int index) {
    if (videoControllers[index]?.value.isInitialized ?? false) {
      videoControllers[index]?.pause();
    }
  }

  // Handle pausing of the adjacent videos (previous and next)
  void handleVideoSwitch(int index) {
    // Pause the previous video if available
    if (previousIndex != null && previousIndex != index) {
      pauseVideo(previousIndex!);
    }

    // Pause the next video if it's initialized and active
    if (index + 1 < videoControllers.length) {
      pauseVideo(index + 1);
    }

    // Pause the previous video if it's initialized and active
    if (index - 1 >= 0) {
      pauseVideo(index - 1);
    }

    // Play the current video
    initializeVideoController(index);

    // Update the previous index
    previousIndex = index;
  }

  // Like a video (toggle liked state and show heart animation)
  void likeVideo(int index) async {
    var video = videos[index];
    if (video.productId != null) {
      // Video is associated with a Product
      await toggleLikeStatus(index, isProduct: true, id: video.productId!);
    } else if (video.packageId != null) {
      // Video is associated with a Package
      await toggleLikeStatus(index, isProduct: false, id: video.packageId!);
    } else {
      print('No product or package associated with this video.');
    }

    // Show heart animation for a short period
    showHeartAnimation[index] = true;
    Future.delayed(Duration(seconds: 1), () {
      showHeartAnimation[index] = false;
    });
  }

  // Toggle like status based on whether it's a product or package
  Future<void> toggleLikeStatus(int index,
      {required bool isProduct, required int id}) async {
    try {
      String? token = await _secureStorage.read(key: 'jwt_token');
      if (token == null) {
        Get.snackbar('Authorization Error', 'You need to log in first.');
        return;
      }

      Uri url;
      int statusCode;

      if (isProduct) {
        // Toggle like for Product
        if (likedProducts[index]) {
          // Currently liked, so remove from favorites
          url = Uri.parse('${Strings().apiUrl}/favorites/$id');
          var response = await http.delete(
            url,
            headers: {
              'Content-Type': 'application/json',
              'authorization': 'Bearer $token',
              'Accept': 'application/json',
              'cookie': 'authToken=$token',
            },
          );

          statusCode = response.statusCode;
          if (statusCode == 200) {
            likedProducts[index] = false;
            Get.find<FavoritesController>().fetchFavorites();
            Get.snackbar(
              'Success',
              'Product removed from favorites',
            );
          } else {
            Get.snackbar('Error', 'Failed to remove product from favorites');
          }
        } else {
          // Not liked, so add to favorites
          url = Uri.parse('${Strings().apiUrl}/product/$id/favorites');
          var response = await http.post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'authorization': 'Bearer $token',
              'Accept': 'application/json',
              'cookie': 'authToken=$token',
            },
          );

          statusCode = response.statusCode;
          if (statusCode == 200 || statusCode == 201) {
            likedProducts[index] = true;
            Get.find<FavoritesController>().fetchFavorites();

            Get.snackbar('Success', 'Product added to favorites');
          } else {
            Get.snackbar('Error', 'Failed to add product to favorites');
          }
        }
      } else {
        // Toggle like for Package
        if (likedPackages[index]) {
          // Currently liked, so remove from favorites
          url = Uri.parse('${Strings().apiUrl}/favoritePackages/$id');
          var response = await http.delete(
            url,
            headers: {
              'Content-Type': 'application/json',
              'authorization': 'Bearer $token',
              'Accept': 'application/json',
              'cookie': 'authToken=$token',
            },
          );

          statusCode = response.statusCode;
          if (statusCode == 200) {
            likedPackages[index] = false;
            Get.find<FavoritesController>().fetchFavorites();

            Get.snackbar('Success', 'Package removed from favorites');
          } else {
            Get.snackbar('Error', 'Failed to remove package from favorites');
          }
        } else {
          // Not liked, so add to favorites
          url = Uri.parse('${Strings().apiUrl}/favoritePackages/$id');
          var response = await http.post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'authorization': 'Bearer $token',
              'Accept': 'application/json',
              'cookie': 'authToken=$token',
            },
          );

          statusCode = response.statusCode;
          if (statusCode == 200 || statusCode == 201) {
            likedPackages[index] = true;
            Get.find<FavoritesController>().fetchFavorites();

            Get.snackbar('Success', 'Package added to favorites');
          } else {
            Get.snackbar('Error', 'Failed to add package to favorites');
          }
        }
      }
    } catch (e) {
      print('Error toggling like status: $e');
      Get.snackbar('Error', 'An error occurred while updating favorites');
    }
  }

  // Check if each video is liked by the user
  Future<void> checkIfLikedForAllVideos() async {
    try {
      String? token = await _secureStorage.read(key: 'jwt_token');
      if (token == null) {
        print('No token found. Skipping like status check.');
        return;
      }

      // Fetch all favorite products
      var favoriteProductsUrl = Uri.parse('${Strings().apiUrl}/favorites');
      var favoritePackagesUrl =
          Uri.parse('${Strings().apiUrl}/favoritePackages');

      var [productsResponse, packagesResponse] = await Future.wait([
        http.get(
          favoriteProductsUrl,
          headers: {
            'Content-Type': 'application/json',
            'authorization': 'Bearer $token',
            'Accept': 'application/json',
            'cookie': 'authToken=$token',
          },
        ),
        http.get(
          favoritePackagesUrl,
          headers: {
            'Content-Type': 'application/json',
            'authorization': 'Bearer $token',
            'Accept': 'application/json',
            'cookie': 'authToken=$token',
          },
        ),
      ]);

      List<int> favoriteProductIds = [];
      List<int> favoritePackageIds = [];

      if (productsResponse.statusCode == 200) {
        var jsonData = json.decode(productsResponse.body);
        var favoriteProducts = jsonData as List<dynamic>;
        favoriteProductIds = favoriteProducts.map((fav) {
          return fav['Product']['ProductID'] as int;
        }).toList();
        print('Favorite products: $favoriteProductIds');
      } else {
        Get.snackbar('Error',
            'Failed to fetch favorite products${productsResponse.body}');
      }

      if (packagesResponse.statusCode == 200) {
        var jsonData = json.decode(packagesResponse.body);
        var favoritePackagesData = jsonData as List<dynamic>;
        favoritePackageIds = favoritePackagesData.map((fav) {
          return fav['Package']['PackageID'] as int;
        }).toList();
        print('Favorite packages: $favoritePackageIds');
      } else {
        Get.snackbar('Error',
            'Failed to fetch favorite packages${packagesResponse.body}');
      }

      // Update likedProducts and likedPackages lists
      for (int i = 0; i < videos.length; i++) {
        var video = videos[i];
        if (video.productId != null) {
          likedProducts[i] = favoriteProductIds.contains(video.productId);
        } else if (video.packageId != null) {
          likedPackages[i] = favoritePackageIds.contains(video.packageId);
        }
      }
    } catch (e) {
      print('Error checking liked status: $e');
      Get.snackbar('Error', 'An error occurred while checking favorites$e');
    }
  }

  // Check if the video is liked
  bool isLiked(int index) {
    var video = videos[index];
    if (video.productId != null) {
      return likedProducts[index];
    } else if (video.packageId != null) {
      return likedPackages[index];
    }
    return false;
  }

  // Navigate to product or package page
  void goToProductOrPackagePage(int index) {
    final video = videos[index];
    if (video.productId != null) {
      Get.toNamed('/product-details', arguments: [video.productId]);
    } else if (video.packageId != null) {
      Get.toNamed('/package-details', arguments: video.packageId);
    } else {
      print('No product or package associated with this video.');
      Get.snackbar('Error', 'No associated product or package found.');
    }
  }

  @override
  void onClose() {
    // Dispose of all video controllers when the controller is destroyed
    for (var controller in videoControllers) {
      if (controller?.value.isInitialized ?? false) {
        controller?.pause();
        controller?.dispose();
      }
    }
    super.onClose();
  }

  toggleVideoPlayPause(int index) {
    if (videoControllers[index]?.value.isPlaying ?? false) {
      videoControllers[index]?.pause();
    } else {
      videoControllers[index]?.play();
    }
  }
}
