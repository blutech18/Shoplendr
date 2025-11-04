import '/auth/firebase_auth/auth_util.dart';
import '/backend/admin_service.dart';
import '/backend/backend.dart';
import '/components/cors_safe_image.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'listing_approval_model.dart';
export 'listing_approval_model.dart';

class ListingApprovalWidget extends StatefulWidget {
  const ListingApprovalWidget({super.key});

  static String routeName = 'ListingApproval';
  static String routePath = '/admin/listings';

  @override
  State<ListingApprovalWidget> createState() => _ListingApprovalWidgetState();
}

class _ListingApprovalWidgetState extends State<ListingApprovalWidget> {
  late ListingApprovalModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ListingApprovalModel());
    _model.searchTextController ??= TextEditingController();
    _model.searchFocusNode ??= FocusNode();
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
          'Listing Approval & Management',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
                fontFamily: 'Outfit',
                color: Colors.white,
              ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              controller: _model.searchTextController,
              focusNode: _model.searchFocusNode,
              decoration: InputDecoration(
                labelText: 'Search listings...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ProductsRecord>>(
              stream: queryProductsRecord(
                queryBuilder: (query) => query.orderBy('created_at', descending: true),
                limit: 100,
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var products = snapshot.data!;
                final searchTerm = _model.searchTextController.text.toLowerCase();
                if (searchTerm.isNotEmpty) {
                  products = products.where((product) {
                    return product.name.toLowerCase().contains(searchTerm) ||
                        product.description.toLowerCase().contains(searchTerm);
                  }).toList();
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        leading: product.photo.isNotEmpty
                            ? CorsSafeImage(
                                imageUrl: product.photo,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                borderRadius: BorderRadius.circular(8),
                              )
                            : Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.image, size: 30),
                              ),
                        title: Text(product.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${product.sellRent} - \$${product.price}'),
                            Row(
                              children: [
                                if (product.isFeatured)
                                  const Chip(
                                    label: Text('Featured', style: TextStyle(fontSize: 10)),
                                    backgroundColor: Colors.amber,
                                  ),
                                const SizedBox(width: 8),
                                Chip(
                                  label: Text(product.catergories, style: const TextStyle(fontSize: 10)),
                                  backgroundColor: Colors.blue[100],
                                ),
                              ],
                            ),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow('Description', product.description),
                                _buildInfoRow('Condition', product.condition),
                                _buildInfoRow('Quantity', product.quantity.toString()),
                                _buildInfoRow('Category', product.catergories),
                                _buildInfoRow('Type', product.sellRent),
                                _buildInfoRow('Created', dateTimeFormat('yMMMd', product.createdAt)),
                                if (product.modifiedAt != null)
                                  _buildInfoRow('Modified', dateTimeFormat('yMMMd', product.modifiedAt)),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    FFButtonWidget(
                                      onPressed: () => _removeProduct(product),
                                      text: 'Remove',
                                      icon: const Icon(Icons.delete, size: 15),
                                      options: const FFButtonOptions(
                                        height: 40,
                                        color: Colors.red,
                                        textStyle: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    FFButtonWidget(
                                      onPressed: () => _toggleFeatured(product),
                                      text: product.isFeatured ? 'Unfeature' : 'Feature',
                                      icon: Icon(
                                        product.isFeatured ? Icons.star_border : Icons.star,
                                        size: 15,
                                      ),
                                      options: const FFButtonOptions(
                                        height: 40,
                                        color: Colors.amber,
                                        textStyle: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    FFButtonWidget(
                                      onPressed: () => _viewProductDetails(product),
                                      text: 'Details',
                                      icon: const Icon(Icons.info, size: 15),
                                      options: FFButtonOptions(
                                        height: 40,
                                        color: FlutterFlowTheme.of(context).primary,
                                        textStyle: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
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

  Future<void> _removeProduct(ProductsRecord product) async {
    final reasonController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Listing'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Remove "${product.name}"?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for removal',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (result == true && reasonController.text.isNotEmpty) {
      await AdminService.removeContent(
        contentType: 'product',
        contentRef: product.reference,
        removedBy: currentUserReference!,
        reason: reasonController.text,
      );
      setState(() {});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listing removed successfully')),
      );
    }
  }

  Future<void> _toggleFeatured(ProductsRecord product) async {
    await product.reference.update({'IsFeatured': !product.isFeatured});
    setState(() {});
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(product.isFeatured ? 'Listing unfeatured' : 'Listing featured'),
      ),
    );
  }

  void _viewProductDetails(ProductsRecord product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (product.photo.isNotEmpty)
                CorsSafeImage(
                  imageUrl: product.photo,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(8),
                ),
              const SizedBox(height: 16),
              _buildInfoRow('Description', product.description),
              _buildInfoRow('Price', '\$${product.price}'),
              _buildInfoRow('Condition', product.condition),
              _buildInfoRow('Quantity', product.quantity.toString()),
              _buildInfoRow('Category', product.catergories),
              _buildInfoRow('Type', product.sellRent),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
