import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/price_format.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'item_page_model.dart';
export 'item_page_model.dart';

/// 🛒 Item Page Layout
///
/// Top Bar
///
/// Back Button ← (goes to previous page)
///
/// Item Image (large display at top)
///
/// Item Details Section
///
/// Item Name (e.g., “Laptop ASUS”)
///
/// Price (in ₱ Peso)
///
/// Type → Label if it’s For Sale or For Rent (ex: 🔹 For Rent / 🔹 For Sale)
///
/// Description (scrollable text area)
///
/// Action Buttons
///
/// 🛒 Add to Cart
///
/// 💬 Message Seller
class ItemPageWidget extends StatefulWidget {
  const ItemPageWidget({
    super.key,
    required this.para,
  });

  final DocumentReference? para;

  static String routeName = 'ItemPage';
  static String routePath = '/itemPage';

  @override
  State<ItemPageWidget> createState() => _ItemPageWidgetState();
}

class _ItemPageWidgetState extends State<ItemPageWidget> {
  late ItemPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ItemPageModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ProductsRecord>(
      stream: ProductsRecord.getDocument(widget.para!),
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

        final itemPageProductsRecord = snapshot.data!;

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
                'Item Details',
                style: FlutterFlowTheme.of(context).titleLarge.override(
                      font: GoogleFonts.interTight(
                        fontWeight: FontWeight.w600,
                        fontStyle:
                            FlutterFlowTheme.of(context).titleLarge.fontStyle,
                      ),
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                      fontStyle:
                          FlutterFlowTheme.of(context).titleLarge.fontStyle,
                    ),
              ),
              actions: const [],
              centerTitle: true,
              elevation: 0.0,
            ),
            body: SafeArea(
              top: true,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth = constraints.maxWidth > 800 ? 800.0 : constraints.maxWidth;
                  final isMobile = constraints.maxWidth < 600;
                  
                  return Center(
                    child: SizedBox(
                      width: maxWidth,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Image
                            Container(
                              width: double.infinity,
                              height: isMobile ? 300.0 : 400.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).secondaryBackground,
                              ),
                              child: CachedNetworkImage(
                                fadeInDuration: const Duration(milliseconds: 200),
                                fadeOutDuration: const Duration(milliseconds: 200),
                                imageUrl: itemPageProductsRecord.photo,
                                width: double.infinity,
                                height: isMobile ? 300.0 : 400.0,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      FlutterFlowTheme.of(context).primary,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 64,
                                  color: FlutterFlowTheme.of(context).secondaryText,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 16.0 : 24.0,
                                vertical: 20.0,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Item Name
                                  Text(
                                    itemPageProductsRecord.name,
                                    style: FlutterFlowTheme.of(context)
                                        .headlineMedium
                                        .override(
                                          font: GoogleFonts.interTight(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          letterSpacing: -0.5,
                                        ),
                                  ),
                                  const SizedBox(height: 12),
                                  // Price
                                  Text(
                                    formatPrice(itemPageProductsRecord.price, showDecimals: true),
                                    style: FlutterFlowTheme.of(context)
                                        .headlineSmall
                                        .override(
                                          font: GoogleFonts.interTight(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          color: FlutterFlowTheme.of(context).primary,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Quantity
                                  Text(
                                    'Available: ${itemPageProductsRecord.quantity} ${itemPageProductsRecord.quantity == 1 ? 'item' : 'items'}',
                                    style: FlutterFlowTheme.of(context).bodySmall.override(
                                          font: GoogleFonts.inter(),
                                          color: FlutterFlowTheme.of(context).secondaryText,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Tags/Badges
                                  Wrap(
                                    spacing: 8.0,
                                    runSpacing: 8.0,
                                    children: [
                                      _buildBadge(
                                        context,
                                        itemPageProductsRecord.sellRent,
                                        FlutterFlowTheme.of(context).primary,
                                      ),
                                      _buildBadge(
                                        context,
                                        itemPageProductsRecord.catergories,
                                        FlutterFlowTheme.of(context).secondary,
                                      ),
                                      _buildBadge(
                                        context,
                                        itemPageProductsRecord.condition,
                                        FlutterFlowTheme.of(context).tertiary,
                                      ),
                                      // Ownership badge
                                      if (itemPageProductsRecord.ownerRef?.id == currentUserUid)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context).success.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(20.0),
                                            border: Border.all(
                                              color: FlutterFlowTheme.of(context).success,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.verified,
                                                color: FlutterFlowTheme.of(context).success,
                                                size: 16.0,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Your Item',
                                                style: FlutterFlowTheme.of(context).labelMedium.override(
                                                      font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                                      color: FlutterFlowTheme.of(context).success,
                                                      fontSize: 12.0,
                                                      letterSpacing: 0.0,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  // Description Section
                                  Text(
                                    'Description',
                                    style: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .override(
                                          font: GoogleFonts.interTight(
                                            fontWeight: FontWeight.w600,
                                          ),
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      borderRadius: BorderRadius.circular(12.0),
                                      border: Border.all(
                                        color: FlutterFlowTheme.of(context).alternate,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Text(
                                      itemPageProductsRecord.description,
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.inter(),
                                            letterSpacing: 0.0,
                                            lineHeight: 1.6,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  // Action Buttons
                                  if (itemPageProductsRecord.ownerRef?.id != currentUserUid)
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        // Buy Now Button
                                        if (itemPageProductsRecord.sellRent == 'Sell')
                                        FFButtonWidget(
                                          onPressed: () async {
                                            context.pushNamed(
                                              'BuyNow',
                                              queryParameters: {
                                                'productRef': serializeParam(
                                                  widget.para,
                                                  ParamType.DocumentReference,
                                                ),
                                              }.withoutNulls,
                                            );
                                          },
                                          text: '🛒 Buy Now',
                                          options: FFButtonOptions(
                                            width: double.infinity,
                                            height: 56.0,
                                            padding: const EdgeInsets.all(0.0),
                                            iconPadding: const EdgeInsets.all(0.0),
                                            color: FlutterFlowTheme.of(context).primary,
                                            textStyle: FlutterFlowTheme.of(context)
                                                .titleMedium
                                                .override(
                                                  font: GoogleFonts.interTight(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  letterSpacing: 0.0,
                                                ),
                                            elevation: 2.0,
                                            borderRadius: BorderRadius.circular(12.0),
                                          ),
                                        ),
                                      // Rent Now Button
                                      if (itemPageProductsRecord.sellRent == 'Rent')
                                        FFButtonWidget(
                                          onPressed: () async {
                                            context.pushNamed(
                                              'RentalRequest',
                                              queryParameters: {
                                                'productRef': serializeParam(
                                                  widget.para,
                                                  ParamType.DocumentReference,
                                                ),
                                              }.withoutNulls,
                                            );
                                          },
                                          text: '📅 Rent Now',
                                          options: FFButtonOptions(
                                            width: double.infinity,
                                            height: 56.0,
                                            padding: const EdgeInsets.all(0.0),
                                            iconPadding: const EdgeInsets.all(0.0),
                                            color: FlutterFlowTheme.of(context).primary,
                                            textStyle: FlutterFlowTheme.of(context)
                                                .titleMedium
                                                .override(
                                                  font: GoogleFonts.interTight(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  letterSpacing: 0.0,
                                                ),
                                            elevation: 2.0,
                                            borderRadius: BorderRadius.circular(12.0),
                                          ),
                                        ),
                                      ].divide(const SizedBox(height: 12.0)),
                                    ),
                                  // Owner message
                                  if (itemPageProductsRecord.ownerRef?.id == currentUserUid)
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(20.0),
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context).success.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12.0),
                                        border: Border.all(
                                          color: FlutterFlowTheme.of(context).success.withValues(alpha: 0.3),
                                          width: 1.0,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.inventory_2_outlined,
                                            size: 48,
                                            color: FlutterFlowTheme.of(context).success,
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'This is Your Item',
                                            style: FlutterFlowTheme.of(context).titleMedium.override(
                                                  font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                                                  color: FlutterFlowTheme.of(context).success,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'You are viewing your own listing. Other users can see and purchase this item.',
                                            textAlign: TextAlign.center,
                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                  font: GoogleFonts.inter(),
                                                  color: FlutterFlowTheme.of(context).secondaryText,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBadge(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            color: color,
            size: 8.0,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: FlutterFlowTheme.of(context).labelMedium.override(
                  font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  color: color,
                  fontSize: 12.0,
                  letterSpacing: 0.0,
                ),
          ),
        ],
      ),
    );
  }
}
