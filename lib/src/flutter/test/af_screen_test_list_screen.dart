

import 'package:afib/afib_dart.dart';
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/utils/af_ui_id.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/test/af_screen_test_screen.dart';
import 'package:afib/src/flutter/utils/af_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';

/// Parameter uses to filter the tests/protoypes shown on the screen.
@immutable
class AFScreenTestListScreenParam extends AFRouteParam {
  final String filter;

  AFScreenTestListScreenParam({this.filter});

  AFScreenTestListScreenParam copyWith() {
    return AFScreenTestListScreenParam();
  }
}

/// Data used to render the screen
class AFScreenTestListScreenData extends AFStoreConnectorData1<AFScreenTests> {
  AFScreenTestListScreenData(AFScreenTests tests): 
    super(first: tests);
  
  AFScreenTests get tests { return first; }
}

/// A screen used internally in prototype mode to render screens and widgets with test data,
/// and display them in a list.
class AFScreenTestListScreen extends AFConnectedScreen<AFAppState, AFScreenTestListScreenData, AFScreenTestListScreenParam>{

  AFScreenTestListScreen(): super(AFUIID.screenPrototypeList);

  @override
  AFScreenTestListScreenData createData(AFAppState state) {
    AFScreenTests tests = AF.screenTests;
    return AFScreenTestListScreenData(tests);
  }

  @override
  Widget buildWithContext(AFBuildContext<AFScreenTestListScreenData, AFScreenTestListScreenParam> context) {
    return _buildList(context);
  }

  Widget _buildList(AFBuildContext<AFScreenTestListScreenData, AFScreenTestListScreenParam> context) {
    final column = AFUI.column();

    AFScreenTests tests = context.s.tests;
    tests.all.forEach( (test) {
      _addForWidget(context, column, test);
    });    

    return Scaffold(
      body: ListView(children: column)
    );    
  }

  void _addForWidget(AFBuildContext<AFScreenTestListScreenData, AFScreenTestListScreenParam> context, List<Widget> column, AFScreenTestGroup source) {
    StringBuffer title = StringBuffer(source.widget.runtimeType.toString());
    column.add(Card(
      color: AFTheme.primaryBackground,
      child: Container(
        margin: EdgeInsets.all(8.0),
        child: Text(
          title.toString()
        )
      )
    ));

    source.tests.forEach((instance) {
      column.add(_createCard(context, source, instance));
    });

  }

  Widget _createCard(AFBuildContext<AFScreenTestListScreenData, AFScreenTestListScreenParam> context, AFScreenTestGroup test, AFScreenPrototypeTest instance) {
    return Card(
      key: Key(instance.id.code),
      child: ListTile(
        title: Text(instance.id.code),
        subtitle: null,
        onTap: () {
          // either create or reset a test context for tracking and executing the test
          context.dispatch(AFScreenTestInstanceScreen.navigatePush(instance, wid: instance.id));
        })
    );
  }
}