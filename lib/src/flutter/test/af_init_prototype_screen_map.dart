
import 'package:afib/afib_flutter.dart';
import 'package:afib/id.dart';
import 'package:afib/src/flutter/core/af_screen_map.dart';
import 'package:afib/src/flutter/ui/screen/afui_prototype_home_screen.dart';
import 'package:afib/src/flutter/ui/screen/afui_prototype_list_screen.dart';
import 'package:afib/src/flutter/ui/screen/afui_prototype_third_party_home_screen.dart';
import 'package:afib/src/flutter/ui/screen/afui_prototype_third_party_list_screen.dart';
import 'package:afib/src/flutter/ui/screen/afui_prototype_widget_screen.dart';
import 'package:afib/src/flutter/ui/screen/afui_prototype_wireframes_list_screen.dart';

void afInitPrototypeScreenMap(AFScreenMap screens) {
  final enabledTests = AFibD.config.stringListFor(AFConfigEntries.testsEnabled);
  screens.startupScreen(AFUIScreenID.screenPrototypeHome, () => AFUIPrototypeHomeScreenParam.createOncePerScreen(filter: enabledTests.join(" ")));

  screens.screen(AFUIScreenID.screenPrototypeHome, (_) => AFPrototypeHomeScreen());
  screens.screen(AFUIScreenID.screenPrototypeListSingleScreen, (_) => AFUIPrototypeTestScreen());
  screens.screen(AFUIScreenID.screenPrototypeWidget, (_) => AFUIPrototypeWidgetScreen());
  screens.screen(AFUIScreenID.screenPrototypeThirdPartyList, (_) => AFUIPrototypeThirdPartyListScreen());
  screens.screen(AFUIScreenID.screenPrototypeThirdPartyHome, (_) => AFUIPrototypeThirdPartyHomeScreen());
  screens.screen(AFUIScreenID.screenPrototypeWireframesList, (_) => AFUIPrototypeWireframesListScreen());
}