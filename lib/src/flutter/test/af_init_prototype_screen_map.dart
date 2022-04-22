
import 'package:afib/afui_id.dart';
import 'package:afib/src/dart/command/af_command_enums.dart';
import 'package:afib/src/dart/utils/af_config_entries.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/core/af_screen_map.dart';
import 'package:afib/src/flutter/ui/screen/afui_prototype_bottomsheet_screen.dart';
import 'package:afib/src/flutter/ui/screen/afui_prototype_dialog_screen.dart';
import 'package:afib/src/flutter/ui/screen/afui_prototype_drawer_screen.dart';
import 'package:afib/src/flutter/ui/screen/afui_prototype_home_screen.dart';
import 'package:afib/src/flutter/ui/screen/afui_prototype_list_screen.dart';
import 'package:afib/src/flutter/ui/screen/afui_prototype_loading_screen.dart';
import 'package:afib/src/flutter/ui/screen/afui_prototype_library_home_screen.dart';
import 'package:afib/src/flutter/ui/screen/afui_prototype_library_list_screen.dart';
import 'package:afib/src/flutter/ui/screen/afui_prototype_waiting_screen.dart';
import 'package:afib/src/flutter/ui/screen/afui_prototype_widget_screen.dart';
import 'package:afib/src/flutter/ui/screen/afui_prototype_wireframes_list_screen.dart';

void afInitPrototypeScreenMap(AFScreenMap screens) {
  final enabledTests = AFibD.config.stringListFor(AFConfigEntries.testsEnabled);
  final config = AFibD.config;
  final env = config.environment;
  if(env == AFEnvironment.prototype) {
    screens.registerStartupScreen(AFUIScreenID.screenPrototypeHome, () => AFUIPrototypeHomeScreenParam.createOncePerScreen(filter: enabledTests.join(" ")));
  } else {
    assert(config.isPrototypeEnvironment);
    screens.registerStartupScreen(AFUIScreenID.screenPrototypeLoading, () => AFRouteParam(id: AFUIScreenID.screenPrototypeLoading));
  }

  screens.registerScreen(AFUIScreenID.screenPrototypeHome, (_) => AFPrototypeHomeScreen());
  screens.registerScreen(AFUIScreenID.screenPrototypeLoading, (_) => AFPrototypeLoadingScreen());
  screens.registerScreen(AFUIScreenID.screenPrototypeListSingleScreen, (_) => AFUIPrototypeTestScreen());
  screens.registerScreen(AFUIScreenID.screenPrototypeWidget, (_) => AFUIPrototypeWidgetScreen());
  screens.registerScreen(AFUIScreenID.screenPrototypeLibraryList, (_) => AFUIPrototypeLibraryListScreen());
  screens.registerScreen(AFUIScreenID.screenPrototypeLibraryHome, (_) => AFUIPrototypeLibraryHomeScreen());
  screens.registerScreen(AFUIScreenID.screenPrototypeWireframesList, (_) => AFUIPrototypeWireframesListScreen());
  screens.registerScreen(AFUIScreenID.screenPrototypeWaiting, (_) => AFUIPrototypeWaitingScreen());
  screens.registerScreen(AFUIScreenID.screenPrototypeDialog, (_) => AFUIPrototypeDialogScreen());
  screens.registerScreen(AFUIScreenID.screenPrototypeBottomSheet, (_) => AFUIPrototypeBottomSheetScreen());
  screens.registerScreen(AFUIScreenID.screenPrototypeDrawer, (_) => AFUIPrototypeDrawerScreen());
}