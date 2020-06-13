import 'package:afib/src/flutter/test/af_base_test_execute.dart';
import 'package:meta/meta.dart';
import 'package:afib/src/dart/redux/actions/af_async_query.dart';
import 'package:afib/src/dart/redux/state/af_route_state.dart';
import 'package:afib/src/dart/redux/state/af_store.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/flutter/af.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';

class AFStateTestError {
  final AFStateTest test;
  final String description;
  AFStateTestError(this.test, this.description);

  String toString() {
    return description;
  }
}

class AFStateTestContext<TState> extends AFBaseTestExecute {
  AFStateTest test;
  AFStore store;
  AFDispatcher testDisp;
  static AFStateTestContext _currentTest;
  final _errors = List<AFStateTestError>();
  final bool isTrueTestContext;
  
  AFStateTestContext(this.test, { @required this.isTrueTestContext } ) {
    store = AF.testOnlyStore;
    testDisp = AFStoreDispatcher(store);    
  }

  TState get state { return store.state.app; }
  AFRouteState get route { return store.state.route; }
  AFDispatcher get dispatcher { return testDisp; }
  static void setCurrentTest(AFStateTestContext context) { _currentTest = context; }
  static AFStateTestContext get currentTest { return _currentTest; }

  void processQuery(AFAsyncQuery q) {
    test.processQuery(this, q);
  }

  List<AFStateTestError> get errors { return _errors; }
  bool get hasErrors { return _errors.isNotEmpty; }

  @override
  void addError(String desc, int nDepth) {
    _errors.add(AFStateTestError(test, desc));
  }

  @override
  bool addPassIf(bool test) {
    return test;
  }
}

typedef void ProcessQuery(AFStateTestContext context, AFAsyncQuery query);
typedef void ProcessTest<TState>(AFStateTest<TState> test);
typedef void ProcessVerify<TState>(AFStateTestContext context);

class AFStateTests {
  final Map<dynamic, dynamic> data = Map<dynamic, dynamic>();
  final List<AFStateTest<dynamic>> tests = List<AFStateTest<dynamic>>();
  AFStateTestContext<dynamic> context;

  void queryTest(AFStateTestID id, AFAsyncQuery query, ProcessTest<dynamic> handler) {
    final test = AFStateTest<dynamic>(id, query, this);
    tests.add(test);
    handler(test);
  }

  void registerData(dynamic id, dynamic data) {
    data[id] = data;
  }

  dynamic lookupData(dynamic id) {
    return data[id];
  }

}
class _AFStateResultEntry {
  final AFAsyncQuery query;
  final ProcessQuery handler;
  _AFStateResultEntry(this.query, this.handler);
}

class _AFStateQueryEntry {
  final AFAsyncQuery query;
  final ProcessVerify verify;
  _AFStateQueryEntry(this.query, this.verify);
}

class AFStateTest<TState> {
  final AFStateTests tests;
  final AFStateTestID id;
  final AFAsyncQuery query;
  final Map<String, _AFStateResultEntry> results = Map<String, _AFStateResultEntry>();
  final List<_AFStateQueryEntry> postQueries = List<_AFStateQueryEntry>();

  AFStateTest(this.id, this.query, this.tests);
    
  void registerResult(AFAsyncQuery query, ProcessQuery handler) {
    results[query.key] = _AFStateResultEntry(query, handler);
  }

  /// 
  void specifySecondaryResponseWithId(AFAsyncQuery query, dynamic idData) {
    registerResult(query, (AFStateTestContext context, AFAsyncQuery query) {
      final data = tests.lookupData(idData);
      query.testFinishAsyncWithResponse(context, data);
    });
  }

  void specifyPrimaryResponseWithId(dynamic idData) {
    specifySecondaryResponseWithId(this.query, idData);
  }

  void verifyAfter(ProcessVerify verify) {
    postQueries.add(_AFStateQueryEntry(query, verify));
  }

  /// Execute the test by kicking of its queries, then 
  void execute(AFStateTestContext context) {    
    AFStateTestContext.setCurrentTest(context);
    // basically, we need to go through an execute each query that they specified.
    postQueries.forEach((q) {
      // lookup the result for that query
      processQuery(context, q.query);
      q?.verify(context);
    });
  }

  /// Process a query by looking up the results we have for that query,
  /// and then feeding them to its testAsyncResponse method.
  void processQuery(AFStateTestContext context, AFAsyncQuery query) {
    final h = results[query.key];
    h.handler(context, query);
  }
}