

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
  final String filter;

  AFPrototypeHomeScreenParam({this.filter});

  AFPrototypeHomeScreenParam copyWith() {
    return AFPrototypeHomeScreenParam();
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
  APrototypeHomeScreenData createData(AFAppState state) {
    AFSingleScreenTests tests = AFibF.screenTests;
    return APrototypeHomeScreenData(tests);
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

    _buildFilteredSection(context, rows);


    return buildPrototypeScaffold('AFib Prototype mode', rows);
  }


  void _buildFilteredSection(AFBuildContext<APrototypeHomeScreenData, AFPrototypeHomeScreenParam> context, List<Widget> rows) {
    List<String> areas = AFibD.config.stringListFor(AFConfigEntries.enabledTestList);
    List<AFScreenPrototypeTest> tests = AFibF.findTestsForAreas(areas);
    if(tests == null || tests.isEmpty) {
      return;
    }
    rows.add(AFPrototypeTestScreen.createSectionHeader("Filtered Tests"));

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