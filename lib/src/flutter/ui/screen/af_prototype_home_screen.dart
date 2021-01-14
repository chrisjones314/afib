

import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/redux/state/af_test_state.dart';
import 'package:afib/src/dart/utils/af_ui_id.dart';
import 'package:afib/src/flutter/ui/af_prototype_base.dart';
import 'package:afib/src/flutter/ui/screen/af_prototype_third_party_list_screen.dart';
import 'package:afib/src/flutter/utils/af_state_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';

class AFScreenTestResultSummary {
  final AFScreenTestContext context;
  final AFSingleScreenTestState state;

  AFScreenTestResultSummary({
    this.context,
    this.state,
  });
}


/// Parameter uses to filter the tests/protoypes shown on the screen.
@immutable
class AFPrototypeHomeScreenParam extends AFRouteParam {
  static const filterTextId = 1;
  static const viewFilter = 1;
  static const viewResults = 2;
  final String filter;
  final AFTextEditingControllersHolder textControllers;
  final List<AFScreenTestResultSummary> results;
  final int view;

  AFPrototypeHomeScreenParam({
    @required this.filter,
    @required this.textControllers,
    @required this.results,
    @required this.view,
  });

  AFPrototypeHomeScreenParam reviseFilter(String filter) {
    return copyWith(filter: filter);
  }

  factory AFPrototypeHomeScreenParam.createOncePerScreen({
    @required String filter,
  }) {

    return AFPrototypeHomeScreenParam(
      filter: filter,
      view: viewFilter,
      results: <AFScreenTestResultSummary>[],
      textControllers: AFTextEditingControllersHolder()
    );
  }

  AFPrototypeHomeScreenParam copyWith({
    String filter,
    List<AFScreenTestResultSummary> results,
    int view
  }) {
    return AFPrototypeHomeScreenParam(
      filter: filter ?? this.filter,
      results: results ?? this.results,
      view: view ?? this.view,
      textControllers: this.textControllers
    );
  }

  @override
  void dispose() {
    textControllers.dispose();    
  }
}

/// Data used to render the screen
class APrototypeHomeScreenStateView extends AFStateView1<AFSingleScreenTests> {
  APrototypeHomeScreenStateView(AFSingleScreenTests tests): 
    super(first: tests);
  
  AFSingleScreenTests get tests { return first; }
}

/// A screen used internally in prototype mode to render screens and widgets with test data,
/// and display them in a list.
class AFPrototypeHomeScreen extends AFProtoConnectedScreen<APrototypeHomeScreenStateView, AFPrototypeHomeScreenParam>{
  static const runWidgetTestsId = "run_widget_tests";
  static const runScreenTestsId = "run_screen_tests";
  static const runWorkflowTestsId = "run_workflow_tests";
  AFPrototypeHomeScreen(): super(AFUIScreenID.screenPrototypeHome);

  @override
  APrototypeHomeScreenStateView createStateViewAF(AFState state, AFPrototypeHomeScreenParam param, AFRouteParamWithChildren withChildren) {
    final tests = AFibF.g.screenTests;
    return APrototypeHomeScreenStateView(tests);
  }

  @override
  APrototypeHomeScreenStateView createStateView(AFAppStateArea state, AFPrototypeHomeScreenParam param) {
    // this should never be called, because createDataAF replaces it.
    throw UnimplementedError();
  }

  @override
  Widget buildWithContext(AFProtoBuildContext<APrototypeHomeScreenStateView, AFPrototypeHomeScreenParam> context) {
    return _buildHome(context);
  }

