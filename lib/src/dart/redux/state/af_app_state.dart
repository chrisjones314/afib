

import 'package:meta/meta.dart';

/// All models in the [AFAppState] must be derived from
/// AFAppStateModel.  
/// 
/// Note that this is only at the root level of AFAppState,
/// nested data can be plain dart objects.
@immutable 
class AFAppStateModel {
  final String customStateKey;

  /// By default each model uses its class name as a key to uniquely 
  /// identify itself in the [AFAppState].  However, if you want
  /// to have two objects of the same class in the AFAppState,
  /// you can pass each one a unique [customStateKey].
  AFAppStateModel({this.customStateKey});

  static String stateKeyFor(Object o) {
    if(o is AFAppStateModel) {
      if(o.customStateKey != null) {
        return o.customStateKey;
      }
    }
    return o.runtimeType.toString();
  }

}

/// The route application state must be an AFAppState.
/// 
/// AFAppState enables one or more subtrees of the state
/// to be replaced.
@immutable
abstract class AFAppState {
  final Map<String, Object> models;

  AFAppState({this.models});

  /*factory AFAppState.createFrom(Iterable<Object> models) {
    return AFAppState(models: AFAppState.integrate(AFAppState.empty(), models));
  }*/

  static Map<String, Object> integrate(Map<String, Object> original, Iterable<Object> toIntegrate) {
    final revised = Map<String, Object>.of(original);
    toIntegrate?.forEach( (model) {
      String key = AFAppStateModel.stateKeyFor(model);
      revised[key] = model;
    });
    return revised;
  }

  static Map<String, Object> empty() {
    return Map<String, Object>();
  }

  Object findModel(Type t) {
    return models[t.toString()];
  }

  Object findModelWithCustomKey(String key) {
    return models[key];
  }

  AFAppState copyWith(List<Object> toIntegrate) {
    return createWith(AFAppState.integrate(models, toIntegrate));
  }

  AFAppState createWith(Map<String, Object> models);
}