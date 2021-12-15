

import 'package:afib/src/dart/redux/state/af_test_state.dart';
import 'package:afib/src/flutter/test/af_test_actions.dart';

/// This reducer handles the default behavior of the app state, which 
/// is just to set one or more 
AFTestState afTestStateReducer(AFTestState state, dynamic action) {
  if(action is AFStartPrototypeScreenTestContextAction) {
    return state.startTest(action.context, action.navigate, action.models, action.stateViewId, action.routeParamId);
  } else if(action is AFUpdatePrototypeScreenTestModelsAction) {
    return state.updateModels(action.testId, action.models);
  } else if(action is AFPrototypeScreenTestIncrementPassCount) {
    return state.incrementPassCount(action.testId);
  } else if(action is AFPrototypeScreenTestAddError) {
    return state.addError(action.testId, action.err);
  } else if(action is AFStartPrototypeScreenTestAction) {
    return state.navigateToTest(action.test, action.navigate, action.models, action.modelsId, action.routeParamId);
  } else if(action is AFStartWireframePopTestAction) {
    return state.popWireframeTest();
  } else if(action is AFResetTestState) {
    return state.reset();
  } else if(action is AFTestUpdateWireframeStateViews) {
    return state.updateWireframeStateViews(action.registry);
  } else if(action is AFStartWireframeAction) {
    return state.startWireframe(action.wireframe);
  }


  return state;
}

