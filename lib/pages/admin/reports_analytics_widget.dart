import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'reports_analytics_model.dart';
export 'reports_analytics_model.dart';

/// Admin Reports & Analytics Page
/// 
/// Features:
/// - View total users, listings, transactions
/// - Monitor sales and rental statistics
/// - Track user activity and engagement
/// - View revenue and transaction trends
class ReportsAnalyticsWidget extends StatefulWidget {
  const ReportsAnalyticsWidget({super.key});

  static String routeName = 'ReportsAnalytics';
  static String routePath = '/admin/reports';

  @override
  State<ReportsAnalyticsWidget> createState() => _ReportsAnalyticsWidgetState();
}

class _ReportsAnalyticsWidgetState extends State<ReportsAnalyticsWidget> {
  late ReportsAnalyticsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ReportsAnalyticsModel());
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
          'Reports & Analytics',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
                fontFamily: 'Outfit',
                color: Colors.white,
              ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            _buildSummarySection(),
            const SizedBox(height: 24),
            
            // Transaction Statistics
            _buildTransactionStats(),
            const SizedBox(height: 24),
            
            // User Activity
            _buildUserActivity(),
            const SizedBox(height: 24),
            
            // Recent Reviews
            _buildRecentReviews(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: FlutterFlowTheme.of(context).headlineSmall.override(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<UsersRecord>>(
          stream: queryUsersRecord(),
          builder: (context, usersSnapshot) {
            return StreamBuilder<List<ProductsRecord>>(
              stream: queryProductsRecord(),
              builder: (context, productsSnapshot) {
                return StreamBuilder<List<PurchaseRequestsRecord>>(
                  stream: queryPurchaseRequestsRecord(),
                  builder: (context, purchasesSnapshot) {
                    return StreamBuilder<List<RentalRequestsRecord>>(
                      stream: queryRentalRequestsRecord(),
                      builder: (context, rentalsSnapshot) {
                        final totalUsers = usersSnapshot.data?.length ?? 0;
                        final totalListings = productsSnapshot.data?.length ?? 0;
                        
                        final confirmedPurchases = purchasesSnapshot.data
                            ?.where((p) => p.status == 'confirmed')
                            .length ?? 0;
                        final approvedRentals = rentalsSnapshot.data
                            ?.where((r) => r.status == 'approved')
                            .length ?? 0;

                        return GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.5,
                          children: [
                            _buildStatCard(
                              'Total Users',
                              totalUsers.toString(),
                              Icons.people,
                              Colors.blue,
                            ),
                            _buildStatCard(
                              'Total Listings',
                              totalListings.toString(),
                              Icons.inventory_2,
                              Colors.green,
                            ),
                            _buildStatCard(
                              'Completed Sales',
                              confirmedPurchases.toString(),
                              Icons.shopping_cart,
                              Colors.orange,
                            ),
                            _buildStatCard(
                              'Active Rentals',
                              approvedRentals.toString(),
                              Icons.event_available,
                              Colors.purple,
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: FlutterFlowTheme.of(context).headlineLarge.override(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                title,
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      fontFamily: 'Readex Pro',
                      color: FlutterFlowTheme.of(context).secondaryText,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transaction Statistics',
          style: FlutterFlowTheme.of(context).headlineSmall.override(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<PurchaseRequestsRecord>>(
          stream: queryPurchaseRequestsRecord(
            queryBuilder: (query) => query.orderBy('requestDate', descending: true),
            limit: 50,
          ),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final purchases = snapshot.data!;
            final pending = purchases.where((p) => p.status == 'pending').length;
            final confirmed = purchases.where((p) => p.status == 'confirmed').length;
            final declined = purchases.where((p) => p.status == 'declined').length;

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildStatRow('Pending Purchases', pending, Colors.orange),
                  const Divider(),
                  _buildStatRow('Confirmed Sales', confirmed, Colors.green),
                  const Divider(),
                  _buildStatRow('Declined Requests', declined, Colors.red),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: FlutterFlowTheme.of(context).bodyMedium,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Readex Pro',
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent User Activity',
          style: FlutterFlowTheme.of(context).headlineSmall.override(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<ProductsRecord>>(
          stream: queryProductsRecord(
            queryBuilder: (query) => query.orderBy('created_at', descending: true),
            limit: 5,
          ),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final products = snapshot.data!;
            if (products.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'No recent activity',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Readex Pro',
                          color: FlutterFlowTheme.of(context).secondaryText,
                        ),
                  ),
                ),
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ListTile(
                    leading: Icon(
                      product.sellRent == 'Sell' ? Icons.sell : Icons.event,
                      color: FlutterFlowTheme.of(context).primary,
                    ),
                    title: Text(product.name),
                    subtitle: Text(
                      '${product.sellRent} • ₱${product.price.toStringAsFixed(2)}',
                      style: FlutterFlowTheme.of(context).bodySmall,
                    ),
                    trailing: Text(
                      product.createdAt != null
                          ? dateTimeFormat('relative', product.createdAt!)
                          : 'Recently',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: 'Readex Pro',
                            color: FlutterFlowTheme.of(context).secondaryText,
                          ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentReviews() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Reviews',
          style: FlutterFlowTheme.of(context).headlineSmall.override(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<ReviewsRecord>>(
          stream: queryReviewsRecord(
            queryBuilder: (query) => query.orderBy('created_at', descending: true),
            limit: 5,
          ),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final reviews = snapshot.data!;
            if (reviews.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'No reviews yet',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Readex Pro',
                          color: FlutterFlowTheme.of(context).secondaryText,
                        ),
                  ),
                ),
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reviews.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final review = reviews[index];
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            review.rating.toStringAsFixed(1),
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  fontFamily: 'Readex Pro',
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                    title: Text(
                      review.comment.isNotEmpty ? review.comment : 'No comment',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      review.reviewType,
                      style: FlutterFlowTheme.of(context).bodySmall,
                    ),
                    trailing: Text(
                      review.createdAt != null
                          ? dateTimeFormat('relative', review.createdAt!)
                          : 'Recently',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: 'Readex Pro',
                            color: FlutterFlowTheme.of(context).secondaryText,
                          ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
