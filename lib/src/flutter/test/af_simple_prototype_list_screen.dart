

import 'package:afib/afib_dart.dart';
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/utils/af_ui_id.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/test/af_proto_home_screen.dart';
import 'package:afib/src/flutter/test/af_test_actions.dart';
import 'package:afib/src/flutter/test/af_test_dispatchers.dart';
import 'package:afib/src/flutter/test/af_simple_prototype_screen.dart';
import 'package:afib/src/flutter/utils/af_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';

/// Parameter uses to filter the tests/protoypes shown on the screen.
@immutable
class AFSimplePrototypeListScreenParam extends AFRouteParam {
  final String filter;

  AFSimplePrototypeListScreenParam({this.filter});

  AFSimplePrototypeListScreenParam copyWith() {
    return AFSimplePrototypeListScreenParam();
  }
}

/// Data used to render the screen
class AFSimplePrototypeListScreenData extends AFStoreConnectorData1<AFScreenTests> {
  AFSimplePrototypeListScreenData(AFScreenTests tests): 
    super(first: tests);
  
  AFScreenTests get tests { return first; }
}

/// A screen used internally in prototype mode to render screens and widgets with test data,
/// and display them in a list.
class AFSimplePrototypeListScreen extends AFConnectedScreen<AFAppState, AFSimplePrototypeListScreenData, AFSimplePrototypeListScreenParam>{

  AFSimplePrototypeListScreen(): super(AFUIID.screenSimplePrototypeList);

  static AFNavigatePushAction navigateTo() {
    return AFNavigatePushAction(screen: AFUIID.screenSimplePrototypeList,
      param: AFSimplePrototypeListScreenParam(filter: ""));
  }

  @override
  AFSimplePrototypeListScreenData createData(AFAppState state) {
    AFScreenTests tests = AFibF.screenTests;
    return AFSimplePrototypeListScreenData(tests);
  }

  @override
  Widget buildWithContext(AFBuildContext<AFSimplePrototypeListScreenData, AFSimplePrototypeListScreenParam> context) {
    return _buildList(context);
  }

  Widget _buildList(AFBuildContext<AFSimplePrototypeListScreenData, AFSimplePrototypeListScreenParam> context) {
    final column = AFUI.column();

    AFScreenTests tests = context.s.tests;
    for(final test in tests.all) { 
      _addForWidget(context, column, test);
    }    

    final leading = AFUI.standardBackButton(context.d);
    return AFPrototypeHomeScreen.buildPrototypeScaffold("Screen Prototypes", column, leading: leading);
  }

  void _addForWidget(AFBuildContext<AFSimplePrototypeListScreenData, AFSimplePrototypeListScreenParam> context, List<Widget> column, AFScreenTestGroup source) {
    StringBuffer title = StringBuffer(source.screenId);
    column.add(Card(
      color: AFTheme.primaryBackground,
      child: Container(
        margin: EdgeInsets.all(8.0),
        child: Text(
          title.toString(),
          style: TextStyle(color: AFTheme.primaryText)
        )
      )
    ));


    source.allTests.forEach((instance) {
      column.add(_createCard(context, source, instance));
    });
  }

  Widget _createCard(AFBuildContext<AFSimplePrototypeListScreenData, AFSimplePrototypeListScreenParam> context, AFScreenTestGroup test, AFSimpleScreenPrototypeTest instance) {
    final subtitleWidget = (instance.subtitle == null) ? null : Text(instance.subtitle);
    return Card(
      key: Key(instance.id.code),
      child: ListTile(
        title: Text(instance.id.code),
        subtitle: subtitleWidget,
        onTap: () {
          _startSimplePrototype(context, instance);
        }
    ));
  }

  void _startSimplePrototype(AFBuildContext<AFSimplePrototypeListScreenData, AFSimplePrototypeListScreenParam> context, AFSimpleScreenPrototypeTest test) {
    context.dispatch(AFStartPrototypeScreenTestAction(test));
    context.dispatch(AFScreenPrototypeScreen.navigatePush(test, id: test.id));
  }
}