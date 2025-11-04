import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/firebase_storage/storage.dart';
import '/chat_page/chat_page_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import '/flutter_flow/price_format.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'buy_now_model.dart';
export 'buy_now_model.dart';

class BuyNowWidget extends StatefulWidget {
  const BuyNowWidget({
    super.key,
    required this.productRef,
  });

  final DocumentReference? productRef;

  static String routeName = 'BuyNow';
  static String routePath = '/buyNow';

  @override
  State<BuyNowWidget> createState() => _BuyNowWidgetState();
}

class _BuyNowWidgetState extends State<BuyNowWidget> {
  late BuyNowModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BuyNowModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ProductsRecord>(
      stream: ProductsRecord.getDocument(widget.productRef!),
      builder: (context, snapshot) {
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

        final productRecord = snapshot.data!;

        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            appBar: AppBar(
              backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
              automaticallyImplyLeading: false,
              leading: FlutterFlowIconButton(
                borderColor: Colors.transparent,
                borderRadius: 20.0,
                borderWidth: 1.0,
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
                'Buy Now',
                style: FlutterFlowTheme.of(context).titleLarge.override(
                      font: GoogleFonts.interTight(
                        fontWeight: FontWeight.w600,
                      ),
                      letterSpacing: 0.0,
                    ),
              ),
              centerTitle: true,
              elevation: 0.0,
            ),
            body: SafeArea(
              top: true,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
                  child: Form(
                    key: _model.formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Summary Card
                        Material(
                          color: Colors.transparent,
                          elevation: 2.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: CachedNetworkImage(
                                      fadeInDuration:
                                          const Duration(milliseconds: 0),
                                      fadeOutDuration:
                                          const Duration(milliseconds: 0),
                                      imageUrl: productRecord.photo,
                                      width: 80.0,
                                      height: 80.0,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                          12.0, 0.0, 0.0, 0.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            productRecord.name,
                                            style: FlutterFlowTheme.of(context)
                                                .titleMedium
                                                .override(
                                                  font: GoogleFonts.interTight(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 8.0, 0.0, 0.0),
                                            child: Text(
                                              formatPrice(productRecord.price),
                                              style: FlutterFlowTheme.of(context)
                                                  .headlineSmall
                                                  .override(
                                                    font:
                                                        GoogleFonts.interTight(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    color:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primary,
                                                    letterSpacing: 0.0,
                                                  ),
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
                        ),

                        // Instructions
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 24.0, 0.0, 8.0),
                          child: Text(
                            'Purchase Instructions',
                            style: FlutterFlowTheme.of(context)
                                .titleMedium
                                .override(
                                  font: GoogleFonts.interTight(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ),
                        FutureBuilder<UsersRecord?>(
                          future: productRecord.ownerRef != null 
                              ? UsersRecord.getDocumentOnce(productRecord.ownerRef!)
                              : null,
                          builder: (context, sellerSnapshot) {
                            final sellerGCash = sellerSnapshot.hasData 
                                ? sellerSnapshot.data?.phoneNumber ?? 'N/A'
                                : 'Loading...';
                            
                            return Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).accent1,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Highlighted GCash Number
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16.0),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            FlutterFlowTheme.of(context).primary,
                                            FlutterFlowTheme.of(context).primary.withValues(alpha: 0.8),
                                          ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                        borderRadius: BorderRadius.circular(12.0),
                                        boxShadow: [
                                          BoxShadow(
                                            color: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.3),
                                            blurRadius: 8.0,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.account_balance_wallet_rounded,
                                                color: Colors.white,
                                                size: 28.0,
                                              ),
                                              const SizedBox(width: 8.0),
                                              Text(
                                                'Seller GCash Number',
                                                style: FlutterFlowTheme.of(context)
                                                    .bodySmall
                                                    .override(
                                                      font: GoogleFonts.inter(
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                      color: Colors.white.withValues(alpha: 0.9),
                                                      letterSpacing: 0.5,
                                                      fontSize: 11.0,
                                                    ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8.0),
                                          Text(
                                            sellerGCash,
                                            style: FlutterFlowTheme.of(context)
                                                .bodyLarge
                                                .override(
                                                  font: GoogleFonts.interTight(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  color: Colors.white,
                                                  fontSize: 24.0,
                                                  letterSpacing: 1.5,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16.0),
                                    Text(
                                      'Payment Instructions:',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.w600,
                                            ),
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      '1. Send payment to the GCash number above\n2. Upload your payment proof\n3. Wait for seller confirmation\n4. Arrange meetup with seller\n5. Complete the transaction',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.inter(),
                                    letterSpacing: 0.0,
                                    lineHeight: 1.5,
                                  ),
                                    ),
                                  ],
                            ),
                          ),
                            );
                          },
                        ),

                        // Chat with Seller Button
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 24.0, 0.0, 0.0),
                          child: FFButtonWidget(
                            onPressed: () async {
                              // Get or create thread with seller
                              final sellerRef = productRecord.ownerRef;
                              if (sellerRef == null) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Unable to contact seller')),
                                  );
                                }
                                return;
                              }
                              
                              // Check if thread already exists
                              final existingThreads = await queryMessagesRecordOnce(
                                queryBuilder: (messagesRecord) => messagesRecord
                                    .where('uid', isEqualTo: currentUserUid)
                                    .where('participants', isEqualTo: sellerRef),
                              );
                              
                              String? threadId;
                              
                              if (existingThreads.isNotEmpty) {
                                // Use existing thread
                                threadId = existingThreads.first.reference.id;
                              } else {
                                // Get seller data
                                final sellerDoc = await sellerRef.get();
                                UsersRecord? sellerData;
                                if (sellerDoc.exists) {
                                  sellerData = UsersRecord.getDocumentFromData(
                                    sellerDoc.data() as Map<String, dynamic>,
                                    sellerDoc.reference,
                                  );
                                }
                                
                                // Create thread for current user (buyer)
                                final newThread = await MessagesRecord.collection.add(
                                  createMessagesRecordData(
                                    uid: currentUserUid,
                                    participants: sellerRef,
                                    createdTime: getCurrentTimestamp,
                                    updatedAt: getCurrentTimestamp,
                                    lastMessage: '',
                                    displayName: sellerData?.displayName ?? 'Seller',
                                    email: sellerData?.email ?? '',
                                    photoUrl: sellerData?.photoUrl ?? '',
                                    phoneNumber: sellerData?.phoneNumber ?? '',
                                    address: sellerData?.address ?? '',
                                  ),
                                );
                                threadId = newThread.id;
                              }
                              
                              // Navigate to chat page with threadId
                              if (!mounted) return;
                              if (context.mounted) {
                                context.pushNamed(
                                  ChatPageWidget.routeName,
                                  queryParameters: {
                                    'threadId': threadId,
                                  },
                                );
                              }
                            },
                            text: 'Chat with Seller',
                            icon: const Icon(
                              Icons.chat_bubble_outline,
                              size: 20.0,
                            ),
                            options: FFButtonOptions(
                              width: double.infinity,
                              height: 50.0,
                              padding: const EdgeInsets.all(8.0),
                              iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 0.0),
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                .override(
                                  font: GoogleFonts.interTight(
                                    fontWeight: FontWeight.w600,
                                  ),
                                    color: FlutterFlowTheme.of(context).primary,
                                  letterSpacing: 0.0,
                                ),
                              elevation: 0.0,
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).primary,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),