  /// 
  Widget _buildHome(AFProtoBuildContext<APrototypeHomeScreenStateView, AFPrototypeHomeScreenParam> context) {
    final t = context.t;
    final protoRows = t.column();
    final primaryTests = AFibF.g.primaryUITests;
    t.buildTestNavDownAll(
      context: context,
      rows: protoRows,
      tests: primaryTests,
    );
    
    protoRows.add(t.childListNav(title: "Third Party", onPressed: () {
      context.dispatch(AFPrototypeThirdPartyListScreen.navigateTo());
    }));

    final areas = context.p.filter.split(" ");
    final tests = AFibF.g.findTestsForAreas(areas);

    final filterRows = t.column();
    filterRows.add(_buildFilterAndRunControls(context, tests));
    
    if(context.p.view == AFPrototypeHomeScreenParam.viewFilter) {
      _buildFilteredSection(context, tests, filterRows);
    } else {
      _buildResultsSection(context, tests, filterRows);
    }

    final rows = t.column();
    rows.add(t.childCardHeader(context, AFUIWidgetID.cardTestHomeHeader, "Prototypes and Tests", protoRows, margin: t.margin.b.s3));    
    rows.add(t.childCardHeader(context, AFUIWidgetID.cardTestHomeSearchAndRun, "Search and Run", filterRows, margin: t.margin.b.s3));
    
    return context.t.buildPrototypeScaffold("AFib Prototype Mode", rows);
  }

  void _onRunTests(AFProtoBuildContext<APrototypeHomeScreenStateView, AFPrototypeHomeScreenParam> context, List<AFScreenPrototypeTest> tests) async { 
    
    final results = <AFScreenTestResultSummary>[];
    for(final test in tests) {
      // first, we navigate into the screen.
      test.startScreen(context.d);

      final state = AFibF.g.storeInternalOnly.state;
      final testState = state.testState;
      final testContext = testState.findContext(test.id);
      final testSpecificState = testState.findState(test.id);

      await Future.delayed(Duration(milliseconds: 500));
      
      await test.onDrawerRun(context.d, testContext, testSpecificState, AFReusableTestID.allTestId, () {
        context.dispatch(AFNavigateExitTestAction());
      });

      await Future.delayed(Duration(milliseconds: 500));

      final stateRevised = AFibF.g.storeInternalOnly.state;
      final testStateRevised = stateRevised.testState;
      final contextRevised = testStateRevised.findContext(test.id);
      final testSpecificStateRevised = testStateRevised.findState(test.id);
      results.add(AFScreenTestResultSummary(
        context: contextRevised,
        state: testSpecificStateRevised 
      ));
      
    }

    updateRouteParam(context, context.p.copyWith(results: results, view: AFPrototypeHomeScreenParam.viewResults));
  }

  void _updateFilter(AFProtoBuildContext<APrototypeHomeScreenStateView, AFPrototypeHomeScreenParam> context, String value) {
    final revised = context.p.reviseFilter(value);
    updateRouteParam(context, revised);
  }

  Widget _buildFilterAndRunControls(AFProtoBuildContext<APrototypeHomeScreenStateView, AFPrototypeHomeScreenParam> context, List<AFScreenPrototypeTest> tests) {
    final t = context.t;

    final rows = t.column();

    final searchText = Container(
      child: t.childTextField(
        wid: AFUIWidgetID.textTestSearch,
        controllers: context.p.textControllers,
        text: context.p.filter,
        obscureText: false,
        autofocus: false,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: "Search"
        ),
        autocorrect: false,
        textAlign: TextAlign.left,
        onChanged: (value) {
          _updateFilter(context, value);
        }
      )
    );    

    rows.add(searchText);

    final colsAction = t.row();
    final colorSearchText = t.colorOnBackground;
    final colorResultsText = t.colorOnBackground;


    colsAction.add(Container(
      child: FlatButton(
        child: t.childText("Search Results", textColor: colorSearchText),
        onPressed: () {
          updateRouteParam(context, context.p.copyWith(view: AFPrototypeHomeScreenParam.viewFilter));
        },
      )
    ));

    colsAction.add(Container(
      child: FlatButton(
        child: t.childText("Test Results", textColor: colorResultsText),
        onPressed: () {
          updateRouteParam(context, context.p.copyWith(view: AFPrototypeHomeScreenParam.viewResults));
        }
    )));

    final textRunMain = tests.isNotEmpty ? 'Sel.' : 'All';
    final colsRun = t.row();
    colsRun.add(t.childText('Run $textRunMain'));

