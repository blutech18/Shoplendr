import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/firebase_storage/storage.dart';
import '/backend/admin_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import '/index.dart';
import '/pages/moderator/moderator_dashboard_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'createprofile_model.dart';
export 'createprofile_model.dart';

class CreateprofileWidget extends StatefulWidget {
  const CreateprofileWidget({super.key});

  static String routeName = 'Createprofile';
  static String routePath = '/createprofile';

  @override
  State<CreateprofileWidget> createState() => _CreateprofileWidgetState();
}

class _CreateprofileWidgetState extends State<CreateprofileWidget> {
  late CreateprofileModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CreateprofileModel());

    _model.yourNameTextController ??= TextEditingController();
    _model.yourNameFocusNode ??= FocusNode();

    _model.cityTextController ??= TextEditingController();
    _model.cityFocusNode ??= FocusNode();
    
    _model.addressTextController ??= TextEditingController();
    _model.addressFocusNode ??= FocusNode();
    
    // Auto-fill with current user data
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUserData());
  }
  
  Future<void> _loadUserData() async {
    if (currentUserDocument != null) {
      setState(() {
        _model.yourNameTextController?.text = currentUserDisplayName;
        _model.cityTextController?.text = currentPhoneNumber;
        _model.addressTextController?.text = valueOrDefault(currentUserDocument?.address, '');
        _model.uploadedFileUrl_uploadDataSu8 = currentUserPhoto;
        _model.uploadedFileUrl_uploadId = valueOrDefault(currentUserDocument?.iDverification, '');
      });
    }
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthUserStreamWidget(
      builder: (context) => Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: FlutterFlowTheme.of(context).primaryText,
              size: 24.0,
            ),
            onPressed: () async {
              context.safePop();
            },
          ),
          title: Text(
            'Edit Profile',
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
        child: Form(
          key: _model.formKey,
          autovalidateMode: AutovalidateMode.disabled,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(24.0, 16.0, 24.0, 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
              // Profile Picture Section
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 24.0),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () async {
                            final selectedMedia =
                                await selectMediaWithSourceBottomSheet(
                              context: context,
                              allowPhoto: true,
                            );
                            if (selectedMedia != null &&
                                selectedMedia.every((m) =>
                                    validateFileFormat(m.storagePath, context))) {
                              safeSetState(
                                  () => _model.isDataUploading_uploadDataSu8 = true);
                              var selectedUploadedFiles = <FFUploadedFile>[];
                              var downloadUrls = <String>[];
                              try {
                                selectedUploadedFiles = selectedMedia
                                    .map((m) => FFUploadedFile(
                                          name: m.storagePath.split('/').last,
                                          bytes: m.bytes,
                                          height: m.dimensions?.height,
                                          width: m.dimensions?.width,
                                          blurHash: m.blurHash,
                                        ))
                                    .toList();

                                downloadUrls = (await Future.wait(
                                  selectedMedia.map(
                                    (m) async =>
                                        await uploadData(m.storagePath, m.bytes),
                                  ),
                                ))
                                    .where((u) => u != null)
                                    .map((u) => u!)
                                    .toList();
                              } finally {
                                _model.isDataUploading_uploadDataSu8 = false;
                              }
                              if (selectedUploadedFiles.length ==
                                      selectedMedia.length &&
                                  downloadUrls.length == selectedMedia.length) {
                                safeSetState(() {
                                  _model.uploadedLocalFile_uploadDataSu8 =
                                      selectedUploadedFiles.first;
                                  _model.uploadedFileUrl_uploadDataSu8 =
                                      downloadUrls.first;
                                });
                              } else {
                                safeSetState(() {});
                                return;
                              }
                            }
                          },
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                width: 120.0,
                                height: 120.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).accent1,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: FlutterFlowTheme.of(context).primary,
                                    width: 3.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 12.0,
                                      color: Colors.black.withValues(alpha: 0.1),
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(60.0),
                                  child: CachedNetworkImage(
                                    fadeInDuration: const Duration(milliseconds: 300),
                                    fadeOutDuration: const Duration(milliseconds: 300),
                                    imageUrl: valueOrDefault<String>(
                                      _model.uploadedFileUrl_uploadDataSu8.isNotEmpty
                                          ? _model.uploadedFileUrl_uploadDataSu8
                                          : currentUserPhoto,
                                      'https://cdn-icons-png.flaticon.com/512/8847/8847419.png',
                                    ),
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Center(
                                      child: CircularProgressIndicator(
                                        color: FlutterFlowTheme.of(context).primary,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Icon(
                                      Icons.person,
                                      size: 60,
                                      color: FlutterFlowTheme.of(context).secondaryText,
                                    ),
                                  ),
                                ),
                              ),
                              // Camera Icon Button
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 36.0,
                                  height: 36.0,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: FlutterFlowTheme.of(context).secondaryBackground,
                                      width: 3.0,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 18.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Text(
                          'Profile Picture',
                          style: FlutterFlowTheme.of(context).titleMedium.override(
                                font: GoogleFonts.interTight(
                                  fontWeight: FontWeight.w600,
                                ),
                                letterSpacing: 0.0,
                              ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Tap the camera icon to change',
                          style: FlutterFlowTheme.of(context).bodySmall.override(
                                font: GoogleFonts.inter(),
                                color: FlutterFlowTheme.of(context).secondaryText,
                                letterSpacing: 0.0,
                              ),
                        ),
                      ],
                    ),
                  ),
                  
              // Form Fields Section
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Full Name',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(
                              fontWeight: FontWeight.w500,
                            ),
                            letterSpacing: 0.0,
                          ),
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: _model.yourNameTextController,
                      focusNode: _model.yourNameFocusNode,
                      textCapitalization: TextCapitalization.words,
                      obscureText: false,
                      decoration: InputDecoration(
                        hintText: 'Enter your full name',
                        hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.inter(),
                              color: FlutterFlowTheme.of(context).secondaryText,
                              letterSpacing: 0.0,
                            ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: FlutterFlowTheme.of(context).alternate,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: FlutterFlowTheme.of(context).primary,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: FlutterFlowTheme.of(context).error,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: FlutterFlowTheme.of(context).error,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        filled: true,
                        fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                        contentPadding: const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
                      ),
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(),
                            letterSpacing: 0.0,
                          ),
                      validator: _model.yourNameTextControllerValidator.asValidator(context),
                      inputFormatters: [
                        if (!isAndroid && !isiOS)
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            return TextEditingValue(
                              selection: newValue.selection,
                              text: newValue.text.toCapitalization(TextCapitalization.words),
                            );
                          }),
                      ],
                    ),
                  ],
                ),
              ),
              // Phone Number Field
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GCash Number',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(
                              fontWeight: FontWeight.w500,
                            ),
                            letterSpacing: 0.0,
                          ),
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: _model.cityTextController,
                      focusNode: _model.cityFocusNode,
                      obscureText: false,
                      decoration: InputDecoration(
                        hintText: '09XX XXX XXXX (11 digits)',
                        hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.inter(),
                              color: FlutterFlowTheme.of(context).secondaryText,
                              letterSpacing: 0.0,
                            ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: FlutterFlowTheme.of(context).alternate,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: FlutterFlowTheme.of(context).primary,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: FlutterFlowTheme.of(context).error,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: FlutterFlowTheme.of(context).error,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        filled: true,
                        fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                        contentPadding: const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
                      ),
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(),
                            letterSpacing: 0.0,
                          ),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        LengthLimitingTextInputFormatter(11),
                      ],
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'GCash number is required';
                        }
                        if (!RegExp(r'^[0-9]{11}$').hasMatch(val)) {
                          return 'GCash number must be exactly 11 digits';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 4.0),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(4.0, 0.0, 0.0, 0.0),
                      child: Text(
                        'Format: 09XX XXX XXXX (11 digits only, e.g. 09123456789)',
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              font: GoogleFonts.inter(),
                              color: FlutterFlowTheme.of(context).secondaryText,
                              fontSize: 11.0,
                              letterSpacing: 0.0,
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Address Field
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Address',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(
                              fontWeight: FontWeight.w500,
                            ),
                            letterSpacing: 0.0,
                          ),
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: _model.addressTextController,
                      focusNode: _model.addressFocusNode,
                      textCapitalization: TextCapitalization.words,
                      obscureText: false,
                      decoration: InputDecoration(
                        hintText: 'Enter your address',
                        hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.inter(),
                              color: FlutterFlowTheme.of(context).secondaryText,
                              letterSpacing: 0.0,
                            ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: FlutterFlowTheme.of(context).alternate,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: FlutterFlowTheme.of(context).primary,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: FlutterFlowTheme.of(context).error,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: FlutterFlowTheme.of(context).error,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        filled: true,
                        fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                        contentPadding: const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
                      ),
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(),
                            letterSpacing: 0.0,
                          ),
                      maxLines: 3,
                      minLines: 2,
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: FlutterFlowTheme.of(context).alternate,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 8.0,
                      color: Colors.black.withValues(alpha: 0.05),
                      offset: const Offset(0.0, 2.0),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      Row(
                        children: [
                          Container(
                            width: 40.0,
                            height: 40.0,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Icon(
                              Icons.verified_user_outlined,
                              color: FlutterFlowTheme.of(context).primary,
                              size: 20.0,
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Student ID Verification',
                                  style: FlutterFlowTheme.of(context).titleMedium.override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    color: FlutterFlowTheme.of(context).primaryText,
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                  ),
                                ),
                                const SizedBox(height: 2.0),
                                Text(
                                  'Upload a clear photo of your University of Antique ID',
                                  style: FlutterFlowTheme.of(context).bodySmall.override(
                                    font: GoogleFonts.inter(),
                                    color: FlutterFlowTheme.of(context).secondaryText,
                                    fontSize: 12.0,
                                    letterSpacing: 0.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),

                      // Upload Area
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: _model.uploadedFileUrl_uploadId.isNotEmpty
                              ? FlutterFlowTheme.of(context).primaryBackground
                              : FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: _model.uploadedFileUrl_uploadId.isNotEmpty
                                ? FlutterFlowTheme.of(context).primary.withValues(alpha: 0.3)
                                : FlutterFlowTheme.of(context).alternate,
                            width: _model.uploadedFileUrl_uploadId.isNotEmpty ? 2.0 : 1.5,
                          ),
                        ),
                        child: InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: _model.isDataUploading_uploadId ? null : () async {
                            final selectedMedia =
                                await selectMediaWithSourceBottomSheet(
                              context: context,
                              allowPhoto: true,
                            );
                            if (selectedMedia != null &&
                                selectedMedia.every((m) =>
                                    validateFileFormat(
                                        m.storagePath, context)) &&
                                selectedMedia.every((m) => m.bytes.length <= 5 * 1024 * 1024)) { // 5MB limit
                              safeSetState(() => _model
                                  .isDataUploading_uploadId = true);
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
                                          height: m.dimensions?.height,
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
                                _model.isDataUploading_uploadId = false;
                              }
                              if (selectedUploadedFiles.length ==
                                      selectedMedia.length &&
                                  downloadUrls.length ==
                                      selectedMedia.length) {
                                safeSetState(() {
                                  _model.uploadedLocalFile_uploadId =
                                      selectedUploadedFiles.first;
                                  _model.uploadedFileUrl_uploadId =
                                      downloadUrls.first;
                                });
                              } else {
                                safeSetState(() {});
                                return;
                              }
                            } else if (selectedMedia != null && 
                                selectedMedia.any((m) => m.bytes.length > 5 * 1024 * 1024)) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('File size must be less than 5MB'),
                                    backgroundColor: null,
                                  ),
                                );
                              }
                              return;
                            }
                          },
                          child: _model.isDataUploading_uploadId
                              ? Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(20.0, 24.0, 20.0, 24.0),
                                  child: _buildUploadLoadingIndicator(),
                                )
                              : _model.uploadedFileUrl_uploadId.isNotEmpty
                                  ? _buildUploadedFilePreview()
                                  : Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(20.0, 24.0, 20.0, 24.0),
                                      child: _buildUploadPlaceholder(),
                                    ),
                        ),
                      ),

                      // Information Section
                      const SizedBox(height: 16.0),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsetsDirectional.fromSTEB(16.0, 14.0, 16.0, 14.0),
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primaryBackground,
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  size: 16.0,
                                  color: FlutterFlowTheme.of(context).primary,
                                ),
                                const SizedBox(width: 8.0),
                                Text(
                                  'Important Information',
                                  style: FlutterFlowTheme.of(context).bodySmall.override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    color: FlutterFlowTheme.of(context).primaryText,
                                    fontSize: 12.0,
                                    letterSpacing: 0.0,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12.0),
                            _buildRequirementItem(Icons.check_circle, 'ID must be clear and valid University of Antique ID'),
                            _buildRequirementItem(Icons.check_circle, 'File size must not exceed 5MB'),
                            _buildRequirementItem(Icons.check_circle, 'Accepted formats: JPG, PNG, PDF'),
                            _buildRequirementItem(Icons.check_circle, 'All information must be clearly visible'),
                            const SizedBox(height: 8.0),
                            Container(
                              padding: const EdgeInsetsDirectional.fromSTEB(10.0, 8.0, 10.0, 8.0),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  color: Colors.blue.withValues(alpha: 0.2),
                                  width: 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.lock_clock_outlined,
                                    size: 16.0,
                                    color: Colors.blue[700],
                                  ),
                                  const SizedBox(width: 8.0),
                                  Expanded(
                                    child: Text(
                                      'Your ID will be reviewed by an admin before verification is completed.',
                                      style: FlutterFlowTheme.of(context).bodySmall.override(
                                        font: GoogleFonts.inter(),
                                        color: Colors.blue[900],
                                        fontSize: 11.0,
                                        letterSpacing: 0.0,
                                      ).copyWith(height: 1.3),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(0.0, 0.05),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                  child: FFButtonWidget(
                    onPressed: () async {
                      if (_isSaving) return;
                      final fullName = _model.yourNameTextController.text.trim();
                      final phone = _model.cityTextController.text.trim();
                      final address = _model.addressTextController?.text.trim() ?? '';

                      if (fullName.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter your full name.')),
                        );
                        return;
                      }
                      if (phone.isNotEmpty && !RegExp(r'^[0-9]{11}$').hasMatch(phone)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Phone number must be exactly 11 digits (e.g., 09123456789).')),
                        );
                        return;
                      }

                      setState(() => _isSaving = true);
                      try {
                        await currentUserReference!.update(createUsersRecordData(
                          displayName: fullName.isNotEmpty ? fullName : null,
                          phoneNumber: phone.isNotEmpty ? phone : null,
                          address: address.isNotEmpty ? address : null,
                          photoUrl: _model.uploadedFileUrl_uploadDataSu8.isNotEmpty
                              ? _model.uploadedFileUrl_uploadDataSu8
                              : null,
                          profilePicture: _model.uploadedFileUrl_uploadDataSu8.isNotEmpty
                              ? _model.uploadedFileUrl_uploadDataSu8
                              : null,
                          iDverification: _model.uploadedFileUrl_uploadId.isNotEmpty
                              ? _model.uploadedFileUrl_uploadId
                              : null,
                          verificationStatus: _model.uploadedFileUrl_uploadId.isNotEmpty
                              ? 'pending'
                              : 'incomplete',
                          studentIdVerified: false,
                        ));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Profile saved.')),
                          );
                          
                          // Check user role and redirect accordingly
                          if (currentUserReference != null) {
                            final adminUser = await AdminService.getAdminUser(currentUserReference!);
                            
                            if (adminUser != null && adminUser.isActive) {
                              // User has admin panel access
                              if (adminUser.role == AdminService.roleAdmin || 
                                  adminUser.role == AdminService.roleSuperAdmin) {
                                // Redirect to admin dashboard
                                if (context.mounted) {
                                  context.pushNamed(AdminDashboardWidget.routeName);
                                }
                              } else if (adminUser.role == AdminService.roleModerator) {
                                // Redirect to moderator dashboard
                                if (context.mounted) {
                                  context.pushNamed(ModeratorDashboardWidget.routeName);
                                }
                              } else {
                                // Unknown role, redirect to student homepage
                                if (context.mounted) {
                                  context.pushNamed(HomepageCopy2Widget.routeName);
                                }
                              }
                            } else {
                              // Regular student user
                              if (context.mounted) {
                                context.pushNamed(HomepageCopy2Widget.routeName);
                              }
                            }
                          } else {
                            // No user reference, redirect to homepage
                            if (context.mounted) {
                              context.pushNamed(HomepageCopy2Widget.routeName);
                            }
                          }
                        }
                      } finally {
                        if (mounted) setState(() => _isSaving = false);
                      }
                    },
                    text: _isSaving ? 'Saving...' : 'Save Changes',
                    options: FFButtonOptions(
                      width: 270.0,
                      height: 50.0,
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      iconPadding:
                          const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      color: _isSaving ? const Color(0xFF9FA8F7) : const Color(0xFF4B39EF),
                      textStyle:
                          FlutterFlowTheme.of(context).titleMedium.override(
                                font: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.normal,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .fontStyle,
                                ),
                                color: Colors.white,
                                fontSize: 18.0,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.normal,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .titleMedium
                                    .fontStyle,
                              ),
                      elevation: 2.0,
                      borderSide: const BorderSide(
                        color: Colors.transparent,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
              ),
                ],
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildUploadPlaceholder() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64.0,
          height: 64.0,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Icon(
            Icons.cloud_upload_outlined,
            color: FlutterFlowTheme.of(context).primary,
            size: 28.0,
          ),
        ),
        const SizedBox(height: 16.0),
        Text(
          'Tap to upload your student ID',
          style: FlutterFlowTheme.of(context).titleSmall.override(
            font: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
            ),
            color: FlutterFlowTheme.of(context).primaryText,
            fontSize: 14.0,
            letterSpacing: 0.0,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          'Take a photo or select from gallery',
          style: FlutterFlowTheme.of(context).bodySmall.override(
            font: GoogleFonts.inter(),
            color: FlutterFlowTheme.of(context).secondaryText,
            fontSize: 12.0,
            letterSpacing: 0.0,
          ),
        ),
      ],
    );
  }

  Widget _buildUploadLoadingIndicator() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64.0,
          height: 64.0,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: CircularProgressIndicator(
            color: FlutterFlowTheme.of(context).primary,
            strokeWidth: 3.0,
          ),
        ),
        const SizedBox(height: 16.0),
        Text(
          'Uploading ID document...',
          style: FlutterFlowTheme.of(context).titleSmall.override(
            font: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
            ),
            color: FlutterFlowTheme.of(context).primaryText,
            fontSize: 14.0,
            letterSpacing: 0.0,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          'Please wait while we process your file',
          style: FlutterFlowTheme.of(context).bodySmall.override(
            font: GoogleFonts.inter(),
            color: FlutterFlowTheme.of(context).secondaryText,
            fontSize: 12.0,
            letterSpacing: 0.0,
          ),
        ),
      ],
    );
  }

  Widget _buildUploadedFilePreview() {
    return Container(
      width: double.infinity,
      height: 200.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.3),
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 8.0,
            color: Colors.black.withValues(alpha: 0.08),
            offset: const Offset(0.0, 2.0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Image.network(
          _model.uploadedFileUrl_uploadId,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 200.0,
          alignment: Alignment.center,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: double.infinity,
              height: 200.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primaryBackground,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported_outlined,
                    color: FlutterFlowTheme.of(context).secondaryText,
                    size: 48.0,
                  ),
                  const SizedBox(height: 12.0),
                  Text(
                    'Preview not available',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(),
                      color: FlutterFlowTheme.of(context).secondaryText,
                      fontSize: 13.0,
                      letterSpacing: 0.0,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRequirementItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 4.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14.0,
            color: FlutterFlowTheme.of(context).primary,
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              text,
              style: FlutterFlowTheme.of(context).bodySmall.override(
                font: GoogleFonts.inter(),
                color: FlutterFlowTheme.of(context).secondaryText,
                fontSize: 11.5,
                letterSpacing: 0.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
