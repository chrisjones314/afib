import 'dart:async';

import 'package:afib/afib_dart.dart';
import 'package:afib/src/dart/redux/state/af_app_state.dart';
import 'package:afib/src/dart/redux/state/af_test_state.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/dart/utils/af_ui_id.dart';
import 'package:afib/src/flutter/core/afui.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:afib/src/flutter/utils/af_theme.dart';
import 'package:afib/src/flutter/utils/af_typedefs_flutter.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

//--------------------------------------------------------------------------------------
class AFTestDrawerData extends AFStoreConnectorData3<AFScreenTestContextSimulator, AFSingleScreenTestState, AFScreenPrototypeTest> {
  AFTestDrawerData(AFScreenTestContextSimulator testContext, AFSingleScreenTestState testState, AFScreenPrototypeTest test): 
    super(first: testContext, second: testState, third: test);

  AFScreenTestContextSimulator get testContext { return first; }
  AFSingleScreenTestState get testState { return second; }
  AFScreenPrototypeTest get test { return third; }

}

//--------------------------------------------------------------------------------------
class AFTestDrawer extends AFConnectedDrawer<AFAppState, AFTestDrawerData, AFRouteParamUnused> {
  final timeFormat = DateFormat('Hms');

  //--------------------------------------------------------------------------------------
  AFTestDrawer({
    AFDispatcher dispatcher,
    AFUpdateParamDelegate<AFRouteParamUnused> updateParamDelegate,
    AFExtractParamDelegate extractParamDelegate,
    AFCreateDataDelegate createDataDelegate,
    AFFindParamDelegate findParamDelegate,
  }): super(
    screenId: AFUIID.screenTestDrawer,
    dispatcher: dispatcher,
    updateParamDelegate: updateParamDelegate,
    extractParamDelegate: extractParamDelegate,
    createDataDelegate: createDataDelegate,
    findParamDelegate: findParamDelegate
  );

  AFScreenID get screenIdForTest {
    return null;
  }

  //--------------------------------------------------------------------------------------
  @override
  AFTestDrawerData createStateDataAF(AFState state) {
    final testState = state.testState;
    final test = AFibF.findScreenTestById(testState.activeTestId);
    return AFTestDrawerData(testState.findContext(test.id), testState.findState(test.id), test);
  }

  @override
  AFTestDrawerData createStateData(AFAppState state) {
    // this should never be called, because createDataAF replaces it.
    throw UnimplementedError();
  }

  //--------------------------------------------------------------------------------------
  @override
  Widget buildWithContext(AFBuildContext<AFTestDrawerData, AFRouteParamUnused> context) {
    return _buildDrawer(context);
  }

  //--------------------------------------------------------------------------------------
  Widget _buildDrawer(AFBuildContext<AFTestDrawerData, AFRouteParamUnused> context) {
    final col = AFUI.column();
    
    _buildTitleRow(context, col);
    _buildControlRow(context, col);
    _buildTestReport(context, col);

    return Drawer(      
      child: ListView(
        padding: EdgeInsets.zero,
        children: col,
    ));
  }

  //--------------------------------------------------------------------------------------
  void _buildTitleRow(AFBuildContext<AFTestDrawerData, AFRouteParamUnused> context, List<Widget> col) {
    col.add(Container(
      margin: EdgeInsets.fromLTRB(8, 60, 8, 20),
      child: Center(child: Text("${context.s.test.id.code} test"))
    ));
  }

  //--------------------------------------------------------------------------------------
  void _buildControlRow(AFBuildContext<AFTestDrawerData, AFRouteParamUnused> context, List<Widget> col) {
    final rowActions = AFUI.row();
    final test = context.s.test;

    rowActions.add(FlatButton(
      child: Text('Exit'),
      color: AFTheme.colorPrimary,
      textColor: AFTheme.colorWhite,
      onPressed: () {
          Navigator.pop(context.c);
          context.dispatch(AFNavigateExitTestAction());
      }
    ));

    rowActions.add(FlatButton(
      child: Text('Reset'),
      color: AFTheme.colorPrimary,
      textColor: AFTheme.colorWhite,
      onPressed: () {
          Navigator.pop(context.c);
          test.onDrawerReset(context.d);
      }
    ));

    if(test.hasBody) {
      rowActions.add(FlatButton(
        child: Text('Run Test'),
        color: AFTheme.colorPrimary,
        textColor: AFTheme.colorWhite,
        onPressed: ()  {
          Navigator.pop(context.c);

          // give the drawer time to close, then 
          Timer(Duration(seconds: 1), () async {            
            test.onDrawerRun(context.d, context.s.testContext, context.s.testState, () {
              test.openTestDrawer();
            });
          });
        },
      ));
    }

    col.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: rowActions
    ));
  }

  void _buildTestReport(AFBuildContext<AFTestDrawerData, AFRouteParamUnused> context, List<Widget> col) {
    final testContext = context.s.testContext;
    final testState = context.s.testState;
    col.add(Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      child: _centerText("Test results")
  ));
    if(testContext == null) {
      col.add(_centerText("None"));
    } else {
      col.add(_centerText("Run ${testContext.runNumber} at ${timeFormat.format(testContext.lastRun)}"));
      col.add(_centerText(testState.summaryText));
      for(var i = 0; i < testState.errors.length; i++) {
        final error = testState.errors[i];
        final background = (i % 2 == 0) ? Colors.grey[300] : Colors.green[50];
        col.add(
          Container(
            padding: EdgeInsets.all(8.0),
            color: background,
            child: Text(error)
        ));
      }
    }

  }

  Widget _centerText(String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [Text(text)]
    );
  }

}
