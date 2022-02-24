
import 'package:afib/src/dart/redux/state/models/af_time_state.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/utils/af_param_ui_state_holder.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AFFlutterRouteParamState {
  final AFTextEditingControllers? textControllers;
  final AFScrollControllersHolder? scrollControllers;
  final AFTapGestureRecognizersHolder? tapRecognizers;
  final AFFocusNodesHolder? focusNodes;

  AFFlutterRouteParamState({
    this.textControllers,
    this.scrollControllers,
    this.tapRecognizers,
    this.focusNodes,
  });

  void dispose() {
    textControllers?.dispose();
    scrollControllers?.dispose();
    tapRecognizers?.dispose();
    focusNodes?.dispose();
  }
}

class AFRouteParamWithFlutterState extends AFRouteParam {
  final AFFlutterRouteParamState flutterState;

  AFRouteParamWithFlutterState({
    required AFID id,
    required this.flutterState,
    AFTimeStateUpdateSpecificity? timeSpecificity,
  }): super(id: id, timeSpecificity: timeSpecificity);

  void updateTextField(AFWidgetID wid, String text) {
    final tc = flutterState.textControllers;
    if(tc == null) {
      throw AFException(AFStateProgrammingInterface.errNeedTextControllers);
    }
    tc.update(wid, text);
  }

  AFTextEditingController? accessTextController(AFWidgetID wid) {
    final tc = flutterState.textControllers;
    if(tc == null) {
      throw AFException(AFStateProgrammingInterface.errNeedTextControllers);
    }
    return tc.access(wid);
  }

  TapGestureRecognizer accessTapRecognizer(AFWidgetID wid) {
    final tc = flutterState.tapRecognizers;
    if(tc == null) {
      throw AFException(AFStateProgrammingInterface.errNeedTapRecognizers);
    }
    return tc.access(wid);
  }

  AFTapGestureRecognizersHolder? get accessTapRecognizers {
    return flutterState.tapRecognizers;
  }

  String accessTextText(AFWidgetID wid) {
    final controller = accessTextController(wid);
    return controller?.text ?? "";
  }


  ScrollController accessScrollController(AFWidgetID wid) {
    final sc = flutterState.scrollControllers;
    if(sc == null) {
      throw AFException(AFStateProgrammingInterface.errNeedScrollControllers);
    }
    return sc.access(wid);
  }

  @override
  void dispose() {
    flutterState.dispose();
  }

}
