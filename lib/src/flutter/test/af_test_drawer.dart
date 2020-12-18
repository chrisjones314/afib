
import 'dart:async';

import 'package:afib/afib_dart.dart';
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/redux/state/af_app_state.dart';
import 'package:afib/src/dart/redux/state/af_test_state.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/dart/utils/af_ui_id.dart';
import 'package:afib/src/flutter/core/afui.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:afib/src/flutter/theme/af_prototype_theme.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

//--------------------------------------------------------------------------------------
class AFTestDrawerRouteParam extends AFRouteParam {
  static const viewTheme = 1;
  static const viewTest  = 2;
  static const viewReuse = 3;
  final int view;

  AFTestDrawerRouteParam({this.view});

  AFTestDrawerRouteParam copyWith({
    int view
  }) {
    return AFTestDrawerRouteParam(
      view: view ?? this.view
    );
  }
}

//--------------------------------------------------------------------------------------
class AFTestDrawerData extends AFStoreConnectorData3<AFScreenTestContextSimulator, AFSingleScreenTestState, AFScreenPrototypeTest> {
  AFTestDrawerData(AFScreenTestContextSimulator testContext, AFSingleScreenTestState testState, AFScreenPrototypeTest test): 
    super(first: testContext, second: testState, third: test);

  AFScreenTestContextSimulator get testContext { return first; }
  AFSingleScreenTestState get testState { return second; }
  AFScreenPrototypeTest get test { return third; }

}

//--------------------------------------------------------------------------------------
class AFTestDrawer extends AFConnectedDrawer<AFAppStateArea, AFTestDrawerData, AFTestDrawerRouteParam, AFPrototypeTheme> {
  static final timeFormat = DateFormat('Hms');
  static const columnWidthsForNumValueTable = {
      0: FixedColumnWidth(20.0),
      1: FlexColumnWidth(),
    };

  //--------------------------------------------------------------------------------------
  AFTestDrawer(): super(AFUIID.screenTestDrawer);

  //--------------------------------------------------------------------------------------
  AFScreenID get screenIdForTest {
    return null;
  }

  //--------------------------------------------------------------------------------------
  @override
  AFTestDrawerData createStateDataAF(AFState state) {
    final testState = state.testState;
    final test = AFibF.g.findScreenTestById(testState.activeTestId);
    return AFTestDrawerData(testState.findContext(test.id), testState.findState(test.id), test);
  }

  //--------------------------------------------------------------------------------------
  AFTestDrawerRouteParam createRouteParam(AFState state) {
    return AFTestDrawerRouteParam(view: AFTestDrawerRouteParam.viewTest);
  }


  //--------------------------------------------------------------------------------------
  @override
  AFTestDrawerData createStateData(AFAppStateArea state) {
    // this should never be called, because createDataAF replaces it.
    throw UnimplementedError();
  }

  //--------------------------------------------------------------------------------------
  @override
  Widget buildWithContext(AFBuildContext<AFTestDrawerData, AFTestDrawerRouteParam, AFPrototypeTheme> context) {
    return _buildDrawer(context);
  }

  //--------------------------------------------------------------------------------------
  Widget _buildDrawer(AFBuildContext<AFTestDrawerData, AFTestDrawerRouteParam, AFPrototypeTheme> context) {
    final rows = AFUI.column();
    
    rows.add(_buildHeader(context));
    rows.add(_buildChoiceRow(context));
    rows.add(_buildContent(context));

    return Drawer(      
        child: Column(
          children: rows,
        )
    );
  }