    colsRun.add(PopupMenuButton<String>(
      onSelected: (id) { 
        var tests;
        if(id == runWorkflowTestsId) {
          tests = AFibF.g.workflowTests.all;
        } else if(id == runScreenTestsId) {
          tests = AFibF.g.screenTests.all;
        } else if(id == runWidgetTestsId) {
          tests = AFibF.g.widgetTests.all;
        }
        _onRunTests(context, tests);
      },
      itemBuilder: (context) {
        final result = <PopupMenuEntry<String>>[];
        result.add(PopupMenuItem<String>(
          value: runWidgetTestsId,
          child: t.childText("Run widget tests")
        ));
        result.add(PopupMenuItem<String>(
          value: runScreenTestsId,
          child: t.childText("Run screen tests")
        ));
        result.add(PopupMenuItem<String>(
          value: runWorkflowTestsId,
          child: t.childText("Run workflow tests")
        ));
        return result;
      }
    ));

    final buttonContent = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: colsRun,
    );

    colsAction.add(FlatButton(
      child: buttonContent,
      color: t.colorSecondary,
      textColor: t.colorOnSecondary,
      onPressed: ()  {
        if(tests.isEmpty) {
          tests = AFibF.g.allScreenTests;
        }
        _onRunTests(context, tests);
      }
    ));

    rows.add(t.childMargin(
      margin: t.margin.v.s3,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: colsAction
      )
    ));

    return Container(
      key: t.keyForWID(AFUIWidgetID.contTestSearchControls),
      margin: t.marginStandard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: rows,
      ));
  }


  void _buildFilteredSection(AFProtoBuildContext<APrototypeHomeScreenStateView, AFPrototypeHomeScreenParam> context, List<AFScreenPrototypeTest> tests, List<Widget> rows, ) {
    if(tests == null || tests.isEmpty) {
      return;
    }

    for(final test in tests) {
      rows.add(context.t.createTestListTile(context.d, test));
    }
  }

  void _buildResultsSection(AFProtoBuildContext<APrototypeHomeScreenStateView, AFPrototypeHomeScreenParam> context, List<AFScreenPrototypeTest> tests, List<Widget> rows) {
    final t = context.t;
    final results = context.p.results;
    if(results.isEmpty) {
      rows.add(Container(
        margin: t.marginStandard,
        child: t.childText("No results yet.")
      ));
      return;
    }
    
    final allErrors = _findAllErrors(results);
    rows.add(Container(
      margin: t.marginStandard,
      child: t.buildErrorsSection(context, allErrors)
    ));
  
    // this is a table showing all the results by test.
    final headerCols = t.row();
    headerCols.add(t.testResultTableHeader(context, "Test", TextAlign.right));
    headerCols.add(t.testResultTableHeader(context, "Pass", TextAlign.right));
    headerCols.add(t.testResultTableHeader(context, "Fail", TextAlign.right));
    final tableRows = t.childrenTable();
    tableRows.add(TableRow(children: headerCols));

    var totalPass = 0;
    var totalFail = 0;

    for(final result in results) {
      final resultCols = t.row();
      final testContext = result.context;
      final testState = result.state;
      final pass = testState.pass;
      final fail = testState.errors.length;
      totalPass += pass;
      totalFail += fail;
      resultCols.add(t.testResultTableValue(context, testContext.testID.toString(), TextAlign.right));
      resultCols.add(t.testResultTableValue(context, pass.toString(), TextAlign.right));
      resultCols.add(t.testResultTableValue(context, fail.toString(), TextAlign.right, showError: (testState.errors.isNotEmpty)));      
      tableRows.add(TableRow(children: resultCols));
    }

    final totalCols = t.row();
    totalCols.add(t.testResultTableValue(context, "TOTAL", TextAlign.right));
    totalCols.add(t.testResultTableValue(context, totalPass.toString(), TextAlign.right));
    totalCols.add(t.testResultTableValue(context, totalFail.toString(), TextAlign.right, showError: (totalFail > 0)));      
    tableRows.add(TableRow(children: totalCols));

    final columnWidths = {
      1: FlexColumnWidth(),
      2: FixedColumnWidth(t.resultColumnWidth),
      3: FixedColumnWidth(t.resultColumnWidth),
    };

    rows.add(Container(
      margin: t.marginCustom(horizontal: 3, top: 4),
      child: Table(children: tableRows, columnWidths: columnWidths)
    ));    
  }

  List<String> _findAllErrors(List<AFScreenTestResultSummary> results) {
    final errors = <String>[];
    for(final result in results) {
      final testState = result.state;
      errors.addAll(testState.errors);
    }
    return errors;
  }

}