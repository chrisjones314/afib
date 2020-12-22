import 'package:afib/src/dart/redux/actions/af_async_query.dart';
import 'package:afib/src/dart/redux/actions/af_deferred_query.dart';
import 'package:afib/src/dart/redux/actions/af_navigation_actions.dart';

mixin AFContextDispatcherMixin {

  /// Push down to a more detailed screen.
  /// 
  /// This is just here for discoverability, its no different
  /// from dispatch(action);
  void dispatchNavigatePush(AFNavigatePushAction action) {
    dispatch(action);
  }

  /// Pop up to the next less detailed screen.
  /// 
  /// This is just here for discoverability, it is not different from
  /// dispatch(action).
  void dispatchNavigatePop(AFNavigatePopAction action) {
    dispatch(action);
  }

  /// Dispatch any of the [AFNavigateAction] subclasses.
  /// 
  /// This is just here for discoverability, see the subclasses
  /// of [AFNavigateAction] for many different ways to navigate.
  /// It is no different from dispatch(action).
  void dispatchNavigate(AFNavigateAction action) {
    dispatch(action);
  }

  /// Dispatch an [AFAsyncQuery] subclass, which is used to interact
  /// asynchronously with the outside world, for example, with a
  /// REST server.
  /// 
  /// This is just here for discoverability, it is no different
  /// from dispatch(query).
  void dispatchQuery(AFAsyncQuery query) {
    dispatch(query);
  }

  /// Dispatch an [AFDeferredQuery], which can be used to schedule
  /// a query that executes later.
  /// 
  /// This is just here for discoverability, it is no different from
  /// dispatch(query).
  void dispatchQueryDeferred(AFDeferredQuery query) {
    dispatch(query);
  }

  /// Dispatch an [AFConsolidatedQuery], which can be used to run several
  /// queries that run later, and then be notified of their results when
  /// all of them have completed via the successDelegate in the constructor.
  ///
  /// This is just here for discoverability, it is no different from 
  /// dispatch(query).
  void dispatchQueryCombined(AFConsolidatedQuery query) {
    dispatch(query);
  }

  /// Dispatch an [AFAsyncQueryListener], which establishes a channel that
  /// recieves results on an ongoing basis (e.g. via a websocket).
  /// 
  /// This is just here for discoverability, it is no different from
  /// dispatch(query).
  void dispatchQueryListener(AFAsyncQueryListener query) {
    dispatch(query);
  }

  void dispatch(dynamic action);
}