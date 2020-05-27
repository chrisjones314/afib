

import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';
import 'package:flutter/widgets.dart';

/// The data, title, and id associated with a particular widget scenario.
class AFUserInterfaceScenarioData {
  String id;
  String title;
  dynamic data;
  dynamic param;

  AFUserInterfaceScenarioData({
    @required this.id,
    @required this.title,
    @required this.data,
    @required this.param
  });

}

/// A single widget that can be populated with multiple different data scenarios.
class AFUserInterfaceScenario {
  AFBuildableWidget widget;
  List<AFUserInterfaceScenarioData> instances = List<AFUserInterfaceScenarioData>();

  AFUserInterfaceScenario({
    @required this.widget,
  });

  /// Add an instance to a scenario.
  void add({
    @required String id,
    @required String title,
    @required dynamic data,
    @required dynamic param
  }) {
    AFUserInterfaceScenarioData instance = AFUserInterfaceScenarioData(
      id: id,
      title: title,
      data: data,
      param: param
    );
    instances.add(instance);
  }
}

class AFUserInterfaceScenarioFull {
  final AFUserInterfaceScenario scenario;
  final AFRouteParam param;
  final AFUserInterfaceScenarioData data;

  AFUserInterfaceScenarioFull({this.scenario, this.param, this.data});
}

/// This class is used to create canned versions of screens and widget populated
/// with specific data for testing and prototyping purposes.
class AFUserInterfaceScenarios<TState> {
  
  List<AFUserInterfaceScenario> scenarios = List<AFUserInterfaceScenario>();

  /// Add a screen widget, and then in the [addInstances] callback add one or more 
  /// data states to render with that screen.
  void addScreen(AFBuildableWidget widget, Function(AFUserInterfaceScenario) addInstances) {
    AFUserInterfaceScenario scenario = AFUserInterfaceScenario(widget: widget);
    addInstances(scenario);
    scenarios.add(scenario);
  }

  AFUserInterfaceScenarioFull findById(String id) {
    for(int s = 0; s < scenarios.length; s++) {
      final scenario = scenarios[s];
      for(int i = 0; i < scenario.instances.length; i++) {
        final instance = scenario.instances[i];
        if(instance.id == id) {
          return AFUserInterfaceScenarioFull(scenario: scenario, data: instance);
        }
      }
    }
    return null;
  }
  
  List<AFUserInterfaceScenario> get all { return scenarios; }

}