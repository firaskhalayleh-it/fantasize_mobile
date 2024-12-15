// lib/app/modules/home/views/widgets/custom_app_bar.dart

import 'package:fantasize/app/modules/search/views/search_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import 'package:fantasize/app/global/strings.dart';
import 'package:fantasize/app/modules/home/controllers/home_controller.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final double screenHeight;
  final double screenWidth;
  final TabController tabController;

  CustomAppBar({
    required this.screenHeight,
    required this.screenWidth,
    required this.tabController,
  });

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize =>
      Size.fromHeight(screenHeight * 0.28); // Reduced height
}

class _CustomAppBarState extends State<CustomAppBar>
    with TickerProviderStateMixin {
  final HomeController homeController = Get.find<HomeController>();
  late ScrollController _scrollController;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  final Map<int, GlobalKey> _itemKeys = {};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Define slide animation from top
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // Define fade-in animation
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // Initialize GlobalKeys for category items
    for (int i = 0; i < homeController.categories.length; i++) {
      _itemKeys[i] = GlobalKey();
    }

    // Start the animations
    _animationController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Scrolls the selected category into the center of the view
  void _scrollToCenter(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RenderBox? renderBox =
          _itemKeys[index]?.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null && _scrollController.hasClients) {
        Offset position = renderBox.localToGlobal(Offset.zero, ancestor: null);
        double itemPosition = position.dx;
        double screenWidth = MediaQuery.of(context).size.width;
        double itemWidth = renderBox.size.width;
        double offset = itemPosition + itemWidth / 2 - screenWidth / 2;

        _scrollController.animateTo(
          (_scrollController.offset + offset).clamp(
            _scrollController.position.minScrollExtent,
            _scrollController.position.maxScrollExtent,
          ),
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.redAccent.withOpacity(0.05),
                Colors.white.withOpacity(0.95),
              ],
            ),
          ),
          child: _buildContent(),
        ),
      ),
    );
  }

  /// Builds the main content of the AppBar, organized into sections
  Widget _buildContent() {
    final screenHeight = widget.screenHeight;
    final screenWidth = widget.screenWidth;
    final tabController = widget.tabController;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header Section (Logo, Greeting, Profile)
        _buildHeader(screenHeight, screenWidth),

        SizedBox(height: 10),
        // Search Section (Search Bar and Filter Button)
        _buildSearchSection(screenHeight, screenWidth),

        SizedBox(height: 10),
        // Categories Section
        _buildCategories(screenWidth, tabController),
        SizedBox(height: 10),
      ],
    );
  }

  /// Builds the header section with logo, greeting, and profile avatar
  Widget _buildHeader(double screenHeight, double screenWidth) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final headerSlide = Tween<Offset>(
          begin: const Offset(0, -1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
        ));

        return SlideTransition(
          position: headerSlide,
          child: Container(
            padding: EdgeInsets.only(
              top: screenHeight * 0.05,
              left: screenWidth * 0.04,
              right: screenWidth * 0.04,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Centered Logo
                _buildLogo(screenWidth, screenHeight),

                // Greeting and Profile Avatar Row
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
        );
      },
    );
  }

  /// Builds the search section with search bar and filter button
  Widget _buildSearchSection(double screenHeight, double screenWidth) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final searchSlide = Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.3, 0.9, curve: Curves.easeOut),
        ));

        final searchFade = Tween<double>(
          begin: 0,
          end: 1,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.3, 0.9, curve: Curves.easeOut),
        ));

        return SlideTransition(
          position: searchSlide,
          child: FadeTransition(
            opacity: searchFade,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: Row(
                children: [
                  // Search Bar
                  Expanded(
                    flex: 7,
                    child: _buildSearchBar(screenHeight, screenWidth),
                  ),
                  SizedBox(width: 10),
                  // Filter Button
                  _buildFilterButton(screenHeight, screenWidth),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds the greeting section with user's name and emoji
  Widget _buildGreetingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
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
            Text(
              '👋',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        Obx(() {
          return Container(
            constraints: BoxConstraints(maxWidth: 130),
            child: Text(
              homeController.user.value?.username ?? '',
              style: TextStyle(
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
    );
  }

  /// Builds the centered logo with decoration
  Widget _buildLogo(double screenWidth, double screenHeight) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
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
      ),
    );
  }

  /// Builds the profile avatar with Hero animation
  Widget _buildProfileAvatar(double screenWidth) {
    return InkWell(
      onTap: () => homeController.goToProfile(),
      child: Obx(() {
        return Hero(
          tag: 'profile',
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: const Color(0xFFFF5252).withOpacity(0.2), width: 2),
              boxShadow: [
                BoxShadow(
                  color:
                      const Color.fromRGBO(255, 82, 82, 1).withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: screenWidth * 0.06,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: screenWidth * 0.055,
                backgroundImage:
                    homeController.user.value?.userProfilePicture?.entityName !=
                            null
                        ? NetworkImage(
                            '${Strings().resourceUrl}/${homeController.user.value!.userProfilePicture!.entityName}',
                          )
                        : const AssetImage('assets/images/profile.jpg')
                            as ImageProvider,
              ),
            ),
          ),
        );
      }),
    );
  }

  /// Builds the search bar with input decoration
  Widget _buildSearchBar(double screenHeight, double screenWidth) {
    return GestureDetector(
      onTap: () {
        Get.toNamed('/search'); // Use named route for consistency
      },
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
        child: Row(
          children: [
            SizedBox(width: 15),
            Icon(
              Icons.search_rounded,
              color: Colors.redAccent,
              size: 22,
            ),
            SizedBox(width: 10),
            Text(
              'Search products...',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the filter button
  Widget _buildFilterButton(double screenHeight, double screenWidth) {
    return GestureDetector(
      onTap: () {
        Get.toNamed('/search'); // Use named route for consistency
      },
      child: Container(
        height: screenHeight * 0.06,
        width: screenWidth * 0.12,
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.redAccent.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Icon(
          Icons.filter_list_rounded,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }

  /// Builds the categories list with horizontal scrolling and animations
  Widget _buildCategories(double screenWidth, TabController tabController) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final categoriesSlide = Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
        ));

        final categoriesFade = Tween<double>(
          begin: 0,
          end: 1,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
        ));

        return SlideTransition(
          position: categoriesSlide,
          child: FadeTransition(
            opacity: categoriesFade,
            child: Container(
              height: 45,
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: BouncingScrollPhysics(),
                padding:
                    EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                itemCount: homeController.categories.length,
                itemBuilder: (context, index) {
                  final category = homeController.categories[index];
                  return Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Obx(() { // Wrap each category button with Obx
                      final isSelected =
                          homeController.currentIndexTabBar.value == index;
                      return _buildCategoryButton(
                        key: _itemKeys[index] ?? GlobalKey(),
                        screenWidth: screenWidth,
                        icon: category['icon'],
                        text: category['text'],
                        selected: isSelected,
                        onTap: () {
                          homeController.changeTabBarIndex(index);
                          _handleCategoryNavigation(
                              tabController, category['text']);
                          _scrollToCenter(index);
                        },
                      );
                    }),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds individual category buttons with animations
  Widget _buildCategoryButton({
    required Key key,
    required double screenWidth,
    required IconData icon,
    required String text,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: selected ? Colors.redAccent : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
                selected ? Colors.redAccent : Colors.grey.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? Colors.redAccent.withOpacity(0.2)
                  : Colors.black.withOpacity(0.03),
              blurRadius: 8,
              spreadRadius: selected ? 1 : 0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 16,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: selected ? Colors.white : Colors.grey[700],
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                color: selected ? Colors.white : Colors.grey[800],
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Handles navigation based on the selected category and current tab
  void _handleCategoryNavigation(
      TabController tabController, String categoryText) {
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
}
  