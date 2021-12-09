import 'package:afib/afib_flutter.dart';
import 'package:afib/id.dart';
import 'package:afib/src/dart/redux/state/af_test_state.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/flutter/test/af_test_dispatchers.dart';
import 'package:afib/src/flutter/ui/af_prototype_base.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

/// Parameter uses to filter the tests shown on the screen.
@immutable
class AFPrototypeWidgetRouteParam extends AFRouteParam {
  final AFWidgetPrototype test;
  final AFRouteParam? routeParam;

  AFPrototypeWidgetRouteParam({
    required this.test, 
    required this.routeParam
  }): super(id: AFUIScreenID.screenPrototypeWidget);

  AFPrototypeWidgetRouteParam copyWith({
    AFWidgetPrototype? test,
    AFRouteParam? param
  }) {
    return AFPrototypeWidgetRouteParam(
      test: test ?? this.test,
      routeParam: param ?? this.routeParam
    );
  }
}

/// Data used to render the screen
class AFPrototypeWidgetStateView extends AFStateView2<AFTestState, AFThemeState> {
  AFPrototypeWidgetStateView(AFTestState testState, AFThemeState themes): 
    super(first: testState, second: themes);
  
  AFTestState? get testState { return first; }
  AFThemeState? get themeState { return second; }
}

/// A screen used internally in prototype mode to render screens and widgets with test data,
/// and display them in a list.
class AFPrototypeWidgetScreen extends AFUIConnectedScreen<AFPrototypeWidgetStateView, AFPrototypeWidgetRouteParam>{

  AFPrototypeWidgetScreen(): super(AFUIScreenID.screenPrototypeWidget);

  static AFNavigateAction navigatePush(AFWidgetPrototype test, {AFID? id}) {
    return AFNavigatePushAction(
      id: id,
      routeParam: AFPrototypeWidgetRouteParam(test: test, routeParam: AFRouteParamUnused.create(id: AFUIScreenID.screenPrototypeWidget)),
    );
  }

  @override
  AFPrototypeWidgetStateView createStateViewAF(AFState state, AFPrototypeWidgetRouteParam param, AFRouteSegmentChildren? children) {
    return AFPrototypeWidgetStateView(state.testState, state.public.themes);
  }

  @override
  AFPrototypeWidgetStateView createStateView(AFBuildStateViewContext<AFAppStateArea?, AFPrototypeWidgetRouteParam> context) {
    // this should never be called, because createDataAF supercedes it.
    throw UnimplementedError();
  }

  @override
  Widget buildWithContext(AFUIBuildContext<AFPrototypeWidgetStateView, AFPrototypeWidgetRouteParam> context) {    
    /// Remember what screen we are on for testing purposes.  Maybe eventually try to do this in navigator observer.
    return _buildScreen(context);
  }

  Widget _buildScreen(AFUIBuildContext<AFPrototypeWidgetStateView, AFPrototypeWidgetRouteParam> context) {
    final test = context.p.test;
    final testStateSource = context.s.testState;
    if(testStateSource == null) { throw AFException("Missing test state source"); }
    final testContext = testStateSource.findContext(test.id);
    final testState = testStateSource.findState(test.id);
    final testData = testState?.stateView ?? test.stateViews;
    final sourceWidget = test.render(this, AFUIWidgetID.widgetPrototypeTest);
    
    Widget resultWidget;
    if(test is AFConnectedWidgetPrototype && sourceWidget is AFConnectedWidget) {
      var paramChild = context.p.routeParam;
      if(paramChild is AFRouteParamUnused) {
        paramChild = test.routeParam;
      }
      if(paramChild == null) throw AFException("Missing route param in test");
      final dispatcher = AFWidgetScreenTestDispatcher(context: testContext, main: context.d, originalParam: context.p);

      final themeChild = sourceWidget.findFunctionalTheme(AFibF.g.storeInternalOnly!.state);
      final standard = AFStandardBuildContextData(
        screenId: this.primaryScreenId,
        context: context.c,
        dispatcher: dispatcher,
        container: this,
        themes: context.standard.themes,
      );

      final childContext = sourceWidget.createContext(standard, testData, paramChild, context.children, themeChild);
      resultWidget = sourceWidget.buildWithContext(childContext);
    } else {
      resultWidget = sourceWidget;
    }

    return _createScaffold(context, resultWidget);
  }

  Widget _createScaffold(AFUIBuildContext<AFPrototypeWidgetStateView, AFPrototypeWidgetRouteParam> context, Widget resultWidget) {
    final createWidget = context.p.test.createWidgetWrapperDelegate;
    if(createWidget != null) {
      return createWidget(context, resultWidget);
    }

    final t = context.t;

    final widgets = [resultWidget];
    return context.t.childScaffold(
      context: context,
      //key: _mainScaffoldKey,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            leading: t.childButtonStandardBack(context, screen: screenId),
            title: t.childText('Widget Test Screen',
              style: t.styleOnPrimary.headline6,
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(widgets)
          )
      ]),
    );

  }
}