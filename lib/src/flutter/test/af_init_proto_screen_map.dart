
import 'package:afib/src/dart/utils/af_ui_id.dart';
import 'package:afib/src/flutter/core/af_screen_map.dart';
import 'package:afib/src/flutter/test/af_screen_test_list_screen.dart';
import 'package:afib/src/flutter/test/af_screen_test_screen.dart';

void afInitPrototypeScreenMap(AFScreenMap screens) {
  screens.initialScreen(AFUIID.screenPrototypeList, (context) => AFScreenTestListScreen());
  screens.screen(AFUIID.screenPrototypeInstance, (context) => AFScreenTestInstanceScreen());
}