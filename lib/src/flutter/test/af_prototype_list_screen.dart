

import 'package:afib/afib_dart.dart';
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/utils/af_ui_id.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/test/af_test_dispatchers.dart';
import 'package:afib/src/flutter/test/af_simple_prototype_screen.dart';
import 'package:afib/src/flutter/utils/af_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';

/// Parameter uses to filter the tests/protoypes shown on the screen.
@immutable
class AFPrototypeListScreenParam extends AFRouteParam {
  final String filter;

  AFPrototypeListScreenParam({this.filter});

  AFPrototypeListScreenParam copyWith() {
    return AFPrototypeListScreenParam();
  }
}

/// Data used to render the screen
class APrototypeListScreenData extends AFStoreConnectorData1<AFScreenTests> {
  APrototypeListScreenData(AFScreenTests tests): 
    super(first: tests);
  
  AFScreenTests get tests { return first; }
}

/// A screen used internally in prototype mode to render screens and widgets with test data,
/// and display them in a list.
class AFPrototypeListScreen extends AFConnectedScreen<AFAppState, APrototypeListScreenData, AFPrototypeListScreenParam>{

  AFPrototypeListScreen(): super(AFUIID.screenPrototypeList);

  @override
  APrototypeListScreenData createData(AFAppState state) {
    AFScreenTests tests = AFibF.screenTests;
    return APrototypeListScreenData(tests);
  }

  @override
  Widget buildWithContext(AFBuildContext<APrototypeListScreenData, AFPrototypeListScreenParam> context) {
    return _buildList(context);
  }

  Widget _buildList(AFBuildContext<APrototypeListScreenData, AFPrototypeListScreenParam> context) {
    final column = AFUI.column();

    column.add(Card(
      color: AFTheme.mainTitleBackground,
      child: Container(
        margin: EdgeInsets.all(8.0),
        child: Text(
          "Afib Prototype Mode",
        )    
    )));

    AFScreenTests tests = context.s.tests;
    tests.all.forEach( (test) {
      _addForWidget(context, column, test);
    });    

    return Scaffold(
      body: ListView(children: column)
    );    
  }

  void _addForWidget(AFBuildContext<APrototypeListScreenData, AFPrototypeListScreenParam> context, List<Widget> column, AFScreenTestGroup source) {
    StringBuffer title = StringBuffer(source.screen.runtimeType.toString());
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

  Widget _createCard(AFBuildContext<APrototypeListScreenData, AFPrototypeListScreenParam> context, AFScreenTestGroup test, AFScreenPrototypeTest instance) {
    final subtitleWidget = (instance.subtitle == null) ? null : Text(instance.subtitle);
    return Card(
      key: Key(instance.id.code),
      child: ListTile(
        title: Text(instance.id.code),
        subtitle: subtitleWidget,
        onTap: () {
          if(instance is AFSimpleScreenPrototypeTest) {
            _startSimpleTest(context, instance);
          } else if(instance is AFStateScreenPrototypeTest) {
            _startStateTest(context, instance);
          }

        })
    );
  }

  void _startSimpleTest(AFBuildContext<APrototypeListScreenData, AFPrototypeListScreenParam> context, AFSimpleScreenPrototypeTest test) {
    context.dispatch(AFScreenPrototypeScreen.navigatePush(test, id: test.id));
  }

  void _startStateTest(AFBuildContext<APrototypeListScreenData, AFPrototypeListScreenParam> context, AFStateScreenPrototypeTest test) {

    // first, reset the state.
    context.dispatch(AFResetToInitialStateAction());

    // lookup the test.
    final testImpl = AFibF.stateTests.findById(test.stateTestId);
    
    // then, execute the desired state test to bring us to our desired state.
    final store = AFibF.testOnlyStore;
    final mainDispatcher = AFStoreDispatcher(store);    
    final stateDispatcher = AFStateScreenTestDispatcher(mainDispatcher);

    final stateTestContext = AFStateTestContext(testImpl, store, stateDispatcher, isTrueTestContext: false);
    testImpl.execute(stateTestContext);

    if(stateTestContext.errors.hasErrors) {
      // TODO: return.
    }

    // then, navigate into the desired path.
    for(final push in test.initialPath) {
      context.dispatch(push);
    }
  }
}