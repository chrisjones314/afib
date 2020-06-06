import 'package:afib/src/dart/redux/actions/af_action_with_key.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:meta/meta.dart';


/// Use this action to reset the entire state of the application to it's
/// initial state.
@immutable
class AFResetToInitialStateAction {

}

/// Action used to update one or more of the root objects in the [AFAppState].
/// 
/// If you have nested data that you need to update, update the leaf objects
/// and use copyWith to propogate the change up to a root object in [AFAppState],
/// then issue an [AFUpdateAppStateAction]
class AFUpdateAppStateAction extends AFActionWithKey {
  final List<Object> toIntegrate = List<Object>();
  
  /// Constructor for use with the [add] method, which allows you to update
  /// several different root objects in the [AFAppState] with a single dispatch.
  AFUpdateAppStateAction({AFID id}): super(id: id);

  /// Constructor for updating one object at the root of the [AFAppState]
  AFUpdateAppStateAction.updateOne(Object o) {
    toIntegrate.add(o);
  }

  /// Constructor for updating multiple objects at the root of the [AFAppState]
  AFUpdateAppStateAction.updateAll(Iterable<Object> objs) {
    toIntegrate.addAll(objs);
  }

  ///
  void add(Object o) {
    toIntegrate.add(o);
  }
}