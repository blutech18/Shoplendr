import 'package:flutter/foundation.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Service for admin panel operations and content moderation
class AdminService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Admin roles
  static const String roleSuperAdmin = 'super_admin';
  static const String roleAdmin = 'admin';
  static const String roleModerator = 'moderator';

  // Permissions
  static const String permManageUsers = 'manage_users';
  static const String permManageProducts = 'manage_products';
  static const String permManageCategories = 'manage_categories';
  static const String permManageReviews = 'manage_reviews';
  static const String permViewAnalytics = 'view_analytics';
  static const String permModerateContent = 'moderate_content';
  static const String permManageAdmins = 'manage_admins';

  // ==================== Admin User Management ====================

  /// Check if user is admin
  static Future<bool> isAdmin(DocumentReference userRef) async {
    try {
      debugPrint('🔍 AdminService.isAdmin: Checking user: ${userRef.path}');
      debugPrint('🔍 AdminService.isAdmin: User ref ID: ${userRef.id}');
      
      // First, try to get all admin users to debug
      final allAdmins = await AdminUsersRecord.collection.get();
      debugPrint('🔍 AdminService.isAdmin: Total AdminUsers in collection: ${allAdmins.docs.length}');
      
      for (var doc in allAdmins.docs) {
        final adminRecord = AdminUsersRecord.fromSnapshot(doc);
        debugPrint('🔍   Admin doc ${doc.id}: user_ref = ${adminRecord.userRef?.path}, is_active = ${adminRecord.isActive}');
      }
      
      // Now try the actual query
      final snapshot = await AdminUsersRecord.collection
          .where('user_ref', isEqualTo: userRef)
          .where('is_active', isEqualTo: true)
          .limit(1)
          .get();

      debugPrint('🔍 AdminService.isAdmin: Query found ${snapshot.docs.length} admin records');
      
      if (snapshot.docs.isNotEmpty) {
        final adminRecord = AdminUsersRecord.fromSnapshot(snapshot.docs.first);
        debugPrint('🔍 AdminService.isAdmin: Admin role: ${adminRecord.role}');
        debugPrint('🔍 AdminService.isAdmin: Admin active: ${adminRecord.isActive}');
      } else {
        debugPrint('❌ AdminService.isAdmin: No matching admin found for user: ${userRef.path}');
      }

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Error checking admin status: $e');
      debugPrint('❌ Stack trace: ${StackTrace.current}');
      return false;
    }
  }

  /// Check if user is moderator
  static Future<bool> isModerator(DocumentReference userRef) async {
    try {
      final adminUser = await getAdminUser(userRef);
      return adminUser != null && 
             adminUser.isActive && 
             adminUser.role == roleModerator;
    } catch (e) {
      debugPrint('❌ Error checking moderator status: $e');
      return false;
    }
  }

  /// Check if user is admin or moderator (has any admin panel access)
  static Future<bool> hasAdminAccess(DocumentReference userRef) async {
    try {
      final adminUser = await getAdminUser(userRef);
      return adminUser != null && adminUser.isActive;
    } catch (e) {
      debugPrint('❌ Error checking admin access: $e');
      return false;
    }
  }

  /// Get admin user record
  static Future<AdminUsersRecord?> getAdminUser(
      DocumentReference userRef) async {
    try {
      final snapshot = await AdminUsersRecord.collection
          .where('user_ref', isEqualTo: userRef)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return AdminUsersRecord.fromSnapshot(snapshot.docs.first);
    } catch (e) {
      debugPrint('Error getting admin user: $e');
      return null;
    }
  }

  /// Check if admin has permission
  static Future<bool> hasPermission(
    DocumentReference userRef,
    String permission,
  ) async {
    try {
      final adminUser = await getAdminUser(userRef);
      if (adminUser == null || !adminUser.isActive) return false;

      // Super admin has all permissions
      if (adminUser.role == roleSuperAdmin) return true;

      return adminUser.permissions.contains(permission);
    } catch (e) {
      debugPrint('Error checking permission: $e');
      return false;
    }
  }

  /// Create admin user
  static Future<bool> createAdminUser({
    required DocumentReference userRef,
    required String role,
    required List<String> permissions,
    required DocumentReference createdBy,
  }) async {
    try {
      await AdminUsersRecord.collection.add(
        createAdminUsersRecordData(
          userRef: userRef,
          role: role,
          isActive: true,
          createdAt: getCurrentTimestamp,
          createdBy: createdBy,
        ),
      );
      return true;
    } catch (e) {
      debugPrint('Error creating admin user: $e');
      return false;
    }
  }

  // ==================== Content Moderation ====================

  /// Report content for moderation
  static Future<bool> reportContent({
    required String contentType, // 'product', 'review', 'user', 'message'
    required DocumentReference contentRef,
    required DocumentReference reporterRef,
    required String reason,
    String? description,
  }) async {
    try {
      await ModerationQueueRecord.collection.add(
        createModerationQueueRecordData(
          contentType: contentType,
          contentRef: contentRef,
          reporterRef: reporterRef,
          reason: reason,
          description: description,
          status: 'pending',
          priority: _calculatePriority(reason),
          createdAt: getCurrentTimestamp,
        ),
      );
      return true;
    } catch (e) {
      debugPrint('Error reporting content: $e');
      return false;
    }
  }

  /// Get pending moderation items
  static Future<List<ModerationQueueRecord>> getPendingModerations({
    int limit = 50,
  }) async {
    try {
      final snapshot = await ModerationQueueRecord.collection
          .where('status', isEqualTo: 'pending')
          .orderBy('priority', descending: true)
          .orderBy('created_at', descending: false)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => ModerationQueueRecord.fromSnapshot(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting pending moderations: $e');
      return [];
    }
  }

  /// Review moderation item
  static Future<bool> reviewModeration({
    required String moderationId,
    required DocumentReference reviewedBy,
    required String actionTaken, // 'approved', 'removed', 'warned', 'dismissed'
    String? notes,
  }) async {
    try {
      await _firestore.collection('ModerationQueue').doc(moderationId).update({
        'status': 'reviewed',
        'reviewed_by': reviewedBy,
        'reviewed_at': FieldValue.serverTimestamp(),
        'action_taken': actionTaken,
        'notes': notes,
      });

      return true;
    } catch (e) {
      debugPrint('Error reviewing moderation: $e');
      return false;
    }
  }

  /// Remove content (admin action)
  static Future<bool> removeContent({
    required String contentType,
    required DocumentReference contentRef,
    required DocumentReference removedBy,
    required String reason,
  }) async {
    try {
      // Mark content as removed
      await contentRef.update({
        'is_removed': true,
        'removed_by': removedBy,
        'removed_at': FieldValue.serverTimestamp(),
        'removal_reason': reason,
      });

      // Log action
      await _logAdminAction(
        action: 'remove_content',
        adminRef: removedBy,
        targetRef: contentRef,
        details: {'content_type': contentType, 'reason': reason},
      );

      return true;
    } catch (e) {
      debugPrint('Error removing content: $e');
      return false;
    }
  }

  /// Ban user (admin action)
  static Future<bool> banUser({
    required DocumentReference userRef,
    required DocumentReference bannedBy,
    required String reason,
    DateTime? banUntil,
  }) async {
    try {
      await userRef.update({
        'is_banned': true,
        'banned_by': bannedBy,
        'banned_at': FieldValue.serverTimestamp(),
        'ban_reason': reason,
        'ban_until': banUntil,
      });

      // Log action
      await _logAdminAction(
        action: 'ban_user',
        adminRef: bannedBy,
        targetRef: userRef,
        details: {
          'reason': reason,
          'ban_until': banUntil?.toIso8601String(),
        },
      );

      return true;
    } catch (e) {
      debugPrint('Error banning user: $e');
      return false;
    }
  }

  /// Unban user
  static Future<bool> unbanUser({
    required DocumentReference userRef,
    required DocumentReference unbannedBy,
  }) async {
    try {
      await userRef.update({
        'is_banned': false,
        'unbanned_by': unbannedBy,
        'unbanned_at': FieldValue.serverTimestamp(),
      });

      await _logAdminAction(
        action: 'unban_user',
        adminRef: unbannedBy,
        targetRef: userRef,
        details: {},
      );

      return true;
    } catch (e) {
      debugPrint('Error unbanning user: $e');
      return false;
    }
  }

  /// Suspend user (admin action)
  static Future<bool> suspendUser({
    required DocumentReference userRef,
    required DocumentReference suspendedBy,
    required String reason,
    DateTime? suspensionUntil,
  }) async {
    try {
      await userRef.update({
        'is_suspended': true,
        'suspended_by': suspendedBy,
        'suspended_at': FieldValue.serverTimestamp(),
        'suspension_reason': reason,
        'suspension_until': suspensionUntil,
      });

      // Log action
      await _logAdminAction(
        action: 'suspend_user',
        adminRef: suspendedBy,
        targetRef: userRef,
        details: {
          'reason': reason,
          'suspension_until': suspensionUntil?.toIso8601String(),
        },
      );

      return true;
    } catch (e) {
      debugPrint('Error suspending user: $e');
      return false;
    }
  }

  /// Unsuspend/Activate user
  static Future<bool> unsuspendUser({
    required DocumentReference userRef,
    required DocumentReference unsuspendedBy,
  }) async {
    try {
      await userRef.update({
        'is_suspended': false,
        'unsuspended_by': unsuspendedBy,
        'unsuspended_at': FieldValue.serverTimestamp(),
      });

      await _logAdminAction(
        action: 'unsuspend_user',
        adminRef: unsuspendedBy,
        targetRef: userRef,
        details: {},
      );

      return true;
    } catch (e) {
      debugPrint('Error unsuspending user: $e');
      return false;
    }
  }

  /// Send automated warning message to user
  static Future<bool> sendWarningMessage({
    required DocumentReference reportedUserRef,
    required DocumentReference adminRef,
    required String reason,
  }) async {
    try {
      // Admin UID for customer support
      const String adminUid = 'e5JeP91nfRVyg8ZINWKSUypPOwD2';
      final adminSupportRef = UsersRecord.collection.doc(adminUid);
      
      // Get the reported user's UID
      final reportedUserDoc = await reportedUserRef.get();
      final reportedUserUid = reportedUserDoc.id;
      
      // Check if a thread already exists between admin and reported user
      final existingThreads = await _firestore.collection('messages')
          .where('uid', isEqualTo: reportedUserUid)
          .where('participants', isEqualTo: adminSupportRef)
          .limit(1)
          .get();
      
      DocumentReference threadRef;
      
      if (existingThreads.docs.isNotEmpty) {
        // Use existing thread
        threadRef = existingThreads.docs.first.reference;
      } else {
        // Create new thread
        final newThread = await _firestore.collection('messages').add({
          'participants': adminSupportRef,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'lastMessage': '',
          'email': 'admin@antiquespride.edu.ph',
          'display_name': 'Customer Service',
          'photo_url': '',
          'uid': reportedUserUid,
          'created_time': FieldValue.serverTimestamp(),
        });
        threadRef = newThread;
      }
      
      // Create warning message
      final warningMessage = '⚠️ WARNING: You have been reported by another student for: $reason. Please review our community guidelines and ensure your behavior complies with our policies.';
      
      // Add message to the thread's chats subcollection
      // The Firebase Cloud Function will automatically handle bidirectional thread updates
      await threadRef.collection('chats').add({
        'senderRef': adminSupportRef,
        'text': warningMessage,
        'sentAt': FieldValue.serverTimestamp(),
      });
      
      // Note: Thread updates are handled by the Firebase Cloud Function
      // No need to manually update threads here to avoid duplicates
      
      return true;
    } catch (e) {
      debugPrint('Error sending warning message: $e');
      return false;
    }
  }

  /// Warn user and increment warning count
  static Future<bool> warnUserAndTrack({
    required DocumentReference userRef,
    required DocumentReference warnedBy,
    required String reason,
  }) async {
    try {
      // Get current user data
      final userDoc = await userRef.get();
      final userData = userDoc.data() as Map<String, dynamic>?;
      final currentWarningCount = (userData?['warning_count'] as int?) ?? 0;
      final newWarningCount = currentWarningCount + 1;
      
      // Update warning count
      await userRef.update({
        'warning_count': newWarningCount,
      });
      
      // Send automated warning message
      await sendWarningMessage(
        reportedUserRef: userRef,
        adminRef: warnedBy,
        reason: reason,
      );
      
      // If user has 5 or more warnings, suspend them
      if (newWarningCount >= 5) {
        await suspendUser(
          userRef: userRef,
          suspendedBy: warnedBy,
          reason: 'Exceeded maximum warnings (5)',
          suspensionUntil: null, // Permanent suspension
        );
      }
      
      return true;
    } catch (e) {
      debugPrint('Error warning user and tracking: $e');
      return false;
    }
  }

  // ==================== Category Management ====================

  /// Create category (admin only)
  static Future<DocumentReference?> createCategory({
    required String name,
    required String description,
    String? iconUrl,
    int displayOrder = 0,
  }) async {
    try {
      final docRef = await CategoriesRecord.collection.add(
        createCategoriesRecordData(
          name: name,
          description: description,
          iconUrl: iconUrl,
          displayOrder: displayOrder,
          isActive: true,
          productCount: 0,
          createdAt: getCurrentTimestamp,
          updatedAt: getCurrentTimestamp,
        ),
      );
      return docRef;
    } catch (e) {
      debugPrint('Error creating category: $e');
      return null;
    }
  }

  /// Update category
  static Future<bool> updateCategory({
    required String categoryId,
    String? name,
    String? description,
    String? iconUrl,
    int? displayOrder,
    bool? isActive,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': FieldValue.serverTimestamp(),
      };

      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;
      if (iconUrl != null) updates['icon_url'] = iconUrl;
      if (displayOrder != null) updates['display_order'] = displayOrder;
      if (isActive != null) updates['is_active'] = isActive;

      await CategoriesRecord.collection.doc(categoryId).update(updates);
      return true;
    } catch (e) {
      debugPrint('Error updating category: $e');
      return false;
    }
  }

  // ==================== Analytics & Reports ====================

  /// Get admin dashboard statistics
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Get counts
      final usersCount = await _getCollectionCount('Users');
      final productsCount = await _getCollectionCount('Products');
      final reviewsCount = await _getCollectionCount('Reviews');
      final pendingModerations = await _getCollectionCount(
        'ModerationQueue',
        where: {'status': 'pending'},
      );
      final pendingIDVerifications = await _getCollectionCount(
        'Users',
        where: {'verificationStatus': 'pending'},
      );

      // Get today's new items
      final newUsersToday = await _getCollectionCount(
        'Users',
        where: {'created_time': today},
        isGreaterThanOrEqualTo: true,
      );

      final newProductsToday = await _getCollectionCount(
        'Products',
        where: {'created_at': today},
        isGreaterThanOrEqualTo: true,
      );

      return {
        'total_users': usersCount,
        'total_products': productsCount,
        'total_reviews': reviewsCount,
        'pending_moderations': pendingModerations,
        'pending_id_verifications': pendingIDVerifications,
        'new_users_today': newUsersToday,
        'new_products_today': newProductsToday,
      };
    } catch (e) {
      debugPrint('Error getting dashboard stats: $e');
      return {};
    }
  }

  /// Get reported content summary
  static Future<Map<String, int>> getReportedContentSummary() async {
    try {
      final snapshot = await ModerationQueueRecord.collection
          .where('status', isEqualTo: 'pending')
          .get();

      final summary = <String, int>{};
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        final contentType = data?['content_type'] as String?;
        if (contentType != null) {
          summary[contentType] = (summary[contentType] ?? 0) + 1;
        }
      }

      return summary;
    } catch (e) {
      debugPrint('Error getting reported content summary: $e');
      return {};
    }
  }

  // ==================== Helper Methods ====================

  /// Calculate priority based on reason
  static String _calculatePriority(String reason) {
    final highPriorityReasons = [
      'illegal_content',
      'harassment',
      'violence',
      'scam',
    ];

    return highPriorityReasons.contains(reason.toLowerCase())
        ? 'high'
        : 'normal';
  }

  /// Log admin action
  static Future<void> _logAdminAction({
    required String action,
    required DocumentReference adminRef,
    required DocumentReference targetRef,
    required Map<String, dynamic> details,
  }) async {
    try {
      await _firestore.collection('AdminLogs').add({
        'action': action,
        'admin_ref': adminRef,
        'target_ref': targetRef,
        'details': details,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error logging admin action: $e');
    }
  }

  /// Get collection count
  static Future<int> _getCollectionCount(
    String collectionName, {
    Map<String, dynamic>? where,
    bool isGreaterThanOrEqualTo = false,
  }) async {
    try {
      Query query = _firestore.collection(collectionName);

      if (where != null) {
        where.forEach((key, value) {
          if (isGreaterThanOrEqualTo) {
            query = query.where(key, isGreaterThanOrEqualTo: value);
          } else {
            query = query.where(key, isEqualTo: value);
          }
        });
      }

      final snapshot = await query.get();
      return snapshot.docs.length;
    } catch (e) {
      debugPrint('Error getting collection count: $e');
      return 0;
    }
  }
}
