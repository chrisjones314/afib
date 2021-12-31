import 'package:afib/id.dart';
import 'package:afib/src/dart/redux/actions/af_route_actions.dart';
import 'package:afib/src/dart/redux/state/stateviews/afui_prototype_state_view.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:afib/src/flutter/ui/afui_connected_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Parameter uses to filter the tests/protoypes shown on the screen.
@immutable
class AFUIPrototypeTestScreenParam extends AFRouteParam {
  static const ungroupedGroup = "ungrouped";
  final String? filter;
  final dynamic title;

  final Map<String, List<AFScreenPrototype>> screenTestsByGroup;

  AFUIPrototypeTestScreenParam({
    required this.screenTestsByGroup,
    required this.title,
    this.filter
  }): super(id: AFUIScreenID.screenPrototypeListSingleScreen);


  factory AFUIPrototypeTestScreenParam.createFromList({
    required dynamic title,
    required List<AFScreenPrototype> tests
  }) {
    final groups = <String, List<AFScreenPrototype>>{};
    for(final test in tests) {
      var group = test.id.effectiveGroup;
      if(group == null) {
       group = ungroupedGroup; 
      }
      var tests = groups[group];      
      if(tests == null) {
        tests = <AFScreenPrototype>[];
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

    return AFUIPrototypeTestScreenParam(title: title, screenTestsByGroup: groups);
  }

  AFUIPrototypeTestScreenParam copyWith({
    String? filter,
    String? title,
    Map<String, List<AFScreenPrototype>>? screenTestsByGroup
  }) {
    return AFUIPrototypeTestScreenParam(
      screenTestsByGroup: screenTestsByGroup ?? this.screenTestsByGroup,
      filter: filter ?? this.filter,
      title: title ?? this.title
    );
  }
}

/// A screen used internally in prototype mode to render screens and widgets with test data,
/// and display them in a list.
class AFUIPrototypeTestScreen extends AFUIDefaultConnectedScreen<AFUIPrototypeTestScreenParam>{

  AFUIPrototypeTestScreen(): super(AFUIScreenID.screenPrototypeListSingleScreen);

  static AFNavigatePushAction navigatePush(List<AFScreenPrototype> tests, dynamic title) {
    return AFNavigatePushAction(
      routeParam: AFUIPrototypeTestScreenParam.createFromList(title: title, tests: tests));
  }

  @override
  Widget buildWithContext(AFUIBuildContext<AFUIPrototypeStateView, AFUIPrototypeTestScreenParam> context) {
    return _buildList(context);
  }

  List<String> _sortIterable(Iterable<String> items) {
    final result = List<String>.of(items);
    result.sort();
    return result;
  }

  Widget _buildList(AFUIBuildContext<AFUIPrototypeStateView, AFUIPrototypeTestScreenParam> context) {
    final t = context.t;
    final rows = t.column();
    final groups = _sortIterable(context.p.screenTestsByGroup.keys);
    for(final group in groups) {
      final tests = context.p.screenTestsByGroup[group];
      assert(tests != null);
      if(tests != null) {
        rows.add(_addGroup(context, AFUIWidgetID.cardTestGroup.with1(group), group, tests));
      }
    }

    final leading = t.childButtonStandardBack(context, screen: screenId);
    return context.t.buildPrototypeScaffold(context.p.title, rows, leading: leading);
  }

  Widget _addGroup(AFUIBuildContext<AFUIPrototypeStateView, AFUIPrototypeTestScreenParam> context, AFWidgetID widGroup, String group, List<AFScreenPrototype> tests) {
    final t = context.t;
    final rows = t.column();
    for(final test in tests) {
      rows.add(t.createTestListTile(context.d, test));
    }

    return t.childCardHeader(context, widGroup, group, rows);
  }

}