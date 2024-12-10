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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(),
        title: const Text(
          'Explore',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState();
        }

        if (controller.videos.isEmpty) {
          return _buildEmptyState();
        }

        if (!_areListsInitialized(controller)) {
          return _buildLoadingState();
        }

        return _buildVideoPageView(controller);
      }),
    );
  }

  bool _areListsInitialized(ExploreController controller) {
    return controller.videoControllers.length == controller.videos.length &&
        controller.likedVideos.length == controller.videos.length &&
        controller.showHeartAnimation.length == controller.videos.length;
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading videos...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.videocam_off,
            color: Colors.white.withOpacity(0.5),
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'No videos available',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPageView(ExploreController controller) {
    return Stack(
      children: [
        PageView.builder(
          scrollDirection: Axis.vertical,
          itemCount: controller.videos.length,
          onPageChanged: controller.handleVideoSwitch,
          itemBuilder: (context, index) {
            if (!_isValidIndex(controller, index)) {
              return _buildErrorState();
            }
            return _buildVideoItem(controller, index);
          },
        ),
        _buildGradientOverlay(),
      ],
    );
  }

  bool _isValidIndex(ExploreController controller, int index) {
    return index < controller.videos.length &&
        index < controller.likedVideos.length &&
        index < controller.showHeartAnimation.length;
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.white.withOpacity(0.5),
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading video',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoItem(ExploreController controller, int index) {
    return GestureDetector(
      onDoubleTap: () => controller.likeVideo(index),
      onTap: () => controller.toggleVideoPlayPause(index),
      child: Stack(
        children: [
          VideoPlayerWidget(videoIndex: index),
          _buildVideoOverlay(controller, index),
          
          if (controller.showHeartAnimation[index]) _buildHeartAnimation(),
        ],
      ),
    );
  }

  Widget _buildVideoOverlay(ExploreController controller, int index) {
    return Positioned(
      right: 16,
      bottom: 80,
      child: Column(
        children: [
          _buildInteractionButton(
            icon: controller.isLiked(index)
                ? Icons.favorite
                : Icons.favorite_border,
            color: controller.isLiked(index) ? Colors.red : Colors.white,
            onTap: () => controller.likeVideo(index),
          ),
          const SizedBox(height: 20),
          _buildInteractionButton(
            icon: Icons.shopping_cart_outlined,
            onTap: () => controller.goToProductOrPackagePage(index),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionButton({
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: color,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildHeartAnimation() {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 800),
        builder: (context, value, child) {
          return Transform.scale(
            scale: 2 * value * (1 - value) + 1,
            child: Opacity(
              opacity: value > 0.5 ? 2 * (1 - value) : 2 * value,
              child: const Icon(
                Icons.favorite,
                color: Colors.red,
                size: 100,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.transparent,
                Colors.transparent,
                Colors.black.withOpacity(0.3),
              ],
              stops: const [0.0, 0.2, 0.8, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}
