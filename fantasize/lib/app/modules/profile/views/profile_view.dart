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
          icon: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Image(image: Svg('assets/icons/back_button.svg')),
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text('Profile'),
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
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            controller.user.value!.userProfilePicture != null
                                ? NetworkImage(
                                    '${Strings().resourceUrl}/${controller.user.value!.userProfilePicture!.entityName}',
                                  )
                                : const AssetImage('assets/images/profile.jpg')
                                    as ImageProvider,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // User Name
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          controller.user.value!.username,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),

                        // Edit Profile Button (Optional)
                      ],
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
                            Icons.credit_card,
                            trailing: IconButton(
                                onPressed: () {}, icon: Icon(Icons.edit)),
                          )
                      else
                        const ListTile(
                            title: Text('No payment methods added yet')),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () => controller.NavigateToPaymentMethod(),
                        child: const Text(
                          'Add Payment Method',
                          style: TextStyle(color: Colors.white),
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
                            Icons.home,
                            trailing: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {},
                            ),
                          )
                      else
                        const ListTile(title: Text('No addresses added yet')),
                    ]),

                    // Notifications
                    BuildSection().buildSection('Notifications', [
                      if (controller.user.value!.notifications != null &&
                          controller.user.value!.notifications!.isNotEmpty)
                        for (var notification
                            in controller.user.value!.notifications!)
                          BuildListTile().buildListTile(
                            notification.template.toString(),
                            Icons.notifications,
                          )
                      else
                        const ListTile(
                            title: Text('No notifications available')),
                    ]),
                    // Order History Section (Optional, if needed)
                    BuildSection().buildSection('Order History', []),

                    // Preferences Section
                    BuildSection().buildSection('Preferences', [
                      BuildListTile().buildListTile(
                          'Currency', Icons.monetization_on,
                          trailing: const Text('USD')),
                      BuildListTile().buildListTile('Language', Icons.language,
                          trailing: const Text('EN')),
                    ]),

                    // Help and Support Section
                    BuildSection().buildSection('Help and Support', [
                      BuildListTile().buildListTile(
                          controller.user.value!.email, Icons.email),
                      BuildListTile().buildListTile(
                          controller.user.value!.phoneNumber ?? '',
                          Icons.phone),
                    ]),

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
                      onTap: () async {
                        await controller
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
