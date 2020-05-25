import 'package:meta/meta.dart';

/// Base class for transient data associated with an [AFScreen], and stored
/// in the [AFRoute]
@immutable
class AFRouteParam {
  AFRouteParam();
}

/// Can be used in cases where no route param is necessary
class AFRouteParamUnused extends AFRouteParam {
  
}