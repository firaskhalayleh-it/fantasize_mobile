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
          top: screenHeight * 0.15, // Adjust padding relative to screen height
          left: screenWidth * 0.05, // Adjust padding relative to screen width
          right: screenWidth * 0.05,
        ),
        child: ListView(
          children: [
            Center(
              child: Text(
                'Sign In',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: screenWidth *
                      0.1, // Adjust font size relative to screen width
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(
                height: screenHeight *
                    0.02), // Adjust space relative to screen height
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FirebaseBtns().btn(
                  'Facebook',
                  'assets/icons/facebook.svg',
                  Colors.black,
                  Color(0xFFECF5FF),
                  () {
                    // controller.signInWithGoogle();
                  },
                ),
                SizedBox(
                    width: screenWidth *
                        0.05), // Adjust space relative to screen width
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
            SizedBox(height: screenHeight * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: Color(0xFF7C8AA0),
                    fontSize: screenWidth * 0.035, // Adjust font size
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                ),
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
                  ),),
                child: Text('Sign In',style: TextStyle(color: Colors.white,fontFamily: 'Poppins',fontSize: 18),)),
            SizedBox(height: screenHeight * 0.02),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Don’t have account? ',
                    style: TextStyle(
                      color: Color(0xFF3A4053),
                      fontSize: screenWidth * 0.035, // Adjust font size
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
                          fontSize: screenWidth * 0.035, // Adjust font size
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
