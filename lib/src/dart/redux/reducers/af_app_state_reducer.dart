

import 'package:afib/src/dart/redux/actions/af_app_state_actions.dart';
import 'package:afib/src/dart/redux/state/af_app_state.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';

/// This reducer handles the default behavior of the app state, which 
/// is just to set one or more 
AFAppState afAppStateReducer(AFAppState state, action) {
  if(action is AFUpdateAppStateAction) {
    return state.copyWith(action.toIntegrate);
  }
  if(AFibF.appReducer != null) {
    return AFibF.appReducer(state, action);
  }
  return state;
}

