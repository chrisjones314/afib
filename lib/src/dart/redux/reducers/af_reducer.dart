

import 'package:afib/src/dart/redux/reducers/af_public_state_reducer.dart';
import 'package:afib/src/dart/redux/reducers/af_test_contexts_reducer.dart';
import 'package:afib/src/dart/redux/state/af_state.dart';

/// The primary reducer for an AFib appliations state.  
/// 
/// It handles routing and a reset state action, but otherwise delegates to the 
/// application state reducer specified in [AFApp.initialize]
AFState afReducer(AFState state, dynamic action) {

  return AFState(
    testState: afTestStateReducer(state.testState, action),
    public: afPublicStateReducer(state.public, action),
  );
}