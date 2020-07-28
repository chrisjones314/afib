import 'package:meta/meta.dart';
import 'af_id.dart';

/// Base class for transient data associated with an [AFScreen], and stored
/// in the [AFRoute]
@immutable
class AFRouteParam {
  AFRouteParam();

  bool matchesScreen(AFScreenID screen) {
    return false;
  }

  Type get effectiveScreenRuntimeType {
    return null;
  }

  AFRouteParam paramFor(AFScreenID screen) {
    return this;
  }
}

/// Can be used in cases where no route param is necessary
class AFRouteParamUnused extends AFRouteParam {
  
}