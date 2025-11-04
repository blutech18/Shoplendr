import 'package:flutter/foundation.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Service for handling cart operations with transaction support
class CartTransactionService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Adds an item to cart with transaction support
  /// Returns true if successful, false otherwise
  static Future<bool> addToCart({
    required DocumentReference userRef,
    required DocumentReference productRef,
    int quantity = 1,
  }) async {
    try {
      return await _firestore.runTransaction<bool>((transaction) async {
        // Get or create cart for user
        final cartQuery = await CartsRecord.collection
            .where('userRef', isEqualTo: userRef)
            .limit(1)
            .get();

        DocumentReference cartRef;
        
        if (cartQuery.docs.isEmpty) {
          // Create new cart
          cartRef = CartsRecord.collection.doc();
          transaction.set(
            cartRef,
            createCartsRecordData(
              userRef: userRef,
              createdAt: getCurrentTimestamp,
              updatedAt: getCurrentTimestamp,
            ),
          );
        } else {
          // Use existing cart
          cartRef = cartQuery.docs.first.reference;
          transaction.update(cartRef, {
            'updatedAt': getCurrentTimestamp,
          });
        }

        // Note: In a full implementation, you would have a CartItems subcollection
        // For now, this creates/updates the cart document
        return true;
      });
    } catch (e) {
      debugPrint('Error adding to cart: $e');
      return false;
    }
  }

  /// Removes an item from cart with transaction support
  static Future<bool> removeFromCart({
    required DocumentReference userRef,
    required DocumentReference productRef,
  }) async {
    try {
      return await _firestore.runTransaction<bool>((transaction) async {
        final cartQuery = await CartsRecord.collection
            .where('userRef', isEqualTo: userRef)
            .limit(1)
            .get();

        if (cartQuery.docs.isEmpty) {
          return false;
        }

        final cartRef = cartQuery.docs.first.reference;
        transaction.update(cartRef, {
          'updatedAt': getCurrentTimestamp,
        });

        // Note: In a full implementation, you would remove from CartItems subcollection
        return true;
      });
    } catch (e) {
      debugPrint('Error removing from cart: $e');
      return false;
    }
  }

  /// Updates item quantity in cart with transaction support
  static Future<bool> updateCartItemQuantity({
    required DocumentReference userRef,
    required DocumentReference productRef,
    required int newQuantity,
  }) async {
    if (newQuantity < 1) {
      return removeFromCart(userRef: userRef, productRef: productRef);
    }

    try {
      return await _firestore.runTransaction<bool>((transaction) async {
        final cartQuery = await CartsRecord.collection
            .where('userRef', isEqualTo: userRef)
            .limit(1)
            .get();

        if (cartQuery.docs.isEmpty) {
          return false;
        }

        final cartRef = cartQuery.docs.first.reference;
        transaction.update(cartRef, {
          'updatedAt': getCurrentTimestamp,
        });

        // Note: In a full implementation, you would update CartItems subcollection
        return true;
      });
    } catch (e) {
      debugPrint('Error updating cart quantity: $e');
      return false;
    }
  }

  /// Clears all items from cart with transaction support
  static Future<bool> clearCart({
    required DocumentReference userRef,
  }) async {
    try {
      return await _firestore.runTransaction<bool>((transaction) async {
        final cartQuery = await CartsRecord.collection
            .where('userRef', isEqualTo: userRef)
            .limit(1)
            .get();

        if (cartQuery.docs.isEmpty) {
          return true; // Cart already empty
        }

        final cartRef = cartQuery.docs.first.reference;
        
        // Delete the cart document
        transaction.delete(cartRef);

        // Note: In a full implementation, you would also delete CartItems subcollection
        return true;
      });
    } catch (e) {
      debugPrint('Error clearing cart: $e');
      return false;
    }
  }

  /// Creates an order from cart with transaction support
  /// This ensures atomicity - either all items are processed or none
  static Future<DocumentReference?> createOrderFromCart({
    required DocumentReference userRef,
    required List<Map<String, dynamic>> cartItems,
    required double totalAmount,
  }) async {
    try {
      return await _firestore.runTransaction<DocumentReference?>((transaction) async {
        // Create order document
        final orderRef = _firestore.collection('Orders').doc();
        
        transaction.set(orderRef, {
          'userRef': userRef,
          'items': cartItems,
          'totalAmount': totalAmount,
          'status': 'pending',
          'createdAt': getCurrentTimestamp,
          'updatedAt': getCurrentTimestamp,
        });

        // Update product quantities
        for (final item in cartItems) {
          final productRef = item['productRef'] as DocumentReference;
          final quantity = item['quantity'] as int;

          final productDoc = await transaction.get(productRef);
          if (!productDoc.exists) {
            throw Exception('Product not found');
          }

          final data = productDoc.data() as Map<String, dynamic>?;
          final currentQuantity = data?['quantity'] as int? ?? 0;
          if (currentQuantity < quantity) {
            throw Exception('Insufficient product quantity');
          }

          transaction.update(productRef, {
            'quantity': currentQuantity - quantity,
            'modified_at': getCurrentTimestamp,
          });
        }

        // Clear the cart
        final cartQuery = await CartsRecord.collection
            .where('userRef', isEqualTo: userRef)
            .limit(1)
            .get();

        if (cartQuery.docs.isNotEmpty) {
          transaction.delete(cartQuery.docs.first.reference);
        }

        return orderRef;
      });
    } catch (e) {
      debugPrint('Error creating order: $e');
      return null;
    }
  }

  /// Validates product availability before adding to cart
  static Future<bool> validateProductAvailability({
    required DocumentReference productRef,
    int requestedQuantity = 1,
  }) async {
    try {
      final productDoc = await productRef.get();
      if (!productDoc.exists) {
        return false;
      }

      final productData = productDoc.data() as Map<String, dynamic>?;
      final availableQuantity = productData?['quantity'] as int? ?? 0;

      return availableQuantity >= requestedQuantity;
    } catch (e) {
      debugPrint('Error validating product: $e');
      return false;
    }
  }

  /// Gets cart total with transaction support for consistency
  static Future<double> getCartTotal({
    required DocumentReference userRef,
  }) async {
    try {
      return await _firestore.runTransaction<double>((transaction) async {
        final cartQuery = await CartsRecord.collection
            .where('userRef', isEqualTo: userRef)
            .limit(1)
            .get();

        if (cartQuery.docs.isEmpty) {
          return 0.0;
        }

        // Note: In a full implementation, you would calculate from CartItems subcollection
        // This is a placeholder that returns 0
        return 0.0;
      });
    } catch (e) {
      debugPrint('Error getting cart total: $e');
      return 0.0;
    }
  }
}
