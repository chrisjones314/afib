

import 'package:afib/afib_dart.dart';
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/redux/state/af_test_state.dart';
import 'package:afib/src/dart/utils/af_ui_id.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/test/af_test_dispatchers.dart';
import 'package:afib/src/flutter/test/af_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';

/// Parameter uses to filter the tests shown on the screen.
@immutable
class AFScreenPrototypeScreenParam extends AFRouteParam {
  final AFID id;
  final AFRouteParam param;
  final dynamic data;

  AFScreenPrototypeScreenParam({this.id, this.param, this.data});

  AFScreenPrototypeScreenParam copyWith() {
    return AFScreenPrototypeScreenParam();
  }

  @override
  bool matchesScreen(AFScreenID screenID) {
    AFSimpleScreenPrototypeTest test = AFibF.screenTests.findById(id);
    if(test.screen?.screen == screenID) {
      return true;
    }
    return false;     
  }

  Type get effectiveScreenRuntimeType {
    AFSimpleScreenPrototypeTest test = AFibF.screenTests.findById(id);
    return test.screen?.runtimeType;
  }

  @override
  AFRouteParam paramFor(AFScreenID screenID) {
    AFSimpleScreenPrototypeTest test = AFibF.screenTests.findById(id);
    if(test.screen?.screen == screenID) {
      return param;
    }
    return this;
  }
}

/// Data used to render the screen
class AFScreenPrototypeScreenData extends AFStoreConnectorData2<AFScreenTests, AFTestState> {
  AFScreenPrototypeScreenData(AFScreenTests tests, AFTestState testState): 
    super(first: tests, second: testState);
  
  AFScreenTests get tests { return first; }
  AFTestState get testState { return second; }
}

/// A screen used internally in prototype mode to render screens and widgets with test data,
/// and display them in a list.
class AFScreenPrototypeScreen extends AFConnectedScreen<AFAppState, AFScreenPrototypeScreenData, AFScreenPrototypeScreenParam>{

  AFScreenPrototypeScreen(): super(AFUIID.screenPrototypeSimple);

  static AFNavigateAction navigatePush(AFSimpleScreenPrototypeTest instance, {AFID id}) {
    return AFNavigatePushAction(
      id: id,
      param: AFScreenPrototypeScreenParam(id: instance.id, param: instance.param),
      screen: AFUIID.screenPrototypeSimple,
    );
  }

  @override
  AFScreenPrototypeScreenData createDataAF(AFState state) {
    AFScreenTests tests = AFibF.screenTests;
    return AFScreenPrototypeScreenData(tests, state.testState);
  }

  @override
  AFScreenPrototypeScreenData createData(AFAppState state) {
    // this should never be called, because createDataAF supercedes it.
    throw UnimplementedError();
  }

  @override
  Widget buildWithContext(AFBuildContext<AFScreenPrototypeScreenData, AFScreenPrototypeScreenParam> context) {
    
    /// Remember what screen we are on for testing purposes.  Maybe eventually try to do this in navigator observer.
    AFTest.currentScreen = context.c;
    return _buildScreen(context);
  }


  Widget _buildScreen(AFBuildContext<AFScreenPrototypeScreenData, AFScreenPrototypeScreenParam> context) {
    AFScreenTests tests = context.s.tests;
    AFSimpleScreenPrototypeTest test = tests.findById(context.p.id);
    AFRouteParam paramChild = context.p.param ?? test.data.param;
    final testContext = context.s.testState.findContext(test.id);
    final testState = context.s.testState.findState(test.id);
    final testData = testState?.data ?? test.data;
    final dispatcher = AFSimpleScreenTestDispatcher(context.p.id, context.d, testContext);
    final childContext = test.screen.createContext(context.c, dispatcher, testData, paramChild);
    childContext.enableTestContext(test);
    return test.screen.buildWithContext(childContext);
    
  }
}