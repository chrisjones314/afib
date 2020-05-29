

import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';


abstract class AFScreenTestContext {
  AFScreenTest test;
  AFScreenTestData instance;
  AFScreenTestContext(this.test, this.instance);

  void expectWidgetExists(AFWidgetID wid);
}

class AFScreenTestContextWidgetTester extends AFScreenTestContext {
  WidgetTester tester;

  AFScreenTestContextWidgetTester(WidgetTester this.tester, AFScreenTest test, AFScreenTestData instance): super(test, instance);
  
  void expectWidgetExists(AFWidgetID wid) {
    final widFinder = find.byKey(Key(wid.code));
    expect(widFinder, findsOneWidget);
  }
}

typedef void AFScreenTestImplementation(AFScreenTestContext context);

/// The data, title, and id associated with a particular widget scenario.
class AFScreenTestData {
  AFID id;
  dynamic data;
  dynamic param;
  AFScreenTestImplementation body;
  

  AFScreenTestData({
    @required this.id,
    @required this.data,
    @required this.param,
    @required this.body
  });
}

/// A single widget that can be populated with multiple different data scenarios.
class AFScreenTest {
  AFBuildableWidget widget;
  List<AFScreenTestData> tests = List<AFScreenTestData>();

  AFScreenTest({
    @required this.widget,
  });

  /// Add an instance to a scenario.
  void addTest({
    @required AFTestID   id,
    @required dynamic data,
    @required dynamic param,
    @required AFScreenTestImplementation body
  }) {
    AFScreenTestData instance = AFScreenTestData(
      id: id,
      data: data,
      param: param,
      body: body
    );
    tests.add(instance);
  }
}

class AFScreenTestFull {
  final AFScreenTest scenario;
  final AFRouteParam param;
  final AFScreenTestData data;

  AFScreenTestFull({this.scenario, this.param, this.data});
}

/// This class is used to create canned versions of screens and widget populated
/// with specific data for testing and prototyping purposes.
class AFScreenTests<TState> {
  
  List<AFScreenTest> screens = List<AFScreenTest>();

  /// Add a screen widget, and then in the [addInstances] callback add one or more 
  /// data states to render with that screen.
  void addScreen(AFBuildableWidget widget, Function(AFScreenTest) addInstances) {
    AFScreenTest scenario = AFScreenTest(widget: widget);
    addInstances(scenario);
    screens.add(scenario);
  }

  AFScreenTestFull findById(AFTestID id) {
    for(int s = 0; s < screens.length; s++) {
      final scenario = screens[s];
      for(int i = 0; i < scenario.tests.length; i++) {
        final instance = scenario.tests[i];
        if(instance.id == id) {
          return AFScreenTestFull(scenario: scenario, data: instance);
        }
      }
    }
    return null;
  }
  
  List<AFScreenTest> get all { return screens; }

}