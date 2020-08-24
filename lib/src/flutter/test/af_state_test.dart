import 'package:afib/afib_dart.dart';
import 'package:afib/src/dart/redux/state/af_app_state.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/flutter/test/af_base_test_execute.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:meta/meta.dart';
import 'package:afib/src/dart/redux/actions/af_async_query.dart';
import 'package:afib/src/dart/redux/state/af_route_state.dart';
import 'package:afib/src/dart/redux/state/af_store.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';



abstract class AFStateTestExecute extends AFBaseTestExecute {

  AFStateTestExecute();
  
}

class AFStateTestContext<TState> extends AFStateTestExecute {
  AFStateTest test;
  final AFStore store;
  final AFDispatcher dispatcher;
  static AFStateTestContext _currentTest;
  final bool isTrueTestContext;
  
  AFStateTestContext(this.test, this.store, this.dispatcher, { @required this.isTrueTestContext} );

  AFTestID get testID { return this.test.id; }
  TState get state { return store.state.app; }
  AFRouteState get route { return store.state.route; }
  static void setCurrentTest(AFStateTestContext context) { _currentTest = context; }
  static AFStateTestContext get currentTest { return _currentTest; }

  void processQuery(AFAsyncQueryCustomError q) {
    test.processQuery(this, q);
  }
}

typedef void ProcessQuery(AFStateTestContext context, AFAsyncQueryCustomError query);
typedef void ProcessTest(AFStateTest test);
typedef void ProcessVerify(AFStateTestExecute execute, AFAppState stateBefore, AFAppState stateAfter);

class AFStateTests {
  final Map<dynamic, dynamic> data = Map<dynamic, dynamic>();
  final List<AFStateTest<dynamic>> tests = List<AFStateTest<dynamic>>();
  AFStateTestContext<dynamic> context;

  void queryTest(AFTestID id, AFAsyncQueryCustomError query, ProcessTest handler) {
    final test = AFStateTest<AFAppState>(id, query, this);
    tests.add(test);
    handler(test);
  }

  AFStateTest findById(AFTestID id) {
    for(var test in tests) {
      if(test.id == id) {
        return test;
      }
    }
    return null;
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
  final AFTestID id;
  AFTestID idPredecessor;
  final AFAsyncQueryCustomError query;
  final Map<String, _AFStateResultEntry> results = Map<String, _AFStateResultEntry>();
  final List<_AFStateQueryEntry> postQueries = List<_AFStateQueryEntry>();

  AFStateTest(this.id, this.query, this.tests);

  void continuesAfter(AFTestID pred) {
    idPredecessor = pred;
  }

  void initializeResultsFrom(AFTestID idTest) {
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

  void initializeVerifyFrom(AFTestID idTest) {
    final test = tests.findById(idTest);
    postQueries.addAll(test.postQueries);
  }
    
  void registerResult(AFAsyncQueryCustomError query, ProcessQuery handler) {
    results[query.key] = _AFStateResultEntry(query, handler);
  }

  /// 
  void specifySecondaryResponseWithId(AFAsyncQueryCustomError query, dynamic idData) {
    registerResult(query, (AFStateTestContext context, AFAsyncQueryCustomError query) {
      final data = AFibF.testData.findData(idData);
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
    if(h == null) {

      /// deferred queries don't have any results.
      if(query is AFDeferredQueryCustomError) {
        query.finishAsyncExecute(context.dispatcher, context.state);
        return;
      }

      throw AFException("No results specified for query ${query.key}");
    }
    h.handler(context, query);
  }
}