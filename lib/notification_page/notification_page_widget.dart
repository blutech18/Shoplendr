import '/components/bottom_nav_bar.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'notification_page_model.dart';
export 'notification_page_model.dart';

/// Header Section
///
/// Title: “Notifications”
///
/// Small bell icon (optional)
///
/// Main Content
///
/// List of notifications (repeating list from Firestore)
///
/// Each notification card should have:
///
/// 🔔 Icon (status or message type)
///
/// Title (e.g., “Request Approved”, “New Message”, “Item Declined”)
///
/// Short description (e.g., “Your borrow request for Laptop was approved.”)
///
/// Timestamp (“2h ago”)
///
/// Types of Notifications
///
/// Borrow/Request Updates
///
/// Pending → “Your request for Calculator is pending.”
///
/// Approved → “Your request for Laptop was approved ✅.”
///
/// Declined → “Your request for Book was declined ❌.”
///
/// Messages
///
/// “You received a new message from [User].”
///
/// General System Alerts (optional)
///
/// “ShopLendr updated its insurance policy.”
///
/// Footer (optional)
///
/// Mark all as read button
///
/// Back button → returns to Home or Profile
///
/// 🧭 Navigation Flow
///
/// Profile Page → Notifications
class NotificationPageWidget extends StatefulWidget {
  const NotificationPageWidget({super.key});

  static String routeName = 'NotificationPage';
  static String routePath = '/notificationPage';

  @override
  State<NotificationPageWidget> createState() => _NotificationPageWidgetState();
}

class _NotificationPageWidgetState extends State<NotificationPageWidget> {
  late NotificationPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NotificationPageModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
          automaticallyImplyLeading: false,
          title: Text(
            'Notifications',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.interTight(
                    fontWeight: FontWeight.bold,
                  ),
                  color: FlutterFlowTheme.of(context).primaryText,
                  fontSize: 24,
                  letterSpacing: -0.5,
                ),
          ),
          actions: const [],
          centerTitle: true,
          elevation: 0.5,
        ),
        body: SafeArea(
          top: true,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Empty State
                Icon(
                  Icons.notifications_none_outlined,
                  size: 80.0,
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
                const SizedBox(height: 24.0),
                Text(
                  'No Notifications',
                  style: FlutterFlowTheme.of(context).headlineMedium.override(
                        font: GoogleFonts.interTight(
                          fontWeight: FontWeight.bold,
                        ),
                        letterSpacing: 0.0,
                      ),
                ),
                const SizedBox(height: 12.0),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(48.0, 0.0, 48.0, 0.0),
                  child: Text(
                    'You\'re all caught up! Check back later for new notifications.',
                    textAlign: TextAlign.center,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.inter(),
                          color: FlutterFlowTheme.of(context).secondaryText,
                          letterSpacing: 0.0,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavBar(currentRoute: NotificationPageWidget.routeName),
      ),
    );
  }
}
