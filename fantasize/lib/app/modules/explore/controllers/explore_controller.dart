import 'package:chewie/chewie.dart';
import 'package:fantasize/app/data/models/video_model.dart';
import 'package:fantasize/app/global/strings.dart';
import 'package:fantasize/app/modules/favorites/controllers/favorites_controller.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';

class ExploreController extends GetxController {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  var videos = <VideoModel>[].obs;
  var isLoading = true.obs;

  // List of controllers for each video
  RxList<VideoPlayerController?> videoControllers =
      RxList<VideoPlayerController?>([]);
  RxList<bool> likedVideos = RxList<bool>([]);
  RxList<bool> showHeartAnimation = RxList<bool>([]);

  // Separate lists to track liked states for products and packages
  RxList<bool> likedProducts = RxList<bool>([]);
  RxList<bool> likedPackages = RxList<bool>([]);

  int? previousIndex; // Keep track of the last playing video

  @override
  void onInit() {
    super.onInit();
    fetchVideos();
  }

  /// Fetch videos from the server
  Future<void> fetchVideos() async {
    try {
      isLoading(true);
      final response =
          await http.get(Uri.parse('${Strings().exploreUrl}/videos'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final videoList = jsonData['videoPaths'] as List;
        videos.value = videoList.map((v) => VideoModel.fromJson(v)).toList();

        // Initialize controllers and liked states
        videoControllers.value =
            List<VideoPlayerController?>.filled(videos.length, null);
        likedVideos.value = List<bool>.filled(videos.length, false);
        showHeartAnimation.value = List<bool>.filled(videos.length, false);

        // Initialize separate lists for product/package likes
        likedProducts.value = List<bool>.filled(videos.length, false);
        likedPackages.value = List<bool>.filled(videos.length, false);

        // After loading all videos, check liked status
        await checkIfLikedForAllVideos();
      } else {
        Get.snackbar('Error', 'Failed to fetch videos');
      }
    } catch (e) {
      debugPrint("Error fetching videos: $e");
      Get.snackbar('Error', 'An error occurred while fetching videos');
    } finally {
      isLoading(false);
    }
  }

  /// Initialize a video controller at [index] if not yet initialized
  Future<void> initializeVideoController(int index) async {
    if (videoControllers[index] == null ||
        !(videoControllers[index]?.value.isInitialized ?? false)) {
      try {
        final videoUrl =
            Uri.parse('${Strings().resourceUrl}/${videos[index].videoPath}');
        final controller = VideoPlayerController.networkUrl(videoUrl);

        await controller.initialize();
        controller.setLooping(true);
        controller.play();

        videoControllers[index] = controller;
      } catch (e) {
        debugPrint("Error initializing video: $e");
      }
    } else {
      // If already initialized, just play
      videoControllers[index]?.play();
    }
  }

  /// Dispose of a video controller at [index] to free resources
  void disposeVideoController(int index) {
    final vc = videoControllers[index];
    if (vc != null) {
      vc.pause();
      vc.dispose();
      videoControllers[index] = null;
    }
  }

  /// Pause a video at [index]
  void pauseVideo(int index) {
    if (videoControllers[index]?.value.isInitialized ?? false) {
      videoControllers[index]?.pause();
    }
  }

  /// Handle switching from one video to another
  void handleVideoSwitch(int index) {
    // Pause the previous video if available
    if (previousIndex != null && previousIndex != index) {
      pauseVideo(previousIndex!);
    }

    // Pause neighbors if needed
    if (index + 1 < videoControllers.length) {
      pauseVideo(index + 1);
    }
    if (index - 1 >= 0) {
      pauseVideo(index - 1);
    }

    // Play the current video
    initializeVideoController(index);
    previousIndex = index;
  }

  /// Toggles the like status for video at [index], 
  /// determines if it's a product or package, then calls toggleLikeStatus
  void likeVideo(int index) async {
    final video = videos[index];

    if (video.productId != null) {
      // Video associated with a Product
      await toggleLikeStatus(
        index,
        isProduct: true,
        id: video.productId!,
      );
    } else if (video.packageId != null) {
      // Video associated with a Package
      await toggleLikeStatus(
        index,
        isProduct: false,
        id: video.packageId!,
      );
    } else {
      debugPrint('No product or package associated with this video.');
    }

    // Trigger heart animation
    showHeartAnimation[index] = true;
    Future.delayed(const Duration(seconds: 1), () {
      showHeartAnimation[index] = false;
    });
  }

  /// Generic method to toggle like for either Product or Package
  Future<void> toggleLikeStatus(
    int index, {
    required bool isProduct,
    required int id,
  }) async {
    try {
      final token = await _secureStorage.read(key: 'jwt_token');
      if (token == null) {
        Get.snackbar('Authorization Error', 'You need to log in first.');
        return;
      }

      final headers = {
        'Content-Type': 'application/json',
        'authorization': 'Bearer $token',
        'Accept': 'application/json',
        'cookie': 'authToken=$token',
      };

      if (isProduct) {
        // If product already liked, remove it
        if (likedProducts[index]) {
          final url = Uri.parse('${Strings().apiUrl}/favorites/$id');
          final response = await http.delete(url, headers: headers);

          if (response.statusCode == 200) {
            likedProducts[index] = false;
            // Refresh favorites in FavoritesController
            Get.find<FavoritesController>().fetchFavorites();
            Get.snackbar('Success', 'Product removed from favorites');
          } else {
            Get.snackbar('Error', 'Failed to remove product from favorites');
          }
        } else {
          // Add it to favorites
          final url = Uri.parse('${Strings().apiUrl}/favorites/$id');
          final response = await http.post(url, headers: headers);

          if (response.statusCode == 200 || response.statusCode == 201) {
            likedProducts[index] = true;
            Get.find<FavoritesController>().fetchFavorites();
            Get.snackbar('Success', 'Product added to favorites');
          } else {
            Get.snackbar('Error', 'Failed to add product to favorites');
          }
        }
      } else {
        // If package already liked, remove it
        if (likedPackages[index]) {
          final url = Uri.parse('${Strings().apiUrl}/favoritePackages/$id');
          final response = await http.delete(url, headers: headers);

          if (response.statusCode == 200) {
            likedPackages[index] = false;
            Get.find<FavoritesController>().fetchFavorites();
            Get.snackbar('Success', 'Package removed from favorites');
          } else {
            Get.snackbar('Error', 'Failed to remove package from favorites');
          }
        } else {
          // Add it to favorites
          final url = Uri.parse('${Strings().apiUrl}/favoritePackages/$id');
          final response = await http.post(url, headers: headers);

          if (response.statusCode == 200 || response.statusCode == 201) {
            likedPackages[index] = true;
            Get.find<FavoritesController>().fetchFavorites();
            Get.snackbar('Success', 'Package added to favorites');
          } else {
            Get.snackbar('Error', 'Failed to add package to favorites');
          }
        }
      }
    } catch (e) {
      debugPrint('Error toggling like status: $e');
      Get.snackbar('Error', 'An error occurred while updating favorites');
    }
  }

  /// Check if videos (either products or packages) are liked by the user
  Future<void> checkIfLikedForAllVideos() async {
    try {
      final token = await _secureStorage.read(key: 'jwt_token');
      if (token == null) {
        debugPrint('No token found. Skipping like status check.');
        return;
      }

      final headers = {
        'Content-Type': 'application/json',
        'authorization': 'Bearer $token',
        'Accept': 'application/json',
        'cookie': 'authToken=$token',
      };

      final favoriteProductsUrl = Uri.parse('${Strings().apiUrl}/favorites');
      final favoritePackagesUrl =
          Uri.parse('${Strings().apiUrl}/favoritePackages');

      final responses = await Future.wait([
        http.get(favoriteProductsUrl, headers: headers),
        http.get(favoritePackagesUrl, headers: headers),
      ]);

      final productsResponse = responses[0];
      final packagesResponse = responses[1];

      List<int> favoriteProductIds = [];
      List<int> favoritePackageIds = [];

      // Process favorite products
      if (productsResponse.statusCode == 200) {
        final jsonData = json.decode(productsResponse.body) as List;
        favoriteProductIds = jsonData
            .map((fav) => fav['Product']['ProductID'] as int)
            .toList();
        debugPrint('Favorite products: $favoriteProductIds');
      } else {
        // If needed, handle other status codes or errors
        debugPrint('Failed to fetch favorite products: ${productsResponse.body}');
      }

      // Process favorite packages
      if (packagesResponse.statusCode == 200) {
        final jsonData = json.decode(packagesResponse.body) as List;
        favoritePackageIds = jsonData
            .map((fav) => fav['Package']['PackageID'] as int)
            .toList();
        debugPrint('Favorite packages: $favoritePackageIds');
      } else {
        debugPrint('Failed to fetch favorite packages: ${packagesResponse.body}');
      }

      // Update liked states
      for (int i = 0; i < videos.length; i++) {
        final video = videos[i];
        if (video.productId != null) {
          likedProducts[i] = favoriteProductIds.contains(video.productId);
        } else if (video.packageId != null) {
          likedPackages[i] = favoritePackageIds.contains(video.packageId);
        }
      }
    } catch (e) {
      debugPrint('Error checking liked status: $e');
      Get.snackbar('Error', 'An error occurred while checking favorites');
    }
  }

  /// Returns true if this video is liked (product or package).
  bool isLiked(int index) {
    final video = videos[index];
    if (video.productId != null) {
      return likedProducts[index];
    } else if (video.packageId != null) {
      return likedPackages[index];
    }
    return false;
  }

  /// Navigate to either the Product or Package details screen
  void goToProductOrPackagePage(int index) {
    final video = videos[index];
    if (video.productId != null) {
      Get.toNamed('/product-details', arguments: [video.productId]);
    } else if (video.packageId != null) {
      Get.toNamed('/package-details', arguments: video.packageId);
    } else {
      debugPrint('No product or package associated with this video.');
      Get.snackbar('Error', 'No associated product or package found.');
    }
  }

  /// Pause all videos (used on page exit or disposal)
  void pauseAllVideos() {
    for (var controller in videoControllers) {
      if (controller?.value.isPlaying ?? false) {
        controller?.pause();
      }
    }
  }

  /// Play/Pause toggle for a specific video
  void toggleVideoPlayPause(int index) {
    if (videoControllers[index]?.value.isPlaying ?? false) {
      videoControllers[index]?.pause();
    } else {
      videoControllers[index]?.play();
    }
  }

  @override
  void onClose() {
    // Dispose all video controllers
    for (var controller in videoControllers) {
      if (controller != null && controller.value.isInitialized) {
        controller.pause();
        controller.dispose();
      }
    }
    super.onClose();
  }
}
