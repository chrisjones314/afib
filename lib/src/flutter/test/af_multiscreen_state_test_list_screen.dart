

import 'package:afib/afib_dart.dart';
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/utils/af_ui_id.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/test/af_proto_home_screen.dart';
import 'package:afib/src/flutter/test/af_test_actions.dart';
import 'package:afib/src/flutter/test/af_test_dispatchers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';

/// Parameter uses to filter the tests/protoypes shown on the screen.
@immutable
class AFMultiScreenStateListScreenParam extends AFRouteParam {
  final String filter;

  AFMultiScreenStateListScreenParam({this.filter});

  AFMultiScreenStateListScreenParam copyWith() {
    return AFMultiScreenStateListScreenParam();
  }
}

/// Data used to render the screen
class AFMultiScreenStateListScreenData extends AFStoreConnectorData1<AFMultiScreenStateTests> {
  AFMultiScreenStateListScreenData(AFMultiScreenStateTests tests): 
    super(first: tests);
  
  AFMultiScreenStateTests get tests { return first; }
}

/// A screen used internally in prototype mode to render screens and widgets with test data,
/// and display them in a list.
class AFMultiScreenStateListScreen extends AFConnectedScreen<AFAppState, AFMultiScreenStateListScreenData, AFMultiScreenStateListScreenParam>{

  AFMultiScreenStateListScreen(): super(AFUIID.screenMultiScreenTestList);

  static AFNavigatePushAction navigateTo() {
    return AFNavigatePushAction(screen: AFUIID.screenMultiScreenTestList,
      param: AFMultiScreenStateListScreenParam(filter: ""));
  }

  @override
  AFMultiScreenStateListScreenData createData(AFAppState state) {
    AFMultiScreenStateTests tests = AFibF.multiScreenStateTests;
    return AFMultiScreenStateListScreenData(tests);
  }

  @override
  Widget buildWithContext(AFBuildContext<AFMultiScreenStateListScreenData, AFMultiScreenStateListScreenParam> context) {
    return _buildList(context);
  }

  Widget _buildList(AFBuildContext<AFMultiScreenStateListScreenData, AFMultiScreenStateListScreenParam> context) {
    final rows = AFUI.column();

    AFMultiScreenStateTests tests = context.s.tests;
    for(final test in tests.stateTests) {
      rows.add(_createCard(context, test));
    };    

    final leading = AFUI.standardBackButton(context.d);
    return AFPrototypeHomeScreen.buildPrototypeScaffold("Multi-Screen Prototypes", rows, leading: leading);
  }

  Widget _createCard(AFBuildContext<AFMultiScreenStateListScreenData, AFMultiScreenStateListScreenParam> context, AFMultiScreenStatePrototypeTest test) {
    final subtitleWidget = (test.subtitle == null) ? null : Text(test.subtitle);
    return Card(
      key: Key(test.id.code),
      child: ListTile(
        title: Text(test.id.code),
        subtitle: subtitleWidget,
        onTap: () {
          _startStatePrototype(context, test);
        })
    );
  }

  void _startStatePrototype(AFBuildContext<AFMultiScreenStateListScreenData, AFMultiScreenStateListScreenParam> context, AFMultiScreenStatePrototypeTest test) {

    // first, reset the state.
    context.dispatch(AFResetToInitialStateAction());
    context.dispatch(AFStartPrototypeScreenTestAction(test));

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