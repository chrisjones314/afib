import 'package:afib/afib_uiid.dart';
import 'package:afib/src/dart/redux/state/models/af_time_state.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/utils/af_param_ui_state_holder.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

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

  AFRouteParamWithFlutterState({
    required AFScreenID screenId,
    required AFRouteLocation routeLocation,
    required AFWidgetID wid,
    AFFlutterRouteParamState? flutterState,
    AFTimeStateUpdateSpecificity? timeSpecificity,
  }): super(
    screenId: screenId,
    routeLocation: routeLocation,
    timeSpecificity: timeSpecificity,
    flutterStatePrivate: flutterState,
    wid: wid,
  );

   void updateTextField(AFWidgetID wid, String text) {
    final tc = flutterStateGuaranteed.textControllers;
    if(tc == null) {
      throw AFException(AFStateProgrammingInterface.errNeedTextControllers);
    }
    tc.update(wid, text);
  }

  AFFlutterRouteParamState? get flutterState {
    return this.flutterStatePrivate as AFFlutterRouteParamState?;
  }


  AFFlutterRouteParamState get flutterStateGuaranteed {
    return this.flutterStatePrivate as AFFlutterRouteParamState;
  }

  AFTextEditingController? accessTextController(AFWidgetID wid) {
    final tc = flutterState?.textControllers;
    if(tc == null) {
      throw AFException(AFStateProgrammingInterface.errNeedTextControllers);
    }
    return tc.access(wid);
  }

  TapGestureRecognizer accessTapRecognizer(AFWidgetID wid) {
    final tc = flutterState?.tapRecognizers;
    if(tc == null) {
      throw AFException(AFStateProgrammingInterface.errNeedTapRecognizers);
    }
    return tc.access(wid);
  }

  AFTapGestureRecognizersHolder? get accessTapRecognizers {
    return flutterState?.tapRecognizers;
  }

  String accessTextText(AFWidgetID wid) {
    final controller = accessTextController(wid);
    return controller?.text ?? "";
  }

  FocusNode? accessFocusNode(AFWidgetID wid) {
    final node = flutterState?.focusNodes?.access(wid);
    return node;
  }


  ScrollController accessScrollController(AFWidgetID wid) {
    final sc = flutterState?.scrollControllers;
    if(sc == null) {
      throw AFException(AFStateProgrammingInterface.errNeedScrollControllers);
    }
    return sc.access(wid);
  }

  @override
  void dispose() {
    flutterState?.dispose();
  }
 
}

class AFScreenRouteParamWithFlutterState extends AFRouteParamWithFlutterState  {
  AFScreenRouteParamWithFlutterState({
    required AFScreenID screenId,
    required AFFlutterRouteParamState flutterState,
    AFTimeStateUpdateSpecificity? timeSpecificity,
    AFRouteLocation routeLocation = AFRouteLocation.screenHierarchy,
  }): super(
    screenId: screenId,
    wid: AFUIWidgetID.useScreenParam,
    routeLocation: routeLocation,
    timeSpecificity: timeSpecificity,
    flutterState: flutterState,
    
  );
}

class AFBottomSheetRouteParamWithFlutterState extends AFScreenRouteParamWithFlutterState {
  AFBottomSheetRouteParamWithFlutterState({
    required AFScreenID screenId,
    required AFFlutterRouteParamState flutterState,
    AFTimeStateUpdateSpecificity? timeSpecificity    
  }): super(
    screenId: screenId,
    flutterState: flutterState,
    timeSpecificity: timeSpecificity,
    routeLocation: AFRouteLocation.globalPool
  );
}

class AFDialogRouteParamWithFlutterState extends AFScreenRouteParamWithFlutterState {
  AFDialogRouteParamWithFlutterState({
    required AFScreenID screenId,
    required AFFlutterRouteParamState flutterState,
  }): super(
    screenId: screenId,
    flutterState: flutterState,
    routeLocation: AFRouteLocation.globalPool
  );
}

class AFDrawerRouteParamWithFlutterState extends AFScreenRouteParamWithFlutterState {
  AFDrawerRouteParamWithFlutterState({
    required AFScreenID screenId,
    required AFFlutterRouteParamState flutterState,
  }): super(
    screenId: screenId,
    flutterState: flutterState,
    routeLocation: AFRouteLocation.globalPool,
  );
}

class AFWidgetRouteParamWithFlutterState extends AFRouteParamWithFlutterState {
  AFWidgetRouteParamWithFlutterState({
    required AFScreenID screenId,
    required AFRouteLocation routeLocation,
    required AFWidgetID wid,
    required AFFlutterRouteParamState flutterState,
  }): super(
    screenId: screenId,
    routeLocation: routeLocation,
    wid: wid,
    flutterState: flutterState,
  );
}

