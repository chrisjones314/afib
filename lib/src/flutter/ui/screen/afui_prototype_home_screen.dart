import 'package:afib/afui_id.dart';
import 'package:afib/src/dart/redux/state/models/af_test_state.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:afib/src/flutter/ui/afui_connected_base.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/ui/screen/afui_prototype_library_list_screen.dart';
import 'package:afib/src/flutter/ui/screen/afui_prototype_list_screen.dart';
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
  final AFTextEditingControllers textControllers;
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
    final controllers = AFTextEditingControllers.createOne(AFUIWidgetID.textTestSearch, filter);
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
    final primaryTests = AFibF.g.primaryUITests;
    final rows = t.column();

    final protoRows = t.column();

    t.buildLibraryPrototypeNav(
      spi: spi,
      rows: protoRows,
      tests: primaryTests,
    );


    rows.add(t.childCardHeader(context, AFUIWidgetID.cardPrototype, AFUITranslationID.prototype, protoRows, margin: t.margin.b.s3));    
    
    final releaseRows = t.column();

    releaseRows.add(t.childListNav(title: AFUITranslationID.stateTests, onPressed: () {
      final tests = primaryTests.afWorkflowTestsForStateTests.all;
      spi.navigatePush(AFUIPrototypeTestScreen.navigatePush(tests, "State Tests"));
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
      spi.navigatePush(AFUIPrototypeLibraryListScreen.navigatePush());
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


    rows.add(t.childCardHeader(context, AFUIWidgetID.cardTestHomeSearchAndRun, AFUITranslationID.recent, recentRows, margin: t.margin.b.s3));
    
    return spi.t.buildPrototypeScaffold(AFUITranslationID.afibPrototypeMode, rows);
  }


}