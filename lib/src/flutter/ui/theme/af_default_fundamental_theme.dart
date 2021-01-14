

import 'package:afib/src/dart/redux/state/af_app_state.dart';
import 'package:afib/src/dart/redux/state/af_theme_state.dart';
import 'package:flutter/material.dart';

void initAFDefaultFundamentalThemeArea(AFFundamentalDeviceTheme device, AFAppStateAreas appState, AFAppFundamentalThemeAreaBuilder primary) {
  final colorsLight = ColorScheme.light();
  final colorsDark = ColorScheme.dark();  
  final themeDark = Typography.whiteCupertino;
  final themeLight = Typography.blackCupertino;

  primary.setFlutterFundamentals(
    colorSchemeLight: colorsLight,
    colorSchemeDark: colorsDark,
    textThemeDark: themeDark,
    textThemeLight: themeLight,
  ); 

  primary.setAfibFundamentals();
}