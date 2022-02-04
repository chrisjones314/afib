import 'package:afib/id.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:meta/meta.dart';

enum AFWidgetParamSource {
  parent,
  child,
  notApplicable
}

/// Can be used in cases where no route param is necessary

/// Base class for transient data associated with an [AFScreen], and stored
/// in the [AFRoute]
@immutable
class AFRouteParam {
  // a screen or widget id this route parameter is associated with.
  final AFID id;

  const AFRouteParam({
    required this.id
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

  /// Called when the param is permenantly destroyed.
  /// 
  /// This is used to that you can put things with persistent state,
  /// like TapGestureRecognizer, in your route parameter, and then clean
  /// it up when the screen goes away.
  void dispose() {

  }

  String toString() {
    return runtimeType.toString();
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
  }): super(id: screenId);
  
  AFRouteParam unwrap() { return original; }
}


class AFRouteParamUnused extends AFRouteParam {
  static const unused = AFRouteParamUnused(id: AFUIScreenID.unused);

  const AFRouteParamUnused({ required AFScreenID id} ): super(id: id);

  factory AFRouteParamUnused.create({
    required AFScreenID id
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