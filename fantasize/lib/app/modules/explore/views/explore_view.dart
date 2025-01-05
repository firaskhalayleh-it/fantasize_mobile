import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/gestures.dart';

import '../controllers/explore_controller.dart';
import 'widgets/video_player_widget.dart';

class ExploreView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ExploreController controller = Get.find<ExploreController>();

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState();
        }

        if (controller.videos.isEmpty) {
          return _buildEmptyState();
        }

        // CHANGED: Removed `controller.likedVideos.length == controller.videos.length`
        // since we no longer use likedVideos array.
        if (!_areListsInitialized(controller)) {
          return _buildLoadingState();
        }

        return _buildVideoPageView(controller);
      }),
    );
  }

  // CHANGED: Removed likedVideos from this check
  bool _areListsInitialized(ExploreController controller) {
    return controller.videoControllers.length == controller.videos.length &&
           controller.showHeartAnimation.length == controller.videos.length;
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
      ),
      title: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: [Color(0xFFFF4C5E), Color(0xFFFF8F9C)],
        ).createShader(bounds),
        child: const Text(
          'Explore',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 1000),
            builder: (context, double value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF4C5E)),
                    strokeWidth: 3,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          TweenAnimationBuilder(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 1000),
            builder: (context, double value, child) {
              return Opacity(
                opacity: value,
                child: Text(
                  'Loading videos...',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              );
            },
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
          TweenAnimationBuilder(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 800),
            builder: (context, double value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.videocam_off,
                    color: Color(0xFFFF4C5E),
                    size: 64,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            'No Videos Available',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new content',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
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
          onPageChanged: (index) {
            debugPrint('DEBUG: Page changed to $index');
            controller.handleVideoSwitch(index);
          },
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
    // CHANGED: Removed `index < controller.likedVideos.length` check
    return index < controller.videos.length &&
           index < controller.showHeartAnimation.length;
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              color: Color(0xFFFF4C5E),
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading video',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 18,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoItem(ExploreController controller, int index) {
    return RawGestureDetector(
      gestures: {
        TapGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
          () => TapGestureRecognizer(),
          (TapGestureRecognizer instance) {
            instance.onTap = () => controller.toggleVideoPlayPause(index);
          },
        ),
        DoubleTapGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<DoubleTapGestureRecognizer>(
          () => DoubleTapGestureRecognizer(),
          (DoubleTapGestureRecognizer instance) {
            instance.onDoubleTap = () => controller.likeVideo(index);
          },
        ),
      },
      behavior: HitTestBehavior.translucent,
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
      bottom: 100,
      child: Column(
        children: [
          _buildInteractionButton(
            icon: controller.isLiked(index)
                ? Icons.favorite
                : Icons.favorite_border,
            color: controller.isLiked(index) ? Color(0xFFFF4C5E) : Colors.white,
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
    return TweenAnimationBuilder(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
          ),
        );
      },
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
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.favorite,
                  color: Color(0xFFFF4C5E),
                  size: 100,
                ),
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
