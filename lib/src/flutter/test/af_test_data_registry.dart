import 'package:afib/src/dart/command/af_standard_configs.dart';
import 'package:afib/src/dart/redux/state/models/af_app_state.dart';
import 'package:afib/src/dart/redux/state/models/af_time_state.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/utils/af_state_view.dart';
import 'package:logger/logger.dart';

/// A registry of test data objects which can be referenced by an id.
/// 
/// It is usually best to use strings for ids, even if your underlying
/// data store uses integer ids (just convert the integers).  Using strings
/// allows you to use descriptive ids for test data, which will then often
/// show up as part of widget ids in your UI, making debugging easier.
class AFDefineTestDataContext {
  static const nowId = "__af__time_now";


  final Map<dynamic, dynamic> testData;
  static int uniqueIdBase = 1;
  static List<String> createdTestIds = <String>[];
  
  AFDefineTestDataContext({
    required this.testData
  });


  /// Associates the test data id [id] with the value [data], and returns the [data] for further use.
  /// 
  /// The data can later be located using the [find] method, and can be referenced directly using the ID
  /// from a variety of AFib test contexts.
  TData define<TData>(dynamic id, TData data) { 
    if(testData.containsKey(id)) {
      assert(false, "You should not redefine a of the existing id $id in the test data");
    }
    testData[id] = data;
    return data;
  }

  /// Given a list of test data ids and object values in [sources], resolves them into a list of
  /// root state objects, and returns that list.
  /// 
  /// This method works just as the `stateView` parameter in UI protoypes does.  If you pass in the test id
  /// of an existing state object, all it's root objects are used.  Then, any additional root objects in [sources]
  /// are written into the state, overwritting those that already exist.
  /// 
  /// This can be used to create a differentiated state with just a few of the root objects replaced.   If you'd like
  /// to create a state from the returned list, you can use your XXXState.fromList constructor.
  List<Object> defineRootStateObjectList(Object id, List<Object> sources) {
    final resolved = resolveStateViewModels(sources);
    final models = define(id, resolved.values.toList());
    return models;
  }

  /// Creates a list of objects of a given type from a list of existing test data ids.
  List<TValue> defineIdentifierList<TValue>(Object id, List<String> listIds) {
    assert(TValue != dynamic);
    final result = <TValue>[];
    for(final itemId in listIds) {
      final found = find<TValue>(itemId);
      assert(found != null);
      result.add(found);
    }
  
    define(id, result);
    return result;
  }

  /// Creates a map from test data ids to object values
  Map<String, TValue> defineIdentifierMap<TValue>(Object id, List<dynamic> list, {
    String Function(TValue)? getId,
  }) {
    assert(TValue != dynamic);
    final result = <String, TValue>{};
    if(list is List<String>) {
      for(final itemId in list) {
        final found = find<TValue>(itemId);
        assert(found != null);
        result[itemId] = found;
      }
    } else {
      for(final obj in list) {
        String id;
        if(getId != null) {
          id = getId(obj);
        } else {
          id = obj.id;
        }
        result[id] = obj;
      }
    }
    
    define(id, result);
    return result;
  }

  AFTimeState currentTime() {
    var exists = testData[nowId];
    if(exists == null) {
      exists = AFTimeState.createNow();
      testData[nowId] = exists;
    }
    return exists;
  }

  AFTimeState currentTimeUTC() {
    return currentTime().reviseToUTC();
  }

  static String get uniqueId {
    final result = uniqueIdBase.toString();
    uniqueIdBase++;
    return result;
  }  

  factory AFDefineTestDataContext.create() {
    return AFDefineTestDataContext(testData: <dynamic, dynamic>{});
  }  

  bool get isEmpty {
    return testData.isEmpty;
  }

  bool get isNotEmpty {
    return testData.isNotEmpty;
  }

  Logger? get log {
    return AFibD.log(AFConfigEntryLogArea.test);
  }

  /// Find a test data object by its id, but if the id is not a string,
  /// just return it.
  /// 
  /// If the id you pass in is not a string, then the object you pass in 
  /// as the id will be returned as the result.   This allows you to
  /// implement parameterized tests where you can pass in either an
  /// instance of the object you want, or an id for an intestance of that object
  /// in the test data registry.
  T find<T>(dynamic id) {
    if(id is String) {
      final result = testData[id];
      return result ?? id;
    } 
    return id;
  }

  List<T> findAll<T>(List<String> ids) {
    final result = <T>[];
    for(final id in ids) {
      result.add(find<T>(id));
    }
    return result;
  }

  Map<String, Object> resolveStateViewModels(dynamic sources) {
    final result = <String, Object>{};
    _internalResolveStateViewModels(sources, result);
    return result;
  }

  void _internalResolveStateViewModels(dynamic sources, Map<String, Object> models) {

    if(sources is Map<String, Object>) {
      for(final items in sources.values) {
        _internalResolveStateViewModels(items, models);
      }
    } else if(sources is List) {
      for(final items in sources) {
        _internalResolveStateViewModels(items, models);
      }
    } else if(sources is String) {
      final item = find(sources);
      if(item is! String) {
        _internalResolveStateViewModels(item, models);
      }
    } else if(sources is AFComponentState) {
      _internalApplyModels(sources.models, models);
    } else if(sources is AFFlexibleStateView) {
      _internalApplyModels(sources.models, models);      
    } else {
      final key = AFModelWithCustomID.stateKeyFor(sources);
      models[key] = sources;
    }
  }

  void _internalApplyModels(Map<String, Object> source, Map<String, Object> models) {
      for(final itemKey in source.keys) {
        final toApply = source[itemKey];
        if(toApply != null) {
          models[itemKey] = toApply;
        }
      }
  }

  dynamic findModels(dynamic id) {
    if(id is String || id is int) {
      return find(id);
    } else if(id is List) {
      return findList(id);
    } else {
      return id;
    }
  }

  List<TData> findList<TData>(List<dynamic> ids) {
    final list = <TData>[];
    for(final id in ids) {
      final data = find(id);
      list.add(data);
    }
    return list;
  }

}