  //--------------------------------------------------------------------------------------
  Widget _buildHeader(AFBuildContext<AFTestDrawerData, AFTestDrawerRouteParam, AFPrototypeTheme> context) {
    final t = context.t;
    final rows = t.column();
    final test = context.s.test;

    rows.add(Container(
      margin: t.marginScaled(left: 0),
      child: t.text(
        "AFib Test Drawer",
        style: t.textOnPrimary.headline2
      )
    ));

    rows.add(Container(
      margin: t.marginScaled(left: 0),
      child: t.text(
          context.s.test.id.toString(), 
          style: t.textOnPrimary.headline6
      )
    ));

    final cols = t.row();
    cols.add(FlatButton(
      child: t.text('Exit'),
      color: t.colorOnPrimary,
      textColor: t.colorSecondary,
      onPressed: () {
          Navigator.pop(context.c);
          context.dispatch(AFNavigateExitTestAction());
      }
    ));

    cols.add(
      Container(
        margin: t.marginScaled(all: 0, left: 1),
        child: FlatButton(
        child: Text('Reset'),
        color: t.colorOnPrimary,
        textColor: t.colorSecondary,
        onPressed: () {
            Navigator.pop(context.c);
            test.onDrawerReset(context.d);
        }
      )
    ));

    rows.add(Row(children: cols));


    return DrawerHeader(
      decoration: BoxDecoration(
        color: t.colorSecondary
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: rows
      ),
    );
  }

  Widget _buildChoiceButton(AFBuildContext<AFTestDrawerData, AFTestDrawerRouteParam, AFPrototypeTheme> context,
    String title,
    int view
  ) {
    final t = context.t;
    final isActive = view == context.p.view;
    final color = isActive ? t.colorSecondary : Colors.grey[400];
    final colorText = isActive ? t.colorOnPrimary : t.colorOnBackground;

    return FlatButton(
      child: t.text(title),
      color: color,
      textColor: colorText,
      shape: RoundedRectangleBorder(),
      onPressed: () {
        updateParam(context, context.p.copyWith(view: view));
      },
    );
  }

