import 'dart:async';

import 'package:afib/afib_dart.dart';
import 'package:afib/src/dart/redux/state/af_app_state.dart';
import 'package:afib/src/dart/redux/state/af_test_state.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/flutter/core/afui.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:afib/src/flutter/test/af_test_actions.dart';
import 'package:afib/src/flutter/utils/af_theme.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

//--------------------------------------------------------------------------------------
class AFTestDrawerData extends AFStoreConnectorData2<AFScreenTestContextSimulator, AFScreenTestState> {
  AFTestDrawerData(AFScreenTestContextSimulator testContext, AFScreenTestState testState): 
    super(first: testContext, second: testState);

  AFScreenTestContextSimulator get testContext { return first; }
  AFScreenTestState get testState { return second; }

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
    return AFTestDrawerData(testState.findContext(test.id), testState.findState(test.id));
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
      child: Text('Exit'),
      color: AFTheme.primaryBackground,
      textColor: AFTheme.primaryText,
      onPressed: () {
          Navigator.pop(context.c);
          context.dispatch(AFNavigatePopAction());
      }
    ));

    rowActions.add(FlatButton(
      child: Text('Reset'),
      color: AFTheme.primaryBackground,
      textColor: AFTheme.primaryText,
      onPressed: () {
          Navigator.pop(context.c);
          context.dispatch(AFUpdatePrototypeScreenTestDataAction(this.test.id, this.test.data));
      }
    ));

    if(test.hasBody) {
      rowActions.add(FlatButton(
        child: Text('Run Test'),
        color: AFTheme.primaryBackground,
        textColor: AFTheme.primaryText,
        onPressed: ()  {
          final scaffold = Scaffold.of(context.c);
          Navigator.pop(context.c);

          // give the drawer time to close, then 
          Timer(Duration(seconds: 1), () async {
            final prevContext = context.s.testContext;
            var runNumber = 1;
            if(prevContext != null && prevContext.runNumber != null) {
              runNumber = prevContext.runNumber + 1;
            }

            final testContext = AFScreenTestContextSimulator(context.d, test, runNumber);
            
            final screenUpdateCount = AFibF.testOnlyScreenUpdateCount(test.screen.runtimeType);
            context.dispatch(AFUpdatePrototypeScreenTestDataAction(this.test.id, this.test.data));
            context.dispatch(AFStartPrototypeScreenTestAction(testContext));
            await testContext.pauseForRender(screenUpdateCount, true);
            test.run(testContext, onEnd: () {
              scaffold.openEndDrawer();
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
      for(int i = 0; i < testState.errors.length; i++) {
        final error = testState.errors[i];
        final Color background = (i % 2 == 0) ? Colors.grey[300] : Colors.green[50];
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
