

import 'package:afib/afib_dart.dart';
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/redux/state/af_test_state.dart';
import 'package:afib/src/dart/utils/af_ui_id.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/test/af_prototype_dispatcher.dart';
import 'package:afib/src/flutter/test/af_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';

/// Parameter uses to filter the tests shown on the screen.
@immutable
class AFStatePrototypeScreenParam extends AFRouteParam {
  final AFID id;
  final AFRouteParam param;

  AFStatePrototypeScreenParam({this.id, this.param});

  AFStatePrototypeScreenParam copyWith() {
    return AFStatePrototypeScreenParam();
  }
}

/// Data used to render the screen
class AFStatePrototypeScreenData extends AFStoreConnectorData2<AFScreenTests, AFTestState> {
  AFStatePrototypeScreenData(AFScreenTests tests, AFTestState testState): 
    super(first: tests, second: testState);
  
  AFScreenTests get tests { return first; }
  AFTestState get testState { return second; }
}

/// A screen used internally in prototype mode to render screens and widgets with test data,
/// and display them in a list.
class AFScreenPrototypeScreen extends AFConnectedScreen<AFAppState, AFStatePrototypeScreenData, AFStatePrototypeScreenParam>{

  AFScreenPrototypeScreen(): super(AFUIID.screenPrototypeInstance);

  static AFNavigateAction navigatePush(AFScreenPrototypeTest instance, {AFID id}) {
    return AFNavigatePushAction(
      id: id,
      param: AFStatePrototypeScreenParam(id: instance.id, param: instance.param),
      screen: AFUIID.screenPrototypeInstance,
    );
  }

  @override
  AFStatePrototypeScreenData createDataAF(AFState state) {
    AFScreenTests tests = AF.screenTests;
    return AFStatePrototypeScreenData(tests, state.testState);
  }

  @override
  AFStatePrototypeScreenData createData(AFAppState state) {
    // this should never be called, because createDataAF supercedes it.
    throw UnimplementedError();
  }

  @override
  Widget buildWithContext(AFBuildContext<AFStatePrototypeScreenData, AFStatePrototypeScreenParam> context) {
    
    /// Remember what screen we are on for testing purposes.  Maybe eventually try to do this in navigator observer.
    AFTest.currentScreen = context.c;
    return _buildScreen(context);
  }


  Widget _buildScreen(AFBuildContext<AFStatePrototypeScreenData, AFStatePrototypeScreenParam> context) {
    AFScreenTests tests = context.s.tests;
    AFScreenPrototypeTest test = tests.findById(context.p.id);
    AFRouteParam paramChild = context.p.param ?? test.data.param;
    final testContext = context.s.testState.findContext(test.id);
    final dispatcher = AFPrototypeDispatcher(context.p.id, context.d, testContext);
    final childContext = test.widget.createContext(context.c, dispatcher, test.data, paramChild);
    childContext.enableTestContext(test);
    return test.widget.buildWithContext(childContext);
    
  }
}