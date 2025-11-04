import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/firebase_storage/storage.dart';
import '/backend/admin_service.dart';
import '/components/bottom_nav_bar.dart';
import '/components/cors_safe_image.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import '/flutter_flow/price_format.dart';
import '/index.dart';
import '/pages/moderator/moderator_dashboard_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'profile_model.dart';
export 'profile_model.dart';

/// Profile Page (Simple Layout)
///
/// Header:
///
/// ShopLendr Logo (top center or left)
///
/// Title: "My Profile"
///
/// Profile Section:
///
/// Profile Picture (circle placeholder, with option to upload/change photo)
///
/// Name (Full Name of User)
///
/// University of Antique Email (for validation)
///
/// Account Details:
///
/// Username
///
/// Contact Number
///
/// Address
///
/// Buttons/Actions:
///
/// Edit Profile (to update details)
///
/// My Listings (to see items posted for sale/rent)
/// Logout
///
/// Bottom Navigation Bar (Always Visible):
///
/// Home | Sell  | Messages | Profile
class ProfileWidget extends StatefulWidget {
  const ProfileWidget({
    super.key,
    this.userRef,
  });

  final DocumentReference? userRef;

  static String routeName = 'profile';
  static String routePath = '/profile';

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  late ProfileModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProfileModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use provided userRef or default to current user
    final profileUserRef = widget.userRef ?? currentUserReference;
    final isViewingOtherUser = widget.userRef != null && widget.userRef != currentUserReference;

