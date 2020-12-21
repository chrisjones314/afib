import 'package:afib/src/dart/utils/af_object_with_key.dart';
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
class AFUpdateAppStateAction extends AFObjectWithKey {
  final Type area;
  final List<Object> toIntegrate;
  
  AFUpdateAppStateAction({AFID id,
    @required this.area,
    @required this.toIntegrate
  }): super(id: id);

  /// A utility for creating a list of revised models.   
  /// 
  /// You will repeatedly call .add for all your revised models,
  /// then use [AFUpdateAppStateAction..updateMany] to create an action
  /// that updates them all.
  static List<Object> createModelList() {
    return <Object>[];
  }

  /// Constructor for updating one object at the root of the [AFAppState]
  factory AFUpdateAppStateAction.updateOne(Type area, Object o) {
    final toIntegrate = [o];
    return AFUpdateAppStateAction(
      area: area,
      toIntegrate: toIntegrate
    );
  }

  /// Constructor for updating multiple objects at the root of the [AFAppState]
  factory AFUpdateAppStateAction.updateMany(Type area, Iterable<Object> objs) {
    final toIntegrate = objs.toList();
    return AFUpdateAppStateAction(
      area: area,
      toIntegrate: toIntegrate
    );        
  }

}