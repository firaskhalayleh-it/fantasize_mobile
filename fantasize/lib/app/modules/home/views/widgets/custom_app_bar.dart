import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  Size get preferredSize => Size.fromHeight(screenHeight * 0.35);
}

class _CustomAppBarState extends State<CustomAppBar> {
  final HomeController homeController = Get.find<HomeController>();
  late ScrollController _scrollController;
  final Map<int, GlobalKey> _itemKeys = {};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Initialize keys for each category
    for (int i = 0; i < homeController.categories.length; i++) {
      _itemKeys[i] = GlobalKey();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCenter(int index) {
    // Delay the calculation to ensure the layout is updated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RenderBox? renderBox =
          _itemKeys[index]?.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        // Get the position of the clicked item
        Offset position = renderBox.localToGlobal(Offset.zero, ancestor: null);
        double itemPosition = position.dx;

        // Calculate the offset to center the item
        double screenWidth = MediaQuery.of(context).size.width;
        double itemWidth = renderBox.size.width;
        double offset = itemPosition + itemWidth / 2 - screenWidth / 2;

        // Ensure offset is within bounds
        double maxScrollExtent = _scrollController.position.maxScrollExtent;
        double minScrollExtent = _scrollController.position.minScrollExtent;
        double targetOffset = _scrollController.offset + offset;

        if (targetOffset < minScrollExtent) {
          targetOffset = minScrollExtent;
        } else if (targetOffset > maxScrollExtent) {
          targetOffset = maxScrollExtent;
        }

        // Scroll the controller to the calculated offset
        _scrollController.animateTo(
          targetOffset,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = widget.screenHeight;
    final screenWidth = widget.screenWidth;
    final tabController = widget.tabController;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top Section with Greeting, Logo, and Profile Picture
        Padding(
          padding: EdgeInsets.only(
            top: screenHeight * 0.04,
            left: screenWidth * 0.02,
            right: screenWidth * 0.02,
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 Row(
                  children: [
                     Text(
                    'Hello, Welcome',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text(
                    '👋',
                    style: TextStyle(fontSize: 14),
                  ),
                  ],
                 ),
                  Obx(() {
                    return Text(
                      homeController.getUserName(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }),
                ],
              ),
              const Spacer(flex: 3),

              // Center Logo
              Image.asset(
                'assets/icons/fantasize.png',
                width: screenWidth * 0.1,
                height: screenHeight * 0.05,
              ),
              const Spacer(flex: 8),

              // Right Profile Picture
              InkWell(
                onTap: () => homeController.goToProfile(),
                child: Obx(() {
                  return Hero(
                    tag: 'profile',
                    child: CircleAvatar(
                      radius: screenWidth * 0.06,
                      backgroundImage: homeController
                                  .user.value?.userProfilePicture?.entityName !=
                              null
                          ? NetworkImage(
                              '${Strings().resourceUrl}/${homeController.user.value!.userProfilePicture!.entityName}',
                            )
                          : const AssetImage('assets/images/profile.jpg')
                              as ImageProvider,
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Search Bar
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          child: Container(
            height: screenHeight * 0.06,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Icon(Icons.search),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: const Color.fromARGB(255, 206, 206, 206),
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: const Color.fromARGB(255, 206, 206, 206),
                    width: 2,
                  ),
                ),
                fillColor: Colors.grey[200],
                filled: true,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Horizontal Category Buttons with Scrollable View
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  List.generate(homeController.categories.length, (index) {
                final category = homeController.categories[index];
                return Obx(() {
                  return Row(
                    children: [
                      _buildCategoryButton(
                        key: _itemKeys[index] ?? GlobalKey(),
                        screenWidth: screenWidth,
                        icon: category['icon'],
                        text: category['text'],
                        selected:
                            homeController.currentIndexTabBar.value == index,
                        onTap: () {
                          homeController.changeTabBarIndex(index);

                          // Handle navigation to category
                          if (tabController.index == 0) {
                            homeController
                                .getNewCollectionSubcategory(category['text']);
                          } else if (tabController.index == 1) {
                            homeController
                                .getOffersSubcategory(category['text']);
                          } else if (tabController.index == 2) {
                            homeController
                                .getNewArrivalsSubcategory(category['text']);
                          } else if (tabController.index == 3) {
                            homeController.getRecommendedForYouSubcategory(
                                category['text']);
                          }

                          // Scroll to center the clicked button
                          _scrollToCenter(index);
                        },
                      ),
                      const SizedBox(width: 10),
                    ],
                  );
                });
              }),
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  // Helper method to build category buttons
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
      child: Container(
        decoration: BoxDecoration(
          color: selected ? Colors.red[300] : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          children: [
            Icon(
              icon,
              size: screenWidth * 0.045,
              color: selected ? Colors.white : Colors.black,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: screenWidth * 0.03,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
