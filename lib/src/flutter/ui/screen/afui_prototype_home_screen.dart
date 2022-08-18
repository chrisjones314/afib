import 'package:afib/afui_id.dart';
import 'package:afib/src/dart/redux/state/models/af_test_state.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param_with_flutter_state.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:afib/src/flutter/ui/afui_connected_base.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/ui/screen/afui_prototype_library_list_screen.dart';
import 'package:afib/src/flutter/ui/screen/afui_state_test_list_screen.dart';
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
class AFUIPrototypeHomeScreenParam extends AFScreenRouteParamWithFlutterState {
  static const filterTextId = 1;
  static const viewFilter = 1;
  static const viewResults = 2;
  final String search;
  final AFTextEditingControllers textControllers;
  final List<AFScreenTestResultSummary> results;
  final int view;

  AFUIPrototypeHomeScreenParam({
    required this.search,
    required this.textControllers,
    required this.results,
    required this.view,
    required AFFlutterRouteParamState flutterState,
  }): super(screenId: AFUIScreenID.screenPrototypeHome, flutterState: flutterState);

  AFUIPrototypeHomeScreenParam reviseFilter(String filter) {
    return copyWith(filter: filter);
  }

  factory AFUIPrototypeHomeScreenParam.createOncePerScreen() {
    final textControllers = AFTextEditingControllers.createOne(AFUIWidgetID.editSearch, "");
    final flutterState = AFFlutterRouteParamState(
      textControllers: textControllers
    );
    final filter = "";
    final controllers = AFTextEditingControllers.createOne(AFUIWidgetID.textTestSearch, filter);
    return AFUIPrototypeHomeScreenParam(
      view: viewFilter,
      results: <AFScreenTestResultSummary>[],
      textControllers: controllers,
      search: filter,
      flutterState: flutterState,
    );
  }

