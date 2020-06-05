

import 'package:afib/src/dart/redux/state/af_test_state.dart';
import 'package:afib/src/flutter/test/af_test_actions.dart';

/// This reducer handles the default behavior of the app state, which 
/// is just to set one or more 
AFTestState afTestStateReducer(AFTestState state, action) {
  if(action is AFAddTestContextAction) {
    return state.addContext(action.context);
  }
  return state;
}

