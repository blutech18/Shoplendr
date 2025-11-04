import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/bottom_nav_bar.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'my_transactions_model.dart';
export 'my_transactions_model.dart';

class MyTransactionsWidget extends StatefulWidget {
  const MyTransactionsWidget({super.key});

  static String routeName = 'MyTransactions';
  static String routePath = '/myTransactions';

  @override
  State<MyTransactionsWidget> createState() => _MyTransactionsWidgetState();
}

class _MyTransactionsWidgetState extends State<MyTransactionsWidget>
    with TickerProviderStateMixin {
  late MyTransactionsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  int _ordersSubTabIndex = 0; // 0 = Purchases, 1 = Rentals
  int _requestsSubTabIndex = 0; // 0 = Sale Requests, 1 = Rental Requests

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MyTransactionsModel());
    _model.tabBarController = TabController(vsync: this, length: 4, initialIndex: 0);
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
        automaticallyImplyLeading: true,
        title: Text(
          'My Transactions',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
                fontFamily: 'Outfit',
                color: Colors.white,
                fontSize: 22.0,
              ),
        ),
        centerTitle: false,
        elevation: 2.0,
      ),
      body: Column(
        children: [
          Align(
            alignment: const Alignment(0.0, 0),
            child: TabBar(
              labelColor: FlutterFlowTheme.of(context).primaryText,
              unselectedLabelColor: FlutterFlowTheme.of(context).secondaryText,
              labelStyle: FlutterFlowTheme.of(context).titleMedium.override(
                    fontFamily: 'Readex Pro',
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
              unselectedLabelStyle: FlutterFlowTheme.of(context).titleMedium.override(
                    fontFamily: 'Readex Pro',
                    fontSize: 14.0,
                  ),
              indicatorColor: FlutterFlowTheme.of(context).primary,
              indicatorSize: TabBarIndicatorSize.tab,
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              isScrollable: false,
              tabs: const [
                Tab(text: 'My Listings'),
                Tab(text: 'My Orders'),
                Tab(text: 'My Sales'),
                Tab(text: 'Requests'),
              ],
              controller: _model.tabBarController,
              onTap: (i) async {
                [() async {}, () async {}, () async {}, () async {}][i]();
              },
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _model.tabBarController,
              children: [
                _buildMyListingsTab(),
                _buildMyOrdersTab(),
                _buildMySalesTab(),
                _buildRequestsTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(currentRoute: MyTransactionsWidget.routeName),
    );
  }

  // Tab 1: My Listings
  Widget _buildMyListingsTab() {
    return StreamBuilder<List<ProductsRecord>>(
      stream: queryProductsRecord(
        queryBuilder: (productsRecord) => productsRecord
            .where('OwnerRef', isEqualTo: currentUserReference)
            .orderBy('created_at', descending: true),
      ),
      builder: (context, snapshot) {
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
        final products = snapshot.data!;
        if (products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 64.0,
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
                const SizedBox(height: 16.0),
                Text(
                  'No listings yet',
                  style: FlutterFlowTheme.of(context).headlineSmall,
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Start selling or renting items!',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Readex Pro',
                        color: FlutterFlowTheme.of(context).secondaryText,
                      ),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return StreamBuilder<List<ReviewsRecord>>(
              stream: queryReviewsRecord(
                queryBuilder: (reviewsRecord) => reviewsRecord
                    .where('product_ref', isEqualTo: product.reference),
              ),
              builder: (context, reviewsSnapshot) {
                final reviews = reviewsSnapshot.data ?? [];
                double averageRating = 0.0;
                if (reviews.isNotEmpty) {
                  final totalRating = reviews.fold<double>(
                    0.0,
                    (totalSum, review) => totalSum + review.rating,
                  );
                  averageRating = totalRating / reviews.length;
                }
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        product.photo.isNotEmpty ? product.photo : '',
                        width: 60.0,
                        height: 60.0,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 60.0,
                          height: 60.0,
                          color: FlutterFlowTheme.of(context).secondaryBackground,
                          child: Icon(Icons.image, color: FlutterFlowTheme.of(context).secondaryText),
                        ),
                      ),
                    ),
                    title: Text(
                      product.name,
                      style: FlutterFlowTheme.of(context).titleMedium,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '₱${product.price.toStringAsFixed(2)} • ${product.sellRent}',
                          style: FlutterFlowTheme.of(context).bodySmall,
                        ),
                        if (reviews.isNotEmpty)
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 16.0),
                              const SizedBox(width: 4.0),
                              Text(
                                '${averageRating.toStringAsFixed(1)} (${reviews.length} ${reviews.length == 1 ? 'review' : 'reviews'})',
                                style: FlutterFlowTheme.of(context).bodySmall.override(
                                      fontFamily: 'Readex Pro',
                                      color: FlutterFlowTheme.of(context).secondaryText,
                                    ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: FlutterFlowTheme.of(context).secondaryText,
                    ),
                    onTap: () {
                      context.pushNamed(
                        'ItemPage',
                        queryParameters: {'para': serializeParam(product.reference, ParamType.DocumentReference)}.withoutNulls,
                      );
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // Tab 2: My Orders (combines Purchases and Rentals)
  Widget _buildMyOrdersTab() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _ordersSubTabIndex = 0;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: _ordersSubTabIndex == 0
                          ? FlutterFlowTheme.of(context).primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      'Purchases',
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).titleMedium.override(
                            fontFamily: 'Readex Pro',
                            color: _ordersSubTabIndex == 0
                                ? Colors.white
                                : FlutterFlowTheme.of(context).secondaryText,
                            fontWeight: _ordersSubTabIndex == 0 ? FontWeight.w600 : FontWeight.normal,
                          ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _ordersSubTabIndex = 1;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: _ordersSubTabIndex == 1
                          ? FlutterFlowTheme.of(context).primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      'Rentals',
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).titleMedium.override(
                            fontFamily: 'Readex Pro',
                            color: _ordersSubTabIndex == 1
                                ? Colors.white
                                : FlutterFlowTheme.of(context).secondaryText,
                            fontWeight: _ordersSubTabIndex == 1 ? FontWeight.w600 : FontWeight.normal,
                          ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _ordersSubTabIndex == 0 ? _buildPurchasesTab() : _buildRentalsTab(),
        ),
      ],
    );
  }

  // Sub-tab: Purchases
  Widget _buildPurchasesTab() {
    return StreamBuilder<List<PurchaseRequestsRecord>>(
      stream: queryPurchaseRequestsRecord(
        queryBuilder: (purchaseRequestsRecord) => purchaseRequestsRecord
            .where('buyerRef', isEqualTo: currentUserReference)
            .orderBy('requestDate', descending: true),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final purchases = snapshot.data!;
        if (purchases.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined, size: 64.0, color: FlutterFlowTheme.of(context).secondaryText),
                const SizedBox(height: 16.0),
                Text('No purchases yet', style: FlutterFlowTheme.of(context).headlineSmall),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: purchases.length,
          itemBuilder: (context, index) {
            final purchase = purchases[index];
            return _buildTransactionCard(
              status: purchase.status,
              amount: purchase.totalAmount,
              date: purchase.requestDate!,
              type: 'Purchase',
              productRef: purchase.productRef,
              sellerRef: purchase.sellerRef,
              transactionRef: purchase.reference,
            );
          },
        );
      },
    );
  }

  // Tab 3: Rentals (as renter)
  Widget _buildRentalsTab() {
    return StreamBuilder<List<RentalRequestsRecord>>(
      stream: queryRentalRequestsRecord(
        queryBuilder: (rentalRequestsRecord) => rentalRequestsRecord
            .where('requesterRef', isEqualTo: currentUserReference)
            .orderBy('requestDate', descending: true),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final rentals = snapshot.data!;
        if (rentals.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_available_outlined, size: 64.0, color: FlutterFlowTheme.of(context).secondaryText),
                const SizedBox(height: 16.0),
                Text('No rentals yet', style: FlutterFlowTheme.of(context).headlineSmall),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: rentals.length,
          itemBuilder: (context, index) {
            final rental = rentals[index];
            return _buildRentalCard(rental);
          },
        );
      },
    );
  }

  // Tab 3: My Sales (as seller)
  Widget _buildMySalesTab() {
    return _buildSalesTab();
  }

  // Sub-tab: Sales (as seller)
  Widget _buildSalesTab() {
    return StreamBuilder<List<PurchaseRequestsRecord>>(
      stream: queryPurchaseRequestsRecord(
        queryBuilder: (purchaseRequestsRecord) => purchaseRequestsRecord
            .where('sellerRef', isEqualTo: currentUserReference)
            .orderBy('requestDate', descending: true),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final sales = snapshot.data!;
        if (sales.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sell_outlined, size: 64.0, color: FlutterFlowTheme.of(context).secondaryText),
                const SizedBox(height: 16.0),
                Text('No sales yet', style: FlutterFlowTheme.of(context).headlineSmall),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: sales.length,
          itemBuilder: (context, index) {
            final sale = sales[index];
            return _buildTransactionCard(
              status: sale.status,
              amount: sale.totalAmount,
              date: sale.requestDate!,
              type: 'Sale',
            );
          },
        );
      },
    );
  }

  Widget _buildTransactionCard({
    required String status,
    required double amount,
    required DateTime date,
    required String type,
    DocumentReference? productRef,
    DocumentReference? sellerRef,
    DocumentReference? transactionRef,
  }) {
    Color statusColor;
    IconData statusIcon;
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case 'declined':
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        leading: Icon(statusIcon, color: statusColor, size: 32.0),
        title: Text(
          '$type - ₱${amount.toStringAsFixed(2)}',
          style: FlutterFlowTheme.of(context).titleMedium,
        ),
        subtitle: Text(
          '${status.toUpperCase()} • ${dateTimeFormat('MMMMEEEEd', date)}',
          style: FlutterFlowTheme.of(context).bodySmall,
        ),
        trailing: null,
      ),
    );
  }

  Widget _buildRentalCard(RentalRequestsRecord rental) {
    Color statusColor;
    IconData statusIcon;
    switch (rental.status.toLowerCase()) {
      case 'approved':
      case 'active':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case 'returned':
        statusColor = Colors.blue;
        statusIcon = Icons.assignment_return;
        break;
      case 'declined':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        leading: Icon(statusIcon, color: statusColor, size: 32.0),
        title: Text(
          'Rental',
          style: FlutterFlowTheme.of(context).titleMedium,
        ),
        subtitle: Text(
          '${rental.status.toUpperCase()} • ${dateTimeFormat('MMMMEEEEd', rental.requestDate)}',
          style: FlutterFlowTheme.of(context).bodySmall,
        ),
        trailing: rental.status.toLowerCase() == 'active'
            ? FFButtonWidget(
                onPressed: () {
                  context.pushNamed(
                    'ReturnItem',
                    queryParameters: {
                      'rentalRequestRef': serializeParam(rental.reference, ParamType.DocumentReference)
                    }.withoutNulls,
                  );
                },
                text: 'Return',
                options: FFButtonOptions(
                  height: 36.0,
                  padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                  color: FlutterFlowTheme.of(context).primary,
                  textStyle: FlutterFlowTheme.of(context).labelSmall.override(
                        fontFamily: 'Readex Pro',
                        color: Colors.white,
                      ),
                  elevation: 0.0,
                  borderRadius: BorderRadius.circular(8.0),
                ),
              )
            : null,
      ),
    );
  }

  // Tab 4: Requests (combines Sale Requests and Rental Requests)
  Widget _buildRequestsTab() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _requestsSubTabIndex = 0;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: _requestsSubTabIndex == 0
                          ? FlutterFlowTheme.of(context).primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      'Sale Requests',
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).titleMedium.override(
                            fontFamily: 'Readex Pro',
                            color: _requestsSubTabIndex == 0
                                ? Colors.white
                                : FlutterFlowTheme.of(context).secondaryText,
                            fontWeight: _requestsSubTabIndex == 0 ? FontWeight.w600 : FontWeight.normal,
                          ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _requestsSubTabIndex = 1;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: _requestsSubTabIndex == 1
                          ? FlutterFlowTheme.of(context).primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      'Rental Requests',
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).titleMedium.override(
                            fontFamily: 'Readex Pro',
                            color: _requestsSubTabIndex == 1
                                ? Colors.white
                                : FlutterFlowTheme.of(context).secondaryText,
                            fontWeight: _requestsSubTabIndex == 1 ? FontWeight.w600 : FontWeight.normal,
                          ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _requestsSubTabIndex == 0
              ? _buildIncomingSaleRequestsTab()
              : _buildIncomingRentalRequestsTab(),
        ),
      ],
    );
  }

  // Sub-tab: Incoming Sale Requests (for sellers)
  Widget _buildIncomingSaleRequestsTab() {
    return StreamBuilder<List<PurchaseRequestsRecord>>(
      stream: queryPurchaseRequestsRecord(
        queryBuilder: (purchaseRequestsRecord) => purchaseRequestsRecord
            .where('sellerRef', isEqualTo: currentUserReference)
            .where('status', isEqualTo: 'pending')
            .orderBy('requestDate', descending: true),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final requests = snapshot.data!;
        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 64.0, color: FlutterFlowTheme.of(context).secondaryText),
                const SizedBox(height: 16.0),
                Text('No pending sale requests', style: FlutterFlowTheme.of(context).headlineSmall),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return _buildSaleRequestCard(request);
          },
        );
      },
    );
  }

  // Sub-tab: Incoming Rental Requests (for owners)
  Widget _buildIncomingRentalRequestsTab() {
    return StreamBuilder<List<RentalRequestsRecord>>(
      stream: queryRentalRequestsRecord(
        queryBuilder: (rentalRequestsRecord) => rentalRequestsRecord
            .where('ownerRef', isEqualTo: currentUserReference)
            .where('status', isEqualTo: 'pending')
            .orderBy('requestDate', descending: true),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final requests = snapshot.data!;
        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 64.0, color: FlutterFlowTheme.of(context).secondaryText),
                const SizedBox(height: 16.0),
                Text('No pending rental requests', style: FlutterFlowTheme.of(context).headlineSmall),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return _buildRentalRequestCard(request);
          },
        );
      },
    );
  }

  Widget _buildSaleRequestCard(PurchaseRequestsRecord request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_cart, color: FlutterFlowTheme.of(context).primary),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    'Purchase Request',
                    style: FlutterFlowTheme.of(context).titleMedium.override(
                          fontFamily: 'Readex Pro',
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    'PENDING',
                    style: FlutterFlowTheme.of(context).labelSmall.override(
                          fontFamily: 'Readex Pro',
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            Text(
              'Amount: ₱${request.totalAmount.toStringAsFixed(2)}',
              style: FlutterFlowTheme.of(context).bodyLarge.override(
                    fontFamily: 'Readex Pro',
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 4.0),
            Text(
              'Date: ${dateTimeFormat('MMMMEEEEd', request.requestDate)}',
              style: FlutterFlowTheme.of(context).bodySmall,
            ),
            if (request.message.isNotEmpty) ...[
              const SizedBox(height: 8.0),
              Text(
                'Message: ${request.message}',
                style: FlutterFlowTheme.of(context).bodyMedium,
              ),
            ],
            if (request.paymentProof.isNotEmpty) ...[
              const SizedBox(height: 8.0),
              Text(
                'Payment Proof Attached',
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      fontFamily: 'Readex Pro',
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: FFButtonWidget(
                    onPressed: () async {
                      await _confirmSaleRequest(request);
                    },
                    text: 'Confirm',
                    options: FFButtonOptions(
                      height: 44.0,
                      padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                      color: Colors.green,
                      textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                            fontFamily: 'Readex Pro',
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                      elevation: 0.0,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: FFButtonWidget(
                    onPressed: () async {
                      await _declineSaleRequest(request);
                    },
                    text: 'Decline',
                    options: FFButtonOptions(
                      height: 44.0,
                      padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                      color: Colors.red,
                      textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                            fontFamily: 'Readex Pro',
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                      elevation: 0.0,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRentalRequestCard(RentalRequestsRecord request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event_available, color: FlutterFlowTheme.of(context).primary),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    'Rental Request',
                    style: FlutterFlowTheme.of(context).titleMedium.override(
                          fontFamily: 'Readex Pro',
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    'PENDING',
                    style: FlutterFlowTheme.of(context).labelSmall.override(
                          fontFamily: 'Readex Pro',
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            Text(
              'Date: ${dateTimeFormat('MMMMEEEEd', request.requestDate)}',
              style: FlutterFlowTheme.of(context).bodySmall,
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: FFButtonWidget(
                    onPressed: () async {
                      await _approveRentalRequest(request);
                    },
                    text: 'Approve',
                    options: FFButtonOptions(
                      height: 44.0,
                      padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                      color: Colors.green,
                      textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                            fontFamily: 'Readex Pro',
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                      elevation: 0.0,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: FFButtonWidget(
                    onPressed: () async {
                      await _declineRentalRequest(request);
                    },
                    text: 'Decline',
                    options: FFButtonOptions(
                      height: 44.0,
                      padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                      color: Colors.red,
                      textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                            fontFamily: 'Readex Pro',
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                      elevation: 0.0,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmSaleRequest(PurchaseRequestsRecord request) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Sale'),
        content: Text('Confirm this purchase request for ₱${request.totalAmount.toStringAsFixed(2)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await request.reference.update({
          'status': 'confirmed',
          'responseDate': DateTime.now(),
          'confirmedDate': DateTime.now(),
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Sale confirmed successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _declineSaleRequest(PurchaseRequestsRecord request) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Decline Sale'),
        content: const Text('Are you sure you want to decline this purchase request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Decline', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await request.reference.update({
          'status': 'declined',
          'responseDate': DateTime.now(),
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sale request declined'),
              backgroundColor: Colors.grey,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _approveRentalRequest(RentalRequestsRecord request) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Rental'),
        content: const Text('Approve this rental request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Approve', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await request.reference.update({
          'status': 'approved',
          'responseDate': DateTime.now(),
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Rental approved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _declineRentalRequest(RentalRequestsRecord request) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Decline Rental'),
        content: const Text('Are you sure you want to decline this rental request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Decline', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await request.reference.update({
          'status': 'declined',
          'responseDate': DateTime.now(),
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Rental request declined'),
              backgroundColor: Colors.grey,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
