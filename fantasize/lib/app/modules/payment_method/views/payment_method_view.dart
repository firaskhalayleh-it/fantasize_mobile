// File: payment_method_view.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for input formatters
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
              cardHolderFullName:
                  controller.paymentMethod.value.cardholderName ?? '',
              cardNumber: controller.paymentMethod.value.cardNumber ?? '',
              validThru: controller.paymentMethod.value.expirationDate != null
                  ? DateFormat('MM/yy')
                      .format(controller.paymentMethod.value.expirationDate!)
                  : '',
              cvvNumber:
                  controller.paymentMethod.value.cvv?.toString() ?? '',
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
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                ],
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
                validator: (value) =>
                    value != null && value.isNotEmpty
                        ? null
                        : 'Enter cardholder name',
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
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                        ExpiryDateInputFormatter(), // Custom formatter
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter expiry date';
                        }
                        final regex = RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$');
                        if (!regex.hasMatch(value)) {
                          return 'Enter valid expiry date';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        // Update expirationDate in controller if needed
                        if (value.length == 5) {
                          final parts = value.split('/');
                          if (parts.length == 2) {
                            final month = int.tryParse(parts[0]);
                            final year = int.tryParse(parts[1]);
                            if (month != null && year != null) {
                              // Assuming current century
                              final fourDigitYear = 2000 + year;
                              controller.paymentMethod.update((val) {
                                val?.expirationDate = DateTime(
                                  fourDigitYear,
                                  month,
                                );
                              });
                            }
                          }
                        } else {
                          controller.paymentMethod.update((val) {
                            val?.expirationDate = null;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInputField(
                      label: 'CVV',
                      controller: controller.cvvController,
                      icon: Icons.lock_outline,
                      hint: 'XXX',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      validator: (value) => value != null && value.length == 3
                          ? null
                          : 'Enter a valid CVV',
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
              // Removed the "Save card details for future use" checkbox
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
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
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
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
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
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2D3142),
                ),
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
                if (controller.agreeToTerms.value) {
                  controller.savePaymentMethod();
                } else {
                  Get.snackbar(
                    'Agreement Required',
                    'Please agree to the terms and conditions',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              } else {
                Get.snackbar('Error', 'Please complete all fields',
                    snackPosition: SnackPosition.BOTTOM);
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

// Custom TextInputFormatter for Expiry Date (MM/YY)
class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    // If user is deleting, allow it
    if (newValue.selection.baseOffset < oldValue.selection.baseOffset) {
      return newValue;
    }

    // Remove any character that is not a digit
    text = text.replaceAll(RegExp(r'[^\d]'), '');

    if (text.length > 4) {
      text = text.substring(0, 4);
    }

    if (text.length > 2) {
      text = '${text.substring(0, 2)}/${text.substring(2)}';
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
