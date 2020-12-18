

import 'package:afib/afib_dart.dart';
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/redux/state/af_test_state.dart';
import 'package:afib/src/dart/utils/af_ui_id.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/test/af_test_dispatchers.dart';
import 'package:afib/src/flutter/test/af_test.dart';
import 'package:afib/src/flutter/theme/af_prototype_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';

/// Parameter uses to filter the tests shown on the screen.
@immutable
class AFPrototypeSingleScreenRouteParam extends AFRouteParam {
  final AFTestID id;
  final AFRouteParam param;
  final dynamic data;

  AFPrototypeSingleScreenRouteParam({this.id, this.param, this.data});

  AFPrototypeSingleScreenRouteParam copyWith() {
    return AFPrototypeSingleScreenRouteParam();
  }

  @override
  bool matchesScreen(AFScreenID screenID) {
    final test = AFibF.g.screenTests.findById(id);
    if(test.screenId == screenID) {
      return true;
    }
    return false;     
  }

  AFScreenID get effectiveScreenId {
    final test = AFibF.g.screenTests.findById(id);
    return test.screenId;
  }

  @override
  AFRouteParam paramFor(AFScreenID screenID) {
    final test = AFibF.g.screenTests.findById(id);
    if(test.screenId == screenID) {
      return param;
    }
    return this;
  }
}

/// Data used to render the screen
class AFPrototypeSingleScreenData extends AFStoreConnectorData3<AFSingleScreenTests, AFTestState, AFThemeState> {
  AFPrototypeSingleScreenData(AFSingleScreenTests tests, AFTestState testState, AFThemeState themeState): 
    super(first: tests, second: testState, third: themeState);
  
  AFSingleScreenTests get tests { return first; }
  AFTestState get testState { return second; }
  AFThemeState get themeState { return third; }
}

/// A screen used internally in prototype mode to render screens and widgets with test data,
/// and display them in a list.
class AFPrototypeSingleScreenScreen extends AFConnectedScreen<AFAppStateArea, AFPrototypeSingleScreenData, AFPrototypeSingleScreenRouteParam, AFPrototypeTheme>{

  AFPrototypeSingleScreenScreen(): super(AFUIID.screenPrototypeSingleScreen);

  static AFNavigateAction navigatePush(AFSingleScreenPrototypeTest instance, {AFID id}) {
    return AFNavigatePushAction(
      id: id,
      param: AFPrototypeSingleScreenRouteParam(id: instance.id, param: instance.param),
      screen: AFUIID.screenPrototypeSingleScreen,
    );
  }

  @override
  AFPrototypeSingleScreenData createStateDataAF(AFState state) {
    final tests = AFibF.g.screenTests;
    return AFPrototypeSingleScreenData(tests, state.testState, state.public.themes);
  }

  @override
  AFPrototypeSingleScreenData createStateData(AFAppStateArea state) {
    // this should never be called, because createDataAF supercedes it.
    throw UnimplementedError();
  }

  @override
  Widget buildWithContext(AFBuildContext<AFPrototypeSingleScreenData, AFPrototypeSingleScreenRouteParam, AFPrototypeTheme> context) {
    
    /// Remember what screen we are on for testing purposes.  Maybe eventually try to do this in navigator observer.
    AFTest.currentScreen = context.c;
    return _buildScreen(context);
  }


  Widget _buildScreen(AFBuildContext<AFPrototypeSingleScreenData, AFPrototypeSingleScreenRouteParam, AFPrototypeTheme> context) {
    final tests = context.s.tests;
    final test = tests.findById(context.p.id);
    AFRouteParam paramChild = context.p.param ?? test.data.param;
    final testContext = context.s.testState.findContext(test.id);
    final testState = context.s.testState.findState(test.id);
    final testData = testState?.data ?? test.data;
    final dispatcher = AFSingleScreenTestDispatcher(context.p.id, context.d, testContext);
    final screenMap = AFibF.g.screenMap;
    final AFConnectedWidgetBase screen = screenMap.createFor(test.screenId);
    final themeChild = screen.findTheme(context.s.themeState);

    final childContext = screen.createContext(context.c, dispatcher, testData, paramChild, themeChild);
    return screen.buildWithContext(childContext);
    
  }
}