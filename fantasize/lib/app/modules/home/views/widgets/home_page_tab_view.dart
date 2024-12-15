// lib/app/modules/home/views/home_tab_view.dart

import 'package:fantasize/app/modules/home/views/widgets/all_tab/all_tab.dart';
import 'package:fantasize/app/modules/home/views/widgets/new_arrivals/new_arrival_view.dart';
import 'package:fantasize/app/modules/home/views/widgets/offers/offer_view.dart';
import 'package:fantasize/app/modules/home/views/widgets/recommended_for_you/recommended_for_you_view.dart';
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
        tabController: homeController.tabController,
      ),
      body: TabBarView(
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
              return Center(
                child: Text('Page ${index + 1}'),
              );
          }
        }),
      ),
    );
  }
}
