import 'package:firebase_core/firebase_core.dart'; // Import firebase_core
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Import flutter_local_notifications
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class SplashController extends GetxController
    with SingleGetTickerProviderMixin {
  FlutterSecureStorage storage = FlutterSecureStorage();
  var verticalOffset = 0.0.obs;
  String? token;

  // Initialize FlutterLocalNotificationsPlugin
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void onInit() {
    super.onInit();
    _initializeFirebaseAndFCM();
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
    // Android initialization
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    // Initialize settings
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initialize the plugin
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tapped logic here
        // For example, navigate to a specific screen
        String? payload = response.payload;

        if (payload == 'notification_payload') {
          _navigateToCartPage();
        }
      },
    );

    // Define and create the notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // Channel ID
      'High Importance Notifications', // Channel name
      description: 'This channel is used for important notifications.', // Channel description
      importance: Importance.high, // Importance level
    );

    // Register the channel with the system
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
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
      });
    } catch (e) {
      print("Error getting device token: $e");
    }
  }

  void updateOffset(double offset) {
    verticalOffset.value = (offset - 400);
  }

  void resetPosition() {
    verticalOffset.value =
        0.0; // Reset position when the user lifts the finger
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
    FirebaseMessaging.instance
        .getInitialMessage()
        .then(_handleInitialMessage);
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
    // Create notification details
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel', // Use the same channel ID
      'High Importance Notifications', // Channel name (optional)
      channelDescription:
          'This channel is used for important notifications.', // Channel description (optional)
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
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
