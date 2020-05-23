import 'package:afib/src/dart/redux/actions/af_async_query_action.dart';

/// A list of asynchronous queries that the app uses to collect and integrate
/// data.
class AFAsyncQueries {

  final List<AFAsyncQueryAction> queries = List<AFAsyncQueryAction>();

  void add(AFAsyncQueryAction action) {
    queries.add(action);
  }

}