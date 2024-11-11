// lib/app/modules/address/views/address_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:get/get.dart';
import '../controllers/address_controller.dart';

class AddressView extends GetView<AddressController> {
  AddressView({Key? key}) : super(key: key);

  // Declare a GlobalKey for the Form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // The controller is automatically provided by GetView
    // Access it using 'controller'

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Image(image: Svg('assets/icons/back_button.svg'))),
        title: Center(
          child: Image.asset(
            'assets/icons/fantasize.png',
            height: 40,
          ),
        ),
        actions: const [
          SizedBox(width: 48),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey, // Assign the GlobalKey to the Form
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Address Line',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                TextFormField(
                  controller: controller.addressLineController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the address line';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Street',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                TextFormField(
                  controller: controller.streetController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the street';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Region',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                TextFormField(
                  controller: controller.regionController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the region';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'City',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                TextFormField(
                  controller: controller.cityController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the city';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Country',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                TextFormField(
                  controller: controller.countryController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the country';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Validate the form before saving
                      if (_formKey.currentState!.validate()) {
                        controller.saveAddress();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 100),
                      backgroundColor: const Color(0xFFFF4C5E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Jost',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 32),
                //delete button under condition that address is not new
                if (controller.addressId != null)
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        controller.deleteAddress();
                      },
                      icon: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 100),
                        backgroundColor: Color(0xFFFF4C5E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      label: const Text(
                        'Delete',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Jost',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
