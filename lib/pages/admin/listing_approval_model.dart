import '/flutter_flow/flutter_flow_util.dart';
import 'listing_approval_widget.dart' show ListingApprovalWidget;
import 'package:flutter/material.dart';

class ListingApprovalModel extends FlutterFlowModel<ListingApprovalWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for search TextField widget.
  FocusNode? searchFocusNode;
  TextEditingController? searchTextController;
  String? Function(BuildContext, String?)? searchTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    searchFocusNode?.dispose();
    searchTextController?.dispose();
  }
}
