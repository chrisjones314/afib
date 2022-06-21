
import 'package:afib/src/dart/command/af_source_template.dart';

class AFDefineCoreT extends AFSourceTemplate {

  final String template = '''
import 'package:flutter/material.dart';
import 'package:afib/afib_flutter.dart';
import 'package:[!af_package_name]/[!af_app_namespace]_id.dart';
import 'package:[!af_package_path]/ui/screens/startup_screen.dart';

void defineCore(AFCoreDefinitionContext context) {
  defineInitialState(context)
  defineFunctionalThemes(context);
  defineLibraryProgrammingInterfaces(context);
  defineScreens(context);
}

void defineInitialState(AFCoreDefinitionContext context) {
  context.defineComponentStateInitializer(() => [!af_app_namespace(upper)]State.initial());
}

void defineFunctionalThemes(AFUIDefinitionContext context) {

}

void defineLibraryProgrammingInterfaces(AFUIDefinitionContext context) {

}

void defineScreens(AFUIDefinitionContext context) {
  context.defineStartupScreen([!af_app_namespace(upper)]ScreenID.startup, () => StartupScreenRouteParam.create());
}  

void defineFundamentalThemeArea(AFFundamentalDeviceTheme device, AFComponentStates appState, AF[!af_lib_kind]FundamentalThemeAreaBuilder primary) {

  [!af_fundamental_theme_init]
}

''';
}
