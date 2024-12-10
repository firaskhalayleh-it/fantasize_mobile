import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:u_credit_card/u_credit_card.dart';
import 'package:get/get.dart';
import '../controllers/payment_method_controller.dart';

class PaymentMethodView extends GetView<PaymentMethodController> {
  const PaymentMethodView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
      ),
      title: Image.asset('assets/icons/fantasize.png', height: 40),
      centerTitle: true,
      actions: const [SizedBox(width: 48)],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildCreditCardPreview(),
          _buildFormSection(),
        ],
      ),
    );
  }

  Widget _buildCreditCardPreview() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[100]!,
            Colors.white,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Obx(() => CreditCardUi(
              cardHolderFullName: controller.paymentMethod.value.cardholderName ?? '',
              cardNumber: controller.paymentMethod.value.cardNumber ?? '',
              validThru: controller.paymentMethod.value.expirationDate != null
                  ? DateFormat('MM/yy').format(controller.paymentMethod.value.expirationDate!)
                  : '',
              cvvNumber: controller.paymentMethod.value.cvv?.toString() ?? '',
              topLeftColor: const Color(0xFFFF4C5E),
              bottomRightColor: const Color(0xFF2D3142),
              placeNfcIconAtTheEnd: true,
              showValidThru: true,
            )),
      ),
    );
  }

  Widget _buildFormSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: controller.formKey,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Card Details',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 24),
              _buildInputField(
                label: 'Card Number',
                controller: controller.cardNumberController,
                icon: Icons.credit_card,
                hint: 'XXXX XXXX XXXX XXXX',
                validator: (value) => value != null && value.length == 16
                    ? null
                    : 'Enter a valid card number',
                onChanged: (value) {
                  controller.paymentMethod.update((val) {
                    val?.cardNumber = value;
                  });
                },
              ),
              _buildInputField(
                label: 'Cardholder Name',
                controller: controller.cardholderNameController,
                icon: Icons.person_outline,
                onChanged: (value) {
                  controller.paymentMethod.update((val) {
                    val?.cardholderName = value;
                  });
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildInputField(
                      label: 'Expiry Date',
                      controller: controller.expirationDateController,
                      icon: Icons.calendar_today_outlined,
                      hint: 'MM/YY',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInputField(
                      label: 'CVV',
                      controller: controller.cvvController,
                      icon: Icons.lock_outline,
                      hint: 'XXX',
                      onChanged: (value) {
                        controller.paymentMethod.update((val) {
                          val?.cvv = int.tryParse(value);
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildCheckboxTile(
                value: controller.agreeToTerms,
                title: 'I agree to the terms and conditions',
              ),
              _buildCheckboxTile(
                value: controller.saveCardDetails,
                title: 'Save card details for future use',
              ),
              const SizedBox(height: 32),
              _buildButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF4C5E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color(0xFFFF4C5E),
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3142),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          onChanged: onChanged,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF4C5E)),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCheckboxTile({
    required RxBool value,
    required String title,
  }) {
    return Obx(() => Row(
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: value.value,
                onChanged: (bool? newValue) => value.value = newValue!,
                activeColor: const Color(0xFFFF4C5E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2D3142),
              ),
            ),
          ],
        ));
  }

  Widget _buildButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (controller.formKey.currentState!.validate()) {
                controller.savePaymentMethod();
              } else {
                Get.snackbar('Error', 'Please complete all fields');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4C5E),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Save Card',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        if (controller.paymentMethod.value.paymentMethodID != null) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: controller.deletePaymentMethod,
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              label: const Text(
                'Delete Card',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ],
    );
  }
}