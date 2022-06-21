



import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareUIFunctionsT extends AFSourceTemplate {
  final String template = '''
void defineFunctionalThemes(AFUIDefinitionContext context) {
}


void defineScreens(AFUIDefinitionContext context) {
  context.defineStartupScreen([!af_app_namespace(upper)]ScreenID.startup, () => StartupScreenRouteParam.create());
}  

void defineFundamentalThemeArea(AFFundamentalDeviceTheme device, AFComponentStates appState, AF[!af_lib_kind]FundamentalThemeAreaBuilder primary) {
  [!af_fundamental_theme_init]
}
''';
}


  
