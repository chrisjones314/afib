

import 'package:afib/src/dart/redux/state/af_test_state.dart';
import 'package:afib/src/flutter/test/af_test_actions.dart';

/// This reducer handles the default behavior of the app state, which 
/// is just to set one or more 
AFTestState afTestStateReducer(AFTestState state, dynamic action) {
  if(action is AFStartPrototypeScreenTestContextAction) {
    return state.startTest(action.context, action.param, action.stateView, action.screen);
  } else if(action is AFUpdatePrototypeScreenTestDataAction) {
    return state.updateStateView(action.testId, action.stateView);
  } else if(action is AFPrototypeScreenTestIncrementPassCount) {
    return state.incrementPassCount(action.testId);
  } else if(action is AFPrototypeScreenTestAddError) {
    return state.addError(action.testId, action.err);
  } else if(action is AFStartPrototypeScreenTestAction) {
    return state.navigateToTest(action.test, action.param, action.stateView, action.screen);
  }


  return state;
}

