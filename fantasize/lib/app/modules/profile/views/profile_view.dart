import 'package:fantasize/app/data/models/address_model.dart';
import 'package:fantasize/app/modules/profile/controllers/profile_controller.dart';
import 'package:fantasize/app/modules/profile/views/widgets/build_list_tile.dart';
import 'package:fantasize/app/modules/profile/views/widgets/build_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:get/get.dart';

import '../../../global/strings.dart';

class ProfileView extends StatelessWidget {
  final ProfileController controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          style: ButtonStyle(
            padding: WidgetStatePropertyAll(const EdgeInsets.all(0)),
            elevation: WidgetStatePropertyAll(2),
            shadowColor: WidgetStatePropertyAll(Colors.black),
          ),
          icon: Image(image: Svg('assets/icons/back_button.svg')),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
              color: Colors.redAccent, fontFamily: 'Poppins', fontSize: 25),
        ),
      ),
      body: Obx(
        () {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          } else if (controller.user.value == null) {
            return const Center(child: Text('No user data found.'));
          } else {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Picture
                    Hero(
                        tag: 'profile',
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage:
                                  controller.user.value!.userProfilePicture !=
                                          null
                                      ? NetworkImage(
                                          '${Strings().resourceUrl}/${controller.user.value!.userProfilePicture!.entityName}',
                                        )
                                      : const AssetImage(
                                              'assets/images/profile.jpg')
                                          as ImageProvider,
                            ),
                            InkWell(
                              onTap: () {
                                controller.pickImage();
                              },
                              child: Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 9,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        controller.user.value!.username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Jost',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Personal Information Section
                    BuildSection().buildSection('Personal Information', [
                      ListTile(
                        title: TextButton(
                            onPressed: () {
                              controller.NavigateToUserInfo();
                            },
                            child: Text(
                              'Edit Personal Information',
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            )),
                      ),
                      TextButton(
                          onPressed: () {
                            controller.showResetPasswordDialog();
                          },
                          child: Text(
                            'Change Password',
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ))
                    ]),

                    // Address Information Section
                    BuildSection().buildSection('Payment Methods', [
                      if (controller.user.value!.paymentMethods != null &&
                          controller.user.value!.paymentMethods!.isNotEmpty)
                        for (var method
                            in controller.user.value!.paymentMethods!)
                          BuildListTile().buildListTile(
                            '${method.cardType} - ${method.cardNumber}',
                            controller.getCardIcon(method.cardNumber),
                            trailing: IconButton(
                                onPressed: () {
                                  Get.toNamed('/payment-method',
                                      arguments: {'paymentMethod': method});
                                },
                                icon: Icon(Icons.edit)),
                          )
                      else
                        const ListTile(
                            title: Text('No payment methods added yet')),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 10),
                          backgroundColor: const Color(0xFFFF4C5E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => controller.NavigateToPaymentMethod(),
                        child: const Text(
                          'Add Payment Method',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Jost',
                          ),
                        ),
                      ),
                    ]),

                    // Addresses
                    BuildSection().buildSection('Addresses', [
                      if (controller.user.value!.addresses != null &&
                          controller.user.value!.addresses!.isNotEmpty)
                        for (var address in controller.user.value!.addresses!)
                          BuildListTile().buildListTile(
                            '${address.addressLine}, ${address.city}, ${address.country}',
                            Icon(Icons.location_on),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Get.toNamed('/address',
                                    arguments: {'address': address});
                              },
                            ),
                          )
                      else
                        ListTile(
                          title: Text('No addresses added yet'),
                          // title: Text('No addresses added yet'),
                          leading: IconButton(
                              onPressed: () {
                                Get.toNamed('/address',
                                    arguments: {'address': Address()});
                              },
                              icon: Icon(Icons.add)),
                        ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 10),
                            backgroundColor: const Color(0xFFFF4C5E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            Get.toNamed('/address');
                          },
                          child: Text('Add Address',
                              style: const TextStyle(
                                fontFamily: 'Jost',
                                color: Colors.white,
                              ))),
                    ]),

                    Padding(
                      padding: const EdgeInsets.only(left: 3),
                      child: Align(
                        alignment: Alignment.centerLeft,

                        child: TextButton(
                            onPressed: () {
                              Get.toNamed('/order-history');
                            },
                            child: Text(
                              'Order History',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                  fontFamily: 'Jost',
                                  fontWeight: FontWeight.bold),
                            )),
                        // Preferences Section,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Logout Button
                    ListTile(
                      title: const Text(
                        'Log Out',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      trailing: const Icon(Icons.logout, color: Colors.red),
                      onTap: () {
                        controller
                            .logout(); // Call the logout method from ProfileController
                      },
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
