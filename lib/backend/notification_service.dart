import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

/// Service for handling push notifications
class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// Initialize notification service
  static Future<void> initialize() async {
    if (_initialized) return;

    // Request permission
    await requestPermission();

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Get FCM token
    final token = await getToken();
    if (token != null) {
      debugPrint('FCM Token: $token');
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpened);

    // Handle notification tap when app is terminated
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpened(initialMessage);
    }

    _initialized = true;
  }

  /// Initialize local notifications for foreground display
  static Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Request notification permissions
  static Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Get FCM token
  static Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  /// Save FCM token to user document
  static Future<void> saveTokenToUser(DocumentReference userRef) async {
    final token = await getToken();
    if (token != null) {
      try {
        await userRef.update({
          'fcm_token': token,
          'fcm_token_updated_at': FieldValue.serverTimestamp(),
          'platform': Platform.isAndroid ? 'android' : 'ios',
        });
      } catch (e) {
        debugPrint('Error saving FCM token: $e');
      }
    }
  }

  /// Handle foreground messages
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Foreground message: ${message.notification?.title}');

    // Show local notification
    await _showLocalNotification(
      title: message.notification?.title ?? 'New Notification',
      body: message.notification?.body ?? '',
      payload: message.data.toString(),
    );
  }

  /// Handle message opened (background/terminated)
  static Future<void> _handleMessageOpened(RemoteMessage message) async {
    debugPrint('Message opened: ${message.notification?.title}');
    
    // Navigate based on notification type
    final type = message.data['type'] as String?;
    final id = message.data['id'] as String?;

    if (type == 'message' && id != null) {
      // Navigate to chat page
      // context.pushNamed('chat_page', extra: {'messageId': id});
    } else if (type == 'offer' && id != null) {
      // Navigate to offer/product page
      // context.pushNamed('item_page', extra: {'productId': id});
    }
  }

  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Handle navigation based on payload
  }

  /// Show local notification
  static Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'shoplendr_channel',
      'ShopLendr Notifications',
      channelDescription: 'Notifications for messages, offers, and updates',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  // ==================== Notification Types ====================

  /// Send message notification
  static Future<void> sendMessageNotification({
    required DocumentReference recipientRef,
    required String senderName,
    required String messagePreview,
    required String messageId,
  }) async {
    await _sendNotificationToUser(
      recipientRef: recipientRef,
      title: 'New Message from $senderName',
      body: messagePreview,
      data: {
        'type': 'message',
        'id': messageId,
        'sender_name': senderName,
      },
    );

    // Log notification
    await _logNotification(
      recipientRef: recipientRef,
      type: 'message',
      title: 'New Message from $senderName',
      body: messagePreview,
    );
  }

  /// Send offer notification
  static Future<void> sendOfferNotification({
    required DocumentReference recipientRef,
    required String offerTitle,
    required String offerDescription,
    required String offerId,
  }) async {
    await _sendNotificationToUser(
      recipientRef: recipientRef,
      title: 'New Offer: $offerTitle',
      body: offerDescription,
      data: {
        'type': 'offer',
        'id': offerId,
      },
    );

    await _logNotification(
      recipientRef: recipientRef,
      type: 'offer',
      title: 'New Offer: $offerTitle',
      body: offerDescription,
    );
  }

  /// Send product inquiry notification
  static Future<void> sendInquiryNotification({
    required DocumentReference sellerRef,
    required String buyerName,
    required String productName,
    required String productId,
  }) async {
    await _sendNotificationToUser(
      recipientRef: sellerRef,
      title: 'Product Inquiry',
      body: '$buyerName is interested in $productName',
      data: {
        'type': 'inquiry',
        'id': productId,
        'buyer_name': buyerName,
      },
    );

    await _logNotification(
      recipientRef: sellerRef,
      type: 'inquiry',
      title: 'Product Inquiry',
      body: '$buyerName is interested in $productName',
    );
  }

  /// Send review notification
  static Future<void> sendReviewNotification({
    required DocumentReference sellerRef,
    required String reviewerName,
    required double rating,
    required String productName,
  }) async {
    await _sendNotificationToUser(
      recipientRef: sellerRef,
      title: 'New Review',
      body: '$reviewerName left a ${rating.toStringAsFixed(1)}-star review on $productName',
      data: {
        'type': 'review',
        'reviewer_name': reviewerName,
        'rating': rating.toString(),
      },
    );

    await _logNotification(
      recipientRef: sellerRef,
      type: 'review',
      title: 'New Review',
      body: '$reviewerName left a review',
    );
  }

  /// Send order notification
  static Future<void> sendOrderNotification({
    required DocumentReference sellerRef,
    required String buyerName,
    required String productName,
    required String orderId,
  }) async {
    await _sendNotificationToUser(
      recipientRef: sellerRef,
      title: 'New Order',
      body: '$buyerName ordered $productName',
      data: {
        'type': 'order',
        'id': orderId,
        'buyer_name': buyerName,
      },
    );

    await _logNotification(
      recipientRef: sellerRef,
      type: 'order',
      title: 'New Order',
      body: '$buyerName ordered $productName',
    );
  }

  /// Send price drop notification
  static Future<void> sendPriceDropNotification({
    required DocumentReference userRef,
    required String productName,
    required double oldPrice,
    required double newPrice,
    required String productId,
  }) async {
    final discount = ((oldPrice - newPrice) / oldPrice * 100).toStringAsFixed(0);
    
    await _sendNotificationToUser(
      recipientRef: userRef,
      title: 'Price Drop Alert!',
      body: '$productName is now $discount% off - ₱${newPrice.toStringAsFixed(2)}',
      data: {
        'type': 'price_drop',
        'id': productId,
        'old_price': oldPrice.toString(),
        'new_price': newPrice.toString(),
      },
    );

    await _logNotification(
      recipientRef: userRef,
      type: 'price_drop',
      title: 'Price Drop Alert!',
      body: '$productName is now on sale',
    );
  }

  // ==================== Helper Methods ====================

  /// Send notification to specific user
  static Future<void> _sendNotificationToUser({
    required DocumentReference recipientRef,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    try {
      // Get user's FCM token
      final userDoc = await recipientRef.get();
      final data = userDoc.data() as Map<String, dynamic>?;
      final fcmToken = data?['fcm_token'] as String?;

      if (fcmToken == null) {
        debugPrint('No FCM token found for user');
        return;
      }

      // In production, you would call your Cloud Function or backend API
      // to send the notification using the FCM Admin SDK
      // For now, we'll just log it
      debugPrint('Would send notification to token: $fcmToken');
      debugPrint('Title: $title');
      debugPrint('Body: $body');
      debugPrint('Data: $data');

      // Example Cloud Function call (implement in Firebase Functions):
      /*
      await _firestore.collection('NotificationQueue').add({
        'token': fcmToken,
        'title': title,
        'body': body,
        'data': data,
        'created_at': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
      */
    } catch (e) {
      debugPrint('Error sending notification: $e');
    }
  }

  /// Log notification to database
  static Future<void> _logNotification({
    required DocumentReference recipientRef,
    required String type,
    required String title,
    required String body,
  }) async {
    try {
      await _firestore.collection('Notifications').add({
        'recipient_ref': recipientRef,
        'type': type,
        'title': title,
        'body': body,
        'is_read': false,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error logging notification: $e');
    }
  }

  /// Get user notifications
  static Future<List<Map<String, dynamic>>> getUserNotifications({
    required DocumentReference userRef,
    int limit = 20,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('Notifications')
          .where('recipient_ref', isEqualTo: userRef)
          .orderBy('created_at', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();
    } catch (e) {
      debugPrint('Error getting notifications: $e');
      return [];
    }
  }

  /// Mark notification as read
  static Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection('Notifications').doc(notificationId).update({
        'is_read': true,
        'read_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  /// Get unread notification count
  static Future<int> getUnreadCount(DocumentReference userRef) async {
    try {
      final snapshot = await _firestore
          .collection('Notifications')
          .where('recipient_ref', isEqualTo: userRef)
          .where('is_read', isEqualTo: false)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      debugPrint('Error getting unread count: $e');
      return 0;
    }
  }

  /// Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic: $e');
    }
  }
}
