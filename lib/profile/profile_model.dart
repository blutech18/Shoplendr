// ignore_for_file: non_constant_identifier_names
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'profile_widget.dart' show ProfileWidget;
import 'package:flutter/material.dart';

class ProfileModel extends FlutterFlowModel<ProfileWidget> {
  ///  State fields for stateful widgets in this page.

  bool isDataUploading_uploadprofilepic = false;
  FFUploadedFile uploadedLocalFile_uploadprofilepic =
      FFUploadedFile(bytes: Uint8List.fromList([]));
  String uploadedFileUrl_uploadprofilepic = '';

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
