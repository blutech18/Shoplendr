import '/flutter_flow/flutter_flow_util.dart';
import 'rental_request_widget.dart' show RentalRequestWidget;
import 'package:flutter/material.dart';

class RentalRequestModel extends FlutterFlowModel<RentalRequestWidget> {
  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  
  // State field(s) for message text field
  FocusNode? messageFocusNode;
  TextEditingController? messageTextController;
  String? Function(BuildContext, String?)? messageTextControllerValidator;

  // State field(s) for rental dates
  DateTime? startDate;
  DateTime? endDate;

  // State field(s) for insurance agreement
  bool insuranceAgreed = false;

  // State field(s) for payment proof upload
  bool isDataUploading = false;
  FFUploadedFile uploadedLocalFile =
      FFUploadedFile(bytes: Uint8List.fromList([]));
  String uploadedFileUrl = '';

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    messageFocusNode?.dispose();
    messageTextController?.dispose();
  }

  /// Validation
  bool validateForm() {
    if (startDate == null || endDate == null) {
      return false;
    }
    if (endDate!.isBefore(startDate!)) {
      return false;
    }
    if (!insuranceAgreed) {
      return false;
    }
    if (uploadedFileUrl.isEmpty) {
      return false;
    }
    return true;
  }

  String? getValidationError() {
    if (startDate == null || endDate == null) {
      return 'Please select rental start and end dates';
    }
    if (endDate!.isBefore(startDate!)) {
      return 'End date must be after start date';
    }
    if (!insuranceAgreed) {
      return 'You must agree to the insurance terms';
    }
    if (uploadedFileUrl.isEmpty) {
      return 'Please upload proof of payment';
    }
    return null;
  }
}
