import 'package:afib/src/dart/redux/actions/af_action_with_key.dart';
import 'package:afib/src/dart/redux/actions/af_route_actions.dart';
import 'package:afib/src/dart/redux/state/af_state.dart';
import 'package:afib/src/dart/redux/state/af_store.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/test/af_test_actions.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';

/// Used to dispatch actions to the store, with a level of indirection
/// for testing.
abstract class AFDispatcher {
  dynamic dispatch(dynamic action);

  bool isTestAction(dynamic action) {
    var shouldPop = false;
    if(action is AFNavigatePopAction) {
      shouldPop = action.worksInSingleScreenTest;
    }

    return ( shouldPop ||
             action is AFNavigateExitTestAction || 
             action is AFUpdatePrototypeScreenTestDataAction || 
             action is AFPrototypeScreenTestAddError ||
             action is AFPrototypeScreenTestIncrementPassCount ||
             action is AFStartPrototypeScreenTestContextAction );
  }

  /// Only meant to make the public state visible in the debugger, not for use
  /// in application code.
  AFPublicState? get debugOnlyPublicState;
}

/// The production dispatcher which dispatches actions to the store.
class AFStoreDispatcher extends AFDispatcher {

  AFStore store;
  AFStoreDispatcher(this.store);

  dynamic dispatch(dynamic action) {  
    if(AFibD.config.requiresTestData && !isTestAction(action) && action is AFActionWithKey) {
      AFibF.g.testOnlyRegisterRegisterAction(action);
      AFibD.logTestAF?.d("Registered action: $action");
    }

    return store.dispatch(action);
  }

  AFPublicState get debugOnlyPublicState {
    return store.state.public;
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
