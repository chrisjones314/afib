
/// Just a registry of test data objects which can be used in various test contexts.
class AFTestDataRegistry {
  final testData = <dynamic, dynamic>{};
  static int uniqueIdBase = 1;
  static List<String> createdTestIds = <String>[];

  static String get uniqueId {
    final result = uniqueIdBase.toString();
    uniqueIdBase++;
    return result;
  }

  void register(dynamic id, dynamic data) {
    testData[id] = data;
  }

  /// Find a test data object by its id, but if the id is not a string,
  /// just return it.
  /// 
  /// If the id you pass in is not a string, then the object you pass in 
  /// as the id will be returned as the result.   This allows you to
  /// implement parameterized tests where you can pass in either an
  /// instance of the object you want, or an id for an intestance of that object
  /// in the test data registry.
  dynamic find(dynamic id) {
    if(id is String) {
      final result = testData[id];
      return result ?? id;
    } 
    return id;
  }

  dynamic operator[](dynamic id) {
    return testData[id];
  }

  void operator[]=(dynamic id, dynamic data) {
    testData[id] = data;
  }

  List<TData> testDataList<TData>(List<dynamic> ids) {
    final list = <TData>[];
    for(final id in ids) {
      TData data = find(id);
      list.add(data);
    }
    return list;
  }

}