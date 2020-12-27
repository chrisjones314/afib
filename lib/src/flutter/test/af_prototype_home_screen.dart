

import 'package:afib/afib_dart.dart';
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/redux/state/af_test_state.dart';
import 'package:afib/src/dart/utils/af_ui_id.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/test/af_prototype_list_screen.dart';
import 'package:afib/src/flutter/theme/af_prototype_theme.dart';
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
class APrototypeHomeScreenData extends AFStoreConnectorData1<AFSingleScreenTests> {
  APrototypeHomeScreenData(AFSingleScreenTests tests): 
    super(first: tests);
  
  AFSingleScreenTests get tests { return first; }
}

/// A screen used internally in prototype mode to render screens and widgets with test data,
/// and display them in a list.
class AFPrototypeHomeScreen extends AFConnectedScreen<AFAppStateArea, APrototypeHomeScreenData, AFPrototypeHomeScreenParam, AFPrototypeTheme>{

  AFPrototypeHomeScreen(): super(AFUIScreenID.screenPrototypeHome);

  @override
  APrototypeHomeScreenData createStateDataAF(AFState state) {
    final tests = AFibF.g.screenTests;
    return APrototypeHomeScreenData(tests);
  }

  @override
  APrototypeHomeScreenData createStateData(AFAppStateArea state) {
    // this should never be called, because createDataAF replaces it.
    throw UnimplementedError();
  }


  @override
  Widget buildWithContext(AFBuildContext<APrototypeHomeScreenData, AFPrototypeHomeScreenParam, AFPrototypeTheme> context) {
    return _buildHome(context);
  }

  /// 
  Widget _buildHome(AFBuildContext<APrototypeHomeScreenData, AFPrototypeHomeScreenParam, AFPrototypeTheme> context) {
    final t = context.t;

    final protoRows = t.childrenColumn();
    protoRows.add(_createKindRow(context, "Widget Prototypes", () {
      List<AFScreenPrototypeTest> tests = AFibF.g.widgetTests.all;
      context.dispatch(AFPrototypeTestScreen.navigateTo(tests));
    }));
    
    protoRows.add(_createKindRow(context, "Screen Prototypes", () {
      List<AFScreenPrototypeTest> tests = AFibF.g.screenTests.all;
      context.dispatch(AFPrototypeTestScreen.navigateTo(tests));
    }));
    
    protoRows.add(_createKindRow(context, "Workflow Prototypes", () {
      List<AFScreenPrototypeTest> tests = AFibF.g.workflowTests.all;
      context.dispatch(AFPrototypeTestScreen.navigateTo(tests));
    }));
    

    final areas = context.p.filter.split(" ");
    final tests = AFibF.g.findTestsForAreas(areas);

    final filterRows = t.childrenColumn();
    filterRows.add(_buildFilterAndRunControls(context, tests));
    
    if(context.p.view == AFPrototypeHomeScreenParam.viewFilter) {
      _buildFilteredSection(context, tests, filterRows);
    } else {
      _buildResultsSection(context, tests, filterRows);
    }

    final rows = t.childrenColumn();
    rows.add(t.buildHeaderCard(context, AFUIWidgetID.cardTestHomeHeader, "Prototypes and Tests", protoRows));    
    rows.add(t.buildHeaderCard(context, AFUIWidgetID.cardTestHomeSearchAndRun, "Search and Run", filterRows));
    
    return context.t.buildPrototypeScaffold("AFib Prototype Mode", rows);
  }

