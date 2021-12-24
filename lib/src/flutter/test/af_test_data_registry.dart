import 'package:afib/src/dart/redux/state/af_app_state.dart';
import 'package:afib/src/flutter/utils/af_state_view.dart';




/// A registry of test data objects which can be referenced by an id.
/// 
/// It is usually best to use strings for ids, even if your underlying
/// data store uses integer ids (just convert the integers).  Using strings
/// allows you to use descriptive ids for test data, which will then often
/// show up as part of widget ids in your UI, making debugging easier.
class AFCompositeTestDataRegistry {

  final Map<dynamic, dynamic> testData;
  static int uniqueIdBase = 1;
  static List<String> createdTestIds = <String>[];
  
  AFCompositeTestDataRegistry({
    required this.testData
  });

  void register(dynamic id, dynamic data) {
    testData[id] = data;
  }

  static String get uniqueId {
    final result = uniqueIdBase.toString();
    uniqueIdBase++;
    return result;
  }  

  factory AFCompositeTestDataRegistry.create() {
    return AFCompositeTestDataRegistry(testData: <dynamic, dynamic>{});
  }  

  /// Find a test data object by its id, but if the id is not a string,
  /// just return it.
  /// 
  /// If the id you pass in is not a string, then the object you pass in 
  /// as the id will be returned as the result.   This allows you to
  /// implement parameterized tests where you can pass in either an
  /// instance of the object you want, or an id for an intestance of that object
  /// in the test data registry.
  dynamic f(dynamic id) {
    if(id is String) {
      final result = testData[id];
      return result ?? id;
    } 
    return id;
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
      final item = f(sources);
      _internalResolveStateViewModels(item, models);
    } else if(sources is AFFlexibleState) {
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


  /// See the shortened version [f].
  dynamic find(dynamic id) {
    return f(id);
  }

  dynamic findModels(dynamic id) {
    if(id is String || id is int) {
      return f(id);
    } else if(id is List) {
      return findList(id);
    } else {
      return id;
    }
  }

  List<TData> findList<TData>(List<dynamic> ids) {
    final list = <TData>[];
    for(final id in ids) {
      TData data = f(id);
      list.add(data);
    }
    return list;
  }

}