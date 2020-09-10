

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
class AFPrototypeSingleScreenRouteParam extends AFRouteParam {
  final AFID id;
  final AFRouteParam param;
  final dynamic data;

  AFPrototypeSingleScreenRouteParam({this.id, this.param, this.data});

  AFPrototypeSingleScreenRouteParam copyWith() {
    return AFPrototypeSingleScreenRouteParam();
  }

  @override
  bool matchesScreen(AFScreenID screenID) {
    AFSingleScreenPrototypeTest test = AFibF.screenTests.findById(id);
    if(test.screenId == screenID) {
      return true;
    }
    return false;     
  }

  AFScreenID get effectiveScreenId {
    AFSingleScreenPrototypeTest test = AFibF.screenTests.findById(id);
    return test.screenId;
  }

  @override
  AFRouteParam paramFor(AFScreenID screenID) {
    AFSingleScreenPrototypeTest test = AFibF.screenTests.findById(id);
    if(test.screenId == screenID) {
      return param;
    }
    return this;
  }
}

/// Data used to render the screen
class AFPrototypeSingleScreenData extends AFStoreConnectorData2<AFSingleScreenTests, AFTestState> {
  AFPrototypeSingleScreenData(AFSingleScreenTests tests, AFTestState testState): 
    super(first: tests, second: testState);
  
  AFSingleScreenTests get tests { return first; }
  AFTestState get testState { return second; }
}

/// A screen used internally in prototype mode to render screens and widgets with test data,
/// and display them in a list.
class AFPrototypeSingleScreenScreen extends AFConnectedScreen<AFAppState, AFPrototypeSingleScreenData, AFPrototypeSingleScreenRouteParam>{

  AFPrototypeSingleScreenScreen(): super(AFUIID.screenPrototypeSingleScreen);

  static AFNavigateAction navigatePush(AFSingleScreenPrototypeTest instance, {AFID id}) {
    return AFNavigatePushAction(
      id: id,
      param: AFPrototypeSingleScreenRouteParam(id: instance.id, param: instance.param),
      screen: AFUIID.screenPrototypeSingleScreen,
    );
  }

  @override
  AFPrototypeSingleScreenData createDataAF(AFState state) {
    AFSingleScreenTests tests = AFibF.screenTests;
    return AFPrototypeSingleScreenData(tests, state.testState);
  }

  @override
  AFPrototypeSingleScreenData createData(AFAppState state) {
    // this should never be called, because createDataAF supercedes it.
    throw UnimplementedError();
  }

  @override
  Widget buildWithContext(AFBuildContext<AFPrototypeSingleScreenData, AFPrototypeSingleScreenRouteParam> context) {
    
    /// Remember what screen we are on for testing purposes.  Maybe eventually try to do this in navigator observer.
    AFTest.currentScreen = context.c;
    return _buildScreen(context);
  }


  Widget _buildScreen(AFBuildContext<AFPrototypeSingleScreenData, AFPrototypeSingleScreenRouteParam> context) {
    AFSingleScreenTests tests = context.s.tests;
    AFSingleScreenPrototypeTest test = tests.findById(context.p.id);
    AFRouteParam paramChild = context.p.param ?? test.data.param;
    final testContext = context.s.testState.findContext(test.id);
    final testState = context.s.testState.findState(test.id);
    final testData = testState?.data ?? test.data;
    final dispatcher = AFSingleScreenTestDispatcher(context.p.id, context.d, testContext);
    final screenMap = AFibF.screenMap;
    final AFConnectedScreenWithoutRoute screen = screenMap.createFor(test.screenId);
    final childContext = screen.createContext(context.c, dispatcher, testData, paramChild);
    return screen.buildWithContext(childContext);
    
  }
}