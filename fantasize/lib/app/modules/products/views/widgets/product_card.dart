import 'package:flutter/material.dart';
import 'package:fantasize/app/global/strings.dart';
import 'package:fantasize/app/data/models/product_model.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';

class ProductCard extends StatelessWidget {
  final Product product; // Product object passed to this widget

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
        createRectTween: (Rect? begin, Rect? end) {
          return RectTween(
            begin: begin,
            end: end,
          );
        },
        tag: 'product_${product.productId}',
        child: Stack(
          children: [
            Card(
              color: Colors.transparent,
              elevation: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image with 'Sold Out' badge if applicable
                  Stack(
                    children: [
                      Material(
                        elevation: 5,
                        borderRadius: BorderRadius.circular(10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            '${Strings().resourceUrl}/${product.resources.isNotEmpty ? product.resources[0].entityName : 'placeholder.jpg'}',
                            height: Get.height * 0.2,
                            width: Get.width < 400
                                ? Get.width * 0.45
                                : Get.width * 0.5,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      product.offer != null
                          ? Positioned(
                              top: Get.height * 0.08,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0xFFFF4C5E),
                                  borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(50),
                                    topRight: Radius.circular(50),
                                  ),
                                ),
                                child: Text(
                                  product.offer != null
                                      ? '${product.offer!.discount}% OFF'
                                      : '',
                                  style: TextStyle(
                                    fontFamily: 'Jost',
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                      if (product.status == 'out of stock')
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFFFF4C5E),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Sold Out',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Jost',
                            fontSize: Get.width < 400 ? 18 : 20,
                          ),
                        ),
                        Text(
                          product.description.split(' ').take(3).join(' ') +
                              (product.description.split(' ').length > 10
                                  ? '...'
                                  : ''),
                          style: TextStyle(
                            color: Color(0xFF3A4053),
                            fontFamily: 'Jost',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '\$${product.price.toString()}',
                          style: TextStyle(
                            fontFamily: 'Jost',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
