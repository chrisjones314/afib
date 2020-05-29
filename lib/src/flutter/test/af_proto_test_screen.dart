
import 'package:afib/src/dart/redux/state/af_state.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

/// A screen that uses data from the store but not from the route.
abstract class AFProtoTestScreen extends StatelessWidget {
  final AFScreenTestContextWidgetTester testContext;
  
  //--------------------------------------------------------------------------------------
  AFProtoTestScreen(this.testContext);

  //--------------------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AFState, AFDispatcher>(
        converter: (store) => AFStoreDispatcher(store),
        distinct: true,
        ignoreChange: (AFState state) {
          return false;
        },
        onInit: (store) {
        },
        onDispose: (store) {
        },
        builder: (buildContext, dispatcher) {
          final widget = testContext.test.widget;
          final withContext = widget.createContext(buildContext, dispatcher, testContext.instance.data, testContext.instance.param);
          return widget.buildWithContext(withContext);
        }
    );
  }
}