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



  void define(dynamic id, dynamic data) {
    if(testData.containsKey(id)) {
      assert(false, "You should not redefine a of the existing id $id in the test data");
    }
    testData[id] = data;
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
      _internalResolveStateViewModels(item, models);
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