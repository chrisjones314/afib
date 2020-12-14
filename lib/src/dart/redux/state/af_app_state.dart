

import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:meta/meta.dart';

/// All models in the [AFAppStateArea] must be derived from
/// AFAppStateModel.  
/// 
/// Note that this is only at the root level of AFAppState,
/// nested data can be plain dart objects.
@immutable 
class AFAppStateModel {
  final String customStateKey;

  /// By default each model uses its class name as a key to uniquely 
  /// identify itself in the [AFAppStateArea].  However, if you want
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
abstract class AFAppStateArea {
  final Map<String, Object> models;

  AFAppStateArea({this.models});

  /*factory AFAppState.createFrom(Iterable<Object> models) {
    return AFAppState(models: AFAppState.integrate(AFAppState.empty(), models));
  }*/

  static Map<String, Object> integrate(Map<String, Object> original, Iterable<Object> toIntegrate) {
    final revised = Map<String, Object>.of(original);
    for(final model in toIntegrate) {
      final key = AFAppStateModel.stateKeyFor(model);
      revised[key] = model;
    }
    return revised;
  }

  static Map<String, Object> empty() {
    return <String, Object>{};
  }

  Object findModel(Type t) {
    return models[t.toString()];
  }

  Object findModelWithCustomKey(String key) {
    return models[key];
  }
  AFAppStateArea mergeWith(AFAppStateArea other) {
    final revisedModels = integrate(this.models, other.models.values);
    return createWith(revisedModels);    
  }

  AFAppStateArea copyWith(List<Object> toIntegrate) {
    return createWith(AFAppStateArea.integrate(models, toIntegrate));
  }

  AFAppStateArea reviseModels(List<Object> toIntegrate) {
    return createWith(AFAppStateArea.integrate(models, toIntegrate));
  }

  AFAppStateArea copyWithOne(Object toIntegrate) {
    final toI = <Object>[];
    toI.add(toIntegrate);
    return copyWith(toI);
  }

  AFAppStateArea createWith(Map<String, Object> models);
}

/// Tracks the application state and any state provided by third parties.
@immutable
class AFAppStateAreas {
  final Map<String, AFAppStateArea> states;

  AFAppStateAreas({
    @required this.states
  });

  factory AFAppStateAreas.createFrom(List<AFAppStateArea> areas) {
    final states = <String, AFAppStateArea>{};
    for(final area in areas) {
      final areaType = _keyForArea(area);
      states[areaType] = area;
    }

    return AFAppStateAreas(states: states);
  }

  AFAppStateAreas reviseArea(Type areaType, List<Object> models) {
    final revisedStates = Map<String, AFAppStateArea>.of(states);
    final key = _keyForArea(areaType);
    if(key == "AFAppStateArea") {
      throw AFException("Attempting to set models on 'AFAppStateArea', this is most likely because you forgot to explicitly specify your AFAppStateArea type as a type parameter somewhere.");
    }
    final initialState = states[key];
    final revisedState = initialState.reviseModels(models);
    revisedStates[key] = revisedState;
    return AFAppStateAreas(states: revisedStates);    
  }

  AFAppStateArea stateFor(Type areaType) {
    final key = _keyForArea(areaType);
    return states[key];
  }

  static _keyForArea(dynamic area) {
    if(area is Type) {
      return area.toString();
    }
    return area.runtimeType.toString();
  }
  
}