    // If viewing another user's profile, show public profile view
    if (isViewingOtherUser && profileUserRef != null) {
      return StreamBuilder<UsersRecord>(
        stream: UsersRecord.getDocument(profileUserRef),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
              backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
              appBar: AppBar(
                backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
                title: Text(
                  'Profile',
                  style: FlutterFlowTheme.of(context).headlineMedium.override(
                        font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                        color: FlutterFlowTheme.of(context).primaryText,
                        fontSize: 24,
                        letterSpacing: -0.5,
                      ),
                ),
                centerTitle: true,
                elevation: 0.5,
              ),
              body: Center(
                child: SizedBox(
                  width: 50.0,
                  height: 50.0,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      FlutterFlowTheme.of(context).primary,
                    ),
                  ),
                ),
              ),
            );
          }

          final profileUser = snapshot.data!;
          return _buildPublicProfileView(context, profileUser);
        },
      );
    }

    // Check if user has admin panel access (admin or moderator)
    return FutureBuilder<AdminUsersRecord?>(
      future: currentUserReference != null 
          ? AdminService.getAdminUser(currentUserReference!)
          : Future.value(null),
      builder: (context, adminSnapshot) {
        // Show loading while checking admin status
        if (adminSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: Center(
              child: SizedBox(
                width: 50.0,
                height: 50.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary,
                  ),
                ),
              ),
            ),
          );
        }

        final adminUser = adminSnapshot.data;

        // If user has admin panel access, show appropriate profile
        if (adminUser != null && adminUser.isActive) {
          if (adminUser.role == AdminService.roleAdmin || adminUser.role == AdminService.roleSuperAdmin) {
            return _buildAdminProfile(context);
          } else if (adminUser.role == AdminService.roleModerator) {
            return _buildModeratorProfile(context);
          }
        }

        // User is not admin, show student profile
        if (currentUserReference == null) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: const Center(
              child: Text('User not logged in'),
            ),
          );
        }
        
        return StreamBuilder<UsersRecord>(
          stream: UsersRecord.getDocument(currentUserReference!),
          builder: (context, snapshot) {
            // Customize what your widget looks like when it's loading.
            if (!snapshot.hasData) {
              return Scaffold(
                backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
                body: Center(
                  child: SizedBox(
                    width: 50.0,
                    height: 50.0,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        FlutterFlowTheme.of(context).primary,
                      ),
                    ),
                  ),
                ),
              );
            }

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
                'My Profile',
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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // Header Section with Profile Picture
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            FlutterFlowTheme.of(context).primary,
                            FlutterFlowTheme.of(context).secondary,
                          ],
                          stops: const [0.0, 1.0],
                          begin: const AlignmentDirectional(-1.0, -1.0),
                          end: const AlignmentDirectional(1.0, 1.0),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(24.0, 32.0, 24.0, 32.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 120.0,
                              height: 120.0,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 20.0,
                                    color: Colors.black.withValues(alpha: 0.2),
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: AuthUserStreamWidget(
                                builder: (context) => InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                      // Store theme before async operations
                                      final theme = FlutterFlowTheme.of(context);
                                      
                                      final selectedMedia =
                                          await selectMediaWithSourceBottomSheet(
                                        context: context,
                                        allowPhoto: true,
                                      );
                                      if (selectedMedia != null &&
                                          selectedMedia.every((m) =>
                                              validateFileFormat(
                                                  m.storagePath, context))) {
                                        safeSetState(() => _model
                                                .isDataUploading_uploadprofilepic =
                                            true);
                                        var selectedUploadedFiles =
                                            <FFUploadedFile>[];

                                        var downloadUrls = <String>[];
                                        try {
                                          selectedUploadedFiles = selectedMedia
                                              .map((m) => FFUploadedFile(
                                                    name: m.storagePath
                                                        .split('/')
                                                        .last,
                                                    bytes: m.bytes,
                                                    height:
                                                        m.dimensions?.height,
                                                    width: m.dimensions?.width,
                                                    blurHash: m.blurHash,
                                                  ))
                                              .toList();

                                          downloadUrls = (await Future.wait(
                                            selectedMedia.map(
                                              (m) async => await uploadData(
                                                  m.storagePath, m.bytes),
                                            ),
                                          ))
                                              .where((u) => u != null)
                                              .map((u) => u!)
                                              .toList();
                                        } finally {
                                          _model.isDataUploading_uploadprofilepic =
                                              false;
                                        }
                                        if (selectedUploadedFiles.length ==
                                                selectedMedia.length &&
                                            downloadUrls.length ==
                                                selectedMedia.length) {
                                          safeSetState(() {
                                            _model.uploadedLocalFile_uploadprofilepic =
                                                selectedUploadedFiles.first;
                                            _model.uploadedFileUrl_uploadprofilepic =
                                                downloadUrls.first;
                                          });
                                          
                                          // Update user's photo URL in Firebase Auth
                                          await currentUserReference!.update({
                                            ...createUsersRecordData(
                                              photoUrl: downloadUrls.first,
                                            ),
                                          });
                                          
                                          if (!mounted) return;
                                          // Show success message
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Profile picture updated successfully!',
                                                style: TextStyle(
                                                  color: theme.info,
                                                ),
                                              ),
                                              duration: const Duration(milliseconds: 2000),
                                              backgroundColor: theme.success,
                                            ),
                                          );
                                          }
                                        } else {
                                          safeSetState(() {});
                                          return;
                                        }
                                      }
                                    },
                                  child: CorsSafeImage(
                                    imageUrl: valueOrDefault<String>(
                                      currentUserPhoto,
                                      'https://cdn-icons-png.flaticon.com/512/8847/8847419.png',
                                    ),
                                    width: 120.0,
                                    height: 120.0,
                                    fit: BoxFit.cover,
                                    borderRadius: BorderRadius.circular(60.0),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            AuthUserStreamWidget(
                              builder: (context) => Text(
                                currentUserDisplayName,
                                style: FlutterFlowTheme.of(context).headlineMedium.override(
                                  font: GoogleFonts.interTight(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  color: Colors.white,
                                  letterSpacing: 0.0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              currentUserEmail,
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                font: GoogleFonts.inter(),
                                color: Colors.white.withValues(alpha: 0.9),
                                letterSpacing: 0.0,
                              ),
                            ),
                            const SizedBox(height: 12.0),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 8.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      valueOrDefault(currentUserDocument?.studentIdVerified, false)
                                          ? Icons.verified
                                          : valueOrDefault(currentUserDocument?.verificationStatus, 'incomplete') == 'pending'
                                              ? Icons.pending
                                              : Icons.info_outline,
                                      color: Colors.white,
                                      size: 16.0,
                                    ),
                                    const SizedBox(width: 6.0),
                                    Text(
                                      valueOrDefault(currentUserDocument?.studentIdVerified, false)
                                          ? 'Verified Account'
                                          : valueOrDefault(currentUserDocument?.verificationStatus, 'incomplete') == 'pending'
                                              ? 'Verification Pending'
                                              : 'Account Not Verified',
                                      style: FlutterFlowTheme.of(context).labelMedium.override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                        ),
                                        color: Colors.white,
                                        letterSpacing: 0.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Stats Cards - Real Data
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 0.0),
                      child: StreamBuilder<List<ProductsRecord>>(
                        stream: queryProductsRecord(
                          queryBuilder: (productsRecord) => productsRecord
                              .where('OwnerRef', isEqualTo: currentUserReference),
                        ),
                        builder: (context, productsSnapshot) {
                          final listingsCount = productsSnapshot.data?.length ?? 0;
                          
                          return StreamBuilder<List<ReviewsRecord>>(
                            stream: queryReviewsRecord(
                              queryBuilder: (reviewsRecord) => reviewsRecord
                                  .where('seller_ref', isEqualTo: currentUserReference),
                            ),
                            builder: (context, reviewsSnapshot) {
                              final reviews = reviewsSnapshot.data ?? [];
                              double averageRating = 0.0;
                              if (reviews.isNotEmpty) {
                                final totalRating = reviews.fold<double>(
                                  0.0,
                                  (totalSum, review) => totalSum + review.rating.toDouble(),
                                );
                                averageRating = totalRating / reviews.length;
                              }
                              
                              return Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        context.pushNamed('MyTransactions');
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(16.0),
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context).secondaryBackground,
                                          borderRadius: BorderRadius.circular(12.0),
                                          boxShadow: [
                                            BoxShadow(
                                              blurRadius: 4.0,
                                              color: Colors.black.withValues(alpha: 0.05),
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.shopping_bag_outlined,
                                              color: FlutterFlowTheme.of(context).primary,
                                              size: 28.0,
                                            ),
                                            const SizedBox(height: 8.0),
                                            Text(
                                              listingsCount.toString(),
                                              style: FlutterFlowTheme.of(context).headlineSmall.override(
                                                font: GoogleFonts.interTight(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                letterSpacing: 0.0,
                                              ),
                                            ),
                                            Text(
                                              'Listings',
                                              style: FlutterFlowTheme.of(context).bodySmall.override(
                                                font: GoogleFonts.inter(),
                                                color: FlutterFlowTheme.of(context).secondaryText,
                                                letterSpacing: 0.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12.0),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(16.0),
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context).secondaryBackground,
                                        borderRadius: BorderRadius.circular(12.0),
                                        boxShadow: [
                                          BoxShadow(
                                            blurRadius: 4.0,
                                            color: Colors.black.withValues(alpha: 0.05),
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.star,
                                            color: reviews.isEmpty 
                                                ? FlutterFlowTheme.of(context).secondaryText
                                                : Colors.amber,
                                            size: 28.0,
                                          ),
                                          const SizedBox(height: 8.0),
                                          Text(
                                            reviews.isEmpty 
                                                ? 'N/A' 
                                                : averageRating.toStringAsFixed(1),
                                            style: FlutterFlowTheme.of(context).headlineSmall.override(
                                              font: GoogleFonts.interTight(
                                                fontWeight: FontWeight.bold,
                                              ),
                                              letterSpacing: 0.0,
                                            ),
                                          ),
                                          Text(
                                            reviews.isEmpty 
                                                ? 'No ratings' 
                                                : 'Rating (${reviews.length})',
                                            style: FlutterFlowTheme.of(context).bodySmall.override(
                                              font: GoogleFonts.inter(),
                                              color: FlutterFlowTheme.of(context).secondaryText,
                                              letterSpacing: 0.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                    
                    // Account Information Section
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 0.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Account Information',
                            style: FlutterFlowTheme.of(context).titleLarge.override(
                              font: GoogleFonts.interTight(
                                fontWeight: FontWeight.bold,
                              ),
                              letterSpacing: 0.0,
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).secondaryBackground,
                              borderRadius: BorderRadius.circular(12.0),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 4.0,
                                  color: Colors.black.withValues(alpha: 0.05),
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  _buildInfoRow(
                                    context,
                                    icon: Icons.email_outlined,
                                    label: 'Email',
                                    value: currentUserEmail,
                                  ),
                                  const SizedBox(height: 16.0),
                                  Divider(
                                    height: 1.0,
                                    thickness: 1.0,
                                    color: FlutterFlowTheme.of(context).alternate,
                                  ),
                                  const SizedBox(height: 16.0),
                                  AuthUserStreamWidget(
                                    builder: (context) => _buildInfoRow(
                                      context,
                                      icon: Icons.account_balance_wallet_outlined,
                                      label: 'GCash Number',
                                      value: currentPhoneNumber.isNotEmpty ? currentPhoneNumber : 'Not provided',
                                    ),
                                  ),
                                  const SizedBox(height: 16.0),
                                  Divider(
                                    height: 1.0,
                                    thickness: 1.0,
                                    color: FlutterFlowTheme.of(context).alternate,
                                  ),
                                  const SizedBox(height: 16.0),
                                  AuthUserStreamWidget(
                                    builder: (context) => _buildInfoRow(
                                      context,
                                      icon: Icons.location_on_outlined,
                                      label: 'Address',
                                      value: valueOrDefault(currentUserDocument?.address, 'Not provided'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // ID Verification Section
                          const SizedBox(height: 24.0),
                          AuthUserStreamWidget(
                            builder: (context) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ID Verification',
                                  style: FlutterFlowTheme.of(context).titleLarge.override(
                                    font: GoogleFonts.interTight(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    letterSpacing: 0.0,
                                  ),
                                ),
                                const SizedBox(height: 16.0),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).secondaryBackground,
                                    borderRadius: BorderRadius.circular(12.0),
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 4.0,
                                        color: Colors.black.withValues(alpha: 0.05),
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.verified_user_outlined,
                                              color: FlutterFlowTheme.of(context).primary,
                                              size: 24.0,
                                            ),
                                            const SizedBox(width: 12.0),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Verification Status',
                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                      font: GoogleFonts.inter(
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                      letterSpacing: 0.0,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4.0),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                                                    decoration: BoxDecoration(
                                                      color: valueOrDefault(currentUserDocument?.verificationStatus, 'incomplete') == 'verified'
                                                          ? FlutterFlowTheme.of(context).success.withValues(alpha: 0.1)
                                                          : valueOrDefault(currentUserDocument?.verificationStatus, 'incomplete') == 'pending'
                                                              ? FlutterFlowTheme.of(context).warning.withValues(alpha: 0.1)
                                                              : FlutterFlowTheme.of(context).error.withValues(alpha: 0.1),
                                                      borderRadius: BorderRadius.circular(20.0),
                                                    ),
                                                    child: Text(
                                                      valueOrDefault(currentUserDocument?.verificationStatus, 'incomplete').toUpperCase(),
                                                      style: FlutterFlowTheme.of(context).bodySmall.override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                        color: valueOrDefault(currentUserDocument?.verificationStatus, 'incomplete') == 'verified'
                                                            ? FlutterFlowTheme.of(context).success
                                                            : valueOrDefault(currentUserDocument?.verificationStatus, 'incomplete') == 'pending'
                                                                ? FlutterFlowTheme.of(context).warning
                                                                : FlutterFlowTheme.of(context).error,
                                                        letterSpacing: 0.5,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (valueOrDefault(currentUserDocument?.iDverification, '').isNotEmpty) ...[
                                          const SizedBox(height: 16.0),
                                          Divider(
                                            height: 1.0,
                                            thickness: 1.0,
                                            color: FlutterFlowTheme.of(context).alternate,
                                          ),
                                          const SizedBox(height: 16.0),
                                          Text(
                                            'Uploaded ID',
                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                              font: GoogleFonts.inter(
                                                fontWeight: FontWeight.w500,
                                              ),
                                              letterSpacing: 0.0,
                                            ),
                                          ),
                                          const SizedBox(height: 12.0),
                                          CorsSafeImage(
                                            imageUrl: valueOrDefault(currentUserDocument?.iDverification, ''),
                                            width: double.infinity,
                                            height: 200.0,
                                            fit: BoxFit.cover,
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 24.0),
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              FFButtonWidget(
                                onPressed: () async {
                                  context
                                      .pushNamed(CreateprofileWidget.routeName);
                                },
                                text: 'Edit Profile',
                                icon: const Icon(
                                  Icons.edit,
                                  size: 20.0,
                                ),
                                options: FFButtonOptions(
                                  width: double.infinity,
                                  height: 50.0,
                                  padding: const EdgeInsets.all(8.0),
                                  iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 0.0),
                                  iconColor:
                                      FlutterFlowTheme.of(context).primary,
                                  color: FlutterFlowTheme.of(context).accent1,
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        font: GoogleFonts.interTight(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .titleSmall
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .titleSmall
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontStyle,
                                      ),
                                  elevation: 0.0,
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                              FFButtonWidget(
                                onPressed: () async {
                                  GoRouter.of(context).prepareAuthEvent();
                                  await authManager.signOut();
                                  if (context.mounted) {
                                    GoRouter.of(context).clearRedirectLocation();
                                    context.goNamedAuth(
                                        LoginWidget.routeName, context.mounted);
                                  }
                                },
                                text: 'Logout',
                                icon: const Icon(
                                  Icons.logout,
                                  size: 20.0,
                                ),
                                options: FFButtonOptions(
                                  width: double.infinity,
                                  height: 50.0,
                                  padding: const EdgeInsets.all(8.0),
                                  iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 0.0),
                                  iconColor: FlutterFlowTheme.of(context).error,
                                  color: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        font: GoogleFonts.interTight(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .titleSmall
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .titleSmall
                                                  .fontStyle,
                                        ),
                                        color:
                                            FlutterFlowTheme.of(context).error,
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontStyle,
                                      ),
                                  elevation: 0.0,
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context).error,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                            ].divide(const SizedBox(height: 12.0)),
                          ),
                        ].divide(const SizedBox(height: 16.0)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: BottomNavBar(currentRoute: ProfileWidget.routeName),
          ),
        );
          },
        );
      },
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          width: 40.0,
          height: 40.0,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).accent1,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Icon(
            icon,
            color: FlutterFlowTheme.of(context).primary,
            size: 20.0,
          ),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: FlutterFlowTheme.of(context).labelSmall.override(
                      font: GoogleFonts.inter(),
                      color: FlutterFlowTheme.of(context).secondaryText,
                      letterSpacing: 0.0,
                    ),
              ),
              const SizedBox(height: 4.0),
              Text(
                value,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                      ),
                      letterSpacing: 0.0,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdminProfile(BuildContext context) {
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
          automaticallyImplyLeading: true,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: FlutterFlowTheme.of(context).primaryText,
              size: 30.0,
            ),
            onPressed: () async {
              context.goNamed(AdminDashboardWidget.routeName);
            },
          ),
          title: Text(
            'Admin Profile',
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                // Header Section with Profile Picture
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        FlutterFlowTheme.of(context).primary,
                        FlutterFlowTheme.of(context).secondary,
                      ],
                      stops: const [0.0, 1.0],
                      begin: const AlignmentDirectional(-1.0, -1.0),
                      end: const AlignmentDirectional(1.0, 1.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(24.0, 32.0, 24.0, 32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 120.0,
                          height: 120.0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 4.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 20.0,
                                color: Colors.black.withValues(alpha: 0.2),
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: AuthUserStreamWidget(
                            builder: (context) => CorsSafeImage(
                              imageUrl: valueOrDefault<String>(
                                currentUserPhoto,
                                'https://cdn-icons-png.flaticon.com/512/8847/8847419.png',
                              ),
                              width: 120.0,
                              height: 120.0,
                              fit: BoxFit.cover,
                              borderRadius: BorderRadius.circular(60.0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        AuthUserStreamWidget(
                          builder: (context) => Text(
                            currentUserDisplayName,
                            style: FlutterFlowTheme.of(context).headlineMedium.override(
                              font: GoogleFonts.interTight(
                                fontWeight: FontWeight.bold,
                              ),
                              color: Colors.white,
                              letterSpacing: 0.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          currentUserEmail,
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(),
                            color: Colors.white.withValues(alpha: 0.9),
                            letterSpacing: 0.0,
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 8.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.admin_panel_settings,
                                  color: Colors.white,
                                  size: 16.0,
                                ),
                                const SizedBox(width: 6.0),
                                Text(
                                  'Administrator',
                                  style: FlutterFlowTheme.of(context).labelMedium.override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    color: Colors.white,
                                    letterSpacing: 0.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Account Information Section
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 0.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account Information',
                        style: FlutterFlowTheme.of(context).titleLarge.override(
                          font: GoogleFonts.interTight(
                            fontWeight: FontWeight.bold,
                          ),
                          letterSpacing: 0.0,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 4.0,
                              color: Colors.black.withValues(alpha: 0.05),
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              _buildInfoRow(
                                context,
                                icon: Icons.email_outlined,
                                label: 'Email',
                                value: currentUserEmail,
                              ),
                              const SizedBox(height: 16.0),
                              Divider(
                                height: 1.0,
                                thickness: 1.0,
                                color: FlutterFlowTheme.of(context).alternate,
                              ),
                              const SizedBox(height: 16.0),
                              AuthUserStreamWidget(
                                builder: (context) => _buildInfoRow(
                                  context,
                                  icon: Icons.phone_outlined,
                                  label: 'Phone',
                                  value: currentPhoneNumber.isNotEmpty ? currentPhoneNumber : 'Not provided',
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              Divider(
                                height: 1.0,
                                thickness: 1.0,
                                color: FlutterFlowTheme.of(context).alternate,
                              ),
                              const SizedBox(height: 16.0),
                              _buildInfoRow(
                                context,
                                icon: Icons.shield_outlined,
                                label: 'Role',
                                value: 'Administrator',
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24.0),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          FFButtonWidget(
                            onPressed: () async {
                              context.pushNamed(CreateprofileWidget.routeName);
                            },
                            text: 'Edit Profile',
                            icon: const Icon(
                              Icons.edit,
                              size: 20.0,
                            ),
                            options: FFButtonOptions(
                              width: double.infinity,
                              height: 50.0,
                              padding: const EdgeInsets.all(8.0),
                              iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 0.0),
                              iconColor:
                                  FlutterFlowTheme.of(context).primary,
                              color: FlutterFlowTheme.of(context).accent1,
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    font: GoogleFonts.interTight(
                                      fontWeight:
                                          FlutterFlowTheme.of(context)
                                              .titleSmall
                                              .fontWeight,
                                      fontStyle:
                                          FlutterFlowTheme.of(context)
                                              .titleSmall
                                              .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context)
                                        .primary,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontStyle,
                                  ),
                              elevation: 0.0,
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          FFButtonWidget(
                            onPressed: () async {
                              context.goNamed(AdminDashboardWidget.routeName);
                            },
                            text: 'Back to Dashboard',
                            icon: const Icon(
                              Icons.dashboard,
                              size: 20.0,
                            ),
                            options: FFButtonOptions(
                              width: double.infinity,
                              height: 50.0,
                              padding: const EdgeInsets.all(8.0),
                              iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 0.0),
                              iconColor:
                                  FlutterFlowTheme.of(context).secondaryText,
                              color: FlutterFlowTheme.of(context).secondaryBackground,
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    font: GoogleFonts.interTight(
                                      fontWeight:
                                          FlutterFlowTheme.of(context)
                                              .titleSmall
                                              .fontWeight,
                                      fontStyle:
                                          FlutterFlowTheme.of(context)
                                              .titleSmall
                                              .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontStyle,
                                  ),
                              elevation: 0.0,
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).alternate,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          FFButtonWidget(
                            onPressed: () async {
                              GoRouter.of(context).prepareAuthEvent();
                              await authManager.signOut();
                              if (context.mounted) {
                                GoRouter.of(context).clearRedirectLocation();
                                context.goNamedAuth(
                                    LoginWidget.routeName, context.mounted);
                              }
                            },
                            text: 'Logout',
                            icon: const Icon(
                              Icons.logout,
                              size: 20.0,
                            ),
                            options: FFButtonOptions(
                              width: double.infinity,
                              height: 50.0,
                              padding: const EdgeInsets.all(8.0),
                              iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 0.0),
                              iconColor: FlutterFlowTheme.of(context).error,
                              color: FlutterFlowTheme.of(context)
                                  .primaryBackground,
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    font: GoogleFonts.interTight(
                                      fontWeight:
                                          FlutterFlowTheme.of(context)
                                              .titleSmall
                                              .fontWeight,
                                      fontStyle:
                                          FlutterFlowTheme.of(context)
                                              .titleSmall
                                              .fontStyle,
                                    ),
                                    color:
                                        FlutterFlowTheme.of(context).error,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontStyle,
                                  ),
                              elevation: 0.0,
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).error,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ].divide(const SizedBox(height: 12.0)),
                      ),
                    ].divide(const SizedBox(height: 16.0)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeratorProfile(BuildContext context) {
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
          automaticallyImplyLeading: true,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: FlutterFlowTheme.of(context).primaryText,
              size: 30.0,
            ),
            onPressed: () async {
              context.goNamed(ModeratorDashboardWidget.routeName);
            },
          ),
          title: Text(
            'Moderator Profile',
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                // Header Section with Profile Picture
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        FlutterFlowTheme.of(context).secondary,
                        FlutterFlowTheme.of(context).tertiary,
                      ],
                      stops: const [0.0, 1.0],
                      begin: const AlignmentDirectional(-1.0, -1.0),
                      end: const AlignmentDirectional(1.0, 1.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(24.0, 32.0, 24.0, 32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 120.0,
                          height: 120.0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 4.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 20.0,
                                color: Colors.black.withValues(alpha: 0.2),
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: AuthUserStreamWidget(
                            builder: (context) => CorsSafeImage(
                              imageUrl: valueOrDefault<String>(
                                currentUserPhoto,
                                'https://cdn-icons-png.flaticon.com/512/8847/8847419.png',
                              ),
                              width: 120.0,
                              height: 120.0,
                              fit: BoxFit.cover,
                              borderRadius: BorderRadius.circular(60.0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        AuthUserStreamWidget(
                          builder: (context) => Text(
                            currentUserDisplayName,
                            style: FlutterFlowTheme.of(context).headlineMedium.override(
                              font: GoogleFonts.interTight(
                                fontWeight: FontWeight.bold,
                              ),
                              color: Colors.white,
                              letterSpacing: 0.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          currentUserEmail,
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(),
                            color: Colors.white.withValues(alpha: 0.9),
                            letterSpacing: 0.0,
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 8.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.shield_outlined,
                                  color: Colors.white,
                                  size: 16.0,
                                ),
                                const SizedBox(width: 6.0),
                                Text(
                                  'Moderator',
                                  style: FlutterFlowTheme.of(context).labelMedium.override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    color: Colors.white,
                                    letterSpacing: 0.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Account Information Section
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 0.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account Information',
                        style: FlutterFlowTheme.of(context).titleLarge.override(
                          font: GoogleFonts.interTight(
                            fontWeight: FontWeight.bold,
                          ),
                          letterSpacing: 0.0,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 4.0,
                              color: Colors.black.withValues(alpha: 0.05),
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              _buildInfoRow(
                                context,
                                icon: Icons.email_outlined,
                                label: 'Email',
                                value: currentUserEmail,
                              ),
                              const SizedBox(height: 16.0),
                              Divider(
                                height: 1.0,
                                thickness: 1.0,
                                color: FlutterFlowTheme.of(context).alternate,
                              ),
                              const SizedBox(height: 16.0),
                              AuthUserStreamWidget(
                                builder: (context) => _buildInfoRow(
                                  context,
                                  icon: Icons.phone_outlined,
                                  label: 'Phone',
                                  value: currentPhoneNumber.isNotEmpty ? currentPhoneNumber : 'Not provided',
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              Divider(
                                height: 1.0,
                                thickness: 1.0,
                                color: FlutterFlowTheme.of(context).alternate,
                              ),
                              const SizedBox(height: 16.0),
                              _buildInfoRow(
                                context,
                                icon: Icons.shield_outlined,
                                label: 'Role',
                                value: 'Moderator',
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24.0),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          FFButtonWidget(
                            onPressed: () async {
                              context.pushNamed(CreateprofileWidget.routeName);
                            },
                            text: 'Edit Profile',
                            icon: const Icon(
                              Icons.edit,
                              size: 20.0,
                            ),
                            options: FFButtonOptions(
                              width: double.infinity,
                              height: 50.0,
                              padding: const EdgeInsets.all(8.0),
                              iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 0.0),
                              iconColor:
                                  FlutterFlowTheme.of(context).secondary,
                              color: FlutterFlowTheme.of(context).accent2,
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    font: GoogleFonts.interTight(
                                      fontWeight:
                                          FlutterFlowTheme.of(context)
                                              .titleSmall
                                              .fontWeight,
                                      fontStyle:
                                          FlutterFlowTheme.of(context)
                                              .titleSmall
                                              .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context)
                                        .secondary,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontStyle,
                                  ),
                              elevation: 0.0,
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          FFButtonWidget(
                            onPressed: () async {
                              context.goNamed(ModeratorDashboardWidget.routeName);
                            },
                            text: 'Back to Dashboard',
                            icon: const Icon(
                              Icons.dashboard,
                              size: 20.0,
                            ),
                            options: FFButtonOptions(
                              width: double.infinity,
                              height: 50.0,
                              padding: const EdgeInsets.all(8.0),
                              iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 0.0),
                              iconColor:
                                  FlutterFlowTheme.of(context).secondaryText,
                              color: FlutterFlowTheme.of(context).secondaryBackground,
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    font: GoogleFonts.interTight(
                                      fontWeight:
                                          FlutterFlowTheme.of(context)
                                              .titleSmall
                                              .fontWeight,
                                      fontStyle:
                                          FlutterFlowTheme.of(context)
                                              .titleSmall
                                              .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontStyle,
                                  ),
                              elevation: 0.0,
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).alternate,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          FFButtonWidget(
                            onPressed: () async {
                              GoRouter.of(context).prepareAuthEvent();
                              await authManager.signOut();
                              if (context.mounted) {
                                GoRouter.of(context).clearRedirectLocation();
                                context.goNamedAuth(
                                    LoginWidget.routeName, context.mounted);
                              }
                            },
                            text: 'Logout',
                            icon: const Icon(
                              Icons.logout,
                              size: 20.0,
                            ),
                            options: FFButtonOptions(
                              width: double.infinity,
                              height: 50.0,
                              padding: const EdgeInsets.all(8.0),
                              iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 0.0),
                              iconColor: FlutterFlowTheme.of(context).error,
                              color: FlutterFlowTheme.of(context)
                                  .primaryBackground,
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    font: GoogleFonts.interTight(
                                      fontWeight:
                                          FlutterFlowTheme.of(context)
                                              .titleSmall
                                              .fontWeight,
                                      fontStyle:
                                          FlutterFlowTheme.of(context)
                                              .titleSmall
                                              .fontStyle,
                                    ),
                                    color:
                                        FlutterFlowTheme.of(context).error,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontStyle,
                                  ),
                              elevation: 0.0,
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).error,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ].divide(const SizedBox(height: 12.0)),
                      ),
                    ].divide(const SizedBox(height: 16.0)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPublicProfileView(BuildContext context, UsersRecord profileUser) {
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
          automaticallyImplyLeading: true,
          title: Text(
            profileUser.displayName,
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.interTight(
                    fontWeight: FontWeight.bold,
                  ),
                  color: FlutterFlowTheme.of(context).primaryText,
                  fontSize: 24,
                  letterSpacing: -0.5,
                ),
          ),
          centerTitle: true,
          elevation: 0.5,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                // Header Section with Profile Picture
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        FlutterFlowTheme.of(context).primary,
                        FlutterFlowTheme.of(context).secondary,
                      ],
                      stops: const [0.0, 1.0],
                      begin: const AlignmentDirectional(-1.0, -1.0),
                      end: const AlignmentDirectional(1.0, 1.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(24.0, 32.0, 24.0, 32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 120.0,
                          height: 120.0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 4.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 20.0,
                                color: Colors.black.withValues(alpha: 0.2),
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: CorsSafeImage(
                            imageUrl: profileUser.photoUrl.isNotEmpty
                                ? profileUser.photoUrl
                                : 'https://cdn-icons-png.flaticon.com/512/8847/8847419.png',
                            width: 120.0,
                            height: 120.0,
                            fit: BoxFit.cover,
                            borderRadius: BorderRadius.circular(60.0),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Text(
                          profileUser.displayName,
                          style: FlutterFlowTheme.of(context).headlineMedium.override(
                                font: GoogleFonts.interTight(
                                  fontWeight: FontWeight.bold,
                                ),
                                color: Colors.white,
                                letterSpacing: 0.0,
                              ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          profileUser.email,
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                font: GoogleFonts.inter(),
                                color: Colors.white.withValues(alpha: 0.9),
                                letterSpacing: 0.0,
                              ),
                        ),
                        const SizedBox(height: 12.0),
                        // Verification status badge
                        Builder(
                          builder: (context) {
                            final isVerified = profileUser.studentIdVerified == true ||
                                profileUser.verificationStatus.toLowerCase() == 'verified';
                            final isPending = profileUser.verificationStatus.toLowerCase() == 'pending';
                            final isNotVerified = !isVerified && !isPending;

                            if (isVerified) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).secondaryBackground,
                                  borderRadius: BorderRadius.circular(24.0),
                                  border: Border.all(
                                    color: FlutterFlowTheme.of(context).success,
                                    width: 2.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: FlutterFlowTheme.of(context).primaryText.withValues(alpha: 0.1),
                                      blurRadius: 4.0,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.verified,
                                      color: FlutterFlowTheme.of(context).success,
                                      size: 18.0,
                                    ),
                                    const SizedBox(width: 6.0),
                                    Text(
                                      'Verified Account',
                                      style: FlutterFlowTheme.of(context).bodySmall.override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            color: FlutterFlowTheme.of(context).success,
                                            fontSize: 13.0,
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                  ],
                                ),
                              );
                            } else if (isPending) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).secondaryBackground,
                                  borderRadius: BorderRadius.circular(24.0),
                                  border: Border.all(
                                    color: FlutterFlowTheme.of(context).warning,
                                    width: 2.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: FlutterFlowTheme.of(context).primaryText.withValues(alpha: 0.1),
                                      blurRadius: 4.0,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.pending_outlined,
                                      color: FlutterFlowTheme.of(context).warning,
                                      size: 18.0,
                                    ),
                                    const SizedBox(width: 6.0),
                                    Text(
                                      'Verification Pending',
                                      style: FlutterFlowTheme.of(context).bodySmall.override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            color: FlutterFlowTheme.of(context).warning,
                                            fontSize: 13.0,
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                  ],
                                ),
                              );
                            } else if (isNotVerified) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).secondaryBackground,
                                  borderRadius: BorderRadius.circular(24.0),
                                  border: Border.all(
                                    color: FlutterFlowTheme.of(context).error,
                                    width: 2.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: FlutterFlowTheme.of(context).primaryText.withValues(alpha: 0.1),
                                      blurRadius: 4.0,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.cancel_outlined,
                                      color: FlutterFlowTheme.of(context).error,
                                      size: 18.0,
                                    ),
                                    const SizedBox(width: 6.0),
                                    Text(
                                      'Not Verified',
                                      style: FlutterFlowTheme.of(context).bodySmall.override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            color: FlutterFlowTheme.of(context).error,
                                            fontSize: 13.0,
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // User Listings Section
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 0.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Listings',
                        style: FlutterFlowTheme.of(context).titleLarge.override(
                              font: GoogleFonts.interTight(
                                fontWeight: FontWeight.bold,
                              ),
                              letterSpacing: 0.0,
                            ),
                      ),
                      const SizedBox(height: 16.0),
                      StreamBuilder<List<ProductsRecord>>(
                        stream: queryProductsRecord(
                          queryBuilder: (productsRecord) => productsRecord
                              .where('OwnerRef', isEqualTo: profileUser.reference)
                              .orderBy('created_at', descending: true),
                        ),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    FlutterFlowTheme.of(context).primary,
                                  ),
                                ),
                              ),
                            );
                          }
                          final products = snapshot.data!;
                          if (products.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.inventory_2_outlined,
                                      size: 48.0,
                                      color: FlutterFlowTheme.of(context).secondaryText,
                                    ),
                                    const SizedBox(height: 12.0),
                                    Text(
                                      'No listings yet',
                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                            font: GoogleFonts.inter(),
                                            color: FlutterFlowTheme.of(context).secondaryText,
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: InkWell(
                                  onTap: () {
                                    context.pushNamed(
                                      ItemPageWidget.routeName,
                                      queryParameters: {
                                        'para': serializeParam(
                                          product.reference,
                                          ParamType.DocumentReference,
                                        ),
                                      }.withoutNulls,
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context).secondaryBackground,
                                      borderRadius: BorderRadius.circular(12.0),
                                      border: Border.all(
                                        color: FlutterFlowTheme.of(context).alternate,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(8.0),
                                            child: CachedNetworkImage(
                                              imageUrl: product.photo,
                                              width: 80.0,
                                              height: 80.0,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 0.0, 0.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    product.name,
                                                    style: FlutterFlowTheme.of(context).titleMedium.override(
                                                          font: GoogleFonts.interTight(
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                          letterSpacing: 0.0,
                                                        ),
                                                  ),
                                                  const SizedBox(height: 4.0),
                                                  Text(
                                                    '${formatPrice(product.price)} • ${product.sellRent}',
                                                    style: FlutterFlowTheme.of(context).bodySmall.override(
                                                          font: GoogleFonts.inter(),
                                                          color: FlutterFlowTheme.of(context).primary,
                                                          letterSpacing: 0.0,
                                                        ),
                                                  ),
                                                  const SizedBox(height: 4.0),
                                                  Text(
                                                    'Available: ${product.quantity} ${product.quantity == 1 ? 'item' : 'items'}',
                                                    style: FlutterFlowTheme.of(context).bodySmall.override(
                                                          font: GoogleFonts.inter(),
                                                          color: FlutterFlowTheme.of(context).secondaryText,
                                                          letterSpacing: 0.0,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            Icons.chevron_right,
                                            color: FlutterFlowTheme.of(context).secondaryText,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
