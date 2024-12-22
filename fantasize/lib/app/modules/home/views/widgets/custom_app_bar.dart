// lib/app/modules/home/views/widgets/custom_app_bar.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fantasize/app/data/models/package_model.dart';
import 'package:fantasize/app/data/models/product_model.dart';
import 'package:fantasize/app/global/widgets/image_handler.dart';
import 'package:fantasize/app/global/strings.dart';
import 'package:fantasize/app/modules/home/controllers/home_controller.dart';
import 'package:fantasize/app/modules/search/views/search_view.dart';

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
  Size get preferredSize => Size.fromHeight(screenHeight * 0.28);
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

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    for (int i = 0; i < homeController.categories.length; i++) {
      _itemKeys[i] = GlobalKey();
    }
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
      final renderBox =
          _itemKeys[index]?.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null && _scrollController.hasClients) {
        final position = renderBox.localToGlobal(Offset.zero, ancestor: null);
        final double itemPosition = position.dx;
        final double screenWidth = MediaQuery.of(context).size.width;
        final double itemWidth = renderBox.size.width;
        final double offset = itemPosition + itemWidth / 2 - screenWidth / 2;

        _scrollController.animateTo(
          (_scrollController.offset + offset).clamp(
            _scrollController.position.minScrollExtent,
            _scrollController.position.maxScrollExtent,
          ),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SlideTransition(
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
        ),
        // Remove the Obx and SearchOverlay from here
      ],
    );
  }

  /// Builds the main content of the AppBar
  Widget _buildContent() {
    final screenHeight = widget.screenHeight;
    final screenWidth = widget.screenWidth;
    final tabController = widget.tabController;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(screenHeight, screenWidth),
        SizedBox(height: 10),
        _buildSearchSection(screenHeight, screenWidth),
        SizedBox(height: 10),
        _buildCategories(screenWidth, tabController),
        SizedBox(height: 10),
      ],
    );
  }

  /// Builds the header section (Logo, Greeting, Profile Avatar)
  Widget _buildHeader(double screenHeight, double screenWidth) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final headerSlide = Tween<Offset>(
          begin: const Offset(0, -1),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
          ),
        );

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

  /// Builds the greeting section with user's name
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
            Text('👋', style: TextStyle(fontSize: 14)),
          ],
        ),
        Obx(() {
          final username = homeController.user.value?.username ?? '';
          return Container(
            constraints: BoxConstraints(maxWidth: 130),
            child: Text(
              username,
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

  /// Centered logo
  Widget _buildLogo(double screenWidth, double screenHeight) {
    return Container(
      padding: const EdgeInsets.all(8),
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
        fit: BoxFit.contain,
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
                color: const Color(0xFFFF5252).withOpacity(0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromRGBO(255, 82, 82, 1).withOpacity(0.1),
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
                backgroundImage: homeController.user.value?.userProfilePicture?.entityName != null
                    ? NetworkImage(
                        '${Strings().resourceUrl}/${homeController.user.value?.userProfilePicture?.entityName}')
                    : const AssetImage('assets/images/profile.jpg')
                        as ImageProvider,
              ),
            ),
          ),
        );
      }),
    );
  }

  /// Search section with a TextField and filter button
  Widget _buildSearchSection(double screenHeight, double screenWidth) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final searchSlide = Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.3, 0.9, curve: Curves.easeOut),
          ),
        );

        final searchFade = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.3, 0.9, curve: Curves.easeOut),
          ),
        );

        final searchScale = Tween<double>(begin: 0.95, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.3, 0.9, curve: Curves.easeOut),
          ),
        );

        return SlideTransition(
          position: searchSlide,
          child: FadeTransition(
            opacity: searchFade,
            child: ScaleTransition(
              scale: searchScale,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                child: Row(
                  children: [
                    Expanded(
                      flex: 7,
                      child: _buildSearchBar(screenHeight, screenWidth),
                    ),
                    const SizedBox(width: 12),
                    _buildFilterButton(screenHeight, screenWidth),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(double screenHeight, double screenWidth) {
    return Container(
      height: screenHeight * 0.06,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey[50]!,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.redAccent.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: TextField(
          controller: homeController.searchController,
          onChanged: homeController.performQuickSearch,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Search products...',
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Container(
              padding: EdgeInsets.all(12),
              child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    Colors.redAccent,
                    Colors.redAccent.shade400,
                  ],
                ).createShader(bounds),
                child: Icon(
                  Icons.search_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
            suffixIcon: Obx(() {
              return homeController.searchText.value.isNotEmpty
                  ? Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(50),
                        onTap: homeController.clearSearch,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.close_rounded,
                            color: Colors.grey[400],
                            size: 20,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink();
            }),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(double screenHeight, double screenWidth) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Get.toNamed('/search'),
        child: Ink(
          height: screenHeight * 0.06,
          width: screenWidth * 0.12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.redAccent,
                Colors.redAccent.shade400,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.redAccent.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 0,
                offset: Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.redAccent.withOpacity(0.2),
                blurRadius: 12,
                spreadRadius: -2,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0),
                ],
              ),
            ),
            child: Center(
              child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.white.withOpacity(0.8),
                  ],
                ).createShader(bounds),
                child: Icon(
                  Icons.filter_list_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the horizontal list of categories
  Widget _buildCategories(double screenWidth, TabController tabController) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final categoriesSlide = Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
          ),
        );

        final categoriesFade = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
          ),
        );

        return SlideTransition(
          position: categoriesSlide,
          child: FadeTransition(
            opacity: categoriesFade,
            child: SizedBox(
              height: 45,
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                itemCount: homeController.categories.length,
                itemBuilder: (context, index) {
                  final category = homeController.categories[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Obx(() {
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

  /// Category button
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
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: selected ? Colors.redAccent : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? Colors.redAccent : Colors.grey.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? Colors.redAccent.withOpacity(0.2)
                  : Colors.black.withOpacity(0.03),
              blurRadius: 8,
              spreadRadius: selected ? 1 : 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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

  /// Handles what happens when you tap a category
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

class SearchOverlay extends StatelessWidget {
  final List<dynamic> results;
  final bool isLoading;
  final VoidCallback onClose;

  const SearchOverlay({
    Key? key,
    required this.results,
    required this.isLoading,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          /// Backdrop
          GestureDetector(
            onTap: onClose,
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),

          /// Results panel
          Positioned(
            top: MediaQuery.of(context).padding.top + 140,
            left: 16,
            right: 16,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 400),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _buildContent(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
          ),
        ),
      );
    }

    if (results.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: Text(
            'No results found',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemCount: results.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = results[index];
        return _buildSearchResultItem(item);
      },
    );
  }

  Widget _buildSearchResultItem(dynamic item) {
    final String imageUrl = ImageHandler.getImageUrl(item.resources);
    final bool hasOffer = item.offer != null;

    return InkWell(
      onTap: () {
        onClose();
        if (item is Product) {
          Get.toNamed('/product-details', arguments: [item.productId]);
        } else if (item is Package) {
          Get.toNamed('/package-details', arguments: item.packageId);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            /// Item Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[200],
                  child:
                      const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 12),

            /// Item Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '\$${item.price}',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (hasOffer) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${item.offer!.discount}% OFF',
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
