

import 'package:afib/src/dart/redux/actions/af_app_state_actions.dart';
import 'package:afib/src/dart/redux/reducers/af_app_state_reducer.dart';
import 'package:afib/src/dart/redux/reducers/af_route_reducer.dart';
import 'package:afib/src/dart/redux/state/af_state.dart';

/// The primary reducer for an AFib appliations state.  
/// 
/// It handles routing and a reset state action, but otherwise delegates to the 
/// application state reducer specified in [AFApp.initialize]
AFState afReducer(AFState state, action) {

  if(action is AFResetToInitialStateAction) {
    return AFState.initialState();
  }

  return AFState(
    route: routeReducer(state.route, action),
    app: afAppStateReducer(state.app, action)
  );
}