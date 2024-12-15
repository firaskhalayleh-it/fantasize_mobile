// splash_controller.dart

import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart'; // Added for opening URLs

class SplashController extends GetxController with SingleGetTickerProviderMixin {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  final RxDouble verticalOffset = 0.0.obs;
  String? token;
  final RxDouble rotationAngle = 0.0.obs;
  late AnimationController animationController;

  // Initialize FlutterLocalNotificationsPlugin
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  var dragOffset = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeFirebaseAndFCM();
    animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  Future<void> _initializeFirebaseAndFCM() async {
    // Initialize Firebase
    await Firebase.initializeApp();
    print('Firebase initialized');

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Request notification permissions
    await _requestNotificationPermissions();

    // Get the device token
    await _getDeviceToken();

    // Set up notification handlers
    _setupInteractedMessage();

    // Check for initial message if the app was launched by a notification
    await _checkForInitialMessage();
  }

  Future<void> _initializeLocalNotifications() async {
    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Initialize settings
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    // Initialize the plugin
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    // Define and create the notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // Channel ID
      'High Importance Notifications', // Channel name
      description:
          'This channel is used for important notifications.', // Channel description
      importance: Importance.high, // Importance level
    );

    // Register the channel with the system
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // Callback when a notification is tapped or an action button is pressed
  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    String? actionId = response.actionId;
    String? payload = response.payload;

    if (actionId != null && actionId.isNotEmpty) {
      // Handle action buttons based on actionId
      switch (actionId) {
        case 'order_history':
          print("Order History button clicked");
          _navigateToOrderHistory();
          break;
        case 'cart':
          print("Cart button clicked");
          _navigateToCartPage();
          break;
        case 'offers':
          print("Offers button clicked");
          _navigateToOffersPage();
          break;
        case 'dismiss':
          print("Dismiss button clicked");
          // No action needed; notification is dismissed
          break;
        default:
          print("Unknown action: $actionId");
          break;
      }
    } else if (payload == 'notification_payload') {
      // Handle notification tap
      _navigateToCartPage();
    }
  }

  // Define navigation functions for action buttons
  void _navigateToOrderHistory() {
    // Implement navigation or other logic for Order History
    print("Navigating to Order History Page");
    Get.toNamed('/order-history');
  }

  void _navigateToCartPage() {
    // Implement navigation or other logic for Cart
    print("Navigating to Cart Page");
    Get.toNamed('/cart');
  }

  void _navigateToOffersPage() async {
    // Implement navigation or other logic for Offers
    print("Navigating to Offers Page");
    // Example: Open external Offers URL
    const url = 'https://www.hebron.edu/';
    if (await canLaunch(url)) {
      await launch(url);  
    } else {
      // ignore: avoid_print
      print('Could not launch $url');
    }
    // Alternatively, navigate internally:
    // Get.toNamed('/offers');
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
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  Future<void> _getDeviceToken() async {
    try {
      token = await FirebaseMessaging.instance.getToken();

      if (token != null) {
        print("Device Token: $token");

        // Store the token
        await storage.write(key: 'DeviceToken', value: token);

        // Retrieve the stored token by awaiting the result
        var storedToken = await storage.read(key: 'DeviceToken');
        print('Stored Device Token: $storedToken');
      } else {
        print("Failed to get device token");
      }

      // Handle token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        print("Device Token Refreshed: $newToken");

        // Store the new token
        await storage.write(key: 'DeviceToken', value: newToken);

        // Optionally, retrieve and print the refreshed token
        var refreshedToken = await storage.read(key: 'DeviceToken');
        print('Refreshed Device Token: $refreshedToken');

        // Send the new token to your backend server
        await sendTokenToServer(newToken);
      });
    } catch (e) {
      print("Error getting device token: $e");
    }
  }

  Future<void> sendTokenToServer(String newToken) async {
    // Implement your logic to send the new token to your backend
    // Example using http package:
    /*
    final response = await http.post(
      Uri.parse('https://yourbackend.com/api/updateToken'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'token': newToken,
        // Include any other necessary data, such as user ID
      }),
    );

    if (response.statusCode == 200) {
      print('Token successfully sent to server.');
    } else {
      print('Failed to send token to server.');
    }
    */
    print('Implement sendTokenToServer logic here.');
  }

  void updateOffset(double offset) {
    // Limit the offset to create a smoother feel
    double newOffset = (offset - 400).clamp(-200.0, 200.0);
    verticalOffset.value = newOffset;
    rotationAngle.value = (newOffset / 200) * 360;
  }

  void resetPosition() {
    verticalOffset.value = 0.0;
    rotationAngle.value = 0.0;
  }

  void navigateToHome() {
    VideoPlayerWebOptionsControls.disabled();
    Get.offAllNamed('/login');
  }

  // Set up notification message handlers
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

    // Display a notification when the app is in the foreground
    if (message.notification != null) {
      _showNotification(message);
    }
  }

  Future<void> _showNotification(RemoteMessage message) async {
    // Extract buttons from the data payload
    List<dynamic> buttonsData = [];
    if (message.data['buttons'] != null) {
      try {
        buttonsData = jsonDecode(message.data['buttons']);
      } catch (e) {
        print("Error decoding buttons JSON: $e");
      }
    }

    // Convert buttonsData to List<Map<String, String>>
    List<Map<String, String>> buttons = [];
    for (var button in buttonsData) {
      if (button is Map<String, dynamic>) {
        buttons.add({
          'text': button['text'] ?? 'Button',
          'action': button['action'] ?? 'action_default',
        });
      }
    }

    // Extract image URL from the notification payload
    String? imageUrl = message.notification?.android?.imageUrl ??
        message.notification?.apple?.imageUrl ??
     
        '';

    // Download and save the image locally
    String? bigPicturePath;
    if (imageUrl.isNotEmpty) {
      bigPicturePath = await _downloadAndSaveImage(imageUrl, 'bigPicture');
    }

    // Define Android-specific notification details with action buttons
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel', // Same channel ID as defined earlier
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
      // Define action buttons dynamically based on received data
      actions: buttons.map((button) {
        return AndroidNotificationAction(
          button['action']!, // action ID
          button['text']!, // button title
          // icon: '@mipmap/ic_launcher', // Optional: specify a valid icon name
        );
      }).toList(),
      // Add BigPictureStyleInformation if an image is available
      styleInformation: bigPicturePath != null
          ? BigPictureStyleInformation(
              FilePathAndroidBitmap(bigPicturePath),
              contentTitle: message.notification?.title,
              summaryText: message.notification?.body,
            )
          : null,
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    // Show the notification
    await flutterLocalNotificationsPlugin.show(
      message.notification.hashCode, // Unique ID for the notification
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: 'notification_payload', // Optional payload
    );
  }

  // Helper function to download and save the image
  Future<String?> _downloadAndSaveImage(String url, String fileName) async {
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final String filePath = '${directory.path}/$fileName';
      final http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        print("Image downloaded and saved to $filePath");
        return filePath;
      } else {
        print("Failed to download image. Status code: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error downloading image: $e");
      return null;
    }
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

      // Handle other titles or conditions as needed
      if (title == 'Special Offers') {
        _navigateToOffersPage();
      }
    }

    // Alternatively, check for data payload
    // Example:
    // if (message.data['type'] == 'order_confirmation') {
    //   _navigateToCartPage();
    // }
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}
