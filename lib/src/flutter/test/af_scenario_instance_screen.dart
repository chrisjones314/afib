

import 'package:afib/afib_dart.dart';
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/utils/af_ui_constants.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/test/af_prototype_dispatcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';

/// Parameter uses to filter the scenarios shown on the screen.
@immutable
class AFScenarioInstanceScreenParam extends AFRouteParam {
  final String id;
  final AFRouteParam param;

  AFScenarioInstanceScreenParam({this.id, this.param});

  AFScenarioInstanceScreenParam copyWith() {
    return AFScenarioInstanceScreenParam();
  }
}

/// Data used to render the screen
class AFScenarioInstanceScreenData extends AFStoreConnectorData1<AFUserInterfaceScenarios> {
  AFScenarioInstanceScreenData(AFUserInterfaceScenarios scenarios): 
    super(first: scenarios);
  
  AFUserInterfaceScenarios get scenarios { return first; }
}

/// A screen used internally in prototype mode to render screens and widgets with test data,
/// and display them in a list.
class AFScenarioInstanceScreen extends AFConnectedScreen<AFAppState, AFScenarioInstanceScreenData, AFScenarioInstanceScreenParam>{

  AFScenarioInstanceScreen(): super(AFUIConstants.scenarioInstanceScreenId);

  @override
  AFScenarioInstanceScreenData createData(AFAppState state) {
    AFUserInterfaceScenarios scenarios = AF.userInterfaceScenarios;
    return AFScenarioInstanceScreenData(scenarios);
  }

  @override
  Widget buildWithContext(AFBuildContext<AFScenarioInstanceScreenData, AFScenarioInstanceScreenParam> context) {
    return _buildScreen(context);
  }


  Widget _buildScreen(AFBuildContext<AFScenarioInstanceScreenData, AFScenarioInstanceScreenParam> context) {
    AFUserInterfaceScenarios scenarios = context.s.scenarios;
    AFUserInterfaceScenarioFull full = scenarios.findById(context.p.id);
    AFRouteParam paramChild = context.p.param ?? full.data.param;
    final dispatcher = AFPrototypeDispatcher(context.p.id, context.d);
    final childContext = full.scenario.widget.createContext(context.c, dispatcher, full.data.data, paramChild);
    return full.scenario.widget.buildWithContext(childContext);
  }
}