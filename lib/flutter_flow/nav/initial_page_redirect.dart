import 'package:flutter/material.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/admin_service.dart';
import '/backend/backend.dart';
import '/homepage_copy2_copy/homepage_copy2_copy_widget.dart';
import '/pages/admin/admin_dashboard_widget.dart';
import '/pages/moderator/moderator_dashboard_widget.dart';

/// Widget that determines the initial page based on user role
class InitialPageRedirect extends StatelessWidget {
  const InitialPageRedirect({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AdminUsersRecord?>(
      future: _getAdminUser(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final adminUser = snapshot.data;
        
        // Check if user has admin panel access
        if (adminUser != null && adminUser.isActive) {
          if (adminUser.role == AdminService.roleAdmin || adminUser.role == AdminService.roleSuperAdmin) {
            return const AdminDashboardWidget();
          } else if (adminUser.role == AdminService.roleModerator) {
            return const ModeratorDashboardWidget();
          }
        }
        
        // Regular student user
        return const HomepageCopy2CopyWidget();
      },
    );
  }

  Future<AdminUsersRecord?> _getAdminUser() async {
    if (currentUserReference == null) return null;
    return await AdminService.getAdminUser(currentUserReference!);
  }
}