  //--------------------------------------------------------------------------------------
  Widget _buildChoiceRow(AFBuildContext<AFTestDrawerData, AFTestDrawerRouteParam, AFPrototypeTheme> context) {
    final t = context.t;

    final cols = t.row();

    cols.add(_buildChoiceButton(context, "Theme", AFTestDrawerRouteParam.viewTheme));
    cols.add(_buildChoiceButton(context, "Test", AFTestDrawerRouteParam.viewTest));
    cols.add(_buildChoiceButton(context, "Reuse", AFTestDrawerRouteParam.viewReuse));

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: cols);
  }

  Widget _buildContent(AFBuildContext<AFTestDrawerData, AFTestDrawerRouteParam, AFPrototypeTheme> context) {
    var item;
    final view = context.p.view;
    if(view == AFTestDrawerRouteParam.viewTheme) {
      item = _buildThemeContent(context);
    } else if(view == AFTestDrawerRouteParam.viewTest) {
      item = _buildTestContent(context);
    } else if(view == AFTestDrawerRouteParam.viewReuse) {
      item = _buildReuseContent(context);
    }

    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [item]
      );
  }

  Widget _buildThemeContent(AFBuildContext<AFTestDrawerData, AFTestDrawerRouteParam, AFPrototypeTheme> context) {
    final content = context.t.testExplanationText("TODO: Theme");
    return _areaContentCard(context, content);
  }

  void _onRun(AFBuildContext<AFTestDrawerData, AFTestDrawerRouteParam, AFPrototypeTheme> context, AFReusableTestID id) {
    final test = context.s.test;
    Navigator.pop(context.c);
    Timer(Duration(seconds: 1), () async {            
      await test.onDrawerRun(context.d, context.s.testContext, context.s.testState, id, () {
        test.openTestDrawer(id);
      });
    });    
  }

  Widget _buildRunButton(AFBuildContext<AFTestDrawerData, AFTestDrawerRouteParam, AFPrototypeTheme> context) {
    final t = context.t;
    final test = context.s.test;
    final sectionIds = test.sectionIds;

    final cols = t.row();

    final hasMultiple = sectionIds.length > 1;
    final firstId = sectionIds.first;
    var defaultRunId = firstId;
    var rowAlign = MainAxisAlignment.start;
    if(hasMultiple) {
      defaultRunId = AFReusableTestID.allTestId;
      rowAlign = MainAxisAlignment.spaceBetween;
    }

    cols.add(t.text('Run $defaultRunId'));

    if(hasMultiple) {
      cols.add(PopupMenuButton<AFReusableTestID>(
        onSelected: (id) { 
          _onRun(context, id);
        },
        itemBuilder: (context) {
          final result = <PopupMenuEntry<AFReusableTestID>>[];
          for(final id in sectionIds) {
            result.add(PopupMenuItem<AFReusableTestID>(
              value: id,
              child: t.text(id.toString())
            ));
          }

          return result;
        }
      ));
    }

    final buttonContent = Row(
      mainAxisAlignment: rowAlign,
      children: cols,
    );

    return FlatButton(
      child: buttonContent,
      color: t.colorSecondary,
      textColor: t.colorOnPrimary,
      onPressed: ()  {
        _onRun(context, defaultRunId);
      }
    );


    
      
    
  }

  Widget _buildTestContent(AFBuildContext<AFTestDrawerData, AFTestDrawerRouteParam, AFPrototypeTheme> context) {
    final t = context.t;
    var content;
    if(context.s.test.hasBody) {
      final rows = t.column();
      rows.add(_buildRunButton(context));
      _buildTestReport(context, rows);
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: rows
      );
    } else {
      content = t.testExplanationText("This test does not have a test body.  To add one, see definitions.addSmokeTest or definitions.addReusableTest1...");
    }

    return _areaContentCard(context, content);
  }

  Widget _areaContentCard(AFBuildContext<AFTestDrawerData, AFTestDrawerRouteParam, AFPrototypeTheme> context, Widget child) {
    return Card(child: Container(
      margin: context.t.marginScaled(),
      child: child
    ));
  }

  Widget _buildReuseContent(AFBuildContext<AFTestDrawerData, AFTestDrawerRouteParam, AFPrototypeTheme> context) {
    final t = context.t;
    final test = context.s.test;
    var content;
    if(test.hasReusable) {

      for(final reusableId in test.sectionIds) {
        final rows = t.column();
        if(reusableId == AFReusableTestID.smokeTestId) {
          continue;
        }

        if(reusableId != null) {
          rows.add(Container(
            margin: t.marginScaled(bottom: 2, all: 0),
            child: t.text('Reusable: ${reusableId.toString()}', textAlign: TextAlign.left)
          ));
        }
        final params = test.paramDescriptions(reusableId);

        final tableRows = t.tableColumn();
        final headerCols = t.row();
        headerCols.add(_testResultTableHeader(context, "#", TextAlign.left));
        headerCols.add(_testResultTableHeader(context, "Param Description", TextAlign.left));
        tableRows.add(TableRow(children: headerCols));
        
        for(var i = 0; i < params.length; i++) {
          final param = params[i];
          final resultCols = t.row();
          resultCols.add(_testResultTableValue(context, (i+1).toString(), TextAlign.right));
          resultCols.add(_testResultTableValue(context, param, TextAlign.left));
          tableRows.add(TableRow(children: resultCols));
        }

        rows.add(Table(children: tableRows, columnWidths: columnWidthsForNumValueTable));
        content = Container(
          margin: t.marginScaled(horizontal: 0, top: 1),
          child: Column(
            children: rows
          )
        );
      }
    } else {
      content = t.testExplanationText("This test has no reusable sections.  To add on, see definitions.defineReusable1...");
    }
    return _areaContentCard(context, content);
  }

  void _buildTestReport(AFBuildContext<AFTestDrawerData, AFTestDrawerRouteParam, AFPrototypeTheme> context, List<Widget> rows) {
    final t = context.t;
    final testContext = context.s.testContext;
    final testState = context.s.testState;
    
    if(testContext == null) {
      return;
    }

    if(testState.errors.isNotEmpty) {
      final headerColsErrors = t.row();
      headerColsErrors.add(_testResultTableValue(context, "#", TextAlign.left, showError: true));
      headerColsErrors.add(_testResultTableValue(context, "Error", TextAlign.left, showError: true));
      
      final tableRowsErrors = t.tableColumn();
      tableRowsErrors.add(TableRow(children: headerColsErrors));

      for(var i = 0; i < testState.errors.length; i++) {
        final error = _stripErrorPath(testState.errors[i]);
        final errorCols = t.row();
        errorCols.add(_testResultTableErrorLine(context, t.text((i+1).toString()), i));
        errorCols.add(_testResultTableErrorLine(context, t.text(error), i));
        tableRowsErrors.add(TableRow(children: errorCols));
      }

      final columnWidths = columnWidthsForNumValueTable;
      rows.add(Container(
        margin: t.marginScaled(horizontal: 0, top: 1),
        child: Table(children: tableRowsErrors, columnWidths: columnWidths)
      ));
    }

    final headerCols = t.row();
    headerCols.add(_testResultTableHeader(context, "Run", TextAlign.right));
    headerCols.add(_testResultTableHeader(context, "At", TextAlign.left));
    headerCols.add(_testResultTableHeader(context, "Pass", TextAlign.right));
    headerCols.add(_testResultTableHeader(context, "Fail", TextAlign.right));

    final resultCols = t.row();
    resultCols.add(_testResultTableValue(context, testContext.runNumber.toString(), TextAlign.right));
    resultCols.add(_testResultTableValue(context, timeFormat.format(testContext.lastRun), TextAlign.left));
    resultCols.add(_testResultTableValue(context, testState.pass.toString(), TextAlign.right));
    resultCols.add(_testResultTableValue(context, testState.errors.length.toString(), TextAlign.right, showError: (testState.errors.isNotEmpty)));
    
    final tableRows = t.tableColumn();
    tableRows.add(TableRow(children: headerCols));
    tableRows.add(TableRow(children: resultCols));

    const columnWidths = {
      0: FixedColumnWidth(50.0),
      1: FlexColumnWidth(),
      2: FixedColumnWidth(50.0),
      3: FixedColumnWidth(50.0),
    };

    rows.add(Container(
      margin: t.marginScaled(horizontal: 0, top: 2),
      child: Table(children: tableRows, columnWidths: columnWidths)
    ));
  }

  Widget _testResultTableHeader(AFBuildContext<AFTestDrawerData, AFTestDrawerRouteParam, AFPrototypeTheme> context, String text, TextAlign textAlign) {
    final t = context.t;
    return Container(
      padding: t.paddingScaled(),
      color: t.colorPrimary,
      child: t.text(text, textColor: t.colorOnPrimary, textAlign: textAlign)
    );
  }

  Widget _testResultTableErrorLine(AFBuildContext<AFTestDrawerData, AFTestDrawerRouteParam, AFPrototypeTheme> context, Widget text, int row) {
    final color = (row % 2 == 0) ? Colors.white : Colors.grey[350];
    return Container(
      padding: context.t.paddingScaled(all: 0.5),
      color: color,
      child: text
    );
  }

  Widget _testResultTableValue(AFBuildContext<AFTestDrawerData, AFTestDrawerRouteParam, AFPrototypeTheme> context, String text, TextAlign textAlign, {
    bool showError = false
  }) {
    final t = context.t;
    var color;
    var colorText;
    if(showError) {
      color = t.colorError;
      colorText = t.colorOnError;
    }
    return Container(
      color: color,
      padding: t.paddingScaled(),
      child: t.text(text, textColor: colorText, textAlign: textAlign)
    );
  }

  String _stripErrorPath(String err) {
    final idx = err.lastIndexOf('/');
    if(idx < 0) {
      return err;
    }
    return err.substring(idx+1);
  }

}
