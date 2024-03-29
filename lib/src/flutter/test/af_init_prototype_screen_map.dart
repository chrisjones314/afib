
import 'package:afib/afib_uiid.dart';
import 'package:afib/src/dart/command/af_command_enums.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/core/af_screen_map.dart';
import 'package:afib/src/flutter/ui/drawer/afui_prototype_drawer.dart';
import 'package:afib/src/flutter/ui/screen/afui_prototype_bottomsheet_screen.dart';
import 'package:afib/src/flutter/ui/screen/afui_prototype_dialog_screen.dart';
import 'package:afib/src/flutter/ui/screen/afui_prototype_drawer_screen.dart';
import 'package:afib/src/flutter/ui/screen/afui_prototype_home_screen.dart';
import 'package:afib/src/flutter/ui/screen/afui_prototype_library_home_screen.dart';
import 'package:afib/src/flutter/ui/screen/afui_prototype_library_list_screen.dart';
import 'package:afib/src/flutter/ui/screen/afui_prototype_list_screen.dart';
import 'package:afib/src/flutter/ui/screen/afui_prototype_loading_screen.dart';
import 'package:afib/src/flutter/ui/screen/afui_prototype_waiting_screen.dart';
import 'package:afib/src/flutter/ui/screen/afui_prototype_widget_screen.dart';
import 'package:afib/src/flutter/ui/screen/afui_prototype_wireframes_list_screen.dart';
import 'package:afib/src/flutter/ui/screen/afui_state_test_list_screen.dart';

void afInitPrototypeScreenMap(AFScreenMap screens) {
  final config = AFibD.config;
  final env = config.environment;
  if(env == AFEnvironment.prototype) {
    screens.registerStartupScreen(AFUIScreenID.screenPrototypeHome, () => AFUIPrototypeHomeScreenParam.createOncePerScreen());
  } else {
    assert(config.isPrototypeEnvironment);
    screens.registerStartupScreen(AFUIScreenID.screenPrototypeLoading, () => const AFRouteParam(screenId: AFUIScreenID.screenPrototypeLoading, wid: AFUIWidgetID.useScreenParam, routeLocation: AFRouteLocation.screenHierarchy));
  }

  screens.registerScreen(AFUIScreenID.screenPrototypeHome, (_) => AFPrototypeHomeScreen(), AFPrototypeHomeScreen.config);
  screens.registerScreen(AFUIScreenID.screenPrototypeLoading, (_) => AFPrototypeLoadingScreen(), AFPrototypeLoadingScreen.config);
  screens.registerScreen(AFUIScreenID.screenPrototypeListSingleScreen, (_) => AFUIPrototypeTestScreen(), AFUIPrototypeTestScreen.config);
  screens.registerScreen(AFUIScreenID.screenStateTestListScreen, (_) => AFUIStateTestListScreen(), AFUIStateTestListScreen.config);
  screens.registerScreen(AFUIScreenID.screenPrototypeWidget, (_) => AFUIPrototypeWidgetScreen(), AFUIPrototypeWidgetScreen.config);
  screens.registerScreen(AFUIScreenID.screenPrototypeLibraryList, (_) => AFUIPrototypeLibraryListScreen(), AFUIPrototypeLibraryListScreen.config);
  screens.registerScreen(AFUIScreenID.screenPrototypeLibraryHome, (_) => AFUIPrototypeLibraryHomeScreen(), AFUIPrototypeLibraryHomeScreen.config);
  screens.registerScreen(AFUIScreenID.screenPrototypeWireframesList, (_) => AFUIPrototypeWireframesListScreen(), AFUIPrototypeWireframesListScreen.config);
  screens.registerScreen(AFUIScreenID.screenPrototypeWaiting, (_) => AFUIPrototypeWaitingScreen(), AFUIPrototypeWaitingScreen.config);
  screens.registerScreen(AFUIScreenID.screenPrototypeDialog, (_) => AFUIPrototypeDialogScreen(), AFUIPrototypeDialogScreen.config);
  screens.registerScreen(AFUIScreenID.screenPrototypeBottomSheet, (_) => AFUIPrototypeBottomSheetScreen(), AFUIPrototypeBottomSheetScreen.config);
  screens.registerScreen(AFUIScreenID.screenPrototypeDrawer, (_) => AFUIPrototypeDrawerScreen(), AFUIPrototypeDrawerScreen.config);
  screens.registerDrawer(AFUIScreenID.drawerPrototype, (_) => AFUIPrototypeDrawer(), AFUIPrototypeDrawer.config);
}