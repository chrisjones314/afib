

import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';
import 'package:flutter/widgets.dart';


/// Base class for all statements in a test body.
abstract class AFTestStatement {
}

/// Verifies that a widget with the specified ID is present on the screen
class AFVerifyPresent extends AFTestStatement {
  final AFID widParent;
  final AFID widChild; 
  AFVerifyPresent({this.widParent, this.widChild});
}

/// Represents a sequence of actions that manipulate and verify
/// the state of a screen.
class AFTestBody {
  final List<AFTestStatement> statements = List<AFTestStatement>();

  void verifyPresent(AFID wid) {
    statements.add(AFVerifyPresent(widChild: wid));   
  }
}

/// The data, title, and id associated with a particular widget scenario.
class AFUserInterfaceScreenTestData {
  AFID id;
  dynamic data;
  dynamic param;
  final AFTestBody testBody = AFTestBody();
  

  AFUserInterfaceScreenTestData({
    @required this.id,
    @required this.data,
    @required this.param
  });
}

/// A single widget that can be populated with multiple different data scenarios.
class AFUserInterfaceScreenTest {
  AFBuildableWidget widget;
  List<AFUserInterfaceScreenTestData> instances = List<AFUserInterfaceScreenTestData>();

  AFUserInterfaceScreenTest({
    @required this.widget,
  });

  /// Add an instance to a scenario.
  AFTestBody add({
    @required AFTestID   id,
    @required dynamic data,
    @required dynamic param
  }) {
    AFUserInterfaceScreenTestData instance = AFUserInterfaceScreenTestData(
      id: id,
      data: data,
      param: param
    );
    instances.add(instance);
    return instance.testBody;
  }
}

class AFUserInterfaceScreenTestFull {
  final AFUserInterfaceScreenTest scenario;
  final AFRouteParam param;
  final AFUserInterfaceScreenTestData data;

  AFUserInterfaceScreenTestFull({this.scenario, this.param, this.data});
}

/// This class is used to create canned versions of screens and widget populated
/// with specific data for testing and prototyping purposes.
class AFUserInterfaceScreenTests<TState> {
  
  List<AFUserInterfaceScreenTest> scenarios = List<AFUserInterfaceScreenTest>();

  /// Add a screen widget, and then in the [addInstances] callback add one or more 
  /// data states to render with that screen.
  void addScreen(AFBuildableWidget widget, Function(AFUserInterfaceScreenTest) addInstances) {
    AFUserInterfaceScreenTest scenario = AFUserInterfaceScreenTest(widget: widget);
    addInstances(scenario);
    scenarios.add(scenario);
  }

  AFUserInterfaceScreenTestFull findById(AFTestID id) {
    for(int s = 0; s < scenarios.length; s++) {
      final scenario = scenarios[s];
      for(int i = 0; i < scenario.instances.length; i++) {
        final instance = scenario.instances[i];
        if(instance.id == id) {
          return AFUserInterfaceScreenTestFull(scenario: scenario, data: instance);
        }
      }
    }
    return null;
  }
  
  List<AFUserInterfaceScreenTest> get all { return scenarios; }

}