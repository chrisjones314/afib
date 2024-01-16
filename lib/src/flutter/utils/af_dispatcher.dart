import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/redux/actions/af_action_with_key.dart';
import 'package:afib/src/dart/redux/actions/af_async_query.dart';
import 'package:afib/src/dart/redux/actions/af_deferred_query.dart';
import 'package:afib/src/dart/redux/actions/af_route_actions.dart';
import 'package:afib/src/dart/redux/queries/af_isolate_listener_query.dart';
import 'package:afib/src/dart/redux/state/af_state.dart';
import 'package:afib/src/dart/redux/state/af_store.dart';
import 'package:afib/src/dart/redux/state/models/af_app_state.dart';
import 'package:afib/src/dart/utils/af_library_programming_interface.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/test/af_test_actions.dart';
import 'package:afib/src/flutter/utils/af_api_mixins.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';

/// Used to dispatch actions to the store, with a level of indirection
/// for testing.
abstract class AFDispatcher {
  dynamic dispatch(dynamic action);

}

abstract class AFStandardAPIContextInterface {
  TLPI accessLPI<TLPI extends AFLibraryProgrammingInterface>(AFLibraryProgrammingInterfaceID id);

  Stream<AFPublicStateChange> get accessStreamPublicStateChanges;

  //-------------------------------------------------------------------------------------
  // update...
  //-------------------------------------------------------------------------------------

  /// Dispatches an action that updates a single value in the app state area associated
  /// with the [TState] type parameter.
  void updateComponentRootStateOne<TState extends AFComponentState>(Object toIntegrate);

  /// Dispatches an action that updates several blaues in the app state area associated
  /// with the [TState] type parameter.
  void updateComponentRootStateMany<TState extends AFComponentState>(List<Object> toIntegrate);

  //-------------------------------------------------------------------------------------
  // navigate...
  //-------------------------------------------------------------------------------------

  /// Shuts down all existing listener and deferred queries.   Often called
  /// as part of a signout process.
  void executeShutdownAllActiveQueries();

  void executeShutdownListenerQuery<TQuery extends AFAsyncListenerQuery>({ AFID? id });



  //-------------------------------------------------------------------------------------
  // execute...
  //-------------------------------------------------------------------------------------
  void executeQuery(AFAsyncQuery query);

  /// Resets your application state to it's initial state (see your static initialState method).
  /// This is often called as part of a signout process.
  /// 
  /// Note that you have to be a little careful with the ordering of this, as if you are navigating
  /// from a screen within your app that references state, back out to a signin screen, Flutter will
  /// usually re-render the screen within your app once more as part of the animation.  You may need
  /// to first do the navigation, then use context.executeDeferredCallback with a ~500 ms delay to 
  /// allow the animation to complete, then reset the state once you are fully on the signin screen.
  void executeResetToInitialState();

  /// A utility which delays for the specified time, then updates the resulting code.   
  /// 
  /// This deferral is active in UIs, but is disabled during automated tests to speed results and reduce 
  /// complexity.
  void executeDeferredQuery(AFDeferredQuery query);
  void executePeriodicQuery(AFPeriodicQuery query);
  void executeCompositeQuery(AFCompositeQuery query);
  void executeIsolateListenerQuery(AFIsolateListenerQuery query);

  void executeWireframeEvent(AFWidgetID wid, Object? event);


  /// Dispatch an [AFAsyncListenerQuery], which establishes a channel that
  /// recieves results on an ongoing basis (e.g. via a websocket).
  /// 
  /// This is just here for discoverability, it is no different from
  /// dispatch(query).
  void executeListenerQuery(AFAsyncListenerQuery query);

  void navigatePush(
    AFNavigatePushAction action
  );

  void navigateReplaceCurrent(
    AFNavigateReplaceAction action,
  );

  void navigateReplaceAll(
    AFNavigateReplaceAllAction action
  );

  void navigateToUnimplementedScreen(String message);

  void navigate(AFNavigateAction action);
  void navigatePop();

  void navigatePopN({ 
    required int popCount,
  });

  void navigatePopTo(
    AFNavigatePopToAction popTo
  );

  void navigatePopToAndPush({
    required AFScreenID popTo,
    required AFNavigatePushAction push
  });

}


/// The production dispatcher which dispatches actions to the store.
class AFStoreDispatcher extends AFDispatcher {

  AFStore store;
  AFStoreDispatcher(this.store);

  @override
  dynamic dispatch(dynamic action) {  

    if(action is AFExecuteBeforeInterface) {
      final queryBefore = action.executeBefore;

      if(queryBefore != null) {
        // create a composite query to execute the original query.
        final composite = AFCompositeQuery.createFrom(queries: [queryBefore], onSuccess: (compositeSuccess) {
          // execute the original action after it finishes successfully, note that currently on error, we just drop
          // the original action.   I think that is fairly reasonable, as it is likely that an error will have been displayed
          // to the user, which implicitly explains why the action didn't have the intended effect.
          store.dispatch(action);
        });

        // execute the composite.
        store.dispatch(composite);
        return;
      }
    }

    if(action is AFExecuteDuringInterface) {
      // in this case, we don't wait for the query to finish, we just execute the query, and fall through to immediately execute the action.
      final query = action.executeDuring;

      if(query != null) {
        store.dispatch(query);

      }
    }


    if(AFibD.config.requiresTestData && !isTestAction(action) && action is AFActionWithKey) {
      AFibF.g.testOnlyRegisterRegisterAction(action);
      AFibD.logTestAF?.d("Registered action: $action");
    }



    return store.dispatch(action);
  }

  AFPublicState get debugOnlyPublicState {
    return store.state.public;
  }

  static bool isTestAction(dynamic action) {
    var shouldPop = false;
    if(action is AFNavigatePopAction) {
      shouldPop = action.worksInSingleScreenTest;
    }

    return ( shouldPop ||
             action is AFNavigateExitTestAction || 
             action is AFUpdatePrototypeScreenTestModelsAction || 
             action is AFPrototypeScreenTestAddError ||
             action is AFPrototypeScreenTestIncrementPassCount ||
             action is AFStartPrototypeScreenTestContextAction );
  }

}

/// A test dispatcher which records actions for later inspection.
class AFTestDispatcher extends AFDispatcher {
  List<dynamic> actions = <dynamic>[];

  int get actionCount {
    return actions.length;
  }

  dynamic get first {
    return actions[0];
  }

  dynamic nth(int i ) {
    return actions[i];
  } 

  void clear() {
    actions.clear();
  }

  @override
  dynamic dispatch(dynamic action) {
    actions.add(action);
    return null;
  }

  AFPublicState? get debugOnlyPublicState {
    return null;
  }


}
