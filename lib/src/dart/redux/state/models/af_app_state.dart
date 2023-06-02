import 'package:afib/afib_uiid.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_object_with_key.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/dart/utils/af_typedefs_dart.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:meta/meta.dart';
import 'package:quiver/core.dart';

/// When wrapped around a model object, causes it to be 
/// referenced by the specified id in an 
/// [AFComponentState] or [AFFlexibleStateView].
///
class AFWrapModelWithCustomID {
  final String id;
  final Object? model;
  AFWrapModelWithCustomID(this.id, this.model);
}



class AFModelWithCustomID {
  final String? customStateId;

  /// By default each model uses its class name as a key to uniquely 
  /// identify itself in the [AFComponentState].  However, if you want
  /// to have two objects of the same class in the AFAppState,
  /// you can pass each one a unique [customStateId].
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

    if(o is AFObjectWithKey) {
      return o.key;
    }

    if(o is AFRouteParam) {
      final wid = o.wid;
      if(wid == AFUIWidgetID.useScreenParam) {
        return o.screenId.toString();
      } else {
        return wid.toString();
      }
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

/// Interface for finding state data 
/// 
/// Both states and state views are mappings of type names to object values.  This interface
/// provides standard methods for accessing data at the root of a state or state view.
abstract class AFStateModelAccess {
  T findType<T extends Object>();
  T? findTypeOrNull<T extends Object>();
  T findId<T extends Object>(String id);
  T? findIdOrNull<T extends Object>(String id);
  TRouteParam findScreenParam<TRouteParam extends AFRouteParam>(AFScreenID screenId);
  TRouteParam? findScreenParamOrNull<TRouteParam extends AFRouteParam>(AFScreenID screenId);
  TRouteParam findChildWidgetParam<TRouteParam extends AFRouteParam>(AFWidgetID widgetId);
  TRouteParam? findChildWidgetParamOrNull<TRouteParam extends AFRouteParam>(AFWidgetID widgetId);

  Iterable<Object> get allModels;
}

/// The root class for both state and state views
@immutable
abstract class AFComponentState extends AFStateModelAccess {
  final Map<String, Object> models;
  final AFCreateComponentStateDelegate create;

  AFComponentState({
    required this.models,
    required this.create,
  });

  /// Returns the map of type names to objects that the 
  /// constructor's [models] parameter expects.
  static Map<String, Object> createModels(Iterable<Object> toIntegrate) {
    return integrate(<String, Object>{}, toIntegrate);
  }

  /// Utility used to augment an existing mapping of type names to objects.
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

  //// Returns an empty map of type names to objects.
  static Map<String, Object> empty() {
    return <String, Object>{};
  }

  @override
  bool operator==(Object other) {
    if(other is! AFComponentState) {
      return false;
    }
    final modelsO = other.models;
    if(models.length != modelsO.length) {
      return false;
    }

    for(final keyT in models.keys) {
      final modelT = models[keyT];
      final modelO = modelsO[keyT];
      if(modelT != modelO) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode {
    var code = 0;
    for(final model in models.values) {
      code = hash2(code, model.hashCode);
    }
    return code;    
  }

  /// Returns all the model objects
  @override
  Iterable<Object> get allModels {
    return models.values;
  }

  /// Returns the object value for the type T
  @override
  T findType<T extends Object>() {
    return findModelWithCustomKey(T.toString());
  }

  /// Returns the object value for the type T, allows null or missing values.
  @override
  T? findTypeOrNull<T extends Object>() {
    return findModelWithCustomKeyOrNull(T.toString());
  }

  /// Returns the object value for the specified String key.
  @override
  T findId<T extends Object>(String id) {
    return findModelWithCustomKey(id);
  }

  /// Returns the object value for the specified String key, allows null or missing values.
  @override
  T? findIdOrNull<T extends Object>(String id) {
    return findModelWithCustomKeyOrNull(id);
  }

  /// Same as [findId]
  T findModelWithCustomKey<T>(String key) {
    final result = models[key] as T;
    if(result == null) throw AFException("No model defined for $key");
    return result;
  }

  /// Same as [findIdOrNull]
  T? findModelWithCustomKeyOrNull<T extends Object?>(String key) {
    final result = models[key] as T?;
    return result;
  }

  @override
  TRouteParam findScreenParam<TRouteParam extends AFRouteParam>(AFScreenID screenId) {
    final key = screenId.toString();
    return models[key] as TRouteParam;
  }

  @override
  TRouteParam? findScreenParamOrNull<TRouteParam extends AFRouteParam>(AFScreenID screenId) {
    final key = screenId.toString();
    return models[key] as TRouteParam;
  }

  @override
  TRouteParam findChildWidgetParam<TRouteParam extends AFRouteParam>(AFWidgetID widgetId) {
    final key = widgetId.toString();
    return models[key] as TRouteParam;
  }

  @override
  TRouteParam? findChildWidgetParamOrNull<TRouteParam extends AFRouteParam>(AFWidgetID widgetId) {
    final key = widgetId.toString();
    return models[key] as TRouteParam?;
  }

  /// Returns a new state, which overrides or augments this object's models with those from [other].
  AFComponentState mergeWith(AFComponentState other) {
    final revisedModels = integrate(this.models, other.models.values);
    return createWith(revisedModels);    
  }

  /// Returns a new state with the new objects integrated at the root, overriding or augmenting the existing objects.
  AFComponentState copyWith(List<Object> toIntegrate) {
    return createWith(AFComponentState.integrate(models, toIntegrate));
  }

  AFComponentState reviseModels(List<Object> toIntegrate) {
    return createWith(AFComponentState.integrate(models, toIntegrate));
  }

  // Returns a new state, with [toIntegrate] overriding or augmenting the existing objects.
  AFComponentState copyWithOne(Object toIntegrate) {
    final toI = <Object>[];
    toI.add(toIntegrate);
    return copyWith(toI);
  }

  AFComponentState createWith(Map<String, Object> models) {
    return create(models);
  }
}

@immutable
class AFComponentStateUnused extends AFComponentState {
  static final AFCreateComponentStateDelegate creator = (models) => AFComponentStateUnused(models);
  AFComponentStateUnused(Map<String, Object> models): super(models: models, create: creator);


  static AFComponentStateUnused initialValue() { return AFComponentStateUnused(const <String, Object>{}); }


}


/// Tracks the application state and any state provided by third parties.
/// 
/// You will not usually interact with this class directly.  It is maintained 
/// by AFib.  You manipulate it using `context.update...` calls.
@immutable
class AFComponentStates {
  final Map<String, AFComponentState> states;

  const AFComponentStates({
    required this.states
  });

  factory AFComponentStates.createFrom(List<AFComponentState> areas) {
    final states = <String, AFComponentState>{};
    for(final area in areas) {
      final areaType = _keyForComponent(area);
      states[areaType] = area;
    }

    // if you don't have a state, you can use AFFlexibleState as a substitute.  We need to have this
    // be non-null, so we add an empty one.
    final tempModel = AFComponentStateUnused(const <String, Object>{});
    final areaType = _keyForComponent(tempModel);
    states[areaType] = tempModel;

    return AFComponentStates(states: states);
  }

  AFComponentStates reviseComponent(Type areaType, List<Object> models) {
    final revisedStates = Map<String, AFComponentState>.of(states);
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

  TState? findState<TState extends AFComponentState>() {
    final key = _keyForComponent(TState);
    return states[key] as TState?;
  }

  AFComponentState? stateFor(Type areaType) {
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
