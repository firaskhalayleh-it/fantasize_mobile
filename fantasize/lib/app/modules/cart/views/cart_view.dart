import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

import 'package:get/get.dart';

import '../controllers/cart_controller.dart';

class CartView extends GetView<CartController> {
  const CartView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Image.asset(
            'assets/icons/fantasize.png',
            height: Get.height * 0.05,
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Container(
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    child: Image.asset(
                      'assets/images/placeholder.jpg',
                      width: 70,
                      height: 70,
                      fit: BoxFit.fill,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'golden product',
                              style: TextStyle(
                                fontFamily: 'Jost',
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(
                              width: Get.width * 0.35,
                            ),
                            Icon((Icons.star)),
                            Icon((Icons.star)),
                            Icon((Icons.star))
                          ],
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Description',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontFamily: 'Jost',
                              fontSize: 10,
                              color: Color(0xFFA4AAAD)),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Row(
                          children: [
                            Text(
                              '202',
                              style: TextStyle(
                                  fontFamily: 'Jost',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                          SizedBox(
                            width: Get.width * 0.5,
                          ),
                            Row(
                              children: [
                                 Container(
                              height: 28,
                              width: 27 ,
                              decoration: BoxDecoration(
                                color: Color(0xFFFF4C5E),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  bottomLeft: Radius.circular(8),
                                ),
                              ),

                            ),
                            Container(
                              height: 28,
                              width: 27,
                              decoration: BoxDecoration(
                                color: Color(0xFFE5E5E5),
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(8),
                                  bottomRight: Radius.circular(8),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '1',
                                  style: TextStyle(
                                    fontFamily: 'Jost',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                              ],
                            )
                          ],
                        ),
                        
                      ],
                    ),
                  )
                ],
              ),
            ),
            Divider()
          ],
        ));
  }
}