  void _onRunTests(AFBuildContext<APrototypeHomeScreenData, AFPrototypeHomeScreenParam, AFPrototypeTheme> context, List<AFScreenPrototypeTest> tests) async { 
    
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

  void _updateFilter(AFBuildContext<APrototypeHomeScreenData, AFPrototypeHomeScreenParam, AFPrototypeTheme> context, String value) {
    final revised = context.p.reviseFilter(value);
    updateRouteParam(context, revised);
  }

  Widget _buildFilterAndRunControls(AFBuildContext<APrototypeHomeScreenData, AFPrototypeHomeScreenParam, AFPrototypeTheme> context, List<AFScreenPrototypeTest> tests) {
    final t = context.t;
    final searchController = context.p.textControllers.syncText(AFPrototypeHomeScreenParam.filterTextId, context.p.filter);

    final rows = t.childrenColumn();

    final searchText = Container(
      child: TextField(
        key: t.keyForWID(AFUIWidgetID.textTestSearch),
        controller: searchController,
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

    if(tests.isNotEmpty) {
      final colsAction = t.childrenRow();
      final view = context.p.view;
      final isFilter = view == AFPrototypeHomeScreenParam.viewFilter;
      final colorSearch = isFilter ? t.colorSecondary : t.colorBackground;
      final colorResults = isFilter ? t.colorBackground : t.colorSecondary;
      final colorSearchText = isFilter ? t.colorOnPrimary : t.colorOnBackground;
      final colorResultsText = isFilter ? t.colorOnBackground : t.colorOnPrimary;


      colsAction.add(Container(
        child: FlatButton(
          child: t.childText("Search Results", textColor: colorSearchText),
          color: colorSearch,
          onPressed: () {
            updateRouteParam(context, context.p.copyWith(view: AFPrototypeHomeScreenParam.viewFilter));
          },
        )
      ));

      colsAction.add(Container(
        child: FlatButton(
          child: t.childText("Test Results", textColor: colorResultsText),
          color: colorResults,
          onPressed: () {
            updateRouteParam(context, context.p.copyWith(view: AFPrototypeHomeScreenParam.viewResults));
          }
      )));

      colsAction.add(Container(
        child: FlatButton(
          child: t.childText("Run All", style: t.styleOnPrimary.bodyText1),
          color: t.colorPrimary,
          onPressed: () {
            _onRunTests(context, tests);
          }
        )
      ));

      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: colsAction
      ));
    }

    return Container(
      key: t.keyForWID(AFUIWidgetID.contTestSearchControls),
      margin: context.t.marginScaled(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: rows,
      ));
  }


  void _buildFilteredSection(AFBuildContext<APrototypeHomeScreenData, AFPrototypeHomeScreenParam, AFPrototypeTheme> context, List<AFScreenPrototypeTest> tests, List<Widget> rows, ) {
    if(tests == null || tests.isEmpty) {
      return;
    }

    for(final test in tests) {
      rows.add(context.t.createTestListTile(context.d, test));
    }
  }

  void _buildResultsSection(AFBuildContext<APrototypeHomeScreenData, AFPrototypeHomeScreenParam, AFPrototypeTheme> context, List<AFScreenPrototypeTest> tests, List<Widget> rows) {
    final t = context.t;
    final results = context.p.results;
    if(results.isEmpty) {
      rows.add(Container(
        margin: t.marginScaled(all: 2),
        child: t.childText("No results yet.")
      ));
      return;
    }
    
    final allErrors = _findAllErrors(results);
    rows.add(Container(
      margin: t.marginScaled(),
      child: t.buildErrorsSection(context, allErrors)
    ));
  
    // this is a table showing all the results by test.
    final headerCols = t.childrenRow();
    headerCols.add(t.testResultTableHeader(context, "Test", TextAlign.right));
    headerCols.add(t.testResultTableHeader(context, "Pass", TextAlign.right));
    headerCols.add(t.testResultTableHeader(context, "Fail", TextAlign.right));
    final tableRows = t.childrenTable();
    tableRows.add(TableRow(children: headerCols));

    var totalPass = 0;
    var totalFail = 0;

    for(final result in results) {
      final resultCols = t.childrenRow();
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

    final totalCols = t.childrenRow();
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
      margin: t.marginScaled(horizontal: 1, top: 2),
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

  Widget _createKindRow(AFBuildContext<APrototypeHomeScreenData, AFPrototypeHomeScreenParam, AFPrototypeTheme> context, String text, Function onTap) {
    return ListTile(
      title: context.t.childText(text),
      dense: true,
      trailing: context.t.icon(AFUIThemeID.iconNavDown),
      onTap: onTap
    );
  }
}