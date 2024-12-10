import 'dart:ui';
import 'package:fantasize/app/data/models/offer_model.dart';
import 'package:fantasize/app/data/models/product_model.dart';
import 'package:fantasize/app/data/models/package_model.dart';
import 'package:fantasize/app/global/strings.dart';
import 'package:fantasize/app/modules/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeOffersWidget extends GetView<HomeController> {
  final dynamic item;

  const HomeOffersWidget({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String imageUrl = item.resources.isNotEmpty
        ? '${Strings().resourceUrl}/${item.resources.first.entityName}'
        : '${Strings().resourceUrl}/placeholder.jpg';
    String name = item.name;
    int discount = int.tryParse(item.offer?.discount?.toString() ?? '0') ?? 0;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Stack(
                children: [
                  Hero(
                    tag: 'offer_${item.hashCode}',
                    child: Container(
                      height: Get.height * 0.45,
                      width: Get.width * 0.8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.redAccent.withOpacity(0.2),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Background Image with Advanced Effects
                            ShaderMask(
                              shaderCallback: (rect) {
                                return LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.9),
                                  ],
                                  stops: [0.4, 0.95],
                                ).createShader(rect);
                              },
                              blendMode: BlendMode.darken,
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'assets/images/placeholder.jpg',
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            ),

                            // Modern Glassmorphic Layer
                            BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.white.withOpacity(0.0),
                                      Colors.black.withOpacity(0.7),
                                    ],
                                    stops: [0.4, 0.95],
                                  ),
                                ),
                              ),
                            ),

                            // Content Layer
                            Padding(
                              padding: EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // Animated Discount Badge
                                  TweenAnimationBuilder<double>(
                                    duration: const Duration(milliseconds: 600),
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    curve: Curves.elasticOut,
                                    builder: (context, value, child) {
                                      return Transform.scale(
                                        scale: value,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.redAccent,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.redAccent
                                                    .withOpacity(0.4),
                                                blurRadius: 12,
                                                offset: Offset(0, 6),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                '$discount%',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 28,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 1,
                                                ),
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                'OFF',
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.9),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(height: 16),

                                  // Product Name with Shimmer
                                  ShaderMask(
                                    shaderCallback: (bounds) {
                                      return LinearGradient(
                                        colors: [
                                          Colors.white,
                                          Colors.white.withOpacity(0.8),
                                          Colors.white,
                                        ],
                                        stops: [0.0, 0.5, 1.0],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ).createShader(bounds);
                                    },
                                    child: Text(
                                      name,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20),

                                  // Modern Action Button
                                  MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: Container(
                                      width: double.infinity,
                                      height: 54,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          if (item is Product) {
                                            Get.toNamed('/product-details',
                                                arguments: [item.productId]);
                                          } else if (item is Package) {
                                            Get.toNamed('/package-details',
                                                arguments: item.packageId);
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: Colors.redAccent,
                                          elevation: 12,
                                          shadowColor:
                                              Colors.redAccent.withOpacity(0.4),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Explore Offer',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Icon(
                                              Icons.arrow_forward_rounded,
                                              size: 24,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
