import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'transaction_monitoring_model.dart';
export 'transaction_monitoring_model.dart';

class TransactionMonitoringWidget extends StatefulWidget {
  const TransactionMonitoringWidget({super.key});

  static String routeName = 'TransactionMonitoring';
  static String routePath = '/admin/transactions';

  @override
  State<TransactionMonitoringWidget> createState() => _TransactionMonitoringWidgetState();
}

class _TransactionMonitoringWidgetState extends State<TransactionMonitoringWidget>
    with TickerProviderStateMixin {
  late TransactionMonitoringModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TransactionMonitoringModel());
    _model.tabBarController = TabController(vsync: this, length: 3, initialIndex: 0);
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
          'Transaction Monitoring',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
                fontFamily: 'Outfit',
                color: Colors.white,
              ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                TabBar(
                  labelColor: FlutterFlowTheme.of(context).primaryText,
                  unselectedLabelColor: FlutterFlowTheme.of(context).secondaryText,
                  indicatorColor: FlutterFlowTheme.of(context).primary,
                  tabs: const [
                    Tab(text: 'Rental Requests'),
                    Tab(text: 'Shop Offers'),
                    Tab(text: 'Insurance'),
                  ],
                  controller: _model.tabBarController,
                ),
                Expanded(
                  child: TabBarView(
                    controller: _model.tabBarController,
                    children: [
                      _buildRentalRequestsTab(),
                      _buildShopOffersTab(),
                      _buildInsuranceTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRentalRequestsTab() {
    return StreamBuilder<List<RentalRequestsRecord>>(
      stream: queryRentalRequestsRecord(
        queryBuilder: (query) => query.orderBy('created_at', descending: true),
        limit: 100,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final requests = snapshot.data!;
        if (requests.isEmpty) {
          return Center(
            child: Text('No rental requests', style: FlutterFlowTheme.of(context).headlineSmall),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                leading: _getStatusIcon(request.status),
                title: Text('Request #${request.reference.id.substring(0, 8)}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status: ${request.status}'),
                    Text('Created: ${dateTimeFormat('relative', request.requestDate)}'),
                  ],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Start Date', dateTimeFormat('yMMMd', request.rentalStartDate)),
                        _buildInfoRow('End Date', dateTimeFormat('yMMMd', request.rentalEndDate)),
                        _buildInfoRow('Total Price', '\$${request.totalAmount}'),
                        _buildInfoRow('Status', request.status),
                        if (request.message.isNotEmpty)
                          _buildInfoRow('Notes', request.message),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildShopOffersTab() {
    return StreamBuilder<List<ShopOffersRecord>>(
      stream: queryShopOffersRecord(
        limit: 100,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final offers = snapshot.data!;
        if (offers.isEmpty) {
          return Center(
            child: Text('No shop offers', style: FlutterFlowTheme.of(context).headlineSmall),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: offers.length,
          itemBuilder: (context, index) {
            final offer = offers[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.local_offer),
                title: Text(offer.offerName.isNotEmpty ? offer.offerName : 'Offer #${offer.reference.id.substring(0, 8)}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Discount: ${offer.offerDiscount}'),
                    if (offer.offerDescription.isNotEmpty)
                      Text(offer.offerDescription),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInsuranceTab() {
    return StreamBuilder<List<InsuranceAgreementsRecord>>(
      stream: queryInsuranceAgreementsRecord(
        limit: 100,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final agreements = snapshot.data!;
        if (agreements.isEmpty) {
          return Center(
            child: Text('No insurance agreements', style: FlutterFlowTheme.of(context).headlineSmall),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: agreements.length,
          itemBuilder: (context, index) {
            final agreement = agreements[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.shield, color: Colors.blue),
                title: Text('Agreement #${agreement.reference.id.substring(0, 8)}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Terms Version: ${agreement.termsVersion}'),
                    if (agreement.agreedAt != null)
                      Text('Agreed: ${dateTimeFormat('yMMMd', agreement.agreedAt)}'),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Readex Pro',
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: FlutterFlowTheme.of(context).bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Icon(Icons.pending, color: Colors.orange);
      case 'approved':
      case 'accepted':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'rejected':
      case 'declined':
        return const Icon(Icons.cancel, color: Colors.red);
      case 'completed':
        return const Icon(Icons.done_all, color: Colors.blue);
      default:
        return const Icon(Icons.info, color: Colors.grey);
    }
  }
}
