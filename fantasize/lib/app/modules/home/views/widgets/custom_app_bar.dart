import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:fantasize/app/global/strings.dart';
import 'package:fantasize/app/modules/home/controllers/home_controller.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final double screenHeight;
  final double screenWidth;
  final TabController tabController;

  const CustomAppBar({
    Key? key,
    required this.screenHeight,
    required this.screenWidth,
    required this.tabController,
  }) : super(key: key);

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(screenHeight * 0.28);
}

class _CustomAppBarState extends State<CustomAppBar>
    with TickerProviderStateMixin {
  final HomeController homeController = Get.find<HomeController>();
  late ScrollController _scrollController;

  // Animation controllers
  late AnimationController _mainAnimationController;
  late AnimationController _logoAnimationController;
  late AnimationController _searchAnimationController;
  late AnimationController _filterAnimationController;
  late AnimationController _pulseAnimationController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _searchWidthAnimation;
  late Animation<double> _filterRotateAnimation;
  late Animation<double> _pulseScaleAnimation;

  final Map<int, GlobalKey> _itemKeys = {};
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _setupAnimationControllers();
    _setupAnimations();
    _startInitialAnimations();

    for (int i = 0; i < homeController.categories.length; i++) {
      _itemKeys[i] = GlobalKey();
    }
  }

  void _setupAnimationControllers() {
    _mainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  void _setupAnimations() {
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: Curves.easeOutBack,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _rotateAnimation = Tween<double>(
      begin: -0.5,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: Curves.easeOutBack,
    ));

    _logoScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2),
        weight: 40.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0),
        weight: 60.0,
      ),
    ]).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));

    _searchWidthAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.easeInOut,
    ));

    _filterRotateAnimation = Tween<double>(
      begin: 0,
      end: math.pi * 2,
    ).animate(CurvedAnimation(
      parent: _filterAnimationController,
      curve: Curves.easeInOutBack,
    ));

    _pulseScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void _startInitialAnimations() {
    Future.delayed(const Duration(milliseconds: 200), () {
      _mainAnimationController.forward();
      _logoAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _mainAnimationController.dispose();
    _logoAnimationController.dispose();
    _searchAnimationController.dispose();
    _filterAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  void _scrollToCenter(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RenderBox? renderBox =
          _itemKeys[index]?.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        Offset position =
            renderBox.localToGlobal(Offset.zero, ancestor: null);
        double itemPosition = position.dx;
        double screenWidth = widget.screenWidth;
        double itemWidth = renderBox.size.width;
        double offset = itemPosition + itemWidth / 2 - screenWidth / 2;

        double maxScrollExtent = _scrollController.position.maxScrollExtent;
        double minScrollExtent = _scrollController.position.minScrollExtent;
        double targetOffset = (_scrollController.offset + offset)
            .clamp(minScrollExtent, maxScrollExtent);

        _scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = widget.screenHeight;
    final screenWidth = widget.screenWidth;
    final tabController = widget.tabController;

    return AnimatedBuilder(
      animation: _mainAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.redAccent.withOpacity(0.05 * _fadeAnimation.value),
                      Colors.white.withOpacity(0.95 * _fadeAnimation.value),
                    ],
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 10 * _fadeAnimation.value,
                    sigmaY: 10 * _fadeAnimation.value,
                  ),
                  child:
                      _buildContent(screenHeight, screenWidth, tabController),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(
      double screenHeight, double screenWidth, TabController tabController) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header Section with Logo and Profile
        Container(
          padding: EdgeInsets.only(
            top: screenHeight * 0.05,
            left: screenWidth * 0.04,
            right: screenWidth * 0.04,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ScaleTransition(
                scale: _logoScaleAnimation,
                child: _buildLogo(screenWidth, screenHeight),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildGreetingSection(),
                  _buildProfileAvatar(screenWidth),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        // Search and Filter Section
        _buildSearchSection(screenHeight, screenWidth),
        const SizedBox(height: 15),
        // Categories Section
        _buildCategories(screenWidth, tabController),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildGreetingSection() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1, 0),
        end: Offset.zero,
      ).animate(_mainAnimationController),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Hello,',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 4),
              ScaleTransition(
                scale: _pulseScaleAnimation,
                child: const Text(
                  '👋',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          Obx(() {
            return Container(
              constraints: const BoxConstraints(maxWidth: 130),
              child: Text(
                homeController.getUserName(),
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLogo(double screenWidth, double screenHeight) {
    return MouseRegion(
      onEnter: (_) => _logoAnimationController.forward(from: 0),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.redAccent.withOpacity(0.1),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Image.asset(
          'assets/icons/fantasize.png',
          width: screenWidth * 0.15,
          height: screenHeight * 0.05,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(double screenWidth) {
    return Container(
      width: screenWidth * 0.1,
      height: screenWidth * 0.1,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: AssetImage('assets/images/profile_avatar.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildSearchSection(double screenHeight, double screenWidth) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: Row(
        children: [
          Expanded(
            flex: 7,
            child: ScaleTransition(
              scale: _searchWidthAnimation,
              child: _buildSearchBar(screenHeight, screenWidth),
            ),
          ),
          const SizedBox(width: 10),
          RotationTransition(
            turns: _filterRotateAnimation,
            child: _buildFilterButton(screenHeight),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(double screenHeight) {
    return MouseRegion(
      onEnter: (_) => _filterAnimationController.forward(),
      onExit: (_) => _filterAnimationController.reverse(),
      child: AnimatedBuilder(
        animation: _pulseScaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseScaleAnimation.value,
            child: GestureDetector(
              onTap: () {
                // Define filter button action here
                // For example, navigate to filter options
                // You can also trigger additional animations if needed
              },
              child: Container(
                height: screenHeight * 0.06,
                width: screenHeight * 0.06,
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.redAccent.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(double screenHeight, double screenWidth) {
    return MouseRegion(
      onEnter: (_) => _searchAnimationController.forward(),
      onExit: (_) => _searchAnimationController.reverse(),
      child: Container(
        height: screenHeight * 0.06,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.redAccent.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: TextField(
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
          onTap: () => setState(() => _isSearchFocused = true),
          onSubmitted: (_) => setState(() => _isSearchFocused = false),
          decoration: InputDecoration(
            hintText: 'Search products...',
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                _isSearchFocused ? Icons.search : Icons.search_rounded,
                color: Colors.redAccent,
                size: 22,
                key: ValueKey<bool>(_isSearchFocused),
              ),
            ),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildCategories(double screenWidth, TabController tabController) {
    final categoriesCount = homeController.categories.length;
    final maxDelay = 0.4; // Ensures end = delay + 0.6 <= 1.0
    final perCategoryDelay =
        categoriesCount > 1 ? maxDelay / (categoriesCount - 1) : 0.0;

    return SizedBox(
      height: 45,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
        itemCount: homeController.categories.length,
        itemBuilder: (context, index) {
          final category = homeController.categories[index];
          return Obx(() {
            return AnimatedBuilder(
              animation: _mainAnimationController,
              builder: (context, child) {
                // Calculate staggered delay based on index
                final delay = index * perCategoryDelay;
                final begin = delay.clamp(0.0, 1.0);
                final end = (delay + 0.6).clamp(0.0, 1.0);

                // Ensure that begin is less than end to avoid assertion errors
                if (begin >= end) {
                  return SizedBox.shrink();
                }

                final slideAnimation = Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _mainAnimationController,
                    curve: Interval(
                      begin,
                      end,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                );

                final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _mainAnimationController,
                    curve: Interval(
                      begin,
                      end,
                      curve: Curves.easeOut,
                    ),
                  ),
                );

                return SlideTransition(
                  position: slideAnimation,
                  child: FadeTransition(
                    opacity: fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: _buildCategoryButton(
                        key: _itemKeys[index]!,
                        screenWidth: screenWidth,
                        icon: category['icon'],
                        text: category['text'],
                        selected:
                            homeController.currentIndexTabBar.value == index,
                        onTap: () {
                          homeController.changeTabBarIndex(index);
                          _handleCategoryNavigation(
                              tabController, category['text']);
                          _scrollToCenter(index);

                          // Add ripple effect animation
                          _filterAnimationController.forward(from: 0);
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          });
        },
      ),
    );
  }

  void _handleCategoryNavigation(
      TabController tabController, String categoryText) {
    // Add scale animation when changing categories
    _searchAnimationController.forward(from: 0);

    switch (tabController.index) {
      case 0:
        homeController.getNewCollectionSubcategory(categoryText);
        break;
      case 1:
        homeController.getOffersSubcategory(categoryText);
        break;
      case 2:
        homeController.getNewArrivalsSubcategory(categoryText);
        break;
      case 3:
        homeController.getRecommendedForYouSubcategory(categoryText);
        break;
      default:
        break;
    }
  }

  Widget _buildCategoryButton({
    required Key key,
    required double screenWidth,
    required IconData icon,
    required String text,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      onEnter: (_) {
        _pulseAnimationController.forward();
      },
      onExit: (_) {
        _pulseAnimationController.reverse();
      },
      child: GestureDetector(
        key: key,
        onTap: () {
          onTap();
          // Trigger pulse animation on tap
          _pulseAnimationController.forward(from: 0);
        },
        child: AnimatedBuilder(
          animation: _pulseScaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: selected ? _pulseScaleAnimation.value : 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: selected ? Colors.redAccent : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected
                        ? Colors.redAccent
                        : Colors.grey.withOpacity(0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: selected
                          ? Colors.redAccent.withOpacity(0.3)
                          : Colors.black.withOpacity(0.05),
                      blurRadius: selected ? 12 : 8,
                      spreadRadius: selected ? 2 : 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Row(
                  children: [
                    // Animated Icon
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 300),
                      tween: Tween<double>(
                        begin: 0,
                        end: selected ? 1 : 0,
                      ),
                      builder: (context, value, child) {
                        return Transform.rotate(
                          angle: value * math.pi * 2,
                          child: Icon(
                            icon,
                            size: 20,
                            color: Color.lerp(
                              Colors.grey[700],
                              Colors.white,
                              value,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 6),
                    // Animated Text
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 300),
                      tween: Tween<double>(
                        begin: 0,
                        end: selected ? 1 : 0,
                      ),
                      builder: (context, value, child) {
                        return Text(
                          text,
                          style: TextStyle(
                            color: Color.lerp(
                              Colors.grey[800],
                              Colors.white,
                              value,
                            ),
                            fontWeight:
                                selected ? FontWeight.w600 : FontWeight.w500,
                            fontSize: 13 + (value * 1), // Slight size increase
                            letterSpacing: 0.3,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
