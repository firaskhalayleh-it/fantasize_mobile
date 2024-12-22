import 'dart:ui';

import 'package:fantasize/app/data/models/package_model.dart';
import 'package:fantasize/app/data/models/product_model.dart';
import 'package:fantasize/app/global/widgets/image_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fantasize/app/modules/home/controllers/home_controller.dart';
import 'package:fantasize/app/modules/home/views/widgets/custom_app_bar.dart';
import 'package:fantasize/app/modules/home/views/widgets/all_tab/all_tab.dart';
import 'package:fantasize/app/modules/home/views/widgets/new_arrivals/new_arrival_view.dart';
import 'package:fantasize/app/modules/home/views/widgets/offers/offer_view.dart';
import 'package:fantasize/app/modules/home/views/widgets/recommended_for_you/recommended_for_you_view.dart';
class HomeTabView extends StatelessWidget {
  final HomeController homeController = Get.find<HomeController>();

  HomeTabView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = screenHeight * 0.28;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main content
          Column(
            children: [
              Container(
                height: appBarHeight,
                child: CustomAppBar(
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                  tabController: homeController.tabController,
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: homeController.tabController,
                  children: List.generate(homeController.categories.length, (index) {
                    switch (index) {
                      case 0:
                        return AllTab();
                      case 1:
                        return NewArrivalView();
                      case 2:
                        return OfferView();
                      case 3:
                        return RecommendedForYouView();
                      default:
                        return Center(child: Text('Page ${index + 1}'));
                    }
                  }),
                ),
              ),
            ],
          ),

          // Animated backdrop
          Obx(() {
            return AnimatedOpacity(
              duration: Duration(milliseconds: 200),
              opacity: homeController.showQuickResults.value ? 1.0 : 0.0,
              child: homeController.showQuickResults.value
                  ? GestureDetector(
                      onTap: () => homeController.showQuickResults.value = false,
                      child: Container(
                        color: Colors.black.withOpacity(0.4),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                          child: Container(
                            color: Colors.transparent,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            );
          }),

          // Enhanced Search Results Overlay
          Obx(() {
            return AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              top: homeController.showQuickResults.value ? topPadding + 120 : -screenHeight,
              left: 16,
              right: 16,
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 200),
                opacity: homeController.showQuickResults.value ? 1.0 : 0.0,
                child: Container(
                  constraints: BoxConstraints(maxHeight: screenHeight * 0.7),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.98),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 5,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Search header
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.search, color: Colors.grey[600], size: 20),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Search Results',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => homeController.showQuickResults.value = false,
                                    icon: Icon(Icons.close, color: Colors.grey[600], size: 20),
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(),
                                  ),
                                ],
                              ),
                            ),
                            // Search results
                            Container(
                              constraints: BoxConstraints(
                                maxHeight: screenHeight * 0.6,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(16),
                                  bottomRight: Radius.circular(16),
                                ),
                                child: SearchOverlay(
                                  results: homeController.quickSearchResults,
                                  isLoading: homeController.isQuickSearching.value,
                                  onClose: () => homeController.showQuickResults.value = false,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// Update the SearchOverlay class to have enhanced styling
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
    return _buildContent(context);
  }

  Widget _buildContent(BuildContext context) {
    if (isLoading) {
      return Container(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
                  strokeWidth: 3,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Searching...',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (results.isEmpty) {
      return Container(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 48,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16),
              Text(
                'No results found',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Try different keywords',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemCount: results.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: Colors.grey.withOpacity(0.2),
      ),
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
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _buildItemImage(imageUrl),
            SizedBox(width: 12),
            Expanded(
              child: _buildItemDetails(item, hasOffer),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemImage(String imageUrl) {
    return Hero(
      tag: imageUrl,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[200],
              child: Icon(Icons.image_not_supported, color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemDetails(dynamic item, bool hasOffer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.grey[800],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 4),
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(4),
              ),
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Text(
                '\$${item.price}',
                style: TextStyle(
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            if (hasOffer) ...[
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_offer_rounded,
                      size: 12,
                      color: Colors.red,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${item.offer!.discount}% OFF',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}