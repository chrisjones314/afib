
import 'package:afib/afib_flutter.dart';
import 'package:afib/id.dart';
import 'package:afib/src/flutter/core/af_screen_map.dart';
import 'package:afib/src/flutter/ui/screen/af_prototype_home_screen.dart';
import 'package:afib/src/flutter/ui/screen/af_prototype_list_screen.dart';
import 'package:afib/src/flutter/ui/screen/af_prototype_third_party_home_screen.dart';
import 'package:afib/src/flutter/ui/screen/af_prototype_third_party_list_screen.dart';
import 'package:afib/src/flutter/ui/screen/af_prototype_widget_screen.dart';
import 'package:afib/src/flutter/ui/screen/af_prototype_wireframes_list_screen.dart';

void afInitPrototypeScreenMap(AFScreenMap screens) {
  final enabledTests = AFibD.config.stringListFor(AFConfigEntries.testsEnabled);
  screens.startupScreen(AFUIScreenID.screenPrototypeHome, () => AFPrototypeHomeScreenParam.createOncePerScreen(filter: enabledTests.join(" ")));

  screens.screen(AFUIScreenID.screenPrototypeHome, (_) => AFPrototypeHomeScreen());
  screens.screen(AFUIScreenID.screenPrototypeListSingleScreen, (_) => AFPrototypeTestScreen());
  screens.screen(AFUIScreenID.screenPrototypeWidget, (_) => AFPrototypeWidgetScreen());
  screens.screen(AFUIScreenID.screenPrototypeThirdPartyList, (_) => AFPrototypeThirdPartyListScreen());
  screens.screen(AFUIScreenID.screenPrototypeThirdPartyHome, (_) => AFPrototypeThirdPartyHomeScreen());
  screens.screen(AFUIScreenID.screenPrototypeWireframesList, (_) => AFPrototypeWireframesListScreen());
}