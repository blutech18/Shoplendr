import '/flutter_flow/flutter_flow_util.dart';
import 'buy_now_widget.dart' show BuyNowWidget;
import 'package:flutter/material.dart';

class BuyNowModel extends FlutterFlowModel<BuyNowWidget> {
  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  
  // State field(s) for payment proof upload
  bool isDataUploading = false;
  FFUploadedFile uploadedLocalFile =
      FFUploadedFile(bytes: Uint8List.fromList([]));
  String uploadedFileUrl = '';

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    // No controllers to dispose
  }

  /// Validation
  bool validateForm() {
    if (uploadedFileUrl.isEmpty) {
      return false;
    }
    return true;
  }

  String? getValidationError() {
    if (uploadedFileUrl.isEmpty) {
      return 'Please upload proof of payment';
    }
    return null;
  }
}
