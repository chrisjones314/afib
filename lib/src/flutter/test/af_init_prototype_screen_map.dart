
import 'package:afib/afib_dart.dart';
import 'package:afib/src/dart/utils/af_ui_id.dart';
import 'package:afib/src/flutter/core/af_screen_map.dart';
import 'package:afib/src/flutter/test/af_prototype_home_screen.dart';
import 'package:afib/src/flutter/test/af_prototype_list_screen.dart';
import 'package:afib/src/flutter/test/af_prototype_widget_screen.dart';

void afInitPrototypeScreenMap(AFScreenMap screens) {
  final enabledTests = AFibD.config.stringListFor(AFConfigEntries.enabledTestList);
  screens.startupScreen(AFUIScreenID.screenPrototypeHome, (context) => AFPrototypeHomeScreen(), () => AFPrototypeHomeScreenParam.createOncePerScreen(filter: enabledTests.join(" ")));
  screens.screen(AFUIScreenID.screenPrototypeListSingleScreen, (context) => AFPrototypeTestScreen());
  screens.screen(AFUIScreenID.screenPrototypeWidget, (context) => AFPrototypeWidgetScreen());
}