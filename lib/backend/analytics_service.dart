import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Service for tracking user behavior and analytics
class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Analytics observer for navigation tracking
  static FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  /// Initialize analytics with user properties
  static Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }

  /// Set user properties
  static Future<void> setUserProperties({
    String? userType,
    String? accountAge,
    int? totalProducts,
    int? totalPurchases,
  }) async {
    if (userType != null) {
      await _analytics.setUserProperty(name: 'user_type', value: userType);
    }
    if (accountAge != null) {
      await _analytics.setUserProperty(name: 'account_age', value: accountAge);
    }
    if (totalProducts != null) {
      await _analytics.setUserProperty(
        name: 'total_products',
        value: totalProducts.toString(),
      );
    }
    if (totalPurchases != null) {
      await _analytics.setUserProperty(
        name: 'total_purchases',
        value: totalPurchases.toString(),
      );
    }
  }

  // ==================== Product Events ====================

  /// Track product view
  static Future<void> logProductView({
    required String productId,
    required String productName,
    required String category,
    required double price,
  }) async {
    await _analytics.logViewItem(
      currency: 'PHP',
      value: price,
      items: [
        AnalyticsEventItem(
          itemId: productId,
          itemName: productName,
          itemCategory: category,
          price: price,
        ),
      ],
    );

    // Also log to custom collection for detailed analytics
    await _logCustomEvent('product_view', {
      'product_id': productId,
      'product_name': productName,
      'category': category,
      'price': price,
    });
  }

  /// Track product search
  static Future<void> logSearch({
    required String searchTerm,
    String? category,
    int? resultsCount,
  }) async {
    await _analytics.logSearch(
      searchTerm: searchTerm,
      numberOfNights: null,
      numberOfRooms: null,
      numberOfPassengers: null,
      origin: null,
      destination: null,
      startDate: null,
      endDate: null,
      travelClass: null,
    );

    await _logCustomEvent('search', {
      'search_term': searchTerm,
      'category': category,
      'results_count': resultsCount,
    });
  }

  /// Track product listing creation
  static Future<void> logProductListed({
    required String productId,
    required String productName,
    required String category,
    required double price,
    required String listingType, // 'sell' or 'rent'
  }) async {
    await _analytics.logEvent(
      name: 'product_listed',
      parameters: {
        'product_id': productId,
        'product_name': productName,
        'category': category,
        'price': price,
        'listing_type': listingType,
      },
    );

    await _logCustomEvent('product_listed', {
      'product_id': productId,
      'product_name': productName,
      'category': category,
      'price': price,
      'listing_type': listingType,
    });
  }

  /// Track add to cart
  static Future<void> logAddToCart({
    required String productId,
    required String productName,
    required double price,
    int quantity = 1,
  }) async {
    await _analytics.logAddToCart(
      currency: 'PHP',
      value: price * quantity,
      items: [
        AnalyticsEventItem(
          itemId: productId,
          itemName: productName,
          price: price,
          quantity: quantity,
        ),
      ],
    );
  }

  /// Track purchase/order
  static Future<void> logPurchase({
    required String transactionId,
    required double totalAmount,
    required List<Map<String, dynamic>> items,
  }) async {
    await _analytics.logPurchase(
      currency: 'PHP',
      value: totalAmount,
      transactionId: transactionId,
      items: items.map((item) {
        return AnalyticsEventItem(
          itemId: item['product_id'] as String,
          itemName: item['product_name'] as String,
          price: item['price'] as double,
          quantity: item['quantity'] as int? ?? 1,
        );
      }).toList(),
    );

    await _logCustomEvent('purchase', {
      'transaction_id': transactionId,
      'total_amount': totalAmount,
      'item_count': items.length,
    });
  }

  // ==================== User Interaction Events ====================

  /// Track review submission
  static Future<void> logReviewSubmitted({
    required String productId,
    required double rating,
    required String reviewType, // 'product' or 'seller'
  }) async {
    await _analytics.logEvent(
      name: 'review_submitted',
      parameters: {
        'product_id': productId,
        'rating': rating,
        'review_type': reviewType,
      },
    );

    await _logCustomEvent('review_submitted', {
      'product_id': productId,
      'rating': rating,
      'review_type': reviewType,
    });
  }

  /// Track message sent
  static Future<void> logMessageSent({
    required String recipientId,
    required String messageType, // 'inquiry', 'negotiation', 'general'
  }) async {
    await _analytics.logEvent(
      name: 'message_sent',
      parameters: {
        'recipient_id': recipientId,
        'message_type': messageType,
      },
    );
  }

  /// Track share action
  static Future<void> logShare({
    required String contentType, // 'product', 'profile'
    required String contentId,
    required String method, // 'facebook', 'twitter', 'copy_link'
  }) async {
    await _analytics.logShare(
      contentType: contentType,
      itemId: contentId,
      method: method,
    );
  }

  // ==================== Navigation Events ====================

  /// Track screen view
  static Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass ?? screenName,
    );
  }

  // ==================== Authentication Events ====================

  /// Track user signup
  static Future<void> logSignUp({
    required String method, // 'email', 'google', 'apple'
  }) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  /// Track user login
  static Future<void> logLogin({
    required String method,
  }) async {
    await _analytics.logLogin(loginMethod: method);
  }

  // ==================== Error Tracking ====================

  /// Track errors
  static Future<void> logError({
    required String errorType,
    required String errorMessage,
    String? stackTrace,
  }) async {
    await _analytics.logEvent(
      name: 'error_occurred',
      parameters: {
        'error_type': errorType,
        'error_message': errorMessage,
        if (stackTrace != null) 'stack_trace': stackTrace,
      },
    );

    await _logCustomEvent('error_occurred', {
      'error_type': errorType,
      'error_message': errorMessage,
    });
  }

  // ==================== Custom Events ====================

  /// Track category browsing
  static Future<void> logCategoryBrowse({
    required String categoryId,
    required String categoryName,
  }) async {
    await _analytics.logEvent(
      name: 'category_browse',
      parameters: {
        'category_id': categoryId,
        'category_name': categoryName,
      },
    );
  }

  /// Track filter usage
  static Future<void> logFilterUsed({
    required String filterType, // 'price', 'condition', 'category'
    required String filterValue,
  }) async {
    await _analytics.logEvent(
      name: 'filter_used',
      parameters: {
        'filter_type': filterType,
        'filter_value': filterValue,
      },
    );
  }

  /// Track profile view
  static Future<void> logProfileView({
    required String profileId,
    required String profileType, // 'seller', 'buyer'
  }) async {
    await _analytics.logEvent(
      name: 'profile_view',
      parameters: {
        'profile_id': profileId,
        'profile_type': profileType,
      },
    );
  }

  // ==================== Custom Analytics Collection ====================

  /// Log custom event to Firestore for detailed analytics
  static Future<void> _logCustomEvent(
    String eventName,
    Map<String, dynamic> parameters,
  ) async {
    try {
      await _firestore.collection('Analytics').add({
        'event_name': eventName,
        'parameters': parameters,
        'timestamp': FieldValue.serverTimestamp(),
        'platform': 'flutter',
      });
    } catch (e) {
      debugPrint('Error logging custom event: $e');
    }
  }

  /// Get analytics summary for admin dashboard
  static Future<Map<String, dynamic>> getAnalyticsSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection('Analytics');

      if (startDate != null) {
        query = query.where('timestamp', isGreaterThanOrEqualTo: startDate);
      }
      if (endDate != null) {
        query = query.where('timestamp', isLessThanOrEqualTo: endDate);
      }

      final snapshot = await query.get();
      final events = snapshot.docs;

      // Calculate metrics
      final totalEvents = events.length;
      final productViews = events
          .where((doc) {
            final data = doc.data() as Map<String, dynamic>?;
            return data?['event_name'] == 'product_view';
          })
          .length;
      final searches = events.where((doc) {
        final data = doc.data() as Map<String, dynamic>?;
        return data?['event_name'] == 'search';
      }).length;
      final purchases = events.where((doc) {
        final data = doc.data() as Map<String, dynamic>?;
        return data?['event_name'] == 'purchase';
      }).length;

      return {
        'total_events': totalEvents,
        'product_views': productViews,
        'searches': searches,
        'purchases': purchases,
        'conversion_rate':
            productViews > 0 ? (purchases / productViews * 100) : 0,
      };
    } catch (e) {
      debugPrint('Error getting analytics summary: $e');
      return {};
    }
  }

  /// Get popular products
  static Future<List<Map<String, dynamic>>> getPopularProducts({
    int limit = 10,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('Analytics')
          .where('event_name', isEqualTo: 'product_view')
          .orderBy('timestamp', descending: true)
          .limit(1000)
          .get();

      // Count product views
      final productCounts = <String, int>{};
      for (final doc in snapshot.docs) {
        final productId = doc.data()['parameters']?['product_id'] as String?;
        if (productId != null) {
          productCounts[productId] = (productCounts[productId] ?? 0) + 1;
        }
      }

      // Sort by count
      final sorted = productCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sorted.take(limit).map((entry) {
        return {
          'product_id': entry.key,
          'view_count': entry.value,
        };
      }).toList();
    } catch (e) {
      debugPrint('Error getting popular products: $e');
      return [];
    }
  }
}
