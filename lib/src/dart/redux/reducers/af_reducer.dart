

import 'package:afib/src/dart/redux/actions/af_root_actions.dart';
import 'package:afib/src/dart/redux/reducers/af_private_state_reducer.dart';
import 'package:afib/src/dart/redux/reducers/af_public_state_reducer.dart';
import 'package:afib/src/dart/redux/state/af_state.dart';

/// The primary reducer for an AFib appliations state.  
/// 
/// It handles routing and a reset state action, but otherwise delegates to the 
/// application state reducer specified in [AFApp.initializeTests]
AFState afReducer(AFState state, dynamic action) {

  if(action is AFUpdateRootStateAction) {
    return action.state;
  }

  return AFState(
    private: afPrivateStateReducer(state.private, action),
    public: afPublicStateReducer(state.public, action),
  );
}