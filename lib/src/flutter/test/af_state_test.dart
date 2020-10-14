import 'package:afib/afib_dart.dart';
import 'package:afib/src/dart/redux/state/af_app_state.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/flutter/test/af_base_test_execute.dart';
import 'package:afib/src/flutter/test/af_test_data_registry.dart';
import 'package:afib/src/flutter/utils/af_typedefs_flutter.dart';
import 'package:meta/meta.dart';
import 'package:afib/src/dart/redux/actions/af_async_query.dart';
import 'package:afib/src/dart/redux/state/af_route_state.dart';
import 'package:afib/src/dart/redux/state/af_store.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';

abstract class AFStateTestExecute extends AFBaseTestExecute {

  AFStateTestExecute();
  
}

class AFStateTestContext<TState extends AFAppState> extends AFStateTestExecute {
  AFStateTest test;
  final AFStore store;
  final AFDispatcher dispatcher;
  static AFStateTestContext currentTest;
  final bool isTrueTestContext;
  
  AFStateTestContext(this.test, this.store, this.dispatcher, { @required this.isTrueTestContext} );

  AFStateTestID get testID { return this.test.id; }
  AFState get afState { return store.state; }
  TState get state { return store.state.public.app; }
  AFRouteState get route { return store.state.public.route; }

  void processQuery(AFAsyncQuery q) {
    test.processQuery(this, q);
  }
}

class AFStateTests<TState extends AFAppState> {
  final Map<dynamic, dynamic> data = <dynamic, dynamic>{};
  final List<AFStateTest<dynamic>> tests = <AFStateTest<dynamic>>[];
  AFStateTestContext<dynamic> context;

  void addTest(AFStateTestID id, AFProcessTestDelegate handler) {
    final test = AFStateTest<TState>(id, this);
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
}

class _AFStateResultEntry {
  final dynamic querySpecifier;
  final AFProcessQueryDelegate handler;
  _AFStateResultEntry(this.querySpecifier, this.handler);
}

class _AFStateQueryBody {
  final AFAsyncQuery query;
  final AFProcessVerifyDelegate verify;
  _AFStateQueryBody(this.query, this.verify);
}

class AFStateTest<TState extends AFAppState> {
  final AFStateTests<TState> tests;
  final AFStateTestID id;
  AFStateTestID idPredecessor;
  final Map<String, _AFStateResultEntry> results = <String, _AFStateResultEntry>{};
  final List<_AFStateQueryBody> queryBodies = <_AFStateQueryBody>[];

  AFStateTest(this.id, this.tests);

  void extendsTest(AFStateTestID idTest) {
    idPredecessor = idTest;
    final test = tests.findById(idTest);
    this.results.addAll(test.results);
  }

  void initializeVerifyFrom(AFStateTestID idTest) {
    final test = tests.findById(idTest);
    queryBodies.addAll(test.queryBodies);
  }
    
  void registerResult(dynamic querySpecifier, AFProcessQueryDelegate handler) {
    final key = _specifierToId(querySpecifier);
    results[key] = _AFStateResultEntry(querySpecifier, handler);
  }

  String _specifierToId(dynamic querySpecifier) {
    if(querySpecifier is AFID) {
      return querySpecifier.code;
    } else if(querySpecifier is Type) {
      return querySpecifier.toString();
    } else if(querySpecifier is AFAsyncQuery) {
      if(querySpecifier.id != null) {
        return querySpecifier.id.code;
      }
      return querySpecifier.runtimeType.toString();
    }
    throw AFException("Unknown query specifier type ${querySpecifier.runtimeType}");
  }

  /// 
  void specifyResponse(dynamic querySpecifier, AFTestDataRegistry testData, dynamic idData) {
    registerResult(querySpecifier, (context, query) {
      final data = testData.find(idData);
      query.testFinishAsyncWithResponse(context, data);
    });
  }

  void createResponse(dynamic querySpecifier, AFCreateQueryResultDelegate delegate) {
    registerResult(querySpecifier, (context, query) {
      final result = delegate(context, query);
      query.testFinishAsyncWithResponse(context, result);
    });
  }

  void specifySecondaryError(dynamic querySpecifier, dynamic error) {
    registerResult(querySpecifier, (context, query) {
      query.testFinishAsyncWithError(context, error);
    });
  }

  void executeQuery(AFAsyncQuery query, {
    AFProcessVerifyDelegate verify
  }) {
    queryBodies.add(_AFStateQueryBody(query, verify));
  }

  /// Execute the test by kicking of its queries, then 
  void execute(AFStateTestContext context) {    
    AFStateTestContext.currentTest = context;
    
    // first, execute an predecessor tests.
    if(idPredecessor != null) {
      final test = tests.findById(idPredecessor);
      test.execute(context);
    }

    // basically, we need to go through an execute each query that they specified.
    for(final q in queryBodies) {
      final stateBefore = context.state;
      processQuery(context, q.query);

      // lookup the result for that query
      AFStateTestExecute e = context;
      q?.verify(e, stateBefore, context.state);
    }
  }

  /// Process a query by looking up the results we have for that query,
  /// and then feeding them to its testAsyncResponse method.
  void processQuery(AFStateTestContext context, AFAsyncQuery query) {
    final key = _specifierToId(query);
    final h = results[key];
    if(h == null) {
      /// deferred queries don't have any results.
      if(query is AFDeferredQuery) {
        final successContext = query.createSuccessContext(
          dispatcher: context.dispatcher,
          state: context.afState
        );

        query.finishAsyncExecute(successContext);
        return;
      }

      throw AFException("No results specified for query ${_specifierToId(query)}");
    }

    h.handler(context, query);
  }
}