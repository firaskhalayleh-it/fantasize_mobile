import 'package:flutter/material.dart';
import 'package:get/get.dart';
Widget homeOffers =Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    child: Image.asset(
                      'assets/images/placeholder.jpg',
                      fit: BoxFit.cover,
                      scale: 4 / 2,
                      height: Get.height * 0.4,
                      width: Get.width * 0.7,
                    ),
                  ),
                ),
                Positioned(
                  top: Get.height * 0.4 - 200,
                  left: Get.width * 0.4 - 120,
                  child: Container(
                    padding: EdgeInsets.all(5),
                    child: Text(
                      '50% OFF',
                      style: TextStyle(
                        fontFamily: 'Abel',
                        color: Colors.black,
                        fontSize: 48,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: Get.height * 0.4 - 150,
                  left: Get.width * 0.4 - 140,
                  child: Container(
                    padding: EdgeInsets.all(5),
                    child: Text(
                      'Have a grate discount on Gifts For Her',
                      style: TextStyle(
                        fontFamily: 'Abel',
                        color: Colors.black,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: Get.height * 0.4 - 185,
                  left: Get.width * 0.4 - 140,
                  child: Container(
                    padding: EdgeInsets.all(5),
                    child: Text(
                      'UP\nTO',
                      style: TextStyle(
                        fontFamily: 'Abel',
                        color: Colors.black,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: Get.height * 0.4 - 60,
                  left: Get.width * 0.4 - 140,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {},
                      child: Text('see offers',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Abel',
                              fontSize: 18)),
                    ),
                  ),
                ),
              ],
            );