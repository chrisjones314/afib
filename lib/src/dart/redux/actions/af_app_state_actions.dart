import 'package:afib/src/dart/redux/actions/af_action_with_key.dart';
import 'package:afib/src/dart/redux/state/models/af_app_platform_info_state.dart';
import 'package:meta/meta.dart';


/// Use this action to reset the entire state of the application to it's
/// initial state.
@immutable
class AFResetToInitialStateAction {

}

/// This is typically not used by the application, it is used during testing
/// to revert to the initial application route.
class AFResetToInitialRouteAction {

}

class AFUpdateAppPlatformInfoAction {
  final AFAppPlatformInfoState appState;
  AFUpdateAppPlatformInfoAction(this.appState);
}

/// Use `context.updateComponent...` instead of using this directly.
/// 
/// Action used to update one or more of the root objects in the [AFComponentStates].
class AFUpdateAppStateAction extends AFActionWithKey {
  final Type area;
  final List<Object> toIntegrate;
  
  AFUpdateAppStateAction({
    super.id,
    required this.area,
    required this.toIntegrate
  });

  /// A utility for creating an empty list of models.
  static List<Object> createModelList() {
    return <Object>[];
  }

  /// Constructor for updating one object at the root of the [AFComponentState]
  factory AFUpdateAppStateAction.updateOne(Type area, Object o) {
    final toIntegrate = [o];
    return AFUpdateAppStateAction(
      area: area,
      toIntegrate: toIntegrate
    );
  }

  /// Constructor for updating multiple objects at the root of the [AFComponentState]
  factory AFUpdateAppStateAction.updateMany(Type area, Iterable<Object> objs) {
    final toIntegrate = objs.toList();
    return AFUpdateAppStateAction(
      area: area,
      toIntegrate: toIntegrate
    );        
  }

}