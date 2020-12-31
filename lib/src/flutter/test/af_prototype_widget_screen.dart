import 'package:afib/afib_dart.dart';
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/redux/state/af_test_state.dart';
import 'package:afib/src/dart/utils/af_ui_id.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/test/af_test_dispatchers.dart';
import 'package:afib/src/flutter/test/af_test.dart';
import 'package:afib/src/flutter/theme/af_prototype_theme.dart';
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
class AFPrototypeWidgetData extends AFStateView2<AFTestState, AFThemeState> {
  AFPrototypeWidgetData(AFTestState testState, AFThemeState themes): 
    super(first: testState, second: themes);
  
  AFTestState get testState { return first; }
  AFThemeState get themeState { return second; }
}

/// A screen used internally in prototype mode to render screens and widgets with test data,
/// and display them in a list.
class AFPrototypeWidgetScreen extends AFConnectedScreen<AFAppStateArea, AFPrototypeWidgetData, AFPrototypeWidgetRouteParam, AFPrototypeTheme>{

  AFPrototypeWidgetScreen(): super(AFUIScreenID.screenPrototypeWidget);

  static AFNavigateAction navigatePush(AFWidgetPrototypeTest test, {AFID id}) {
    return AFNavigatePushAction(
      id: id,
      param: AFPrototypeWidgetRouteParam(test: test),
      screen: AFUIScreenID.screenPrototypeWidget,
    );
  }

  @override
  AFPrototypeWidgetData createStateViewAF(AFState state) {
    return AFPrototypeWidgetData(state.testState, state.public.themes);
  }

  @override
  AFPrototypeWidgetData createStateView(AFAppStateArea state) {
    // this should never be called, because createDataAF supercedes it.
    throw UnimplementedError();
  }

  @override
  Widget buildWithContext(AFBuildContext<AFPrototypeWidgetData, AFPrototypeWidgetRouteParam, AFPrototypeTheme> context) {    
    /// Remember what screen we are on for testing purposes.  Maybe eventually try to do this in navigator observer.
    AFTest.currentScreen = context.c;
    return _buildScreen(context);
  }

  Widget _buildScreen(AFBuildContext<AFPrototypeWidgetData, AFPrototypeWidgetRouteParam, AFPrototypeTheme> context) {
    final test = context.p.test;
    final testContext = context.s.testState.findContext(test.id);
    final testState = context.s.testState.findState(test.id);
    final testData = testState?.stateView ?? test.data;
    final sourceWidget = test.createConnectedWidget(context.d, findParam, (dispatcher, param, { id }) {
      dispatcher.dispatch(AFNavigateSetParamAction(
        id: id,
        screen: this.screenId, 
        param: param,
        route: AFNavigateRoute.routeHierarchy)
      );
    });
    Widget resultWidget;
    if(test is AFConnectedWidgetPrototypeTest && sourceWidget is AFConnectedWidgetWithParam) {
      final paramChild = context.p.param ?? test.param;
      final dispatcher = AFWidgetScreenTestDispatcher(context: testContext, main: context.d, originalParam: context.p);

      final themeChild = sourceWidget.findTheme(context.s.themeState);
      final childContext = sourceWidget.createContext(context.c, dispatcher, testData, paramChild, null, themeChild);
      resultWidget = sourceWidget.buildWithContext(childContext);
    } else {
      resultWidget = sourceWidget;
    }

    return _createScaffold(context, resultWidget);
  }

  Widget _createScaffold(AFBuildContext<AFPrototypeWidgetData, AFPrototypeWidgetRouteParam, AFPrototypeTheme> context, Widget resultWidget) {
    if(context.p.test.createWidgetWrapperDelegate != null) {
      return context.p.test.createWidgetWrapperDelegate(context, resultWidget);
    }

    final t = context.t;

    final widgets = [resultWidget];
    return createScaffold(
      context: context,
      //key: _mainScaffoldKey,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            leading: t.childStandardBackButton(context),
            title: t.childText('Widget Test Screen',
              style: t.styleOnPrimary.headline4,
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(widgets)
          )
      ]),
    );

  }
}