


import 'package:afib/src/dart/redux/actions/af_app_state_actions.dart';
import 'package:afib/src/dart/redux/state/models/af_app_platform_info_state.dart';

/// This reducer handles the default behavior of the app state, which 
/// is just to set one or more 
AFAppPlatformInfoState afAppPlatformInfoStateReducer(AFAppPlatformInfoState current, dynamic action) {
  
  if(action is AFUpdateAppPlatformInfoAction) {
    return action.appState;
  }
  return current;
}

