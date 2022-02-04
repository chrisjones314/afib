import 'package:afib/id.dart';
import 'package:afib/src/dart/redux/actions/af_route_actions.dart';
import 'package:afib/src/dart/redux/state/models/af_test_state.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:afib/src/flutter/test/af_test_actions.dart';
import 'package:afib/src/flutter/ui/afui_connected_base.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/ui/screen/afui_prototype_third_party_list_screen.dart';
import 'package:afib/src/flutter/ui/screen/afui_prototype_wireframes_list_screen.dart';
import 'package:afib/src/flutter/ui/stateviews/afui_default_state_view.dart';
import 'package:afib/src/flutter/ui/theme/afui_default_theme.dart';
import 'package:afib/src/flutter/utils/af_param_ui_state_holder.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:flutter/material.dart';

class AFScreenTestResultSummary {
  final AFScreenTestContext context;
  final AFSingleScreenTestState state;

  AFScreenTestResultSummary({
    required this.context,
    required this.state,
  });
}


/// Parameter uses to filter the tests/protoypes shown on the screen.
@immutable
class AFUIPrototypeHomeScreenParam extends AFRouteParam {
  static const filterTextId = 1;
  static const viewFilter = 1;
  static const viewResults = 2;
  final String filter;
  final AFTextEditingControllersHolder textControllers;
  final List<AFScreenTestResultSummary> results;
  final int view;

  AFUIPrototypeHomeScreenParam({
    required this.filter,
    required this.textControllers,
    required this.results,
    required this.view,
  }): super(id: AFUIScreenID.screenPrototypeHome);

  AFUIPrototypeHomeScreenParam reviseFilter(String filter) {
    return copyWith(filter: filter);
  }

  factory AFUIPrototypeHomeScreenParam.createOncePerScreen({
    required String filter,
  }) {
    final controllers = AFTextEditingControllersHolder.createOne(AFUIWidgetID.textTestSearch, filter);
    return AFUIPrototypeHomeScreenParam(
      view: viewFilter,
      results: <AFScreenTestResultSummary>[],
      textControllers: controllers,
      filter: filter
    );
  }

