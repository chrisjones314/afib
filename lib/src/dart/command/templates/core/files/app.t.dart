
import 'package:afib/src/dart/command/af_source_template.dart';

/// Any class that ends in "T" is a source template used in code generation.
class AppT extends AFCoreFileSourceTemplate {

  AppT(): super(
    templateFileId: "app",
  );

  String get template => '''
import 'package:afib/afib_flutter.dart';
import 'package:$insertPackagePath/state/${insertAppNamespace}_state.dart';
import 'package:flutter/material.dart';

class ${insertAppNamespaceUpper}App extends AFMaterialApp<${insertAppNamespaceUpper}State> {

  ${insertAppNamespaceUpper}App(): super();

  @override
  Widget buildMaterialApp(AFFundamentalThemeState fundamentals) {
    final screenMap = AFibF.g.effectiveScreenMap;
    return MaterialApp(
        title: fundamentals.translate(text: AFUITranslationID.appTitle),
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







