import 'package:fantasize/app/global/strings.dart';
import 'package:fantasize/app/global/widgets/image_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NewArrivalCard extends StatelessWidget {
  final dynamic item;
  NewArrivalCard({key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Card(
          color: Color(Colors.white.value),
          elevation: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // item Image with 'Sold Out' badge if applicable
              Stack(
                children: [
                  item.offer != null
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
                              item.offer != null
                                  ? '${item.offer!.discount}% OFF'
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
                  Material(
                    elevation: 5,
                    borderRadius: BorderRadius.circular(10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        ImageHandler.getImageUrl(item.resources),
                        height: Get.height * 0.2,
                        width: Get.width * 0.5,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Image.asset('assets/images/placeholder.jpg',
                              height: Get.height * 0.2,
                              width: Get.width * 0.5,
                              fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  ),
                  if (item.status == 'out of stock')
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
                      item.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Jost',
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      item.description.split(' ').take(5).join(' ') +
                          (item.description.split(' ').length > 10
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
                      '\$${item.price.toString()}',
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
    );
  }
}
