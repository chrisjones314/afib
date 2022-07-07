import 'package:afib/src/dart/redux/actions/af_action_with_key.dart';
import 'package:afib/src/dart/redux/actions/af_async_query.dart';
import 'package:afib/src/dart/redux/actions/af_route_actions.dart';
import 'package:afib/src/dart/redux/state/af_state.dart';
import 'package:afib/src/dart/redux/state/af_store.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/test/af_test_actions.dart';
import 'package:afib/src/flutter/utils/af_api_mixins.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';

/// Used to dispatch actions to the store, with a level of indirection
/// for testing.
abstract class AFDispatcher {
  dynamic dispatch(dynamic action);

}

/// The production dispatcher which dispatches actions to the store.
class AFStoreDispatcher extends AFDispatcher {

  AFStore store;
  AFStoreDispatcher(this.store);

  dynamic dispatch(dynamic action) {  

    if(action is AFExecuteBeforeInterface) {
      final query = action.executeBefore;

      //
      if(query != null) {
        // create a composite query to execute the original query.
        final composite = AFCompositeQuery.createFrom(queries: [query], onSuccessDelegate: (compositeSuccess) {
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

  dynamic dispatch(dynamic action) {
    actions.add(action);
    return null;
  }

  AFPublicState? get debugOnlyPublicState {
    return null;
  }


}
