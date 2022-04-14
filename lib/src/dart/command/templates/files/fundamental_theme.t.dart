



import 'package:afib/src/dart/command/af_source_template.dart';

class AFFundamentalThemeT extends AFSourceTemplate {

  final String template = '''
import 'package:afib/afib_flutter.dart';
import 'package:flutter/material.dart';

void defineFundamentalThemeArea(AFFundamentalDeviceTheme device, AFComponentStates appState, AFAppFundamentalThemeAreaBuilder primary) {

  const colorPrimary = Color(0xFF0d47a1);
  const colorSecondary = Color(0xFF00695c);

  final colorsLight = ColorScheme(
    primary: colorPrimary,
    secondary: colorSecondary,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onBackground: Colors.black,
    error: Colors.red,
    surface: Colors.white,
    onSurface: Colors.black,
    background: Colors.grey[200] ?? Colors.grey,
    onError: Colors.white,
    brightness: Brightness.light
  );


  const colorsDarkBase = ColorScheme.dark();  
  final colorsDark = ColorScheme(
    primary: colorPrimary,
    secondary: colorSecondary,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onBackground: colorsDarkBase.onBackground,
    error: colorsDarkBase.error,
    surface: colorsDarkBase.surface,
    onSurface: colorsDarkBase.onSurface,
    background: colorsDarkBase.background,
    onError: colorsDarkBase.onError,
    brightness: Brightness.dark
  );

  const origDark = Typography.whiteCupertino;
  const origLight = Typography.blackCupertino;

  final themeDark = origDark.copyWith(
    bodyText1: origDark.bodyText1?.copyWith(fontWeight: FontWeight.bold)
  );

  final themeLight = origLight.copyWith(
    bodyText1: origLight.bodyText1?.copyWith(fontWeight: FontWeight.bold)
  );

  primary.setFlutterFundamentals(
    colorSchemeLight: colorsLight,
    colorSchemeDark: colorsDark,
    textThemeDark: themeDark,
    textThemeLight: themeLight,
  ); 

  primary.setAfibFundamentals();

  primary.setTranslations(AFUILocaleID.englishUS, {
    AFUITranslationID.appTitle: "[!af_package_name]"
  });
}
''';

}
