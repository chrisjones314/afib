

import 'package:afib/afib_dart.dart';
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/utils/af_ui_id.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/test/af_prototype_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';


/// Parameter uses to filter the tests/protoypes shown on the screen.
@immutable
class AFPrototypeHomeScreenParam extends AFRouteParam {
  static const filterTextId = 1;
  final String filter;
  final AFTextEditingControllersHolder textControllers;

  AFPrototypeHomeScreenParam({
    @required this.filter,
    @required this.textControllers
  });

  AFPrototypeHomeScreenParam reviseFilter(String filter) {
    return copyWith(filter: filter);
  }

  factory AFPrototypeHomeScreenParam.createOncePerScreen({
    @required String filter,
  }) {

    return AFPrototypeHomeScreenParam(
      filter: filter,
      textControllers: AFTextEditingControllersHolder()
    );
  }

  AFPrototypeHomeScreenParam copyWith({
    String filter
  }) {
    return AFPrototypeHomeScreenParam(
      filter: filter ?? this.filter,
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
class AFPrototypeHomeScreen extends AFConnectedScreen<AFAppState, APrototypeHomeScreenData, AFPrototypeHomeScreenParam>{

  AFPrototypeHomeScreen(): super(AFUIID.screenPrototypeHome);

  @override
  APrototypeHomeScreenData createStateDataAF(AFState state) {
    final tests = AFibF.screenTests;
    return APrototypeHomeScreenData(tests);
  }

  @override
  APrototypeHomeScreenData createStateData(AFAppState state) {
    // this should never be called, because createDataAF replaces it.
    throw UnimplementedError();
  }


  @override
  Widget buildWithContext(AFBuildContext<APrototypeHomeScreenData, AFPrototypeHomeScreenParam> context) {
    return _buildHome(context);
  }

  /// 
  Widget _buildHome(AFBuildContext<APrototypeHomeScreenData, AFPrototypeHomeScreenParam> context) {
    final rows = AFUI.column();
    
    rows.add(_createKindRow("Widget Prototypes", () {
      List<AFScreenPrototypeTest> tests = AFibF.widgetTests.all;
      context.dispatch(AFPrototypeTestScreen.navigateTo(tests));
    }));
    
    rows.add(_createKindRow("Single Screen Prototypes", () {
      List<AFScreenPrototypeTest> tests = AFibF.screenTests.all;
      context.dispatch(AFPrototypeTestScreen.navigateTo(tests));
    }));
    
    rows.add(_createKindRow("Wireframe Prototypes", () {
      
    }));

    rows.add(_createKindRow("Multi-Screen Prototypes", () {
      List<AFScreenPrototypeTest> tests = AFibF.multiScreenStateTests.all;
      context.dispatch(AFPrototypeTestScreen.navigateTo(tests));
    }));
    
    final areas = context.p.filter.split(" ");
    final tests = AFibF.findTestsForAreas(areas);

    _buildFilterAndRunControls(context, tests, rows);

    _buildFilteredSection(context, tests, rows);


    return buildPrototypeScaffold('AFib Prototype mode', rows);
  }

  void _onRunTests(AFBuildContext<APrototypeHomeScreenData, AFPrototypeHomeScreenParam> context, List<AFScreenPrototypeTest> tests) async { 
    for(final test in tests) {
      // first, we navigate into the screen.
      test.startScreen(context.d);

      final state = AFibF.testOnlyStore.state;
      final testState = state.testState;
      final testContext = testState.findContext(test.id);
      final testSpecificState = testState.findState(test.id);

      await Future.delayed(Duration(milliseconds: 500));
      
      await test.onDrawerRun(context.d, testContext, testSpecificState, () {
        context.dispatch(AFNavigateExitTestAction());
      });

      await Future.delayed(Duration(milliseconds: 500));
    }
  }

  void _updateFilter(AFBuildContext<APrototypeHomeScreenData, AFPrototypeHomeScreenParam> context, String value) {
    final revised = context.p.reviseFilter(value);
    updateParam(context, revised);
  }

  void _buildFilterAndRunControls(AFBuildContext<APrototypeHomeScreenData, AFPrototypeHomeScreenParam> context, List<AFScreenPrototypeTest> tests, List<Widget> rows) {
    rows.add(AFPrototypeTestScreen.createSectionHeader("Filter and Run"));
    
    final searchController = context.p.textControllers.syncText(AFPrototypeHomeScreenParam.filterTextId, context.p.filter);

    final searchText = Container(
      margin: EdgeInsets.symmetric(horizontal: 8.0), 
      child: TextField(
        //key: AFUI.keyForWID(DFWidgetID.editSearch),
        controller: searchController,
        obscureText: false,
        autofocus: false,
        autocorrect: false,
        textAlign: TextAlign.left,
        onChanged: (value) {
          _updateFilter(context, value);
        }
      )
    );    

    rows.add(searchText);

    if(tests.isNotEmpty) {
      rows.add(Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        child: RaisedButton(
          child: Text("Run All"),
          onPressed: () {
            _onRunTests(context, tests);
          }
        )
      ));
    }
  }


  void _buildFilteredSection(AFBuildContext<APrototypeHomeScreenData, AFPrototypeHomeScreenParam> context, List<AFScreenPrototypeTest> tests, List<Widget> rows, ) {
    if(tests == null || tests.isEmpty) {
      return;
    }

    for(final test in tests) {
      rows.add(AFPrototypeTestScreen.createTestCard(context.d, test));
    }
  }

  static Widget buildPrototypeScaffold(String title, List<Widget> rows, { Widget leading }) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(        
            leading: leading,
            automaticallyImplyLeading: false,
            title: Text(title),
          ),
          SliverList(
            delegate: SliverChildListDelegate(rows),)
      ])    
    );
  }

  Widget _createKindRow(String title, Function onTap) {
    return Card(
      child: ListTile(
        title: Text(title),
        dense: true,
        trailing: Icon(Icons.chevron_right),
        onTap: onTap
      )
    );
  }
}