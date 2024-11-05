import 'package:fantasize/app/modules/explore/controllers/explore_controller.dart';
import 'package:firebase_core/firebase_core.dart'; // Import firebase_core
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class SplashController extends GetxController with SingleGetTickerProviderMixin {
  var verticalOffset = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeFirebaseAndFCM();
  }

  Future<void> _initializeFirebaseAndFCM() async {
    // Initialize Firebase
    await Firebase.initializeApp();
    print('Firebase initialized');

    // Request notification permissions
    await _requestNotificationPermissions();

    // Get the device token
    await _getDeviceToken();

    // Set up notification handlers
    _setupInteractedMessage();

    // Check for initial message if the app was launched by a notification
    await _checkForInitialMessage();
  }

  Future<void> _requestNotificationPermissions() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false, // Set to true for provisional notifications
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  Future<void> _getDeviceToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        print("Device Token: $token");
        // Send the token to your backend
        _sendTokenToServer(token);
      } else {
        print("Failed to get device token");
      }

      // Handle token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        print("Device Token Refreshed: $newToken");
        // Send the new token to your backend
        _sendTokenToServer(newToken);
      });
    } catch (e) {
      print("Error getting device token: $e");
    }
  }

  Future<void> _sendTokenToServer(String token) async {
    // Implement your logic to send the token to your backend server
    print("Sending token to server: $token");
    // TODO: Send the token to your backend server
  }

  void updateOffset(double offset) {
    verticalOffset.value = (offset - 400);
  }

  void resetPosition() {
    verticalOffset.value = 0.0; // Reset position when the user lifts the finger
  }

  void navigateToHome() {
    VideoPlayerWebOptionsControls.disabled();
    Get.offAllNamed('/login');
  }

  // NEW: Set up notification message handlers
  void _setupInteractedMessage() {
    // Handle when app is in the foreground
    FirebaseMessaging.onMessage.listen(_handleMessage);

    // Handle when app is in the background but not terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

    // Handle background messages (when app is terminated)
    FirebaseMessaging.instance.getInitialMessage().then(_handleInitialMessage);
  }

  void _handleMessage(RemoteMessage message) {
    print('Received a message in the foreground/background!');
    _processNotificationMessage(message);
  }

  Future<void> _checkForInitialMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _processNotificationMessage(initialMessage);
    }
  }

  void _handleInitialMessage(RemoteMessage? message) {
    if (message != null) {
      _processNotificationMessage(message);
    }
  }

  void _processNotificationMessage(RemoteMessage message) {
    // Check if the message contains a notification payload
    if (message.notification != null) {
      String? title = message.notification?.title;
      print('Notification Title: $title');

      if (title == 'Order Confirmation') {
        // Navigate to the cart page
        _navigateToCartPage();
      }
    }

    // Alternatively, check for data payload
    // if (message.data['type'] == 'order_confirmation') {
    //   _navigateToCartPage();
    // }
  }

  void _navigateToCartPage() {
    // Use GetX to navigate to the cart page
    Get.toNamed('/cart');
  }
}
