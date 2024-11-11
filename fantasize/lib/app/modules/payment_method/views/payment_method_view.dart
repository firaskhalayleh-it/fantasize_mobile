import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:u_credit_card/u_credit_card.dart';
import 'package:get/get.dart';
import '../controllers/payment_method_controller.dart';

class PaymentMethodView extends GetView<PaymentMethodController> {
  const PaymentMethodView({super.key});

  String determineCardType(String cardNumber) {
    if (cardNumber.startsWith('4')) {
      return 'Visa';
    } else if (cardNumber.startsWith(RegExp(r'5[1-5]'))) {
      return 'MasterCard';
    } else if (cardNumber.startsWith('3') &&
        (cardNumber.startsWith('34') || cardNumber.startsWith('37'))) {
      return 'American Express';
    }
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Get.back();
              },
            ),
          ),
        ),
        title: Center(
          child: Image.asset(
            'assets/icons/fantasize.png',
            height: 40,
          ),
        ),
        actions: const [SizedBox(width: 48)],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Obx(
                  () {
                    return CreditCardUi(
                      cardHolderFullName:
                          controller.paymentMethod.value.cardholderName ?? '',
                      cardNumber:
                          controller.paymentMethod.value.cardNumber ?? '',
                      validThru: controller
                                  .paymentMethod.value.expirationDate !=
                              null
                          ? DateFormat('MM/yy').format(
                              controller.paymentMethod.value.expirationDate!)
                          : '',
                      cvvNumber:
                          controller.paymentMethod.value.cvv?.toString() ?? '',
                      topLeftColor: Colors.blue,
                      bottomRightColor: Colors.redAccent,
                      placeNfcIconAtTheEnd: true, // Add card type icon
                      showValidThru: true,
                    );
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Enter Card Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: controller.cardNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Card Number',
                          hintText: 'XXXX XXXX XXXX XXXX',
                        ),
                        onChanged: (value) {
                          controller.paymentMethod.update((val) {
                            val?.cardNumber = value;
                          });
                        },
                        validator: (value) {
                          return value != null && value.length == 16
                              ? null
                              : 'Enter a valid card number';
                        },
                      ),
                      TextFormField(
                        controller: controller.expirationDateController,
                        decoration: const InputDecoration(
                          labelText: 'Expiry Date',
                          hintText: 'MM/YY',
                        ),
                      ),
                      TextFormField(
                        controller: controller.cvvController,
                        decoration: const InputDecoration(
                          labelText: 'CVV',
                          hintText: 'XXX',
                        ),
                        onChanged: (value) {
                          controller.paymentMethod.update((val) {
                            val?.cvv = int.tryParse(value);
                          });
                        },
                      ),
                      TextFormField(
                        controller: controller.cardholderNameController,
                        decoration: const InputDecoration(
                          labelText: 'Card Holder',
                        ),
                        onChanged: (value) {
                          controller.paymentMethod.update((val) {
                            val?.cardholderName = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Obx(
                      () => Checkbox(
                        value: controller.agreeToTerms.value,
                        onChanged: (bool? value) {
                          controller.agreeToTerms.value = value!;
                        },
                      ),
                    ),
                    const Text('I agree to the terms and conditions'),
                  ],
                ),
                Row(
                  children: [
                    Obx(
                      () => Checkbox(
                        value: controller.saveCardDetails.value,
                        onChanged: (bool? value) {
                          controller.saveCardDetails.value = value!;
                        },
                      ),
                    ),
                    const Text('Save card details'),
                  ],
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (controller.formKey.currentState!.validate()) {
                        controller.savePaymentMethod();
                      } else {
                        Get.snackbar('Error', 'Please complete all fields');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 100),
                      backgroundColor: Color(0xFFFF4C5E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                //delete button under condition that address is not new
                if (controller.paymentMethod.value.paymentMethodID != null)
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        controller.deletePaymentMethod();
                      },
                      icon: const Icon(
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
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
