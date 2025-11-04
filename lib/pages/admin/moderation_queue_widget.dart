import '/auth/firebase_auth/auth_util.dart';
import '/backend/admin_service.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'moderation_queue_model.dart';
export 'moderation_queue_model.dart';

class ModerationQueueWidget extends StatefulWidget {
  const ModerationQueueWidget({super.key});

  static String routeName = 'ModerationQueue';
  static String routePath = '/admin/moderation';

  @override
  State<ModerationQueueWidget> createState() => _ModerationQueueWidgetState();
}

class _ModerationQueueWidgetState extends State<ModerationQueueWidget> {
  late ModerationQueueModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ModerationQueueModel());
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
          'Content Moderation',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
                fontFamily: 'Outfit',
                color: Colors.white,
              ),
        ),
        centerTitle: false,
      ),
      body: StreamBuilder<List<ModerationQueueRecord>>(
        stream: queryModerationQueueRecord(
          queryBuilder: (moderationQueueRecord) => moderationQueueRecord
              .where('status', isEqualTo: 'pending')
              .orderBy('created_at', descending: true),
          limit: 100,
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final moderations = snapshot.data!;
          if (moderations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
                  const SizedBox(height: 16),
                  Text(
                    'All Clear!',
                    style: FlutterFlowTheme.of(context).headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No pending moderations',
                    style: FlutterFlowTheme.of(context).bodyLarge,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: moderations.length,
            itemBuilder: (context, index) {
              final moderation = moderations[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getPriorityColor(moderation.priority),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              moderation.priority.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text(moderation.contentType),
                            avatar: Icon(_getContentTypeIcon(moderation.contentType), size: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Reason: ${moderation.reason}',
                        style: FlutterFlowTheme.of(context).titleMedium,
                      ),
                      const SizedBox(height: 8),
                      if (moderation.description.isNotEmpty)
                        Text(
                          moderation.description,
                          style: FlutterFlowTheme.of(context).bodyMedium,
                        ),
                      const SizedBox(height: 8),
                      Text(
                        'Reported: ${dateTimeFormat('relative', moderation.createdAt)}',
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              fontFamily: 'Readex Pro',
                              color: FlutterFlowTheme.of(context).secondaryText,
                            ),
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: FFButtonWidget(
                              onPressed: () => _dismissReport(moderation),
                              text: 'Dismiss',
                              icon: const Icon(Icons.close, size: 15),
                              options: const FFButtonOptions(
                                height: 44,
                                color: Colors.grey,
                                textStyle: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FFButtonWidget(
                              onPressed: () => _warnUser(moderation),
                              text: 'Warn',
                              icon: const Icon(Icons.warning, size: 15),
                              options: const FFButtonOptions(
                                height: 44,
                                color: Colors.orange,
                                textStyle: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FFButtonWidget(
                              onPressed: () => _removeContent(moderation),
                              text: 'Remove',
                              icon: const Icon(Icons.delete, size: 15),
                              options: const FFButtonOptions(
                                height: 44,
                                color: Colors.red,
                                textStyle: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getContentTypeIcon(String contentType) {
    switch (contentType.toLowerCase()) {
      case 'product':
        return Icons.inventory;
      case 'review':
        return Icons.rate_review;
      case 'user':
        return Icons.person;
      case 'message':
        return Icons.message;
      case 'chat':
        return Icons.chat;
      default:
        return Icons.flag;
    }
  }

  Future<void> _dismissReport(ModerationQueueRecord moderation) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dismiss Report'),
        content: const Text('Are you sure you want to dismiss this report? No action will be taken.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );

    if (result == true) {
      await AdminService.reviewModeration(
        moderationId: moderation.reference.id,
        reviewedBy: currentUserReference!,
        actionTaken: 'dismissed',
        notes: 'Report dismissed - no violation found',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report dismissed')),
      );
    }
  }

  Future<void> _warnUser(ModerationQueueRecord moderation) async {
    // Check if contentRef exists before showing dialog
    if (moderation.contentRef == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No user reference found for this report'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Warn User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('This will:'),
            const SizedBox(height: 8),
            const Text('• Send an automated warning message to the user'),
            const Text('• Increment their warning count'),
            const Text('• Automatically suspend them after 5 warnings'),
            const SizedBox(height: 16),
            Text(
              'Report Reason: ${moderation.reason}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (moderation.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Details: ${moderation.description}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Warn', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (result == true) {
      // Check if widget is still mounted before using context
      if (!mounted) return;
      
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Processing warning...'),
          duration: Duration(seconds: 2),
        ),
      );
      
      try {
        debugPrint('🔔 Starting warning process for user: ${moderation.contentRef!.path}');
        
        // Warn user and track warning count (auto-sends message)
        final success = await AdminService.warnUserAndTrack(
          userRef: moderation.contentRef!,
          warnedBy: currentUserReference!,
          reason: moderation.reason,
        );
        
        debugPrint('🔔 Warning process completed: $success');
        
        // Mark moderation as reviewed
        await AdminService.reviewModeration(
          moderationId: moderation.reference.id,
          reviewedBy: currentUserReference!,
          actionTaken: 'warned',
          notes: 'User warned for: ${moderation.reason}. Automated warning message sent.',
        );
        
        debugPrint('🔔 Moderation marked as reviewed');
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Warning successfully issued! Automated message sent to the reported user.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 4),
            ),
          );
        }
      } catch (e) {
        debugPrint('❌ Error issuing warning: $e');
        debugPrint('❌ Stack trace: ${StackTrace.current}');
        
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error issuing warning: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  Future<void> _removeContent(ModerationQueueRecord moderation) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Content'),
        content: const Text(
          'Are you sure you want to remove this content? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (result == true && moderation.contentRef != null) {
      await AdminService.removeContent(
        contentType: moderation.contentType,
        contentRef: moderation.contentRef!,
        removedBy: currentUserReference!,
        reason: moderation.reason,
      );
      await AdminService.reviewModeration(
        moderationId: moderation.reference.id,
        reviewedBy: currentUserReference!,
        actionTaken: 'removed',
        notes: 'Content removed due to: ${moderation.reason}',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Content removed successfully')),
      );
    }
  }
}
