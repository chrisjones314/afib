import 'package:afib/src/dart/utils/af_id.dart';
import 'package:meta/meta.dart';

/// Base class for transient data associated with an [AFScreen], and stored
/// in the [AFRoute]
@immutable
class AFRouteParam {
  AFRouteParam();

  bool matchesScreen(AFScreenID screen) {
    return false;
  }

  AFScreenID get effectiveScreenId {
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
}

/// Can be used in cases where no route param is necessary
class AFRouteParamUnused extends AFRouteParam {
  
}