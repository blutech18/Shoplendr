import '/flutter_flow/flutter_flow_util.dart';
import 'admin_messages_widget.dart' show AdminMessagesWidget;
import 'package:flutter/material.dart';
import 'dart:io';

class AdminMessagesModel extends FlutterFlowModel<AdminMessagesWidget> {
  /// Local state fields for this page.
  
  final unfocusNode = FocusNode();
  
  // Text controller for message input
  TextEditingController? messageController;
  FocusNode? messageFocusNode;
  
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
    unfocusNode.dispose();
    messageController?.dispose();
    messageFocusNode?.dispose();
  }
}