                        // Payment Proof Upload
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 24.0, 0.0, 8.0),
                          child: Text(
                            'Upload Payment Proof *',
                            style: FlutterFlowTheme.of(context)
                                .titleMedium
                                .override(
                                  font: GoogleFonts.interTight(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ),
                        FFButtonWidget(
                          onPressed: () async {
                            final selectedMedia =
                                await selectMediaWithSourceBottomSheet(
                              context: context,
                              allowPhoto: true,
                            );
                            if (selectedMedia != null &&
                                selectedMedia.every((m) =>
                                    validateFileFormat(
                                        m.storagePath, context))) {
                              setState(() => _model.isDataUploading = true);
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
                                    (m) async => await uploadData(
                                        m.storagePath, m.bytes),
                                  ),
                                ))
                                    .where((u) => u != null)
                                    .map((u) => u!)
                                    .toList();
                              } finally {
                                _model.isDataUploading = false;
                              }
                              if (selectedUploadedFiles.length ==
                                      selectedMedia.length &&
                                  downloadUrls.length == selectedMedia.length) {
                                setState(() {
                                  _model.uploadedLocalFile =
                                      selectedUploadedFiles.first;
                                  _model.uploadedFileUrl = downloadUrls.first;
                                });
                              } else {
                                setState(() {});
                                return;
                              }
                            }
                          },
                          text: _model.uploadedFileUrl.isEmpty
                              ? 'Choose Image'
                              : 'Change Image',
                          icon: const Icon(
                            Icons.upload_file,
                            size: 20.0,
                          ),
                          options: FFButtonOptions(
                            width: double.infinity,
                            height: 50.0,
                            padding: const EdgeInsets.all(8.0),
                            iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            textStyle: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                  font: GoogleFonts.interTight(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  color: FlutterFlowTheme.of(context).primary,
                                  letterSpacing: 0.0,
                                ),
                            elevation: 0.0,
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).primary,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),

                        // Preview uploaded image
                        if (_model.uploadedFileUrl.isNotEmpty)
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 16.0, 0.0, 0.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: CachedNetworkImage(
                                fadeInDuration: const Duration(milliseconds: 0),
                                fadeOutDuration: const Duration(milliseconds: 0),
                                imageUrl: _model.uploadedFileUrl,
                                width: double.infinity,
                                height: 200.0,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                        // Submit Button
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 32.0, 0.0, 24.0),
                          child: FFButtonWidget(
                            onPressed: () async {
                              if (_model.validateForm()) {
                                // Store theme before async operation
                                final theme = FlutterFlowTheme.of(context);
                                
                                // Create purchase request
                                await PurchaseRequestsRecord.collection.add(
                                  createPurchaseRequestsRecordData(
                                    productRef: widget.productRef,
                                    buyerRef: currentUserReference,
                                    sellerRef: productRecord.ownerRef,
                                    status: 'pending',
                                    requestDate: getCurrentTimestamp,
                                    paymentProof: _model.uploadedFileUrl,
                                    totalAmount: productRecord.price,
                                  ),
                                );
                                
                                // Send payment proof to chat with seller
                                if (productRecord.ownerRef != null) {
                                  try {
                                    // Show loading
                                    if (!mounted) return;
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Sending payment proof to seller...'),
                                          duration: Duration(seconds: 2),
                                          backgroundColor: Colors.blue,
                                        ),
                                      );
                                    }
                                    
                                    // Get or create thread with seller
                                    final sellerRef = productRecord.ownerRef;
                                    final existingThreads = await queryMessagesRecordOnce(
                                      queryBuilder: (messagesRecord) => messagesRecord
                                          .where('uid', isEqualTo: currentUserUid)
                                          .where('participants', isEqualTo: sellerRef),
                                    );
                                    
                                    DocumentReference? threadRef;
                                    
                                    if (existingThreads.isNotEmpty) {
                                      threadRef = existingThreads.first.reference;
                                    } else {
                                      // Fetch seller's information
                                      final sellerDoc = await sellerRef!.get();
                                      UsersRecord? sellerData;
                                      if (sellerDoc.exists) {
                                        sellerData = UsersRecord.getDocumentFromData(
                                          sellerDoc.data() as Map<String, dynamic>,
                                          sellerDoc.reference,
                                        );
                                      }
                                      
                                      // Create thread for current user (buyer)
                                      final newThread = await MessagesRecord.collection.add(
                                        createMessagesRecordData(
                                          uid: currentUserUid,
                                          participants: sellerRef,
                                          createdTime: getCurrentTimestamp,
                                          updatedAt: getCurrentTimestamp,
                                          lastMessage: '📷 Payment proof',
                                          displayName: sellerData?.displayName ?? 'Seller',
                                          email: sellerData?.email ?? '',
                                          photoUrl: sellerData?.photoUrl ?? '',
                                          phoneNumber: sellerData?.phoneNumber ?? '',
                                          address: sellerData?.address ?? '',
                                        ),
                                      );
                                      threadRef = newThread;
                                    }
                                    
                                    // Send payment proof image to chat
                                    if (_model.uploadedFileUrl.isNotEmpty) {
                                      await ChatsRecord.createDoc(threadRef).set(
                                        createChatsRecordData(
                                          senderRef: currentUserReference,
                                          text: '📷 Payment proof for ${productRecord.name}',
                                          sentAt: getCurrentTimestamp,
                                          imageUrl: _model.uploadedFileUrl,
                                        ),
                                      );
                                      
                                      debugPrint('✅ Payment proof sent to chat successfully');
                                    }
                                  } catch (e) {
                                    debugPrint('Error sending payment proof to chat: $e');
                                    if (!mounted) return;
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Failed to send payment proof to chat: $e'),
                                          backgroundColor: Colors.orange,
                                          duration: const Duration(seconds: 3),
                                        ),
                                      );
                                    }
                                  }
                                }

                                if (!mounted) return;
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Purchase request submitted! Payment proof sent to seller.',
                                      style: TextStyle(
                                        color: theme.primaryText,
                                      ),
                                    ),
                                    duration: const Duration(milliseconds: 4000),
                                    backgroundColor: theme.secondary,
                                  ),
                                );
                                }

                                if (context.mounted) {
                                  context.safePop();
                                }
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      _model.getValidationError() ??
                                          'Please complete all required fields',
                                      style: TextStyle(
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                      ),
                                    ),
                                    duration: const Duration(milliseconds: 4000),
                                    backgroundColor:
                                        FlutterFlowTheme.of(context).error,
                                  ),
                                );
                                }
                              }
                            },
                            text: 'Submit Purchase Request',
                            options: FFButtonOptions(
                              width: double.infinity,
                              height: 56.0,
                              padding: const EdgeInsets.all(8.0),
                              iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 0.0),
                              color: FlutterFlowTheme.of(context).primary,
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    font: GoogleFonts.interTight(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    color: Colors.white,
                                    letterSpacing: 0.0,
                                  ),
                              elevation: 3.0,
                              borderRadius: BorderRadius.circular(12.0),
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
      },
    );
  }
}
