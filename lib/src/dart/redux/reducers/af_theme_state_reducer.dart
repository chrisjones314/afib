

import 'package:afib/src/dart/redux/actions/af_theme_actions.dart';
import 'package:afib/src/dart/redux/state/models/af_theme_state.dart';

AFThemeState afThemeStateReducer(AFThemeState theme, dynamic action) {
  if(action is AFUpdateThemeStateAction) {
    return action.themes;
  }
  if(action is AFOverrideThemeValueAction) {
    return theme.reviseOverrideThemeValue(action.id, action.value);
  }
  if(action is AFRebuildThemeState) {
    return theme.reviseRebuildAll();
  }
  if(action is AFRebuildFunctionalThemes) {
    return theme.reviseRebuildFunctional();
  }


  return theme;
}
