import 'package:fantasize/app/global/strings.dart';
import 'package:fantasize/app/modules/profile/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileView extends StatelessWidget {
  final ProfileController controller = Get.put(ProfileController());

  ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Image(image: Svg('assets/icons/back_button.svg')),
          onPressed: () => Get.back(),
        ),
        title: const Text('Profile',
            style: TextStyle(
                color: Color(0xFFFF4C5E),
                fontFamily: 'Poppins',
                fontSize: 24,
                fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Obx(() => controller.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : controller.user.value == null
              ? const Center(child: Text('No user data found.'))
              : _buildContent()),
    );
  }

  Widget _buildContent() {
    final user = controller.user.value!;
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildProfileHeader(user),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSection(
                  'Personal Information',
                  [
                    _buildTile(
                      'Edit Personal Information',
                      Icons.person_outline,
                      onTap: controller.NavigateToUserInfo,
                    ),
                    _buildTile(
                      'Change Password',
                      Icons.lock_outline,
                      onTap: controller.showResetPasswordDialog,
                    ),
                  ],
                ),
                _buildSection(
                  'Payment Methods',
                  [
                    if (user.paymentMethods?.isNotEmpty ?? false)
                      ...user.paymentMethods!.map((method) => _buildTile(
                            '${method.cardType} - ${method.cardNumber}',
                            Icons.credit_card,
                            trailing: IconButton(
                              icon: const Icon(Icons.edit, color: Color(0xFFFF4C5E)),
                              onPressed: () => Get.toNamed('/payment-method',
                                  arguments: {'paymentMethod': method}),
                            ),
                          ))
                    else
                      const Text('No payment methods added yet',
                          style: TextStyle(color: Colors.grey)),
                    _buildButton('Add Payment Method',
                        onTap: controller.NavigateToPaymentMethod),
                  ],
                ),
                _buildSection(
                  'Addresses',
                  [
                    if (user.addresses?.isNotEmpty ?? false)
                      ...user.addresses!.map((address) => _buildTile(
                            '${address.addressLine}, ${address.city}',
                            Icons.location_on,
                            trailing: IconButton(
                              icon: const Icon(Icons.edit, color: Color(0xFFFF4C5E)),
                              onPressed: () => Get.toNamed('/address',
                                  arguments: {'address': address}),
                            ),
                          ))
                    else
                      const Text('No addresses added yet',
                          style: TextStyle(color: Colors.grey)),
                    _buildButton('Add Address',
                        onTap: () => Get.toNamed('/address')),
                  ],
                ),
                _buildTile('Order History', Icons.history,
                    onTap: () => Get.toNamed('/order-history')),
                const SizedBox(height: 20),
                _buildButton(
                  'Log Out',
                  onTap: controller.logout,
                  color: Colors.red,
                  textColor: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(dynamic user) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: user.userProfilePicture != null
                    ? CachedNetworkImageProvider(
                        '${Strings().resourceUrl}/${user.userProfilePicture!.entityName}')
                    : const AssetImage('assets/images/profile.jpg')
                        as ImageProvider,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: controller.pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF4C5E),
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFF4C5E),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              user.username,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: children),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(String title, IconData icon,
      {Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFFF4C5E).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFFFF4C5E), size: 20),
      ),
      title: Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      trailing:
          trailing ?? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildButton(String text,
      {VoidCallback? onTap, Color? color, Color? textColor}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? const Color(0xFFFF4C5E),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        onPressed: onTap,
        child: Text(
          text,
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}