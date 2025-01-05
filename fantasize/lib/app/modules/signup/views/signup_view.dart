import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../login/views/widgets/devider.dart';
import '../../login/views/widgets/firebase_btns.dart';
import '../../login/views/widgets/input.dart';
import '../controllers/signup_controller.dart';

class SignupView extends GetView<SignupController> {
  const SignupView({super.key});
  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/icons/fantasize.png',
          width: screenWidth * 0.065,
          height: screenHeight * 0.1,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.only(
          top: screenHeight * 0.15,
          left: screenWidth * 0.05,
          right: screenWidth * 0.05,
        ),
        child: Form(
          key: controller.formKey,
          child: ListView(
            children: [
              Center(
                child: Text(
                  'Sign Up',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: screenWidth * 0.1,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FirebaseBtns().btn(
                    'Google',
                    'assets/icons/google.svg',
                    Colors.black,
                    Color(0xFFF3F3F3),
                    () {
                      // controller.signInWithGoogle();
                    },
                  )
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Devider().build(),
              SizedBox(height: screenHeight * 0.02),
              
              // Email Input with Validation
              Input().build(
                label: 'Email',
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                validator: controller.validateEmail,
              ),
              SizedBox(height: screenHeight * 0.02),
              
              // Password Input with Validation
              Obx(
                () => Input().build(
                  label: 'Password',
                  controller: controller.passwordController,
                  keyboardType: TextInputType.visiblePassword,
                  PostfixIcon: IconButton(
                    onPressed: controller.toggleObscureText,
                    icon: Icon(
                      controller.obscureText.value
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                  obscureText: controller.obscureText.value,
                  validator: controller.validatePassword,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              
              // Confirm Password Input with Validation
              Obx(
                () => Input().build(
                  label: 'Confirm Password',
                  controller: controller.confirmPasswordController,
                  keyboardType: TextInputType.visiblePassword,
                  PostfixIcon: IconButton(
                    onPressed: controller.toggleConfirmPasswordObscureText,
                    icon: Icon(
                      controller.confirmPasswordObscureText.value
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                  obscureText: controller.confirmPasswordObscureText.value,
                  validator: controller.validateConfirmPassword,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              
              // Signup Button with Loading State
              Obx(
                () => InkWell(
                  onTap: controller.isLoading.value ? null : controller.signup,
                  child: Container(
                    width: screenWidth * 0.9,
                    height: screenHeight * 0.07,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
                    ),
                    decoration: ShapeDecoration(
                      color: controller.isLoading.value
                          ? Colors.grey
                          : Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Center(
                      child: controller.isLoading.value
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.04,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              
              // Error Message Display
              Obx(
                () => controller.errorMessage.value.isNotEmpty
                    ? Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: screenWidth * 0.05,
                        ),
                        child: Text(
                          controller.errorMessage.value,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: screenWidth * 0.035,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : SizedBox(),
              ),
              
              // Sign In Link
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Already have an account? ',
                      style: TextStyle(
                        color: Color(0xFF3A4053),
                        fontSize: screenWidth * 0.035,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    WidgetSpan(
                      child: InkWell(
                        onTap: controller.goToLogin,
                        child: Text(
                          'Sign In',
                          style: TextStyle(
                            color: Color(0xFFFF4C5E),
                            fontSize: screenWidth * 0.035,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}