import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/firebase_storage/storage.dart';
import '/components/bottom_nav_bar.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'sell_model.dart';
export 'sell_model.dart';

class SellWidget extends StatefulWidget {
  const SellWidget({super.key});

  static String routeName = 'sell';
  static String routePath = '/sell';

  @override
  State<SellWidget> createState() => _SellWidgetState();
}

class _SellWidgetState extends State<SellWidget> {
  late SellModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SellModel());
    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();
    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();
    _model.textController4 ??= TextEditingController();
    _model.textFieldFocusNode3 ??= FocusNode();
    _model.textController5 ??= TextEditingController(text: '1');
    _model.textFieldFocusNode4 ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UsersRecord>(
      stream: currentUserReference != null ? UsersRecord.getDocument(currentUserReference!) : null,
      builder: (context, snapshot) {
        // Check if profile is complete: ID verified AND basic fields filled
        final isProfileComplete = snapshot.hasData 
            ? snapshot.data!.studentIdVerified == true &&
              snapshot.data!.displayName.isNotEmpty &&
              snapshot.data!.phoneNumber.isNotEmpty &&
              snapshot.data!.address.isNotEmpty
            : false;

        // If profile is not complete, redirect and show message
        if (!isProfileComplete && snapshot.hasData) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              final user = snapshot.data!;
              String message = 'Please complete your profile to sell or rent items.';
              
              if (user.studentIdVerified != true) {
                message = 'Your student ID verification is pending approval from admin.';
              } else if (user.displayName.isEmpty) {
                message = 'Please complete your name in the profile.';
              } else if (user.phoneNumber.isEmpty) {
                message = 'Please add your GCash number in the profile.';
              } else if (user.address.isEmpty) {
                message = 'Please add your address in the profile.';
              }
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
              context.safePop();
            }
          });
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
          leading: FlutterFlowIconButton(
            borderRadius: 20.0,
            buttonSize: 40.0,
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
            'Sell or Rent Item',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                  color: FlutterFlowTheme.of(context).primaryText,
                  fontSize: 20,
                  letterSpacing: -0.5,
                ),
          ),
          actions: const [],
          centerTitle: true,
          elevation: 0.5,
        ),
        body: SafeArea(
          top: true,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth > 600 ? 600.0 : constraints.maxWidth;
              
              return Center(
                child: Container(
                  width: maxWidth,
                  padding: EdgeInsets.symmetric(
                    horizontal: constraints.maxWidth > 600 ? 24.0 : 16.0,
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _model.formKey,
                      autovalidateMode: AutovalidateMode.disabled,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          
                          // Upload Images Section
                          _buildSectionTitle('Upload Image'),
                          const SizedBox(height: 12),
                          _buildImageUploader(),
                          const SizedBox(height: 24),
                          
                          // Item Details Section
                          _buildSectionTitle('Item Details'),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _model.textController1,
                            focusNode: _model.textFieldFocusNode1,
                            hint: 'Item Name',
                            validator: _model.textController1Validator,
                            minChars: 3,
                            maxChars: 100,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _model.textController2,
                            focusNode: _model.textFieldFocusNode2,
                            hint: 'Description',
                            maxLines: 4,
                            minLines: 3,
                            validator: _model.textController2Validator,
                            minChars: 10,
                            maxChars: 200,
                          ),
                          const SizedBox(height: 16),
                          _buildDropdown(
                            value: _model.categoryValue,
                            hint: 'Select Category',
                            options: ['Books', 'Gadgets', 'Uniforms', 'Dorm Essentials', 'Others'],
                            onChanged: (val) => setState(() => _model.categoryValue = val),
                          ),
                          const SizedBox(height: 16),
                          _buildDropdown(
                            value: _model.conditionValue,
                            hint: 'Select Condition',
                            options: ['New', 'Like New', 'Used'],
                            onChanged: (val) => setState(() => _model.conditionValue = val),
                          ),
                          const SizedBox(height: 24),
                          
                          // Listing Type Section
                          _buildSectionTitle('Listing Type'),
                          const SizedBox(height: 12),
                          _buildDropdown(
                            value: _model.sellrentValue,
                            hint: 'Select Type',
                            options: ['Sell', 'Rent'],
                            onChanged: (val) => setState(() => _model.sellrentValue = val),
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _model.textController4,
                            focusNode: _model.textFieldFocusNode3,
                            hint: _model.sellrentValue == 'Rent' ? 'Rental Price (₱)' : 'Price (₱)',
                            keyboardType: TextInputType.number,
                            validator: _model.textController4Validator,
                          ),
                          const SizedBox(height: 16),
                          _buildQuantityField(),
                          const SizedBox(height: 32),
                          
                          // Submit Button
                          _buildSubmitButton(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: BottomNavBar(
          currentRoute: SellWidget.routeName,
          isProfileComplete: isProfileComplete,
        ),
      ),
    );
    },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: FlutterFlowTheme.of(context).titleMedium.override(
            font: GoogleFonts.interTight(fontWeight: FontWeight.w600),
            letterSpacing: 0.0,
          ),
    );
  }

  Widget _buildImageUploader() {
    return Container(
      width: double.infinity,
      height: 200.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
          width: 2.0,
        ),
      ),
      child: Stack(
        children: [
          InkWell(
            onTap: _isUploading ? null : () async {
              setState(() => _isUploading = true);
              
              final selectedMedia = await selectMedia(
                includeBlurHash: true,
                mediaSource: MediaSource.photoGallery,
                multiImage: false,
              );
              
              if (selectedMedia != null &&
                  selectedMedia.every((m) => validateFileFormat(m.storagePath, context))) {
                
                // Check file size before uploading
                const maxSize = 5 * 1024 * 1024; // 5MB
                final largeFiles = selectedMedia.where((m) => m.bytes.length > maxSize).toList();
                
                if (largeFiles.isNotEmpty) {
                  setState(() => _isUploading = false);
                  if (mounted) {
                    final fileSizeMB = (largeFiles.first.bytes.length / (1024 * 1024)).toStringAsFixed(2);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('File size ($fileSizeMB MB) exceeds the 5MB limit. Please select a smaller file.'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                  return;
                }
                
                var selectedUploadedFiles = <FFUploadedFile>[];
                var downloadUrls = <String>[];
                
                try {
                  // Show upload progress
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Uploading image...'),
                        duration: Duration(seconds: 30),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  }
                  
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
                      (m) async => await uploadData(m.storagePath, m.bytes),
                    ),
                  ))
                      .where((u) => u != null)
                      .map((u) => u!)
                      .toList();
                  
                  // Hide upload progress
                  if (mounted) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  }
                } catch (e) {
                  setState(() => _isUploading = false);
                  if (mounted) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to upload image: ${e.toString()}'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                  return;
                }
                
                if (selectedUploadedFiles.length == selectedMedia.length &&
                    downloadUrls.length == selectedMedia.length) {
                  setState(() {
                    _model.uploadedLocalFile_uploadproductimage = selectedUploadedFiles.first;
                    _model.uploadedFileUrl_uploadproductimage = downloadUrls.first;
                    _isUploading = false;
                  });
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Image uploaded successfully!')),
                    );
                  }
                } else {
                  setState(() => _isUploading = false);
                }
              } else {
                setState(() => _isUploading = false);
              }
            },
            child: _model.uploadedLocalFile_uploadproductimage.bytes != null &&
                    _model.uploadedLocalFile_uploadproductimage.bytes!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.memory(
                      _model.uploadedLocalFile_uploadproductimage.bytes!,
                      width: double.infinity,
                      height: 200.0,
                      fit: BoxFit.cover,
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          color: FlutterFlowTheme.of(context).secondaryText,
                          size: 48.0,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tap to upload image',
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                font: GoogleFonts.inter(),
                                color: FlutterFlowTheme.of(context).secondaryText,
                                letterSpacing: 0.0,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Max size: 5MB',
                          style: FlutterFlowTheme.of(context).bodySmall.override(
                                font: GoogleFonts.inter(),
                                color: FlutterFlowTheme.of(context).secondaryText,
                                fontSize: 11,
                                letterSpacing: 0.0,
                              ),
                        ),
                      ],
                    ),
                  ),
          ),
          if (_isUploading)
            Container(
              width: double.infinity,
              height: 200.0,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        FlutterFlowTheme.of(context).primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Uploading...',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(),
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
    );
  }

  Widget _buildTextField({
    required TextEditingController? controller,
    required FocusNode? focusNode,
    required String hint,
    int maxLines = 1,
    int? minLines,
    TextInputType? keyboardType,
    String? Function(BuildContext, String?)? validator,
    int? minChars,
    int? maxChars,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            autofocus: false,
            obscureText: false,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(),
                    color: FlutterFlowTheme.of(context).secondaryText,
                    letterSpacing: 0.0,
                  ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: FlutterFlowTheme.of(context).alternate,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: FlutterFlowTheme.of(context).primary,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: FlutterFlowTheme.of(context).error,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: FlutterFlowTheme.of(context).error,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              filled: true,
              fillColor: FlutterFlowTheme.of(context).secondaryBackground,
              contentPadding: const EdgeInsets.all(16.0),
            ),
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(),
                  color: FlutterFlowTheme.of(context).primaryText,
                  letterSpacing: 0.0,
                ),
            maxLines: maxLines,
            minLines: minLines,
            keyboardType: keyboardType,
            cursorColor: FlutterFlowTheme.of(context).primary,
            validator: validator?.asValidator(context),
            onChanged: (_) => setState(() {}), // Trigger rebuild for character count
            maxLength: maxChars,
            buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null, // Hide default counter
          ),
        ),
        if (minChars != null || maxChars != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 4.0),
            child: Builder(
              builder: (context) {
                final text = controller?.text ?? '';
                final length = text.length;
                final isValid = (minChars == null || length >= minChars) &&
                    (maxChars == null || length <= maxChars);
                
                return Text(
                  '$length / $maxChars${minChars != null ? ' (min: $minChars)' : ''}',
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        font: GoogleFonts.inter(),
                        color: isValid
                            ? FlutterFlowTheme.of(context).secondaryText
                            : FlutterFlowTheme.of(context).error,
                        letterSpacing: 0.0,
                      ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildQuantityField() {
    final quantityText = _model.textController5?.text ?? '';
    final quantity = int.tryParse(quantityText.trim());
    final isValid = quantity != null && quantity >= 1 && quantity <= 9999;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Row(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 18.0,
              color: FlutterFlowTheme.of(context).primaryText,
            ),
            const SizedBox(width: 8.0),
            Text(
              'Available Stock Quantity',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                    ),
                    color: FlutterFlowTheme.of(context).primaryText,
                    letterSpacing: 0.0,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12.0),
        // Input Field with Increment/Decrement Buttons
        Row(
          children: [
            // Decrement Button
            Container(
              width: 48.0,
              height: 56.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  bottomLeft: Radius.circular(8.0),
                ),
                border: Border.all(
                  color: FlutterFlowTheme.of(context).alternate,
                  width: 1.0,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    final current = int.tryParse(quantityText.trim()) ?? 1;
                    final newValue = (current > 1) ? current - 1 : 1;
                    _model.textController5?.text = newValue.toString();
                    setState(() {});
                  },
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    bottomLeft: Radius.circular(8.0),
                  ),
                  child: Icon(
                    Icons.remove,
                    color: FlutterFlowTheme.of(context).primaryText,
                    size: 20.0,
                  ),
                ),
              ),
            ),
            // Quantity Input
            Expanded(
              child: SizedBox(
                height: 56.0,
                child: TextFormField(
                  controller: _model.textController5,
                  focusNode: _model.textFieldFocusNode4,
                  autofocus: false,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: 'Enter quantity',
                    hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.inter(),
                          color: FlutterFlowTheme.of(context).secondaryText,
                          letterSpacing: 0.0,
                        ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: FlutterFlowTheme.of(context).alternate,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.zero,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: FlutterFlowTheme.of(context).primary,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.zero,
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: FlutterFlowTheme.of(context).error,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.zero,
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: FlutterFlowTheme.of(context).error,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.zero,
                    ),
                    filled: true,
                    fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  ),
                  style: FlutterFlowTheme.of(context).titleMedium.override(
                        font: GoogleFonts.interTight(
                          fontWeight: FontWeight.w600,
                        ),
                        color: FlutterFlowTheme.of(context).primaryText,
                        letterSpacing: 0.0,
                      ),
                  keyboardType: TextInputType.number,
                  cursorColor: FlutterFlowTheme.of(context).primary,
                  validator: _model.textController5Validator?.asValidator(context),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ),
            // Increment Button
            Container(
              width: 48.0,
              height: 56.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8.0),
                  bottomRight: Radius.circular(8.0),
                ),
                border: Border.all(
                  color: FlutterFlowTheme.of(context).alternate,
                  width: 1.0,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    final current = int.tryParse(quantityText.trim()) ?? 1;
                    final newValue = (current < 9999) ? current + 1 : 9999;
                    _model.textController5?.text = newValue.toString();
                    setState(() {});
                  },
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0),
                  ),
                  child: Icon(
                    Icons.add,
                    color: FlutterFlowTheme.of(context).primaryText,
                    size: 20.0,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        // Helper Text and Validation Status
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Row(
            children: [
              Icon(
                isValid
                    ? Icons.check_circle_outline
                    : Icons.info_outline,
                size: 14.0,
                color: isValid
                    ? FlutterFlowTheme.of(context).success
                    : FlutterFlowTheme.of(context).secondaryText,
              ),
              const SizedBox(width: 6.0),
              Expanded(
                child: Text(
                  isValid
                      ? 'Valid quantity: ${quantityText.isNotEmpty ? quantity : '1'} ${quantity == 1 ? 'item' : 'items'} available'
                      : quantityText.isEmpty
                          ? 'Enter the number of items available (1 - 9,999)'
                          : quantity == null
                              ? 'Please enter a valid number'
                              : quantity < 1
                                  ? 'Minimum quantity is 1 item'
                                  : 'Maximum quantity is 9,999 items',
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        font: GoogleFonts.inter(),
                        color: isValid
                            ? FlutterFlowTheme.of(context).success
                            : FlutterFlowTheme.of(context).secondaryText,
                        fontSize: 12.0,
                        letterSpacing: 0.0,
                      ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> options,
    required Function(String?) onChanged,
  }) {
    return Container(
      width: double.infinity,
      height: 56.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
          width: 1.0,
        ),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.inter(),
                color: FlutterFlowTheme.of(context).secondaryText,
                letterSpacing: 0.0,
              ),
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          filled: true,
          fillColor: FlutterFlowTheme.of(context).secondaryBackground,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        ),
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: FlutterFlowTheme.of(context).secondaryText,
          size: 24.0,
        ),
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.inter(),
              color: FlutterFlowTheme.of(context).primaryText,
              letterSpacing: 0.0,
            ),
        items: options.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: onChanged,
        dropdownColor: FlutterFlowTheme.of(context).secondaryBackground,
      ),
    );
  }

  Widget _buildSubmitButton() {
    // Check if fields meet character limits and all required fields are filled
    final itemName = _model.textController1?.text ?? '';
    final description = _model.textController2?.text ?? '';
    final quantity = _model.textController5?.text ?? '';
    final itemNameValid = itemName.length >= 3 && itemName.length <= 100;
    final descriptionValid = description.length >= 10 && description.length <= 200;
    final quantityValid = quantity.isNotEmpty && (int.tryParse(quantity) ?? 0) >= 1 && (int.tryParse(quantity) ?? 0) <= 9999;
    final hasCategory = _model.categoryValue != null;
    final hasCondition = _model.conditionValue != null;
    final hasSellRent = _model.sellrentValue != null;
    final hasImage = _model.uploadedFileUrl_uploadproductimage.isNotEmpty;
    final isFormValid = itemNameValid && 
        descriptionValid && 
        quantityValid &&
        hasCategory && 
        hasCondition && 
        hasSellRent && 
        hasImage;

    return FFButtonWidget(
      onPressed: isFormValid ? () async {
        if (_model.formKey.currentState == null ||
            !_model.formKey.currentState!.validate()) {
          return;
        }
        if (_model.categoryValue == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a category')),
          );
          return;
        }
        if (_model.conditionValue == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a condition')),
          );
          return;
        }
        if (_model.sellrentValue == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select listing type')),
          );
          return;
        }
        if (_model.uploadedFileUrl_uploadproductimage.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please upload an image')),
          );
          return;
        }

        await ProductsRecord.collection.doc().set(createProductsRecordData(
              name: _model.textController1.text,
              description: _model.textController2.text,
              price: double.tryParse(_model.textController4.text),
              createdAt: getCurrentTimestamp,
              modifiedAt: getCurrentTimestamp,
              quantity: int.tryParse(_model.textController5.text) ?? 1,
              photo: _model.uploadedFileUrl_uploadproductimage,
              isFeatured: false,
              ownerRef: currentUserReference,
              sellRent: _model.sellrentValue,
              catergories: _model.categoryValue,
              condition: _model.conditionValue,
            ));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item posted successfully!')),
          );
          
          context.pushNamed('HomepageCopy2Copy');
        }
      } : null,
      text: 'Post Item',
      options: FFButtonOptions(
        width: double.infinity,
        height: 56.0,
        padding: const EdgeInsets.all(0.0),
        iconPadding: const EdgeInsets.all(0.0),
        color: isFormValid
            ? FlutterFlowTheme.of(context).primary
            : FlutterFlowTheme.of(context).alternate,
        textStyle: FlutterFlowTheme.of(context).titleSmall.override(
              font: GoogleFonts.inter(fontWeight: FontWeight.w600),
              color: isFormValid ? Colors.white : FlutterFlowTheme.of(context).secondaryText,
              fontSize: 16,
              letterSpacing: 0.0,
            ),
        elevation: isFormValid ? 3.0 : 0.0,
        borderSide: const BorderSide(
          color: Colors.transparent,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }
}
