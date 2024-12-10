import 'package:fantasize/app/global/dynamic_font.dart';
import 'package:fantasize/app/modules/login/views/widgets/firebase_btns.dart';
import 'package:fantasize/app/modules/login/views/widgets/input.dart';
import 'package:fantasize/app/modules/login/views/widgets/devider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});
  @override
  Widget build(BuildContext context) {
    // Get the screen height and width
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/icons/fantasize.png',
          width: screenWidth * 0.065, // Adjust size relative to screen width
          height: screenHeight * 0.1,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.only(
          left: screenWidth * 0.05, // Adjust padding relative to screen width
          right: screenWidth * 0.05,
        ),
        child: ListView(
          physics: ScrollPhysics(
              parent: BouncingScrollPhysics(
                  decelerationRate: ScrollDecelerationRate.normal)),
          children: [
            SizedBox(height: screenHeight * 0.15),
            Center(
              child: Text(
                'Sign In',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: DynamicFont().getLargeFont(),
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(
                height: screenHeight *
                    0.02), // Adjust space relative to screen height
            Row(
              children: [
                FirebaseBtns().btn(
                  'Google',
                  'assets/icons/google.svg',
                  Colors.black,
                  Color(0xFFF3F3F3),
                  () {
                    controller.loginWithGoogle();
                  },
                )
              ],
            ),
            SizedBox(height: screenHeight * 0.02),
            Devider().build(),
            SizedBox(height: screenHeight * 0.02),
            Form(
                key: controller.formKey,
                child: Column(
                  children: [
                    Input().build(
                      label: 'Email',
                      controller: controller.emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Obx(() => Input().build(
                          label: 'Password',
                          controller: controller.passwordController,
                          keyboardType: TextInputType.visiblePassword,
                          PostfixIcon: IconButton(
                            onPressed: () {
                              controller.toggleObscureText();
                            },
                            icon: Icon(controller.obscureText.value
                                ? Icons.visibility_off
                                : Icons.visibility),
                          ),
                          obscureText: controller.obscureText.value,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        )),
                  ],
                )),
            SizedBox(height: screenHeight * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    controller.goToResetPassword();
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: Color(0xFF7C8AA0),
                      fontSize: DynamicFont().getSmallFont(),
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: screenHeight * 0.02),
            ElevatedButton(
                onPressed: () {
                  controller.login();
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.black),
                  padding: WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  ),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                child: Text(
                  'Sign In',
                  style: TextStyle(
                      color: Colors.white, fontFamily: 'Poppins', fontSize: 18),
                )),
            SizedBox(height: screenHeight * 0.02),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Don’t have account? ',
                    style: TextStyle(
                      color: Color(0xFF3A4053),
                      fontSize: DynamicFont().getSmallFont(),
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  WidgetSpan(
                    child: InkWell(
                      onTap: () {
                        controller.goToSignup();
                      },
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Color(0xFFFF4C5E),
                          fontSize: DynamicFont().getMediumFont(),
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
    );
  }
}
