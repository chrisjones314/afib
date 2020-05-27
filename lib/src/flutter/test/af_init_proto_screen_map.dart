
import 'package:afib/src/dart/utils/af_ui_constants.dart';
import 'package:afib/src/flutter/core/af_screen_map.dart';
import 'package:afib/src/flutter/test/af_scenario_instance_screen.dart';
import 'package:afib/src/flutter/test/af_scenario_list_screen.dart';

void afInitPrototypeScreenMap(AFScreenMap screens) {
  screens.initialScreen(AFUIConstants.scenarioListScreenId, (context) => AFScenarioListScreen());
  screens.screen(AFUIConstants.scenarioInstanceScreenId, (context) => AFScenarioInstanceScreen());
}