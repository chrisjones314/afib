
import 'package:afib/src/dart/redux/state/af_app_state.dart';
import 'package:afib/src/dart/redux/state/af_theme_state.dart';
import 'package:afib/src/flutter/af_material_app.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:flutter/material.dart';

class AFAppUILibrary extends AFMaterialApp<AFAppStateArea> {
  AFAppUILibrary() : super();

  //----------------------------------------------------------------------------
  @override
  Widget buildMaterialApp(AFFundamentalTheme fundamentals) {
    final screenMap = AFibF.g.effectiveScreenMap;
    return MaterialApp(
        title: 'AFib UI Library',
        supportedLocales: fundamentals.supportedLocales,
        navigatorKey: AFibF.g.navigatorKey,
        theme: fundamentals.themeDataActive,
        initialRoute: AFibF.g.effectiveStartupScreenId.code,
        routes: screenMap.screens
      );
  }
}

AFAppUILibrary createUILibraryApp() {
  return AFAppUILibrary();
}