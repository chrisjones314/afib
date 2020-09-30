import 'package:afib/src/dart/redux/actions/af_async_query.dart';

/// A list of asynchronous queries that the app uses to collect and integrate
/// data.
class AFAsyncQueries {

  final List<AFAsyncQuery> queries = <AFAsyncQuery>[];

  void add(AFAsyncQuery action) {
    queries.add(action);
  }

}