  AFUIPrototypeHomeScreenParam copyWith({
    String? filter,
    List<AFScreenTestResultSummary>? results,
    int? view
  }) {
    return AFUIPrototypeHomeScreenParam(
      search: filter ?? this.search,
      results: results ?? this.results,
      view: view ?? this.view,
      textControllers: this.textControllers,
      flutterState: this.flutterStateGuaranteed,
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

  String get searchText {
    return context.p.search;
  }

  List<AFScreenPrototype> get foundTests {
    final tokens = context.p.search.toLowerCase().split(" ");
    final results = AFibF.g.findScreenTestByTokens(tokens);
    return results;
  }

  AFTextEditingController? get searchController {
    final textControllers = context.p.flutterStateGuaranteed.textControllers;
    final controller = textControllers?.access(AFUIWidgetID.editSearch);
    return controller;
  }

  void onEditSearchText(String text) {
    context.updateTextField(AFUIWidgetID.editSearch, text);
    final revised = context.p.copyWith(filter: text);
    context.updateRouteParam(revised);
  }

  void onClear() {
    final controller = searchController;
    controller?.clear();
    final revised = context.p.copyWith(filter: "");
    context.updateRouteParam(revised);
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
    final main = _buildHome(spi);
    return spi.t.buildPrototypeScaffold(spi, AFUITranslationID.afibPrototypeMode, main);
  }

  void _buildSearchResults(AFPrototypeHomeScreenSPI spi, List<Widget> rows) {
    final t = spi.t;
    final foundTests = spi.foundTests;
    final testRows = t.column();
    for(final test in foundTests) {
      testRows.add(t.createTestListTile(spi, test));
    }
    rows.add(t.childCardHeader(spi.context, AFUIWidgetID.cardSearchResults, "Results for '${spi.searchText}'", testRows, margin: t.margin.b.s3));    
  }


  void _buildHomeScreen(AFPrototypeHomeScreenSPI spi, List<Widget> rows) {
    final t = spi.t;
    final context = spi.context;
    final protoRows = t.column();

    final primaryTests = AFibF.g.primaryUITests;
    t.buildLibraryPrototypeNav(
      spi: spi,
      rows: protoRows,
      tests: primaryTests,
    );


    rows.add(t.childCardHeader(context, AFUIWidgetID.cardPrototype, AFUITranslationID.prototype, protoRows, margin: t.margin.b.s3));    
    
    final releaseRows = t.column();

    releaseRows.add(t.childListNav(title: AFUITranslationID.stateTests, onPressed: () {
      final tests = primaryTests.afWorkflowTestsForStateTests.all;
      spi.context.navigatePush(AFUIStateTestListScreen.navigatePush(tests, "State Tests"));
    }));

    final workflowTests = primaryTests.afWorkflowStateTests.all;

    if(workflowTests.isNotEmpty) {
      releaseRows.add(t.childTestNavDown(
        spi: spi,
        title: AFUITranslationID.workflowTests,
        tests: workflowTests
      ));
    }

    releaseRows.add(t.childListNav(title: AFUITranslationID.libraries, onPressed: () {
      spi.context.navigatePush(AFUIPrototypeLibraryListScreen.navigatePush());
    }));


    rows.add(t.childCardHeader(context, AFUIWidgetID.cardRelease, AFUITranslationID.release, releaseRows, margin: t.margin.b.s3));    

    final recentRows = t.column();
    final recentTests = AFibD.config.recentTests;
    for(final testIdStr in recentTests) {
      final testId = AFFromStringTestID(testIdStr);
      final test = AFibF.g.findScreenTestById(testId);
      if(test == null) {
        continue;
      }
      recentRows.add(t.createTestListTile(spi, test));
    }

    final favorites = AFibD.config.favoriteTestIds;
    final favoritesRows = t.column();
    if(favorites != null && favorites.isNotEmpty) {
      for(final favId in favorites) {
        final test = AFibF.g.findScreenTestById(favId);
        if(test != null) {
          favoritesRows.add(t.createTestListTile(spi, test));
        }
      }
    } else {
      favoritesRows.add(t.childMargin(
        margin: t.margin.standard,
        child: t.childText("You can add favorite tests in initialization/environments/prototypes.dart")
      ));
    }
    rows.add(t.childCardHeader(context, AFUIWidgetID.cardRecent, AFUITranslationID.favorites, favoritesRows, margin: t.margin.b.s3));
    rows.add(t.childCardHeader(context, AFUIWidgetID.cardRecent, AFUITranslationID.recent, recentRows, margin: t.margin.b.s3));

  }

  /// 
  Widget _buildHome(AFPrototypeHomeScreenSPI spi) {
    final t = spi.t;
    final context = spi.context;
    final rows = t.column();

    final searchText = spi.searchText;

    if(searchText.isNotEmpty) {
      _buildSearchResults(spi, rows);
    } else {
      _buildHomeScreen(spi, rows);
    }

    final main = ListView(
      children: rows
    );

    final search = _buildSearchRow(spi);

    return t.childTopBottomHostedControls(context.c, main, bottomControls: search);
  }

  Widget _buildSearchRow(AFPrototypeHomeScreenSPI spi) {
    final context = spi.context;
    final t = spi.t;
    final p = context.routeParam;

    final searchText = Expanded(
      child: Container(
      key: t.keyForWID(AFUIWidgetID.editSearch),
      margin: t.margin.h.s3,
      child: t.childTextField(
        screenId: screenId,
        wid: AFUIWidgetID.editSearch,
        parentParam: p,
        obscureText: false,
        autofocus: false,
        autocorrect: false,
        textAlign: TextAlign.left,
        decoration: InputDecoration(
          border: InputBorder.none,
        ),
        onChanged: spi.onEditSearchText
      )
    ));    

    final clearButton = IconButton(
      icon: t.iconClear(),
      onPressed: spi.onClear,
    );

    final cols = t.row();
    cols.add(searchText);
    cols.add(clearButton);

    final rows = t.column();
    rows.add(Row(
      key: t.keyForWID(AFUIWidgetID.rowSearchControls),
      children: cols
    ));

    return t.childMargin(
      margin: const EdgeInsets.only(bottom: 30.0),
      child: Card(
        child: Container(
        key: t.keyForWID(AFUIWidgetID.cardSearchControls),
          decoration: BoxDecoration(
            border: Border.all(color: t.colorPrimary),
            borderRadius: t.borderRadius.standard,
          ),
          child: Column(
            key: t.keyForWID(AFUIWidgetID.columnSearchControls),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: rows
          )
        )
      )
    );
  }
}