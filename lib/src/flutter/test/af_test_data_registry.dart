
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

  dynamic find(dynamic id) {
    return testData[id];
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