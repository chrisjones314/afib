import 'package:afib/afui_id.dart';
import 'package:afib/src/dart/redux/actions/af_route_actions.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:afib/src/flutter/ui/afui_connected_base.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/ui/stateviews/afui_default_state_view.dart';
import 'package:afib/src/flutter/ui/theme/afui_default_theme.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Parameter uses to filter the tests/protoypes shown on the screen.
@immutable
class AFUIStateTestListScreenParam extends AFRouteParam {
  final String? filter;
  final dynamic title;
  final AFWidgetID viewActive;
  final List<AFScreenPrototype> allTests;

  AFUIStateTestListScreenParam({
    required this.allTests,
    required this.title,
    required this.viewActive,
    this.filter
  }): super(id: AFUIScreenID.screenStateTestListScreen);


  factory AFUIStateTestListScreenParam.createFromList({
    required dynamic title,
    required List<AFScreenPrototype> tests
  }) {
    return AFUIStateTestListScreenParam(title: title, allTests: tests, viewActive: AFUIWidgetID.viewParent);
  }

  AFUIStateTestListScreenParam copyWith({
    String? filter,
    String? title,
    Map<String, List<AFScreenPrototype>>? screenTestsByGroup,
    AFWidgetID? viewActive
  }) {
    return AFUIStateTestListScreenParam(
      allTests: allTests,
      filter: filter ?? this.filter,
      title: title ?? this.title,
      viewActive: viewActive ?? this.viewActive,
    );
  }
}


class AFUIStateTestListScreenSPI extends AFUIScreenSPI<AFUIDefaultStateView, AFUIStateTestListScreenParam> {
  static const rootParentName = "root";
  AFUIStateTestListScreenSPI(AFBuildContext<AFUIDefaultStateView, AFUIStateTestListScreenParam> context, AFScreenID screenId, AFUIDefaultTheme theme): super(context, screenId, theme, );
  
  factory AFUIStateTestListScreenSPI.create(AFBuildContext<AFUIDefaultStateView, AFUIStateTestListScreenParam> context, AFUIDefaultTheme theme, AFScreenID screenId) {
    return AFUIStateTestListScreenSPI(context, screenId, theme,
    );
  }

  AFWidgetID get activeView {
    return context.p.viewActive;
  }

  void onPressedView(AFWidgetID view) {
    final revised = context.p.copyWith(viewActive: view);
    context.updateRouteParam(revised);
  }

  Map<String, List<AFScreenPrototype>> get activeTestGroups {
    final av = activeView;
    if(av == AFUIWidgetID.viewParent) {
      final result = _activeGroups;
      result.remove(rootParentName);
      return result;
    } else {
      final result = _activeGroups;
      result.removeWhere((key, value) => key != rootParentName);
      return result;
    }

  }

  Map<String, List<AFScreenPrototype>> get _activeGroups {

    // go through all the testss, and group them by their parent.
    final result = <String, List<AFScreenPrototype>>{};
    for(final test in context.p.allTests) {
      if(test is! AFWorkflowStatePrototype) {
        assert(false);
        continue;
      }      

      final stateTestId = test.stateTestId;
      // find the state test
      final stateTest = AFibF.g.stateTests.findById(stateTestId);
      if(stateTest == null) {
        continue;
      }

      final parentId = stateTest.idPredecessor;
      var parentName = rootParentName;
      if(parentId != null) {
        parentName = parentId.codeId;
      }
      var list = result[parentName];
      if(list == null) {
        list = <AFScreenPrototype>[];
        result[parentName] = list;
      }
      list.add(test);      
    }
    
    return result;

  }

}

/// A screen used internally in prototype mode to render screens and widgets with test data,
/// and display them in a list.
class AFUIStateTestListScreen extends AFUIConnectedScreen<AFUIStateTestListScreenSPI, AFUIDefaultStateView, AFUIStateTestListScreenParam>{
  static final config =  AFUIDefaultScreenConfig<AFUIStateTestListScreenSPI, AFUIStateTestListScreenParam> (
    spiCreator: AFUIStateTestListScreenSPI.create,
  );

  AFUIStateTestListScreen(): super(screenId: AFUIScreenID.screenStateTestListScreen, config: config);

  static AFNavigatePushAction navigatePush(List<AFScreenPrototype> tests, dynamic title) {
    return AFNavigatePushAction(
      param: AFUIStateTestListScreenParam.createFromList(title: title, tests: tests));
  }

  @override
  Widget buildWithSPI(AFUIStateTestListScreenSPI spi) {
    final t = spi.t;
    final body = _buildBody(spi);
    final leading = t.childButtonStandardBack(spi, screen: screenId);
    return t.buildPrototypeScaffold(spi, spi.context.p.title, body, leading: leading);    
  }
  
  Widget _buildHeader(AFUIStateTestListScreenSPI spi) {
    final t = spi.t;
    final cols = t.row();

    // root (no parents)
    // parents (some children)
    // leafs (no children)
    
    cols.add(_childTopTab(spi, AFUIWidgetID.viewParent, "By Parent"));
    cols.add(_childTopTab(spi, AFUIWidgetID.viewDepth, "Root"));

    return t.childMargin(
      margin: t.margin.smaller,
      child: t.childTopTabContainer(children: cols)
    );
  }

  Widget _childTopTab(AFUIStateTestListScreenSPI spi, AFWidgetID thisView, String title) {
    return spi.t.childTopTabText(
      text: title,
      isSel: spi.activeView == thisView,
      onPressed: () => spi.onPressedView(thisView),
    );
  }


  Widget _buildBody(AFUIStateTestListScreenSPI spi) {
    final t = spi.t;
    final context = spi.context;

    final header = _buildHeader(spi);
    final rows = t.column();

    final groups = spi.activeTestGroups;

    final groupIds = groups.keys.toList();
    groupIds.sort((l, r) => l.compareTo(r));
    final roots = groups[AFUIStateTestListScreenSPI.rootParentName];
    if(roots != null) {
      final groupId = AFUIStateTestListScreenSPI.rootParentName;
      rows.add(_addGroup(spi, AFUIWidgetID.cardTestGroup.with1(groupId), groupId, roots));
    }

    for(final groupId in groupIds) {
      final group = groups[groupId];
      if(group != null && groupId != AFUIStateTestListScreenSPI.rootParentName) {
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

  Widget _addGroup(AFUIStateTestListScreenSPI spi, AFWidgetID widGroup, String group, List<AFScreenPrototype> tests) {
    final t = spi.t;
    final context = spi.context;
    final rows = t.column();

    tests.sort((a, b) => a.id.codeId.compareTo(b.id.codeId));
    for(final test in tests) {
      rows.add(t.createTestListTile(spi, test));
    }

    return t.childCardHeader(context, widGroup, group, rows);
  }

}