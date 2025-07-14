// ignore_for_file: deprecated_member_use

import 'package:afib/src/dart/redux/state/models/af_app_state.dart';
import 'package:afib/src/dart/redux/state/models/af_theme_state.dart';
import 'package:flutter/material.dart';

void defineAFDefaultFundamentalTheme(AFFundamentalDeviceTheme device, AFComponentStates appState, AFAppFundamentalThemeAreaBuilder primary) {
  const themeDark = Typography.whiteMountainView;
  const themeLight = Typography.blackMountainView;
  
  const colorPrimary = Color(0xff2D4580);
  const colorPrimaryDark = Color(0xff1b2a4e);
  //final colorPrimaryDarker = Color(0xff320a00);
  const colorSecondary = Color(0xff803953);
  const colorSecondaryDark = Color(0xff80143C);
  //final colorSecondaryDarker = Color(0xff1e1623);
  const colorWhite = Colors.white;
  const colorError = Colors.red;
  const colorBlack = Colors.black;
  final colorBackground = Colors.grey[200] ?? Colors.grey;
  final colorSurfaceDark = Colors.grey[900] ?? Colors.grey;

  final colorsLight = ColorScheme(
    primary: colorPrimary,
    secondary: colorSecondary,
    onPrimary: colorWhite,
    onSecondary: colorWhite,
    onBackground: colorBlack,
    error: colorError,
    surface: colorWhite,
    onSurface: colorBlack,
    background: colorBackground,
    onError: colorWhite,
    brightness: Brightness.light
  );

  final colorsDark = ColorScheme(
    primary: colorPrimaryDark,
    secondary: colorSecondaryDark,
    onPrimary: colorWhite,
    onSecondary: colorWhite,
    onBackground: colorWhite,
    error: colorError,
    surface: colorSurfaceDark,
    onSurface: colorWhite,
    background: colorBlack,
    onError: colorWhite,
    brightness: Brightness.dark
  );

  primary.setFlutterFundamentals(
    colorSchemeLight: colorsLight,
    colorSchemeDark: colorsDark,
    textThemeDark: themeDark,
    textThemeLight: themeLight
  ); 

  primary.setAfibFundamentals();
}