// ignore_for_file: non_constant_identifier_names
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/flutter_flow/form_validators.dart';
import '/index.dart';
import 'sell_widget.dart' show SellWidget;
import 'package:flutter/material.dart';

class SellModel extends FlutterFlowModel<SellWidget> {
  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();

  bool isDataUploading_uploadproductimage = false;
  FFUploadedFile uploadedLocalFile_uploadproductimage =
      FFUploadedFile(bytes: Uint8List.fromList([]));
  String uploadedFileUrl_uploadproductimage = '';

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController2;
  String? Function(BuildContext, String?)? textController2Validator;
  // State field(s) for Category dropdown
  String? categoryValue;
  FormFieldController<String>? categoryValueController;
  // State field(s) for Condition dropdown
  String? conditionValue;
  FormFieldController<String>? conditionValueController;
  // State field(s) for Sell/Rent dropdown
  String? sellrentValue;
  FormFieldController<String>? sellrentValueController;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode3;
  TextEditingController? textController4;
  String? Function(BuildContext, String?)? textController4Validator;
  // State field(s) for Quantity TextField widget.
  FocusNode? textFieldFocusNode4;
  TextEditingController? textController5;
  String? Function(BuildContext, String?)? textController5Validator;

  @override
  void initState(BuildContext context) {
    // Set up validators
    textController1Validator = FormValidators.validateProductName;
    textController2Validator = FormValidators.validateDescription;
    textController4Validator = FormValidators.validatePrice;
    textController5Validator = FormValidators.validateQuantity;
  }

  @override
  void dispose() {
    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    textFieldFocusNode2?.dispose();
    textController2?.dispose();

    textFieldFocusNode3?.dispose();
    textController4?.dispose();

    textFieldFocusNode4?.dispose();
    textController5?.dispose();
  }
}
