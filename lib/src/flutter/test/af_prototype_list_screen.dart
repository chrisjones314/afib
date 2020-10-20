

import 'package:afib/afib_dart.dart';
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/utils/af_ui_id.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/test/af_prototype_home_screen.dart';
import 'package:afib/src/flutter/utils/af_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';

/// Parameter uses to filter the tests/protoypes shown on the screen.
@immutable
class AFPrototypeTestScreenParam extends AFRouteParam {
  static const ungroupedGroup = "ungrouped";
  final String filter;
  final String title;

  final Map<String, List<AFScreenPrototypeTest>> screenTestsByGroup;

  AFPrototypeTestScreenParam({
    @required this.screenTestsByGroup,
    @required this.title,
    this.filter});


  factory AFPrototypeTestScreenParam.createFromList({
    @required String title,
    @required List<AFScreenPrototypeTest> tests
  }) {
    final groups = <String, List<AFScreenPrototypeTest>>{};
    for(final test in tests) {
      var group = test.id.effectiveGroup;
      if(group == null) {
       group = ungroupedGroup; 
      }
      var tests = groups[group];      
      if(tests == null) {
        tests = <AFScreenPrototypeTest>[];
        groups[group] = tests;
      }

      tests.add(test);
    }

    // go through all the test entries and sort them.
    groups.forEach((group, tests) { 
      tests.sort( (left, right) {
        return left.id.compareTo(right.id);
      });
    });

    return AFPrototypeTestScreenParam(title: title, screenTestsByGroup: groups);
  }

  AFPrototypeTestScreenParam copyWith({
    String filter,
    String title,
    Map<String, AFScreenPrototypeTest> screenTestsByGroup
  }) {
    return AFPrototypeTestScreenParam(
      screenTestsByGroup: screenTestsByGroup ?? this.screenTestsByGroup,
      filter: filter ?? this.filter,
      title: title ?? this.title
    );
  }
}

/// Data used to render the screen
class AFPrototypeTestScreenData extends AFStoreConnectorData1<AFSingleScreenTests> {
  AFPrototypeTestScreenData(AFSingleScreenTests tests): 
    super(first: tests);
  
  AFSingleScreenTests get tests { return first; }
}

/// A screen used internally in prototype mode to render screens and widgets with test data,
/// and display them in a list.
class AFPrototypeTestScreen extends AFConnectedScreen<AFAppState, AFStoreConnectorDataUnused, AFPrototypeTestScreenParam>{

  AFPrototypeTestScreen(): super(AFUIID.screenPrototypeListSingleScreen);

  static AFNavigatePushAction navigateTo(List<AFScreenPrototypeTest> tests) {
    return AFNavigatePushAction(screen: AFUIID.screenPrototypeListSingleScreen,
      param: AFPrototypeTestScreenParam.createFromList(title: "Single Screen Prototypes", tests: tests));
  }

  @override
  AFStoreConnectorDataUnused createStateData(AFAppState state) {
    return AFStoreConnectorDataUnused();
  }

  @override
  Widget buildWithContext(AFBuildContext<AFStoreConnectorDataUnused, AFPrototypeTestScreenParam> context) {
    return _buildList(context);
  }

  List<String> _sortIterable(Iterable<String> items) {
    final result = List<String>.of(items);
    result.sort();
    return result;
  }

  Widget _buildList(AFBuildContext<AFStoreConnectorDataUnused, AFPrototypeTestScreenParam> context) {

    final rows = AFUI.column();
    final groups = _sortIterable(context.p.screenTestsByGroup.keys);
    for(final group in groups) {
      final tests = context.p.screenTestsByGroup[group];
      _addGroup(context, rows, group, tests);
    }

    final leading = AFUI.standardBackButton(context.d);
    return AFPrototypeHomeScreen.buildPrototypeScaffold("Screen Prototypes", rows, leading: leading);
  }

  static Widget createSectionHeader(String title) {
    return Card(
      color: AFTheme.colorPrimary,
      child: Container(
        margin: EdgeInsets.all(8.0),
        child: Text(
          title,
          style: AFTheme.styleWhite
        )
      )
    );
  }

  void _addGroup(AFBuildContext<AFStoreConnectorDataUnused, AFPrototypeTestScreenParam> context, List<Widget> column, String group, List<AFScreenPrototypeTest> tests) {
    final title = StringBuffer(group);
    column.add(createSectionHeader(title.toString()));

    for(final test in tests) {
      column.add(createTestCard(context.d, test));
    }
  }

  static Widget createTestCard(AFDispatcher dispatcher, AFScreenPrototypeTest instance) {
    final titleText = instance.title ?? instance.id.code;
    final cols = AFUI.row();
    cols.add(Text(titleText));
    if(instance.isReusable) {
      cols.add(Container(
        margin: EdgeInsets.only(left: 8.0),
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          color: AFTheme.colorPrimary,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Text("Reusable", style: AFTheme.styleWhite)
      ));
    }

    final titleRow = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: cols
    );
    return Card(
      key: Key(instance.id.code),
      child: ListTile(
        title: titleRow,
        subtitle: Text(instance.id.code),
        dense: true,
        trailing: Icon(Icons.chevron_right),
        onTap: () {
          instance.startScreen(dispatcher);
        }
    ));
  }

}