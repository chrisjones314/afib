
/// Just a registry of test data objects which can be used in various test contexts.
class AFTestDataRegistry {
  final testData = Map<dynamic, dynamic>();

  void registerData(dynamic id, dynamic data) {
    testData[id] = data;
  }

  dynamic findData(dynamic id) {
    return testData[id];
  }

  List<TData> testDataList<TData>(List<dynamic> ids) {
    final list = List<TData>();
    for(final id in ids) {
      TData data = findData(id);
      list.add(data);
    }
    return list;
  }

}