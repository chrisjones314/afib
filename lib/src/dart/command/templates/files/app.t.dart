




import 'package:afib/src/dart/command/af_source_template.dart';

class AFAppT extends AFSourceTemplate {

  final String template = '''
import 'package:afib/afib_flutter.dart';
import 'package:[!af_package_path]/state/[!af_app_namespace]_state.dart';
import 'package:flutter/material.dart';

class [!af_app_namespace(upper)]App extends AFMaterialApp<[!af_app_namespace(upper)]State> {

  [!af_app_namespace(upper)]App(): super();

  @override
  Widget buildMaterialApp(AFFundamentalThemeState fundamentals) {
    final screenMap = AFibF.g.effectiveScreenMap;
    return MaterialApp(
        title: fundamentals.translate(AFUITranslationID.appTitle),
        navigatorKey: AFibF.g.navigatorKey,
        theme: fundamentals.themeDataActive,
        supportedLocales: fundamentals.supportedLocales,
        navigatorObservers: [
          createAFNavigatorObserver(),
        ],        
        initialRoute: AFibF.g.effectiveStartupScreenId.code,
        routes: screenMap!.screens
      );
  }
}

''';

}