  AFUIPrototypeHomeScreenParam copyWith({
    String? filter,
    List<AFScreenTestResultSummary>? results,
    int? view
  }) {
    return AFUIPrototypeHomeScreenParam(
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

class AFPrototypeHomeScreenSPI extends AFUIScreenSPI<AFUIDefaultStateView, AFUIPrototypeHomeScreenParam> {
  AFPrototypeHomeScreenSPI(AFBuildContext<AFUIDefaultStateView, AFUIPrototypeHomeScreenParam> context, AFScreenID screenId, AFUIDefaultTheme theme): super(context, screenId, theme, );
  
  factory AFPrototypeHomeScreenSPI.create(AFBuildContext<AFUIDefaultStateView, AFUIPrototypeHomeScreenParam> context, AFUIDefaultTheme theme, AFScreenID screenId) {
    return AFPrototypeHomeScreenSPI(context, screenId, theme,
    );
  }
}

/// A screen used internally in prototype mode to render screens and widgets with test data,
/// and display them in a list.
class AFPrototypeHomeScreen extends AFUIConnectedScreen<AFPrototypeHomeScreenSPI, AFUIDefaultStateView, AFUIPrototypeHomeScreenParam>{
  static const runWidgetTestsId = "run_widget_tests";
  static const runScreenTestsId = "run_screen_tests";
  static const runWorkflowTestsId = "run_workflow_tests";
  static final config =  AFUIDefaultScreenConfig<AFPrototypeHomeScreenSPI, AFUIPrototypeHomeScreenParam> (
    spiCreator: AFPrototypeHomeScreenSPI.create,
  );

  AFPrototypeHomeScreen(): super(screenId: AFUIScreenID.screenPrototypeHome, config: config);

  @override
  Widget buildWithSPI(AFPrototypeHomeScreenSPI spi) {
    return _buildHome(spi);
  }

  /// 
  Widget _buildHome(AFPrototypeHomeScreenSPI spi) {
    final t = spi.t;
    final context = spi.context;
    final protoRows = t.column();
    final primaryTests = AFibF.g.primaryUITests;
    t.buildTestNavDownAll(
      context: context,
      rows: protoRows,
      tests: primaryTests,
    );
    
    protoRows.add(t.childListNav(title: AFUITranslationID.thirdParty, onPressed: () {
      context.dispatch(AFUIPrototypeThirdPartyListScreen.navigatePush());
    }));

    protoRows.add(t.childListNav(title: AFUITranslationID.wireframes, onPressed: () {
      ;;context.dispatch(AFUIPrototypeWireframesListScreen.navigateTo());
    }));

    final areas = context.p.filter.split(" ");
    final tests = AFibF.g.findTestsForAreas(areas);

    final filterRows = t.column();
    filterRows.add(_buildFilterAndRunControls(spi, tests));
    
    if(context.p.view == AFUIPrototypeHomeScreenParam.viewFilter) {
      _buildFilteredSection(spi, tests, filterRows);
    } else {
      _buildResultsSection(spi, tests, filterRows);
    }

    final rows = t.column();
    rows.add(t.childCardHeader(context, AFUIWidgetID.cardTestHomeHeader, AFUITranslationID.prototypesAndTests, protoRows, margin: t.margin.b.s3));    
    rows.add(t.childCardHeader(context, AFUIWidgetID.cardTestHomeSearchAndRun, AFUITranslationID.searchAndRun, filterRows, margin: t.margin.b.s3));
    
    return spi.t.buildPrototypeScaffold(AFUITranslationID.afibPrototypeMode, rows);
  }

  void _onRunTests(AFPrototypeHomeScreenSPI spi, List<AFScreenPrototype> tests) async { 
    final context = spi.context;    
    final results = <AFScreenTestResultSummary>[];
    for(final test in tests) {
      // first, we navigate into the screen.
      context.dispatch(AFUpdateActivePrototypeAction(prototypeId: test.id));
      test.startScreen(context.d, AFibF.g.testData);

      final state = AFibF.g.storeInternalOnly!.state;
      final testState = state.private.testState;
      final testContext = testState.findContext(test.id);
      final testSpecificState = testState.findState(test.id);

      await Future.delayed(Duration(milliseconds: 500));
      
      // note: not sure if this is true.
      if(testContext == null) throw AFException("Text context should not be null");
      await test.onDrawerRun(context.d, testContext as AFScreenTestContextSimulator, testSpecificState!, AFUIScreenTestID.all, () {
        context.dispatch(AFNavigateExitTestAction());
      });

      await Future.delayed(Duration(milliseconds: 500));

      final stateRevised = AFibF.g.storeInternalOnly!.state;
      final testStateRevised = stateRevised.private.testState;
      final contextRevised = testStateRevised.findContext(test.id);
      final testSpecificStateRevised = testStateRevised.findState(test.id);

      // not sure if this is true.
      if(contextRevised == null || testSpecificStateRevised == null) { throw AFException("Should not be null"); }
      results.add(AFScreenTestResultSummary(
        context: contextRevised,
        state: testSpecificStateRevised 
      ));
      
    }

    spi.updateRouteParam(context.p.copyWith(results: results, view: AFUIPrototypeHomeScreenParam.viewResults));
  }

  void _updateFilter(AFPrototypeHomeScreenSPI spi, String value) {
    final context = spi.context;
    final revised = context.p.reviseFilter(value);
    spi.updateRouteParam(revised);
  }

  Widget _buildFilterAndRunControls(AFPrototypeHomeScreenSPI spi, List<AFScreenPrototype> tests) {
    final t = spi.t;
    final context = spi.context;

    final rows = t.column();

    final searchText = Container(
      child: t.childTextField(
        wid: AFUIWidgetID.textTestSearch,
        controllers: context.p.textControllers,
        obscureText: false,
        autofocus: false,
        text: context.p.filter,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: "Search"
        ),
        autocorrect: false,
        textAlign: TextAlign.left,
        onChanged: (value) {
          _updateFilter(spi, value);
        }
      )
    );    

    rows.add(searchText);

    final colsAction = t.row();
    final colorSearchText = t.colorOnBackground;
    final colorResultsText = t.colorOnBackground;


    colsAction.add(Container(
      child: TextButton(
        child: t.childText(AFUITranslationID.searchResults, textColor: colorSearchText),
        onPressed: () {
          spi.updateRouteParam(context.p.copyWith(view: AFUIPrototypeHomeScreenParam.viewFilter));
        },
      )
    ));

    colsAction.add(Container(
      child: TextButton(
        child: t.childText(AFUITranslationID.testResults, textColor: colorResultsText),
        onPressed: () {
          spi.updateRouteParam(context.p.copyWith(view: AFUIPrototypeHomeScreenParam.viewResults));
        }
    )));

    final textRunMain = tests.isNotEmpty ? 'Sel.' : 'All';
    final colsRun = t.row();
    colsRun.add(t.childText(AFUITranslationID.run.insert1(textRunMain)));

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
        _onRunTests(spi, tests);
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

    final buttonStyle = t.styleTextButton(
      color: t.colorSecondary,
      textColor: t.colorOnSecondary,
    );

    colsAction.add(TextButton(
      child: buttonContent,
      style: buttonStyle,
      onPressed: ()  {
        if(tests.isEmpty) {
          tests = AFibF.g.allScreenTests;
        }
        _onRunTests(spi, tests);
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


  void _buildFilteredSection(AFPrototypeHomeScreenSPI spi, List<AFScreenPrototype> tests, List<Widget> rows, ) {
    if(tests.isEmpty) {
      return;
    }
    final context = spi.context;

    for(final test in tests) {
      rows.add(spi.t.createTestListTile(context.d, test));
    }
  }

  void _buildResultsSection(AFPrototypeHomeScreenSPI spi, List<AFScreenPrototype> tests, List<Widget> rows) {
    final t = spi.t;
    final context = spi.context;
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
      child: t.buildErrorsSection(allErrors)
    ));
  
    // this is a table showing all the results by test.
    final headerCols = t.row();
    headerCols.add(t.testResultTableHeader("Test", TextAlign.right));
    headerCols.add(t.testResultTableHeader("Pass", TextAlign.right));
    headerCols.add(t.testResultTableHeader("Fail", TextAlign.right));
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
      resultCols.add(t.testResultTableValue(testContext.testID.toString(), TextAlign.right));
      resultCols.add(t.testResultTableValue(pass.toString(), TextAlign.right));
      resultCols.add(t.testResultTableValue(fail.toString(), TextAlign.right, showError: (testState.errors.isNotEmpty)));      
      tableRows.add(TableRow(children: resultCols));
    }

    final totalCols = t.row();
    totalCols.add(t.testResultTableValue("TOTAL", TextAlign.right));
    totalCols.add(t.testResultTableValue(totalPass.toString(), TextAlign.right));
    totalCols.add(t.testResultTableValue(totalFail.toString(), TextAlign.right, showError: (totalFail > 0)));      
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