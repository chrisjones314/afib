import 'package:afib/src/dart/redux/state/af_app_state.dart';
import 'package:afib/src/flutter/test/af_base_test_execute.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
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

abstract class AFStateTestExecute extends AFBaseTestExecute {

  AFStateTestExecute();
  
}

class AFStateTestContext<TState> extends AFStateTestExecute {
  AFStateTest test;
  AFStore store;
  AFDispatcher testDisp;
  static AFStateTestContext _currentTest;
  final _errors = List<AFStateTestError>();
  final bool isTrueTestContext;
  int pass = 0;
  
  AFStateTestContext(this.test, { @required this.isTrueTestContext } ) {
    store = AF.testOnlyStore;
    testDisp = AFStoreDispatcher(store);    
  }

  TState get state { return store.state.app; }
  AFRouteState get route { return store.state.route; }
  AFDispatcher get dispatcher { return testDisp; }
  static void setCurrentTest(AFStateTestContext context) { _currentTest = context; }
  static AFStateTestContext get currentTest { return _currentTest; }

  void processQuery(AFAsyncQueryCustomError q) {
    test.processQuery(this, q);
  }

  List<AFStateTestError> get errors { return _errors; }
  bool get hasErrors { return _errors.isNotEmpty; }

  @override
  void addError(String desc, int depth) {
    String err = AFScreenTestExecute.composeError(desc, depth);
    _errors.add(AFStateTestError(test, err));
  }

  @override
  bool addPassIf(bool test) {
    if(test) {
      pass++;
    }
    return test;
  }
}

typedef void ProcessQuery(AFStateTestContext context, AFAsyncQueryCustomError query);
typedef void ProcessTest(AFStateTest test);
typedef void ProcessVerify(AFStateTestExecute execute, AFAppState stateBefore, AFAppState stateAfter);

class AFStateTests {
  final Map<dynamic, dynamic> data = Map<dynamic, dynamic>();
  final List<AFStateTest<dynamic>> tests = List<AFStateTest<dynamic>>();
  AFStateTestContext<dynamic> context;

  void queryTest(AFStateTestID id, AFAsyncQueryCustomError query, ProcessTest handler) {
    final test = AFStateTest<AFAppState>(id, query, this);
    tests.add(test);
    handler(test);
  }

  AFStateTest findById(AFStateTestID id) {
    for(var test in tests) {
      if(test.id == id) {
        return test;
      }
    }
    return null;
  }

  void registerData(dynamic id, dynamic data) {
    this.data[id] = data;
  }

  dynamic lookupData(dynamic id) {
    return data[id];
  }

}
class _AFStateResultEntry {
  final AFAsyncQueryCustomError query;
  final ProcessQuery handler;
  _AFStateResultEntry(this.query, this.handler);
}

class _AFStateQueryEntry {
  //final AFAsyncQuery query;
  final AFTestSectionID id;
  final ProcessVerify verify;
  _AFStateQueryEntry(this.id, this.verify);
}

class AFStateTest<TState extends AFAppState> {
  final AFStateTests tests;
  final AFStateTestID id;
  AFStateTestID idPredecessor;
  final AFAsyncQueryCustomError query;
  final Map<String, _AFStateResultEntry> results = Map<String, _AFStateResultEntry>();
  final List<_AFStateQueryEntry> postQueries = List<_AFStateQueryEntry>();

  AFStateTest(this.id, this.query, this.tests);

  void continuesAfter(AFStateTestID pred) {
    idPredecessor = pred;
  }

  void initializeResultsFrom(AFStateTestID idTest) {
    final test = tests.findById(idTest);
    test.results.forEach((key, result) { 
      /// if this is the primary result, then copy it over to the primary result for
      /// our query.
      if(key == test.query.key) {
        this.results[this.query.key] = _AFStateResultEntry(this.query, result.handler);
      } else {
        this.results[key] = result;
      }
    });
  }

  void initializeVerifyFrom(AFStateTestID idTest) {
    final test = tests.findById(idTest);
    postQueries.addAll(test.postQueries);
  }
    
  void registerResult(AFAsyncQueryCustomError query, ProcessQuery handler) {
    results[query.key] = _AFStateResultEntry(query, handler);
  }

  /// 
  void specifySecondaryResponseWithId(AFAsyncQueryCustomError query, dynamic idData) {
    registerResult(query, (AFStateTestContext context, AFAsyncQueryCustomError query) {
      final data = tests.lookupData(idData);
      query.testFinishAsyncWithResponse(context, data);
    });
  }

  void specifyPrimaryResponseWithId(dynamic idData) {
    specifySecondaryResponseWithId(this.query, idData);
  }

  void specifyPrimaryError(dynamic error) {
    specifySecondaryError(this.query, error);
  }

  void specifySecondaryError(AFAsyncQueryCustomError query, dynamic error) {
    registerResult(query, (AFStateTestContext context, AFAsyncQueryCustomError query) {
      query.testFinishAsyncWithError(context, error);
    });
  }

  void verifyAfter({AFTestSectionID id, ProcessVerify verify}) {
    postQueries.add(_AFStateQueryEntry(id, verify));
  }

  /// Execute the test by kicking of its queries, then 
  void execute(AFStateTestContext context) {    
    AFStateTestContext.setCurrentTest(context);
    
    // first, execute an predecessor tests.
    if(idPredecessor != null) {
      final test = tests.findById(idPredecessor);
      test.execute(context);
    }
    final AFAppState stateBefore = context.state;
    processQuery(context, this.query);

    // basically, we need to go through an execute each query that they specified.
    postQueries.forEach((q) {
      // lookup the result for that query
      AFStateTestExecute e = context;
      q?.verify(e, stateBefore, context.state);
    });
  }

  /// Process a query by looking up the results we have for that query,
  /// and then feeding them to its testAsyncResponse method.
  void processQuery(AFStateTestContext context, AFAsyncQueryCustomError query) {
    final h = results[query.key];
    h.handler(context, query);
  }
}