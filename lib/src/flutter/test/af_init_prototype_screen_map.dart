
import 'package:afib/src/dart/utils/af_ui_id.dart';
import 'package:afib/src/flutter/core/af_screen_map.dart';
import 'package:afib/src/flutter/test/af_prototype_list_multi_screen.dart';
import 'package:afib/src/flutter/test/af_prototype_home_screen.dart';
import 'package:afib/src/flutter/test/af_prototype_list_single_screen.dart';
import 'package:afib/src/flutter/test/af_prototype_single_screen_screen.dart';

void afInitPrototypeScreenMap(AFScreenMap screens) {
  screens.initialScreen(AFUIID.screenPrototypeHome, (context) => AFPrototypeHomeScreen());
  screens.screen(AFUIID.screenPrototypeSingleScreen, (context) => AFPrototypeSingleScreenScreen());
  screens.screen(AFUIID.screenPrototypeListSingleScreen, (context) => AFPrototypeListSingleScreen());
  screens.screen(AFUIID.screenPrototypeListMultiScreen, (context) => AFPrototypeListMultiScreen());
}