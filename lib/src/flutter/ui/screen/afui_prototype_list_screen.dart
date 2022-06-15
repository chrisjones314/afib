import 'package:afib/afui_id.dart';
import 'package:afib/src/dart/redux/actions/af_route_actions.dart';
import 'package:afib/src/dart/redux/state/models/af_route_state.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:afib/src/flutter/ui/afui_connected_base.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/ui/stateviews/afui_default_state_view.dart';
import 'package:afib/src/flutter/ui/theme/afui_default_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Parameter uses to filter the tests/protoypes shown on the screen.
@immutable
class AFUIPrototypeTestScreenParam extends AFRouteParam {
  final String? filter;
  final dynamic title;
  final AFUIType activeUIType;
  final  List<AFScreenPrototype> allTests;

  AFUIPrototypeTestScreenParam({
    required this.allTests,
    required this.title,
    required this.activeUIType,
    this.filter
  }): super(id: AFUIScreenID.screenPrototypeListSingleScreen);


  factory AFUIPrototypeTestScreenParam.createFromList({
    required dynamic title,
    required List<AFScreenPrototype> tests
  }) {
    return AFUIPrototypeTestScreenParam(title: title, allTests: tests, activeUIType: AFUIType.screen);
  }

  AFUIPrototypeTestScreenParam copyWith({
    String? filter,
    String? title,
    Map<String, List<AFScreenPrototype>>? screenTestsByGroup,
    AFUIType? activeUIType
  }) {
    return AFUIPrototypeTestScreenParam(
      allTests: allTests,
      filter: filter ?? this.filter,
      title: title ?? this.title,
      activeUIType: activeUIType ?? this.activeUIType,
    );
  }
}


class AFUIPrototypeTestScreenSPI extends AFUIScreenSPI<AFUIDefaultStateView, AFUIPrototypeTestScreenParam> {
  AFUIPrototypeTestScreenSPI(AFBuildContext<AFUIDefaultStateView, AFUIPrototypeTestScreenParam> context, AFScreenID screenId, AFUIDefaultTheme theme): super(context, screenId, theme, );
  
  factory AFUIPrototypeTestScreenSPI.create(AFBuildContext<AFUIDefaultStateView, AFUIPrototypeTestScreenParam> context, AFUIDefaultTheme theme, AFScreenID screenId) {
    return AFUIPrototypeTestScreenSPI(context, screenId, theme,
    );
  }

  AFUIType get activeView {
    return context.p.activeUIType;
  }

  void onPressedView(AFUIType uiType) {
    final revised = context.p.copyWith(activeUIType: uiType);
    context.updateRouteParam(revised);
  }

  Map<AFID, List<AFScreenPrototype>> get activeTestGroups {
    final activeTests = context.p.allTests.where((t) => t.uiType == activeView);
    
    final result = <AFID, List<AFScreenPrototype>>{};
    for(final test in activeTests) {
      final nav = test.navigate;
      final screenId = nav.screenId;
      var list = result[screenId];
      if(list == null) {
        list = <AFScreenPrototype>[];
        result[screenId] = list;
      }
      list.add(test);
    }

    return result;
  }

}

/// A screen used internally in prototype mode to render screens and widgets with test data,
/// and display them in a list.
class AFUIPrototypeTestScreen extends AFUIConnectedScreen<AFUIPrototypeTestScreenSPI, AFUIDefaultStateView, AFUIPrototypeTestScreenParam>{
  static final config =  AFUIDefaultScreenConfig<AFUIPrototypeTestScreenSPI, AFUIPrototypeTestScreenParam> (
    spiCreator: AFUIPrototypeTestScreenSPI.create,
  );

  AFUIPrototypeTestScreen(): super(screenId: AFUIScreenID.screenPrototypeListSingleScreen, config: config);

  static AFNavigatePushAction navigatePush(List<AFScreenPrototype> tests, dynamic title) {
    return AFNavigatePushAction(
      routeParam: AFUIPrototypeTestScreenParam.createFromList(title: title, tests: tests));
  }

  @override
  Widget buildWithSPI(AFUIPrototypeTestScreenSPI spi) {
    final t = spi.t;
    final body = _buildBody(spi);
    final leading = t.childButtonStandardBack(spi, screen: screenId);
    return t.buildPrototypeScaffold(spi, spi.context.p.title, body, leading: leading);    
  }
  
  Widget _buildHeader(AFUIPrototypeTestScreenSPI spi) {
    final t = spi.t;
    final cols = t.row();
    
    cols.add(_childTopTab(spi, AFUIType.screen, "Scre"));
    cols.add(_childTopTab(spi, AFUIType.dialog, "Dial"));
    cols.add(_childTopTab(spi, AFUIType.bottomSheet, "Bot"));
    cols.add(_childTopTab(spi, AFUIType.drawer, "Dra"));
    cols.add(_childTopTab(spi, AFUIType.widget, "Wid"));

    return t.childMargin(
      margin: t.margin.smaller,
      child: t.childTopTabContainer(children: cols)
    );
  }

  Widget _childTopTab(AFUIPrototypeTestScreenSPI spi, AFUIType thisView, String title) {
    return spi.t.childTopTab(
      text: title,
      isSel: spi.activeView == thisView,
      onPressed: () => spi.onPressedView(thisView),
    );
  }


  Widget _buildBody(AFUIPrototypeTestScreenSPI spi) {
    final t = spi.t;
    final context = spi.context;

    final header = _buildHeader(spi);
    final rows = t.column();

    final groups = spi.activeTestGroups;

    final groupIds = groups.keys.toList();
    groupIds.sort((l, r) => l.codeId.compareTo(r.codeId));
    for(final groupId in groupIds) {
      final group = groups[groupId];
      if(group != null) {
        rows.add(_addGroup(spi, AFUIWidgetID.cardTestGroup.with1(groupId), groupId, group));
      }
    }

    final main = ListView(
      children: rows
    );

    return t.childTopBottomHostedControls(
      context.c, 
      main,
      topControls: header,
      topHeight: 60.0
    );
  }

  Widget _addGroup(AFUIPrototypeTestScreenSPI spi, AFWidgetID widGroup, AFID group, List<AFScreenPrototype> tests) {
    final t = spi.t;
    final context = spi.context;
    final rows = t.column();

    tests.sort((a, b) => a.id.codeId.compareTo(b.id.codeId));
    for(final test in tests) {
      rows.add(t.createTestListTile(spi, test));
    }

    return t.childCardHeader(context, widGroup, group.codeId, rows);
  }

}