import '/auth/firebase_auth/auth_util.dart';
import '/backend/admin_service.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'user_management_model.dart';
export 'user_management_model.dart';

class UserManagementWidget extends StatefulWidget {
  const UserManagementWidget({super.key});

  static String routeName = 'UserManagement';
  static String routePath = '/admin/users';

  @override
  State<UserManagementWidget> createState() => _UserManagementWidgetState();
}

class _UserManagementWidgetState extends State<UserManagementWidget> {
  late UserManagementModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => UserManagementModel());
    _model.searchTextController ??= TextEditingController();
    _model.searchFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primary,
        title: Text(
          'User Management',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
                fontFamily: 'Outfit',
                color: Colors.white,
              ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              controller: _model.searchTextController,
              focusNode: _model.searchFocusNode,
              decoration: InputDecoration(
                labelText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<UsersRecord>>(
              stream: queryUsersRecord(
                queryBuilder: (query) => query.orderBy('created_time', descending: true),
                limit: 100,
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var users = snapshot.data!;
                final searchTerm = _model.searchTextController.text.toLowerCase();
                if (searchTerm.isNotEmpty) {
                  users = users.where((user) {
                    return user.displayName.toLowerCase().contains(searchTerm) ||
                        user.username.toLowerCase().contains(searchTerm);
                  }).toList();
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundImage: user.photoUrl.isNotEmpty
                              ? NetworkImage(user.photoUrl)
                              : null,
                          child: user.photoUrl.isEmpty
                              ? Text(user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'U')
                              : null,
                        ),
                        title: Text(user.displayName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('@${user.username}'),
                            if (user.isSuspended)
                              const Chip(
                                label: Text('Suspended', style: TextStyle(color: Colors.white)),
                                backgroundColor: Colors.red,
                              ),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow('Email Verified', user.emailVerified ? 'Yes' : 'No'),
                                _buildInfoRow('Student ID Verified', user.studentIdVerified ? 'Yes' : 'No'),
                                _buildInfoRow('Phone', user.phoneNumber),
                                _buildInfoRow('Address', user.address),
                                _buildInfoRow('Joined', dateTimeFormat('relative', user.createdTime)),
                                if (user.isSuspended) ...[
                                  const Divider(),
                                  _buildInfoRow('Suspension Reason', user.suspensionReason),
                                  if (user.suspensionUntil != null)
                                    _buildInfoRow('Suspended Until', dateTimeFormat('yMMMd', user.suspensionUntil)),
                                ],
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    if (!user.isSuspended)
                                      FFButtonWidget(
                                        onPressed: () => _suspendUser(user),
                                        text: 'Suspend',
                                        icon: const Icon(Icons.block, size: 15),
                                        options: const FFButtonOptions(
                                          height: 40,
                                          color: Colors.orange,
                                          textStyle: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    if (user.isSuspended)
                                      FFButtonWidget(
                                        onPressed: () => _activateUser(user),
                                        text: 'Activate',
                                        icon: const Icon(Icons.check_circle, size: 15),
                                        options: const FFButtonOptions(
                                          height: 40,
                                          color: Colors.green,
                                          textStyle: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    FFButtonWidget(
                                      onPressed: () => _viewUserDetails(user),
                                      text: 'View Details',
                                      icon: const Icon(Icons.info, size: 15),
                                      options: FFButtonOptions(
                                        height: 40,
                                        color: FlutterFlowTheme.of(context).primary,
                                        textStyle: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Readex Pro',
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: FlutterFlowTheme.of(context).bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _suspendUser(UsersRecord user) async {
    final reasonController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Suspend User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Suspend ${user.displayName}?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Suspend'),
          ),
        ],
      ),
    );

    if (result == true && reasonController.text.isNotEmpty) {
      await AdminService.suspendUser(
        userRef: user.reference,
        suspendedBy: currentUserReference!,
        reason: reasonController.text,
      );
      setState(() {});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User suspended successfully')),
      );
    }
  }

  Future<void> _activateUser(UsersRecord user) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Activate User'),
        content: Text('Activate ${user.displayName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Activate'),
          ),
        ],
      ),
    );

    if (result == true) {
      await AdminService.unsuspendUser(
        userRef: user.reference,
        unsuspendedBy: currentUserReference!,
      );
      setState(() {});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User activated successfully')),
      );
    }
  }

  void _viewUserDetails(UsersRecord user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.displayName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoRow('Username', user.username),
              _buildInfoRow('Email Verified', user.emailVerified ? 'Yes' : 'No'),
              _buildInfoRow('Student ID Verified', user.studentIdVerified ? 'Yes' : 'No'),
              _buildInfoRow('Phone', user.phoneNumber),
              _buildInfoRow('Address', user.address),
              _buildInfoRow('Verification Status', user.verificationStatus),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
