import '/flutter_flow/flutter_flow_util.dart';
import 'my_transactions_widget.dart' show MyTransactionsWidget;
import 'package:flutter/material.dart';

class MyTransactionsModel extends FlutterFlowModel<MyTransactionsWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    tabBarController?.dispose();
  }
}
