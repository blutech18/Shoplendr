import '/flutter_flow/flutter_flow_util.dart';
import 'return_item_widget.dart' show ReturnItemWidget;
import 'package:flutter/material.dart';

class ReturnItemModel extends FlutterFlowModel<ReturnItemWidget> {
  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  
  // State field(s) for notes text field
  FocusNode? notesFocusNode;
  TextEditingController? notesTextController;
  String? Function(BuildContext, String?)? notesTextControllerValidator;

  // State field(s) for return proof upload
  bool isDataUploading = false;
  FFUploadedFile uploadedLocalFile =
      FFUploadedFile(bytes: Uint8List.fromList([]));
  String uploadedFileUrl = '';

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    notesFocusNode?.dispose();
    notesTextController?.dispose();
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
      return 'Please upload proof of return (photo of item returned)';
    }
    return null;
  }
}
