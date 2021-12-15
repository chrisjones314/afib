import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/af_typedefs_dart.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:meta/meta.dart';

/// When wrapped around a model object, causes it to be 
/// referenced by the specified id in an 
/// [AFFlexibleState] or [AFFlexibleStateView].
///
class AFWrapModelWithCustomID {
  final String id;
  final Object? model;
  AFWrapModelWithCustomID(this.id, this.model);
}


// When an object is derived from this method.
class AFModelWithCustomID {
  final String? customStateId;

  /// By default each model uses its class name as a key to uniquely 
  /// identify itself in the [AFFlexibleState].  However, if you want
  /// to have two objects of the same class in the AFAppState,
  /// you can pass each one a unique [customStateKey].
  AFModelWithCustomID({this.customStateId});

  static String stateKeyFor(Object o) {
    if(o is AFModelWithCustomID) {
      final customSK = o.customStateId;
      if(customSK != null) {
        return customSK;
      }
    }

    if(o is AFWrapModelWithCustomID) {
      return o.id;
    }

    return o.runtimeType.toString();
  }

  static Object? modelFor(Object? source) {
    if(source is AFWrapModelWithCustomID) {
      return source.model;
    }
    return source;
  }

}

abstract class AFStateModelAccess {
  T findModel<T extends Object>();
  T? findModelOrNull<T extends Object>();
  T findId<T extends Object>(String id);
  T? findIdOrNull<T extends Object>(String id);
  Iterable<Object> get allModels;
}

/// 
/// 
@immutable
abstract class AFFlexibleState extends AFStateModelAccess {
  final Map<String, Object> models;
  final AFCreateComponentStateDelegate create;

  AFFlexibleState({
    required this.models,
    required this.create,
  });

  /*factory AFAppState.createFrom(Iterable<Object> models) {
    return AFAppState(models: AFAppState.integrate(AFAppState.empty(), models));
  }*/

  static Map<String, Object> createModels(Iterable<Object> toIntegrate) {
    return integrate(<String, Object>{}, toIntegrate);
  }

  static Map<String, Object> integrate(Map<String, Object> original, Iterable<Object> toIntegrate) {
    final revised = Map<String, Object>.of(original);
    for(final sourceModel in toIntegrate) {
      final key = AFModelWithCustomID.stateKeyFor(sourceModel);
      final model = AFModelWithCustomID.modelFor(sourceModel);
      if(model != null) {
        revised[key] = model;
      }
    }
    return revised;
  }

  static Map<String, Object> empty() {
    return <String, Object>{};
  }

  Iterable<Object> get allModels {
    return models.values;
  }

  T findModel<T extends Object>() {
    return findModelWithCustomKey(T.toString());
  }

  T? findModelOrNull<T extends Object>() {
    return findModelWithCustomKeyOrNull(T.toString());
  }

  T findId<T extends Object>(String id) {
    return findModelWithCustomKey(id);
  }

  T? findIdOrNull<T extends Object>(String id) {
    return findModelWithCustomKeyOrNull(id);
  }

  T findModelWithCustomKey<T>(String key) {
    final result = models[key] as T;
    if(result == null) throw AFException("No model defined for $key");
    return result;
  }

  T? findModelWithCustomKeyOrNull<T extends Object?>(String key) {
    final result = models[key] as T?;
    return result;
  }

  AFFlexibleState mergeWith(AFFlexibleState other) {
    final revisedModels = integrate(this.models, other.models.values);
    return createWith(revisedModels);    
  }

  AFFlexibleState copyWith(List<Object> toIntegrate) {
    return createWith(AFFlexibleState.integrate(models, toIntegrate));
  }

  AFFlexibleState reviseModels(List<Object> toIntegrate) {
    return createWith(AFFlexibleState.integrate(models, toIntegrate));
  }

  AFFlexibleState copyWithOne(Object toIntegrate) {
    final toI = <Object>[];
    toI.add(toIntegrate);
    return copyWith(toI);
  }

  AFFlexibleState createWith(Map<String, Object> models) {
    return create(models);
  }
}

@immutable
class AFComponentStateUnused extends AFFlexibleState {
  static final AFCreateComponentStateDelegate creator = (models) => AFComponentStateUnused(models);
  AFComponentStateUnused(Map<String, Object> models): super(models: models, create: creator);


  static AFComponentStateUnused initialValue() { return AFComponentStateUnused(<String, Object>{}); }


}


/// Tracks the application state and any state provided by third parties.
@immutable
class AFComponentStates {
  final Map<String, AFFlexibleState> states;

  AFComponentStates({
    required this.states
  });

  factory AFComponentStates.createFrom(List<AFFlexibleState> areas) {
    final states = <String, AFFlexibleState>{};
    for(final area in areas) {
      final areaType = _keyForComponent(area);
      states[areaType] = area;
    }

    // if you don't have a state, you can use AFFlexibleState as a substitute.  We need to have this
    // be non-null, so we add an empty one.
    final tempModel = AFComponentStateUnused(<String, Object>{});
    final areaType = _keyForComponent(tempModel);
    states[areaType] = tempModel;

    return AFComponentStates(states: states);
  }

  AFComponentStates reviseComponent(Type areaType, List<Object> models) {
    final revisedStates = Map<String, AFFlexibleState>.of(states);
    final key = _keyForComponent(areaType);
    if(key == "AFFlexibleState") {
      throw AFException("Attempting to set models on 'AFFlexibleState', this is most likely because you forgot to explicitly specify your AFFlexibleState type as a type parameter somewhere.");
    }
    final initialState = states[key];
    assert(initialState != null);
    if(initialState != null) {
      final revisedState = initialState.reviseModels(models);
      revisedStates[key] = revisedState;
    }

    final log = AFibD.logStateAF;
    if(log != null) {
      log.d("In area $areaType revised");
      for(final model in models ) {
        log.d("  ${model.runtimeType}: ${model.toString()}");
      }
    }

    return AFComponentStates(states: revisedStates);    
  }

  AFFlexibleState? stateFor(Type areaType) {
    final key = _keyForComponent(areaType);
    return states[key];
  }

  static _keyForComponent(dynamic area) {
    if(area is Type) {
      return area.toString();
    }
    return area.runtimeType.toString();
  }
  
}
