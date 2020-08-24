

import 'package:afib/afib_dart.dart';
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/utils/af_ui_id.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/test/af_prototype_home_screen.dart';
import 'package:afib/src/flutter/test/af_test_actions.dart';
import 'package:afib/src/flutter/test/af_prototype_single_screen_screen.dart';
import 'package:afib/src/flutter/utils/af_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';

/// Parameter uses to filter the tests/protoypes shown on the screen.
@immutable
class AFPrototypeListSingleScreenParam extends AFRouteParam {
  final String filter;

  AFPrototypeListSingleScreenParam({this.filter});

  AFPrototypeListSingleScreenParam copyWith() {
    return AFPrototypeListSingleScreenParam();
  }
}

/// Data used to render the screen
class AFPrototypeListSingleScreenData extends AFStoreConnectorData1<AFScreenTests> {
  AFPrototypeListSingleScreenData(AFScreenTests tests): 
    super(first: tests);
  
  AFScreenTests get tests { return first; }
}

/// A screen used internally in prototype mode to render screens and widgets with test data,
/// and display them in a list.
class AFPrototypeListSingleScreen extends AFConnectedScreen<AFAppState, AFPrototypeListSingleScreenData, AFPrototypeListSingleScreenParam>{

  AFPrototypeListSingleScreen(): super(AFUIID.screenPrototypeListSingleScreen);

  static AFNavigatePushAction navigateTo() {
    return AFNavigatePushAction(screen: AFUIID.screenPrototypeListSingleScreen,
      param: AFPrototypeListSingleScreenParam(filter: ""));
  }

  @override
  AFPrototypeListSingleScreenData createData(AFAppState state) {
    AFScreenTests tests = AFibF.screenTests;
    return AFPrototypeListSingleScreenData(tests);
  }

  @override
  Widget buildWithContext(AFBuildContext<AFPrototypeListSingleScreenData, AFPrototypeListSingleScreenParam> context) {
    return _buildList(context);
  }

  Widget _buildList(AFBuildContext<AFPrototypeListSingleScreenData, AFPrototypeListSingleScreenParam> context) {
    final column = AFUI.column();

    AFScreenTests tests = context.s.tests;
    for(final test in tests.all) { 
      _addForWidget(context, column, test);
    }    

    final leading = AFUI.standardBackButton(context.d);
    return AFPrototypeHomeScreen.buildPrototypeScaffold("Screen Prototypes", column, leading: leading);
  }

  void _addForWidget(AFBuildContext<AFPrototypeListSingleScreenData, AFPrototypeListSingleScreenParam> context, List<Widget> column, AFScreenTestGroup source) {
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

  Widget _createCard(AFBuildContext<AFPrototypeListSingleScreenData, AFPrototypeListSingleScreenParam> context, AFScreenTestGroup test, AFSingleScreenPrototypeTest instance) {
    final subtitleWidget = (instance.subtitle == null) ? null : Text(instance.subtitle);
    return Card(
      key: Key(instance.id.code),
      child: ListTile(
        title: Text(instance.id.code),
        subtitle: subtitleWidget,
        onTap: () {
          _startSingleScreenPrototype(context, instance);
        }
    ));
  }

  void _startSingleScreenPrototype(AFBuildContext<AFPrototypeListSingleScreenData, AFPrototypeListSingleScreenParam> context, AFSingleScreenPrototypeTest test) {
    context.dispatch(AFStartPrototypeScreenTestAction(test));
    context.dispatch(AFPrototypeSingleScreenScreen.navigatePush(test, id: test.id));
  }
}