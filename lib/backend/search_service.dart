import 'package:flutter/foundation.dart';
import '/backend/backend.dart';

/// Service for searching products with various filters and sorting options
class SearchService {

  /// Search products by name (case-insensitive partial match)
  static Future<List<ProductsRecord>> searchByName(String query,
      {int limit = 20}) async {
    if (query.isEmpty) {
      return [];
    }

    try {
      // Convert query to lowercase for case-insensitive search
      final lowerQuery = query.toLowerCase();
      
      // Firestore doesn't support full-text search natively
      // This is a workaround using range queries
      final snapshot = await ProductsRecord.collection
          .orderBy('name')
          .startAt([lowerQuery])
          .endAt(['$lowerQuery\uf8ff'])
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => ProductsRecord.fromSnapshot(doc))
          .toList();
    } catch (e) {
      debugPrint('Error searching products: $e');
      return [];
    }
  }

  /// Get products by category
  static Future<List<ProductsRecord>> getProductsByCategory(
    DocumentReference categoryRef, {
    String? sortBy = 'created_at',
    bool descending = true,
    int limit = 20,
  }) async {
    try {
      Query query = ProductsRecord.collection
          .where('category_ref', isEqualTo: categoryRef);

      if (sortBy != null) {
        query = query.orderBy(sortBy, descending: descending);
      }

      final snapshot = await query.limit(limit).get();

      return snapshot.docs
          .map((doc) => ProductsRecord.fromSnapshot(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting products by category: $e');
      return [];
    }
  }

  /// Get products by price range
  static Future<List<ProductsRecord>> getProductsByPriceRange(
    double minPrice,
    double maxPrice, {
    int limit = 20,
  }) async {
    try {
      final snapshot = await ProductsRecord.collection
          .where('price', isGreaterThanOrEqualTo: minPrice)
          .where('price', isLessThanOrEqualTo: maxPrice)
          .orderBy('price')
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => ProductsRecord.fromSnapshot(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting products by price range: $e');
      return [];
    }
  }

  /// Get featured products
  static Future<List<ProductsRecord>> getFeaturedProducts({
    int limit = 10,
  }) async {
    try {
      final snapshot = await ProductsRecord.collection
          .where('is_featured', isEqualTo: true)
          .orderBy('created_at', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => ProductsRecord.fromSnapshot(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting featured products: $e');
      return [];
    }
  }

  /// Get products by owner
  static Future<List<ProductsRecord>> getProductsByOwner(
    DocumentReference ownerRef, {
    int limit = 20,
  }) async {
    try {
      final snapshot = await ProductsRecord.collection
          .where('owner_ref', isEqualTo: ownerRef)
          .orderBy('created_at', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => ProductsRecord.fromSnapshot(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting products by owner: $e');
      return [];
    }
  }

  /// Advanced search with multiple filters
  static Future<List<ProductsRecord>> advancedSearch({
    String? nameQuery,
    DocumentReference? categoryRef,
    double? minPrice,
    double? maxPrice,
    String? condition,
    String? sellRent,
    bool? isFeatured,
    String sortBy = 'created_at',
    bool descending = true,
    int limit = 20,
  }) async {
    try {
      Query query = ProductsRecord.collection;

      // Apply filters
      if (categoryRef != null) {
        query = query.where('category_ref', isEqualTo: categoryRef);
      }

      if (minPrice != null) {
        query = query.where('price', isGreaterThanOrEqualTo: minPrice);
      }

      if (maxPrice != null) {
        query = query.where('price', isLessThanOrEqualTo: maxPrice);
      }

      if (condition != null && condition.isNotEmpty) {
        query = query.where('condition', isEqualTo: condition);
      }

      if (sellRent != null && sellRent.isNotEmpty) {
        query = query.where('sell_rent', isEqualTo: sellRent);
      }

      if (isFeatured != null) {
        query = query.where('is_featured', isEqualTo: isFeatured);
      }

      // Apply sorting
      query = query.orderBy(sortBy, descending: descending);

      // Apply limit
      query = query.limit(limit);

      final snapshot = await query.get();
      var results = snapshot.docs
          .map((doc) => ProductsRecord.fromSnapshot(doc))
          .toList();

      // Client-side filtering for name (since Firestore doesn't support full-text search)
      if (nameQuery != null && nameQuery.isNotEmpty) {
        final lowerQuery = nameQuery.toLowerCase();
        results = results.where((product) {
          return product.name.toLowerCase().contains(lowerQuery) ||
              product.description.toLowerCase().contains(lowerQuery);
        }).toList();
      }

      return results;
    } catch (e) {
      debugPrint('Error in advanced search: $e');
      return [];
    }
  }

  /// Get reviews for a product
  static Future<List<ReviewsRecord>> getProductReviews(
    DocumentReference productRef, {
    int limit = 20,
  }) async {
    try {
      final snapshot = await ReviewsRecord.collection
          .where('product_ref', isEqualTo: productRef)
          .orderBy('created_at', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => ReviewsRecord.fromSnapshot(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting product reviews: $e');
      return [];
    }
  }

  /// Get reviews for a seller
  static Future<List<ReviewsRecord>> getSellerReviews(
    DocumentReference sellerRef, {
    int limit = 20,
  }) async {
    try {
      final snapshot = await ReviewsRecord.collection
          .where('seller_ref', isEqualTo: sellerRef)
          .orderBy('created_at', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => ReviewsRecord.fromSnapshot(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting seller reviews: $e');
      return [];
    }
  }

  /// Calculate average rating for a product
  static Future<double> getProductAverageRating(
      DocumentReference productRef) async {
    try {
      final snapshot = await ReviewsRecord.collection
          .where('product_ref', isEqualTo: productRef)
          .get();

      if (snapshot.docs.isEmpty) {
        return 0.0;
      }

      final reviews =
          snapshot.docs.map((doc) => ReviewsRecord.fromSnapshot(doc)).toList();
      final totalRating = reviews.fold<double>(
          0.0, (total, review) => total + review.rating);

      return totalRating / reviews.length;
    } catch (e) {
      debugPrint('Error calculating average rating: $e');
      return 0.0;
    }
  }

  /// Calculate average rating for a seller
  static Future<double> getSellerAverageRating(
      DocumentReference sellerRef) async {
    try {
      final snapshot = await ReviewsRecord.collection
          .where('seller_ref', isEqualTo: sellerRef)
          .get();

      if (snapshot.docs.isEmpty) {
        return 0.0;
      }

      final reviews =
          snapshot.docs.map((doc) => ReviewsRecord.fromSnapshot(doc)).toList();
      final totalRating = reviews.fold<double>(
          0.0, (total, review) => total + review.rating);

      return totalRating / reviews.length;
    } catch (e) {
      debugPrint('Error calculating seller average rating: $e');
      return 0.0;
    }
  }

  /// Get active categories sorted by display order
  static Future<List<CategoriesRecord>> getActiveCategories() async {
    try {
      final snapshot = await CategoriesRecord.collection
          .where('is_active', isEqualTo: true)
          .orderBy('display_order')
          .get();

      return snapshot.docs
          .map((doc) => CategoriesRecord.fromSnapshot(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting active categories: $e');
      return [];
    }
  }

  /// Get recent products
  static Future<List<ProductsRecord>> getRecentProducts({
    int limit = 20,
  }) async {
    try {
      final snapshot = await ProductsRecord.collection
          .orderBy('created_at', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => ProductsRecord.fromSnapshot(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting recent products: $e');
      return [];
    }
  }
}
