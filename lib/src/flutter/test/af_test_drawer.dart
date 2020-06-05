import 'dart:async';

import 'package:afib/afib_dart.dart';
import 'package:afib/src/dart/redux/state/af_app_state.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/flutter/core/afui.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:afib/src/flutter/test/af_test_actions.dart';
import 'package:afib/src/flutter/utils/af_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

//--------------------------------------------------------------------------------------
class AFTestDrawerData extends AFStoreConnectorData1<AFScreenTestContextSimulator> {
  AFTestDrawerData(AFScreenTestContextSimulator testContext): 
    super(first: testContext);

  AFScreenTestContextSimulator get testContext { return first; }

}

//--------------------------------------------------------------------------------------
class AFTestDrawer extends AFConnectedDrawer<AFAppState, AFTestDrawerData> {
  final AFScreenPrototypeTest test;
  final timeFormat = DateFormat('Hms');

  //--------------------------------------------------------------------------------------
  AFTestDrawer(this.test);

  //--------------------------------------------------------------------------------------
  @override
  AFTestDrawerData createDataAF(AFState state) {
    final testState = state.testState;
    return AFTestDrawerData(testState.findContext(test.id));
  }

  @override
  AFTestDrawerData createData(AFAppState state) {
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

  void _buildTitleRow(AFBuildContext<AFTestDrawerData, AFRouteParamUnused> context, List<Widget> col) {
    col.add(Container(
      margin: EdgeInsets.fromLTRB(8, 60, 8, 20),
      child: Center(child: Text(test.id.code + " test"))
    ));
  }

  void _buildControlRow(AFBuildContext<AFTestDrawerData, AFRouteParamUnused> context, List<Widget> col) {
    final rowActions = AFUI.row();

    rowActions.add(FlatButton(
      child: Text('Exit Screen'),
      color: AFTheme.primaryBackground,
      textColor: AFTheme.primaryText,
      onPressed: () {
          Navigator.pop(context.c);
          context.dispatch(AFNavigatePopInTestAction());
      }
    ));

    if(test.hasBody) {
      rowActions.add(FlatButton(
        child: Text('Run Test'),
        color: AFTheme.primaryBackground,
        textColor: AFTheme.primaryText,
        onPressed: () {
          Navigator.pop(context.c);

          // give the drawer time to close, then 
          Timer(Duration(seconds: 1), () {
            final prevContext = context.s.testContext;
            var runNumber = 1;
            if(prevContext != null && prevContext.runNumber != null) {
              runNumber = prevContext.runNumber + 1;
            }
            final testContext = AFScreenTestContextSimulator(test, runNumber);
            context.dispatch(AFAddTestContextAction(testContext));
            test.run(testContext);
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
    col.add(Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      child: _centerText("Test results")
    ));
    if(testContext == null) {
      col.add(_centerText("None"));
    } else {
      col.add(_centerText("Run ${testContext.runNumber} at ${timeFormat.format(testContext.lastRun)}"));
      col.add(_centerText(testContext.summaryText));
    }

  }

  Widget _centerText(String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [Text(text)]
    );
  }

}
