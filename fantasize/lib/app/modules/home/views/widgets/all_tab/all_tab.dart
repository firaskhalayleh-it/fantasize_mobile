import 'package:flutter/material.dart';

class AllTab extends StatelessWidget {
  const AllTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 1,
      itemBuilder: (BuildContext context, int index) {
        return Column(
          children: [
            // Image.asset(
            //   'assets/images/placeholder.png',
            //   width: screenWidth * 0.9,
            //   height: screenHeight * 0.3,
            // ),
            const SizedBox(height: 10),
            const Text(
              'Product Name',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Product Description',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Product Price',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            // ElevatedButton(
            //   onPressed: () {},
            //   child: const Text('Add to Cart'),
            // ),
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }
}