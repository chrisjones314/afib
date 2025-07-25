import 'package:afib/afib_uiid.dart';
import 'package:afib/src/dart/redux/state/models/af_time_state.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:meta/meta.dart';

/// The two different 'route' types in AFib.
enum AFRouteLocation {
  /// The primary hierarchical route, as you push screens using [AFNavigatePushAction],
  /// this route gets longer/deeper.   As you pop them with [AFNavigatePopAction] it gets
  /// shorter/shallower.
  screenHierarchy,

  /// The global pool just a pool of route paramaters organized by screen id.  This is used
  /// for things like drawers that can be dragged onto the screen, dialogs and popups, and 
  /// third party widgets that want to maintain a global root parameter across many different
  /// screens.
  globalPool, 
}

class AFRouteParam {
  final AFRouteLocation routeLocation;
  final AFWidgetID wid;
  final Object? flutterStatePrivate;
  final AFScreenID screenId;
  final AFTimeStateUpdateSpecificity? timeSpecificity;

  const AFRouteParam({
    required this.screenId,
    required this.routeLocation,
    this.wid = AFUIWidgetID.useScreenParam,
    this.flutterStatePrivate,
    this.timeSpecificity,
  });

  bool get hasChildWID {
    return wid != AFUIWidgetID.useScreenParam;
  }

  bool matchesScreen(AFID screen) {
    return false;
  }

  AFScreenID? get effectiveScreenId {
    return null;
  }

  AFRouteParam paramFor(AFScreenID screen) {
    return this;
  }

  AFRouteParam? reviseForTime(AFTimeState timeState) {
    return null;
  }

  @override
  String toString() {
    return runtimeType.toString();
  }

  void dispose() {}

  /// Provides an opportunity to merge this new param with an old param when you 
  /// update a route parameter that already exists.
  /// 
  /// By default, just returns this, meaning that writes are just straight replacements.
  AFRouteParam mergeOnWrite(AFRouteParam oldParam) {
    return this;
  }
}


class AFScreenRouteParam extends AFRouteParam {
  AFScreenRouteParam({
    required super.screenId,
    super.routeLocation = AFRouteLocation.screenHierarchy,
    super.timeSpecificity,
    super.wid,
  }): super(
    flutterStatePrivate: null,
  );
}

class AFBottomSheetRouteParam extends AFScreenRouteParam {
  AFBottomSheetRouteParam({
    required super.screenId,
    super.timeSpecificity,
  }): super(
    routeLocation: AFRouteLocation.globalPool,
  );
}

class AFDialogRouteParam extends AFScreenRouteParam {
  AFDialogRouteParam({
    required super.screenId,
    super.timeSpecificity    
  }): super(
    routeLocation: AFRouteLocation.globalPool,
  );
}


class AFDrawerRouteParam extends AFScreenRouteParam {
  AFDrawerRouteParam({
    required super.screenId,
    super.timeSpecificity    
  }): super(
    routeLocation: AFRouteLocation.globalPool,
  );
}

class AFWidgetRouteParam extends AFRouteParam {
  AFWidgetRouteParam({
    required super.screenId,
    required super.routeLocation,
    required super.wid,
  });
}

/// Used internally in test cases where we need to substitute a different screen id,
/// for the original screen id in a route param passed to a test.   You can call 
/// unwrap to get the original route param of the correct type.
@immutable
class AFRouteParamWrapper extends AFRouteParam {
  final AFRouteParam original;

  AFRouteParamWrapper({
    required super.screenId,
    required this.original,
  }): super(routeLocation: original.routeLocation, wid: AFUIWidgetID.useScreenParam);
  
  AFRouteParam unwrap() { return original; }
}


class AFRouteParamUnused extends AFRouteParam {
  static const unused = AFRouteParamUnused(screenId: AFUIScreenID.unused, routeLocation: AFRouteLocation.globalPool, wid: AFUIWidgetID.useScreenParam);
  const AFRouteParamUnused({ 
    required super.screenId, 
    required super.wid, 
    required super.routeLocation 
  });

  factory AFRouteParamUnused.forScreen(AFScreenID screenId) {
    return AFRouteParamUnused(
      screenId: screenId,
      wid: AFUIWidgetID.useScreenParam,
      routeLocation: AFRouteLocation.screenHierarchy,
    );
  }

}

class AFRouteParamRef extends AFRouteParam {
  const AFRouteParamRef({ 
    required super.screenId,
     required super.routeLocation,
     super.wid,
  } );

  factory AFRouteParamRef.forScreen(
    AFScreenID screenId, {
    AFRouteLocation routeLocation = AFRouteLocation.screenHierarchy,
  }) {
    return AFRouteParamRef(screenId: screenId, routeLocation: routeLocation);
  }

  factory AFRouteParamRef.forWidget({
    required AFScreenID screenId,
    required AFWidgetID wid,
    AFRouteLocation routeLocation = AFRouteLocation.screenHierarchy,
  }) {
    return AFRouteParamRef(screenId: screenId, wid: wid, routeLocation: routeLocation);
  }

  factory AFRouteParamRef.forWidgetTest({
    required AFWidgetID wid,
  }) {
    return AFRouteParamRef(screenId: AFUIScreenID.screenPrototypeWidget, routeLocation: AFRouteLocation.screenHierarchy, wid: wid);
  }

  /*
  factory AFRouteParamRef.createForWidget({
    required AFScreenID screenId,
    required AFWidgetID wid,
    required AFRouteLocation routeLocation,    
  }) {
    return AFRouteParamRef(screenId: screenId, routeLocation: routeLocation, wid: wid);
  }
  */


  factory AFRouteParamRef.forDrawer({
    required AFScreenID screenId,
  }) {
    return AFRouteParamRef(screenId: screenId, routeLocation: AFRouteLocation.globalPool);
  }

  factory AFRouteParamRef.forBottomSheet({
    required AFScreenID screenId,
  }) {
    return AFRouteParamRef(screenId: screenId, routeLocation: AFRouteLocation.globalPool);
  }

  factory AFRouteParamRef.forDialog({
    required AFScreenID screenId,
  }) {
    return AFRouteParamRef(screenId: screenId, routeLocation: AFRouteLocation.globalPool);
  }

}


class AFRouteParamChild {
  final AFID wid;
  final AFRouteParam param;
  
  AFRouteParamChild({
    required this.wid,
    required this.param,
  });
  
  AFRouteParamChild reviseParam(AFRouteParam revised) {
    return AFRouteParamChild(
      wid: this.wid,
      param: revised
    );
  }

  void dispose() {
    param.dispose();
  }
}