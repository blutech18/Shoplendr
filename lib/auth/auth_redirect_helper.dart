import 'package:flutter/material.dart';
import '/backend/admin_service.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/homepage_copy2_copy/homepage_copy2_copy_widget.dart';
import '/pages/admin/admin_dashboard_widget.dart';
import '/pages/moderator/moderator_dashboard_widget.dart';
import 'package:go_router/go_router.dart';

/// Helper class to handle post-login redirects based on user role
class AuthRedirectHelper {
  /// Redirect user to appropriate page after login based on their role
  static Future<void> redirectAfterLogin(BuildContext context) async {
    if (!context.mounted) return;

    debugPrint('🔍 AuthRedirectHelper: Checking user role...');
    debugPrint('🔍 Current user reference: ${currentUserReference?.path}');

    if (currentUserReference == null) {
      debugPrint('❌ No current user reference found!');
      context.goNamed(HomepageCopy2CopyWidget.routeName);
      return;
    }

    // Get admin user record to check role
    final adminUser = await AdminService.getAdminUser(currentUserReference!);
    
    if (!context.mounted) return;

    if (adminUser != null && adminUser.isActive) {
      // User has admin panel access
      if (adminUser.role == AdminService.roleAdmin || adminUser.role == AdminService.roleSuperAdmin) {
        // Redirect to admin dashboard
        debugPrint('✅ Redirecting to Admin Dashboard (${adminUser.role})');
        context.goNamed(AdminDashboardWidget.routeName);
      } else if (adminUser.role == AdminService.roleModerator) {
        // Redirect to moderator dashboard
        debugPrint('✅ Redirecting to Moderator Dashboard');
        context.goNamed(ModeratorDashboardWidget.routeName);
      } else {
        // Unknown role, redirect to student homepage
        debugPrint('⚠️ Unknown admin role: ${adminUser.role}, redirecting to Student Homepage');
        context.goNamed(HomepageCopy2CopyWidget.routeName);
      }
    } else {
      // Regular student user
      debugPrint('✅ Redirecting to Student Homepage');
      context.goNamed(HomepageCopy2CopyWidget.routeName);
    }
  }

  /// Check if current user is admin (synchronous check for UI)
  static Future<bool> isCurrentUserAdmin() async {
    if (currentUserReference == null) return false;
    return await AdminService.isAdmin(currentUserReference!);
  }

  /// Check if current user is moderator
  static Future<bool> isCurrentUserModerator() async {
    if (currentUserReference == null) return false;
    return await AdminService.isModerator(currentUserReference!);
  }

  /// Check if current user has any admin panel access
  static Future<bool> hasAdminAccess() async {
    if (currentUserReference == null) return false;
    return await AdminService.hasAdminAccess(currentUserReference!);
  }
}
