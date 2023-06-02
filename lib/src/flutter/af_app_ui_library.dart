
import 'package:afib/src/dart/redux/state/models/af_app_state.dart';
import 'package:afib/src/dart/redux/state/models/af_theme_state.dart';
import 'package:afib/src/flutter/af_material_app.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:flutter/material.dart';

class AFAppUILibrary extends AFMaterialApp<AFComponentState> {
  const AFAppUILibrary({Key? key}) : super(key: key);

  //----------------------------------------------------------------------------
  @override
  Widget buildMaterialApp(AFFundamentalThemeState fundamentals) {
    final screenMap = AFibF.g.effectiveScreenMap;
    assert(screenMap != null);
    return MaterialApp(
        title: 'AFib UI Library',
        supportedLocales: fundamentals.supportedLocales,
        navigatorKey: AFibF.g.navigatorKey,
        theme: fundamentals.themeDataActive,
        initialRoute: AFibF.g.effectiveStartupScreenId.code,
        routes: screenMap!.screens
      );
  }
}

AFAppUILibrary createUILibraryApp() {
  return const AFAppUILibrary();
}