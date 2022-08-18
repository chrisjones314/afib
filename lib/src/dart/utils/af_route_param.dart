import 'package:afib/afui_id.dart';
import 'package:afib/src/dart/redux/state/models/af_time_state.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:meta/meta.dart';

/// The two different 'route' types in AFib.
enum AFRouteLocation {
  /// The primary hierarchical route, as you push screens using [AFNavigatePushAction],
  /// this route gets longer/deeper.   As you pop them with [AFNavigatePopAction] it gets
  /// shorter/shallower.
  routeHierarchy,

  /// The global pool just a pool of route paramaters organized by screen id.  This is used
  /// for things like drawers that can be dragged onto the screen, dialogs and popups, and 
  /// third party widgets that want to maintain a global root parameter across many different
  /// screens.
  routeGlobalPool, 
}

enum AFWidgetParamSource {
  parent,
  child,
  global,
  notApplicable
}

class AFRouteParam {
  final AFRouteLocation routeLocation;
  final AFWidgetID? wid;
  final Object? flutterStatePrivate;
  final AFID screenId;
  final AFTimeStateUpdateSpecificity? timeSpecificity;

  const AFRouteParam({
    required this.screenId,
    required this.routeLocation,
    this.wid,
    this.flutterStatePrivate,
    this.timeSpecificity,
  });

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

  String toString() {
    return runtimeType.toString();
  }

  void dispose() {}

}


class AFScreenRouteParam extends AFRouteParam {
  AFScreenRouteParam({
    required AFID screenId,
    AFRouteLocation routeLocation = AFRouteLocation.routeHierarchy,
    AFTimeStateUpdateSpecificity? timeSpecificity,
  }): super(
    screenId: screenId,
    routeLocation: routeLocation,
    timeSpecificity: timeSpecificity,
    flutterStatePrivate: null,
    wid: null,
  );
}

class AFBottomSheetRouteParam extends AFScreenRouteParam {
  AFBottomSheetRouteParam({
    required AFID screenId,
    AFTimeStateUpdateSpecificity? timeSpecificity,
  }): super(
    screenId: screenId,
    routeLocation: AFRouteLocation.routeGlobalPool,
    timeSpecificity: timeSpecificity,
  );
}

class AFDialogRouteParam extends AFScreenRouteParam {
  AFDialogRouteParam({
    required AFID screenId,
    AFTimeStateUpdateSpecificity? timeSpecificity    
  }): super(
    screenId: screenId,
    routeLocation: AFRouteLocation.routeGlobalPool,
    timeSpecificity: timeSpecificity,
  );
}


class AFDrawerRouteParam extends AFScreenRouteParam {
  AFDrawerRouteParam({
    required AFID screenId,
    AFTimeStateUpdateSpecificity? timeSpecificity    
  }): super(
    screenId: screenId,
    routeLocation: AFRouteLocation.routeGlobalPool,
    timeSpecificity: timeSpecificity,
  );
}

class AFWidgetRouteParam extends AFRouteParam {
  AFWidgetRouteParam({
    required AFID screenId,
    required AFRouteLocation routeLocation,
    required AFWidgetID wid,
  }): super(
    screenId: screenId,
    routeLocation: routeLocation,
    wid: wid,
  );

  AFWidgetID get widGuaranteed {
    return wid!;
  }
}

/// Used internally in test cases where we need to substitute a different screen id,
/// for the original screen id in a route param passed to a test.   You can call 
/// unwrap to get the original route param of the correct type.
@immutable
class AFRouteParamWrapper extends AFRouteParam {
  final AFRouteParam original;

  AFRouteParamWrapper({
    required AFID screenId,
    required this.original,
  }): super(screenId: screenId, routeLocation: original.routeLocation);
  
  AFRouteParam unwrap() { return original; }
}


class AFRouteParamUnused extends AFRouteParam {
  static const unused = AFRouteParamUnused(id: AFUIScreenID.unused);

  const AFRouteParamUnused({ required AFID id} ): super(screenId: id, routeLocation: AFRouteLocation.routeGlobalPool, wid: null);

  factory AFRouteParamUnused.create({
    required AFID id
  }) {
    return AFRouteParamUnused(id: id);
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