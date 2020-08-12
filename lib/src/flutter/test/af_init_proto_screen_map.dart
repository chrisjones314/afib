
import 'package:afib/src/dart/utils/af_ui_id.dart';
import 'package:afib/src/flutter/core/af_screen_map.dart';
import 'package:afib/src/flutter/test/af_multiscreen_state_test_list_screen.dart';
import 'package:afib/src/flutter/test/af_proto_home_screen.dart';
import 'package:afib/src/flutter/test/af_simple_prototype_list_screen.dart';
import 'package:afib/src/flutter/test/af_simple_prototype_screen.dart';

void afInitPrototypeScreenMap(AFScreenMap screens) {
  screens.initialScreen(AFUIID.screenPrototypeHome, (context) => AFPrototypeHomeScreen());
  screens.screen(AFUIID.screenPrototypeSimple, (context) => AFScreenPrototypeScreen());
  screens.screen(AFUIID.screenSimplePrototypeList, (context) => AFSimplePrototypeListScreen());
  screens.screen(AFUIID.screenMultiScreenTestList, (context) => AFMultiScreenStateListScreen());
}