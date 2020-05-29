

import 'package:afib/afib_dart.dart';
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/utils/af_ui_id.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/test/af_scenario_instance_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';

/// Parameter uses to filter the scenarios shown on the screen.
@immutable
class AFScenarioListScreenParam extends AFRouteParam {
  final String filter;

  AFScenarioListScreenParam({this.filter});

  AFScenarioListScreenParam copyWith() {
    return AFScenarioListScreenParam();
  }
}

/// Data used to render the screen
class AFScenarioListScreenData extends AFStoreConnectorData1<AFScreenTests> {
  AFScenarioListScreenData(AFScreenTests scenarios): 
    super(first: scenarios);
  
  AFScreenTests get scenarios { return first; }
}

/// A screen used internally in prototype mode to render screens and widgets with test data,
/// and display them in a list.
class AFScenarioListScreen extends AFConnectedScreen<AFAppState, AFScenarioListScreenData, AFScenarioListScreenParam>{

  AFScenarioListScreen(): super(AFUIID.screenPrototypeList);

  @override
  AFScenarioListScreenData createData(AFAppState state) {
    AFScreenTests scenarios = AF.screenTests;
    return AFScenarioListScreenData(scenarios);
  }

  @override
  Widget buildWithContext(AFBuildContext<AFScenarioListScreenData, AFScenarioListScreenParam> context) {
    return _buildList(context);
  }

  Widget _buildList(AFBuildContext<AFScenarioListScreenData, AFScenarioListScreenParam> context) {
    final column = AFUI.column();

    AFScreenTests scenarios = context.s.scenarios;
    scenarios.all.forEach( (scenario) {
      _addForWidget(context, column, scenario);
    });    

    return Scaffold(
      body: ListView(children: column)
    );    
  }

  void _addForWidget(AFBuildContext<AFScenarioListScreenData, AFScenarioListScreenParam> context, List<Widget> column, AFScreenTest source) {
    StringBuffer title = StringBuffer(source.widget.runtimeType.toString());
    column.add(Card(
      color: Colors.grey,
      child: Container(
        margin: EdgeInsets.all(8.0),
        child: Text(title.toString())
      )
    ));

    source.tests.forEach((instance) {
      column.add(_createCard(context, instance));
    });

  }

  Widget _createCard(AFBuildContext<AFScenarioListScreenData, AFScenarioListScreenParam> context, AFScreenTestData instance) {
    return Card(
      key: Key(instance.id.code),
      child: ListTile(
        title: Text(instance.id.name),
        subtitle: Text(instance.id.code),
        onTap: () {
          context.dispatch(AFScenarioInstanceScreen.navigatePush(instance));
        })
    );
  }
}