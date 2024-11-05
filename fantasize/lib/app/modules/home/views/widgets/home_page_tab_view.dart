import 'package:fantasize/app/modules/home/views/widgets/all_tab/all_tab.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fantasize/app/modules/home/controllers/home_controller.dart';
import 'package:fantasize/app/modules/home/views/widgets/custom_app_bar.dart';

class HomeTabView extends StatelessWidget {
  final HomeController homeController = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      
      appBar: CustomAppBar(
        screenHeight: screenHeight,
        screenWidth: screenWidth,
        tabController: homeController.tabController, // Pass the GetX-controlled TabController
      ),
      body: TabBarView(
        controller: homeController.tabController, // Bind TabBarView to TabController
        children: List.generate(
          homeController.categories.length,
          (index) {
            if(index == 0) {
              return Center(
                child: AllTab(),
              );
            }
            return Center(
              child: Text('Page ${index + 1}'),
            );
          }
        ),
      ),
    );
  }
}
