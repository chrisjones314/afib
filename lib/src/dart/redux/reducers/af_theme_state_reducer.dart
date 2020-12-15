

import 'package:afib/src/dart/redux/actions/af_theme_actions.dart';
import 'package:afib/src/dart/redux/state/af_theme_state.dart';

AFThemeState afThemeStateReducer(AFThemeState theme, dynamic action) {
  if(action is AFUpdateThemeStateAction) {
    return action.themes;
  }
  return theme;
}
