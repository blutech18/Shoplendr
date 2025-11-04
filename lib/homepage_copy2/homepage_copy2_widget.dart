import '/backend/backend.dart';
import '/components/bottom_nav_bar.dart';
import '/components/cors_safe_image.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/price_format.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'homepage_copy2_model.dart';
export 'homepage_copy2_model.dart';

/// Title: ShopLendr
///
///
/// Search Bar under the app bar.
///
/// Toggle Buttons (Segment Control):
///
/// For Sale | For Rent
///
/// Default: For Sale.
///
/// When tapped, reloads the item list with different dataset & images.
///
/// For Sale → show items with sale images.
///
/// For Rent → show items with rent images.
///
/// Item Grid/List Section:
///
/// Cards with:
///
/// Image (changes depending on Rent/Sell toggle).
///
/// Item Name.
///
/// Description.
///
/// Price OR Rent Fee.
///
/// Bottom Navigation Bar:
///
/// Home (current).
///
/// Messages (chat inbox).
///
/// Sell (goes to create post page).
///
/// Profile (user profile).
///
/// 🔧 Data Binding Logic (for Rent/Sell switch)
///
/// Add a Boolean state variable: isForSale (default = true).
///
/// Bind toggle buttons:
///
/// Tap “For Sale” → set isForSale = true.
///
/// Tap “For Rent” → set isForSale = false.
///
/// Item Grid Source:
/// Conditional Collection Binding:
/// IF isForSale = true → Show SaleItems collection (with sale images).
/// IF isForSale = false → Show RentItems collection (with rent images).
class HomepageCopy2Widget extends StatefulWidget {
  const HomepageCopy2Widget({super.key});

  static String routeName = 'HomepageCopy2';
  static String routePath = '/homepageCopy2';

  @override
  State<HomepageCopy2Widget> createState() => _HomepageCopy2WidgetState();
}

class _HomepageCopy2WidgetState extends State<HomepageCopy2Widget> {
  late HomepageCopy2Model _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomepageCopy2Model());
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
          title: Row(
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                color: FlutterFlowTheme.of(context).primary,
                size: 28.0,
              ),
              const SizedBox(width: 8),
              Text(
                'ShopLendr',
                style: FlutterFlowTheme.of(context).headlineMedium.override(
                      font: GoogleFonts.interTight(
                        fontWeight: FontWeight.bold,
                      ),
                      color: FlutterFlowTheme.of(context).primaryText,
                      fontSize: 24,
                      letterSpacing: -0.5,
                    ),
              ),
            ],
          ),
          actions: const [],
          centerTitle: false,
          elevation: 0.5,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
                child: InkWell(
                  onTap: () async {
                    context.pushNamed(
                      SearchWidget.routeName,
                      extra: <String, dynamic>{
                        kTransitionInfoKey: const TransitionInfo(
                          hasTransition: true,
                          transitionType: PageTransitionType.fade,
                          duration: Duration(milliseconds: 0),
                        ),
                      },
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 48.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: FlutterFlowTheme.of(context).alternate,
                        width: 1.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: FlutterFlowTheme.of(context).secondaryText,
                            size: 22.0,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Search for items...',
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
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
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).alternate,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            context.pushNamed(HomepageCopy2CopyWidget.routeName);
                          },
                          child: Container(
                            height: 44.0,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'For Sale',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    color: FlutterFlowTheme.of(context).secondaryText,
                                    fontSize: 15,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            context.pushNamed(HomepageCopy2Widget.routeName);
                          },
                          child: Container(
                            height: 44.0,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).primary,
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x1A000000),
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'For Rent',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    color: Colors.white,
                                    fontSize: 15,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                child: StreamBuilder<List<ProductsRecord>>(
                  stream: queryProductsRecord(
                    queryBuilder: (productsRecord) => productsRecord.where(
                      'SellRent',
                      isEqualTo: 'Rent',
                    ),
                  ),
                  builder: (context, snapshot) {
                    // Customize what your widget looks like when it's loading.
                    if (!snapshot.hasData) {
                      return Center(
                        child: SizedBox(
                          width: 50.0,
                          height: 50.0,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              FlutterFlowTheme.of(context).primary,
                            ),
                          ),
                        ),
                      );
                    }
                    
                    // Get all products for rent
                    final allProducts = snapshot.data!;
                    
                    // Fetch approved rental requests to filter out currently rented items
                    return StreamBuilder<List<RentalRequestsRecord>>(
                      stream: queryRentalRequestsRecord(
                        queryBuilder: (rentalRequestsRecord) => rentalRequestsRecord
                            .where('status', whereIn: ['approved', 'active']),
                      ),
                      builder: (context, rentalSnapshot) {
                        // Show loading while fetching rental requests
                        if (!rentalSnapshot.hasData) {
                          return Center(
                            child: SizedBox(
                              width: 50.0,
                              height: 50.0,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  FlutterFlowTheme.of(context).primary,
                                ),
                              ),
                            ),
                          );
                        }
                        
                        // Get list of rented product references
                        final rentedProductRefs = rentalSnapshot.data!
                            .map((request) => request.productRef)
                            .where((ref) => ref != null)
                            .toSet();
                        
                        // Filter out currently rented products
                        final availableProducts = allProducts
                            .where((product) => !rentedProductRefs.contains(product.reference))
                            .toList();
                        
                        List<ProductsRecord> gridViewProductsRecordList = availableProducts;

                    return GridView.builder(
                      padding: EdgeInsets.zero,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12.0,
                        mainAxisSpacing: 12.0,
                        childAspectRatio: 0.75,
                      ),
                      physics: const NeverScrollableScrollPhysics(),
                      primary: false,
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: gridViewProductsRecordList.length,
                      itemBuilder: (context, gridViewIndex) {
                        final gridViewProductsRecord =
                            gridViewProductsRecordList[gridViewIndex];
                        return InkWell(
                          onTap: () async {
                            context.pushNamed(
                              ItemPageWidget.routeName,
                              queryParameters: {
                                'para': serializeParam(
                                  gridViewProductsRecord.reference,
                                  ParamType.DocumentReference,
                                ),
                              }.withoutNulls,
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              borderRadius: BorderRadius.circular(16.0),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0D000000),
                                  offset: Offset(0, 2),
                                  blurRadius: 8,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CorsSafeImage(
                                  imageUrl: gridViewProductsRecord.photo,
                                  width: double.infinity,
                                  height: 140.0,
                                  fit: BoxFit.cover,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16.0),
                                    topRight: Radius.circular(16.0),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          gridViewProductsRecord.name,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: FlutterFlowTheme.of(context)
                                              .bodyLarge
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                fontSize: 14.0,
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                        const Spacer(),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            formatPrice(gridViewProductsRecord.price),
                                            style: FlutterFlowTheme.of(context)
                                                .titleMedium
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  color: FlutterFlowTheme.of(context).primary,
                                                  fontSize: 16.0,
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
                        );
                      },
                    );
                      },
                    );
                  },
                ),
              ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavBar(currentRoute: HomepageCopy2Widget.routeName),
      ),
    );
  }
}
