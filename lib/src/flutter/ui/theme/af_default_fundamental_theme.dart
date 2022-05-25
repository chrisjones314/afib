import 'package:afib/src/dart/redux/state/models/af_app_state.dart';
import 'package:afib/src/dart/redux/state/models/af_theme_state.dart';
import 'package:flutter/material.dart';

void defineAFDefaultFundamentalThemeArea(AFFundamentalDeviceTheme device, AFComponentStates appState, AFAppFundamentalThemeAreaBuilder primary) {
  final themeDark = Typography.whiteMountainView;
  final themeLight = Typography.blackMountainView;
  
  final colorPrimary = Color(0xff8d5b4c);
  final colorPrimaryDark = Color(0xff5d3124);
  //final colorPrimaryDarker = Color(0xff320a00);
  final colorSecondary = Color(0xff706677);
  final colorSecondaryDark = Color(0xff453c4b);
  //final colorSecondaryDarker = Color(0xff1e1623);
  final colorWhite = Colors.white;
  final colorError = Color(0xffbf0603);
  final colorBlack = Colors.black;
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