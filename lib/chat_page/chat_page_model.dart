import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'chat_page_widget.dart' show ChatPageWidget;
import 'package:flutter/material.dart';
import 'dart:io';

class ChatPageModel extends FlutterFlowModel<ChatPageWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;

  // State field(s) for Report modal
  String? reportCategory;
  TextEditingController? reportDescriptionController;
  FocusNode? reportDescriptionFocusNode;

  // State field(s) for attachment
  File? selectedFile;
  String? selectedFileName;
  String? selectedFileType;
  String? uploadedFileUrl;
  Uint8List? selectedFileBytes;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
    reportDescriptionController?.dispose();
    reportDescriptionFocusNode?.dispose();
  }
}
