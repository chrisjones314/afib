import 'package:afib/afib_dart.dart';
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/redux/state/af_test_state.dart';
import 'package:afib/src/dart/utils/af_ui_id.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/test/af_test_dispatchers.dart';
import 'package:afib/src/flutter/test/af_test.dart';
import 'package:afib/src/flutter/utils/af_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';

/// Parameter uses to filter the tests shown on the screen.
@immutable
class AFPrototypeWidgetRouteParam extends AFRouteParam {
  final AFWidgetPrototypeTest test;
  final AFRouteParam param;

  AFPrototypeWidgetRouteParam({this.test, this.param});

  AFPrototypeWidgetRouteParam copyWith({
    AFWidgetPrototypeTest test,
    AFRouteParam param
  }) {
    return AFPrototypeWidgetRouteParam(
      test: test ?? this.test,
      param: param ?? this.param
    );
  }
}

/// Data used to render the screen
class AFPrototypeWidgetData extends AFStoreConnectorData1<AFTestState> {
  AFPrototypeWidgetData(AFTestState testState): 
    super(first: testState);
  
  AFTestState get testState { return first; }
}

typedef AFCreateWidgetWrapperDelegate = Widget Function(AFBuildContext<AFPrototypeWidgetData, AFPrototypeWidgetRouteParam> context, Widget testWidget);

/// A screen used internally in prototype mode to render screens and widgets with test data,
/// and display them in a list.
class AFPrototypeWidgetScreen extends AFConnectedScreen<AFAppState, AFPrototypeWidgetData, AFPrototypeWidgetRouteParam>{

  AFPrototypeWidgetScreen(): super(AFUIID.screenPrototypeWidget);

  static AFNavigateAction navigatePush(AFWidgetPrototypeTest test, {AFID id}) {
    return AFNavigatePushAction(
      id: id,
      param: AFPrototypeWidgetRouteParam(test: test),
      screen: AFUIID.screenPrototypeWidget,
    );
  }

  @override
  AFPrototypeWidgetData createStateDataAF(AFState state) {
    return AFPrototypeWidgetData(state.testState);
  }

  @override
  AFPrototypeWidgetData createStateData(AFAppState state) {
    // this should never be called, because createDataAF supercedes it.
    throw UnimplementedError();
  }

  @override
  Widget buildWithContext(AFBuildContext<AFPrototypeWidgetData, AFPrototypeWidgetRouteParam> context) {    
    /// Remember what screen we are on for testing purposes.  Maybe eventually try to do this in navigator observer.
    AFTest.currentScreen = context.c;
    return _buildScreen(context);
  }

  Widget _buildScreen(AFBuildContext<AFPrototypeWidgetData, AFPrototypeWidgetRouteParam> context) {
    final test = context.p.test;
    final testContext = context.s.testState.findContext(test.id);
    final testState = context.s.testState.findState(test.id);
    final testData = testState?.data ?? test.data;
    final sourceWidget = test.createConnectedWidget(context.d, findParam, (dispatcher, param, { id }) {
      dispatcher.dispatch(AFNavigateSetParamAction(
        id: id,
        screen: this.screenId, 
        param: param)
      );
    });
    Widget resultWidget;
    if(test is AFConnectedWidgetPrototypeTest && sourceWidget is AFConnectedWidgetWithParam) {
      final paramChild = context.p.param ?? test.param;
      final dispatcher = AFWidgetScreenTestDispatcher(context: testContext, main: context.d, originalParam: context.p);
      final childContext = sourceWidget.createContext(context.c, dispatcher, testData, paramChild);
      resultWidget = sourceWidget.buildWithContext(childContext);
    } else {
      resultWidget = sourceWidget;
    }

    return _createScaffold(context, resultWidget);
  }

  Widget _createScaffold(AFBuildContext<AFPrototypeWidgetData, AFPrototypeWidgetRouteParam> context, Widget resultWidget) {
    if(context.p.test.createWidgetWrapperDelegate != null) {
      return context.p.test.createWidgetWrapperDelegate(context, resultWidget);
    }

    final widgets = [resultWidget];
    return Scaffold(
      //key: _mainScaffoldKey,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            title: Text('Widget Test Screen',
              style: TextStyle(color: AFTheme.primaryText)),
          ),
          SliverList(
            delegate: SliverChildListDelegate(widgets)
          )
      ]),
      endDrawer: context.createDebugDrawer()
    );

  }
}