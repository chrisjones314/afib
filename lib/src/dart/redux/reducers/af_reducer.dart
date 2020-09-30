

import 'package:afib/src/dart/redux/actions/af_app_state_actions.dart';
import 'package:afib/src/dart/redux/reducers/af_app_state_reducer.dart';
import 'package:afib/src/dart/redux/reducers/af_route_reducer.dart';
import 'package:afib/src/dart/redux/reducers/af_test_contexts_reducer.dart';
import 'package:afib/src/dart/redux/state/af_state.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';

/// The primary reducer for an AFib appliations state.  
/// 
/// It handles routing and a reset state action, but otherwise delegates to the 
/// application state reducer specified in [AFApp.initialize]
AFState afReducer(AFState state, dynamic action) {

  if(action is AFResetToInitialStateAction) {
    // In the state/screen test context, we want to reset to the intial
    // app state, but leave the route and test state unchanged.
    return state.copyWith(
      app: AFibF.initializeAppState()
    );
  }

  return AFState(
    testState: afTestStateReducer(state.testState, action),
    route: routeReducer(state.route, action),
    app: afAppStateReducer(state.app, action)
  );
}