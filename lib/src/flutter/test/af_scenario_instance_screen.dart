

import 'package:afib/afib_dart.dart';
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/utils/af_ui_id.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/test/af_prototype_dispatcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';

/// Parameter uses to filter the scenarios shown on the screen.
@immutable
class AFScenarioInstanceScreenParam extends AFRouteParam {
  final AFID id;
  final AFRouteParam param;

  AFScenarioInstanceScreenParam({this.id, this.param});

  AFScenarioInstanceScreenParam copyWith() {
    return AFScenarioInstanceScreenParam();
  }
}

/// Data used to render the screen
class AFScenarioInstanceScreenData extends AFStoreConnectorData1<AFUserInterfaceScreenTests> {
  AFScenarioInstanceScreenData(AFUserInterfaceScreenTests scenarios): 
    super(first: scenarios);
  
  AFUserInterfaceScreenTests get scenarios { return first; }
}

/// A screen used internally in prototype mode to render screens and widgets with test data,
/// and display them in a list.
class AFScenarioInstanceScreen extends AFConnectedScreen<AFAppState, AFScenarioInstanceScreenData, AFScenarioInstanceScreenParam>{

  AFScenarioInstanceScreen(): super(AFUIID.screenPrototypeInstance);

  @override
  AFScenarioInstanceScreenData createData(AFAppState state) {
    AFUserInterfaceScreenTests scenarios = AF.userInterfaceScenarios;
    return AFScenarioInstanceScreenData(scenarios);
  }

  @override
  Widget buildWithContext(AFBuildContext<AFScenarioInstanceScreenData, AFScenarioInstanceScreenParam> context) {
    return _buildScreen(context);
  }


  Widget _buildScreen(AFBuildContext<AFScenarioInstanceScreenData, AFScenarioInstanceScreenParam> context) {
    AFUserInterfaceScreenTests scenarios = context.s.scenarios;
    AFUserInterfaceScreenTestFull full = scenarios.findById(context.p.id);
    AFRouteParam paramChild = context.p.param ?? full.data.param;
    final dispatcher = AFPrototypeDispatcher(context.p.id, context.d);
    final childContext = full.scenario.widget.createContext(context.c, dispatcher, full.data.data, paramChild);
    return full.scenario.widget.buildWithContext(childContext);
  }
}