import 'package:meta/meta.dart';
import 'package:afib/src/dart/redux/actions/af_async_query.dart';
import 'package:afib/src/dart/redux/state/af_route_state.dart';
import 'package:afib/src/dart/redux/state/af_store.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/flutter/af.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';
import 'package:flutter_test/flutter_test.dart' as flutter_test;
import 'package:stack_trace/stack_trace.dart';

class AFStateTestError {
  final AFStateTest test;
  final String description;
  final String line;
  AFStateTestError(this.test, this.description, this.line);

  String toString() {
    return "$line: $description";
  }
}

class AFStateTestContext<TState> {
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

  void expect(dynamic value, flutter_test.Matcher matcher) {
    final matchState = Map();
    if(!matcher.matches(value, matchState)) {
      final matchDesc = matcher.describe(flutter_test.StringDescription());
      final desc = "Expected $matchDesc, found $value";

      final List<Frame> frames = Trace.current().frames;
      final Frame f = frames[1];
      _addError(test, desc, "${f.library}:${f.line}");
    }
  }

  List<AFStateTestError> get errors { return _errors; }
  bool get hasErrors { return _errors.isNotEmpty; }

  void _addError(AFStateTest test, String desc, String line) {
    _errors.add(AFStateTestError(test, desc, line));
  }
}

typedef void ProcessQuery(AFStateTestContext context, AFAsyncQuery query);
typedef void ProcessTest<TState>(AFStateTest<TState> test);
typedef void ProcessVerify<TState>(AFStateTestContext context);

class AFStateTests {
  final List<AFStateTest<dynamic>> tests = List<AFStateTest<dynamic>>();
  AFStateTestContext<dynamic> context;

  void test(AFStateTestID id, ProcessTest<dynamic> handler) {
    final test = AFStateTest<dynamic>(id);
    tests.add(test);
    handler(test);
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
  final AFStateTestID id;
  final Map<String, _AFStateResultEntry> results = Map<String, _AFStateResultEntry>();
  final List<_AFStateQueryEntry> queries = List<_AFStateQueryEntry>();

  AFStateTest(this.id);
    
  void result<TQuery extends AFAsyncQuery>(TQuery query, ProcessQuery handler) {
    results[query.key] = _AFStateResultEntry(query, handler);
  }

  void query<TQuery extends AFAsyncQuery>(TQuery query, { ProcessVerify<TState> verify }) {
  queries.add(_AFStateQueryEntry(query, verify));
  }


  /// Execute the test by kicking of its queries, then 
  void execute(AFStateTestContext context) {    
    AFStateTestContext.setCurrentTest(context);
    // basically, we need to go through an execute each query that they specified.
    queries.forEach((q) {
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