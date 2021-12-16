import 'package:afib/afib_flutter.dart';
import 'package:afib/id.dart';
import 'package:afib/src/dart/redux/state/stateviews/afui_prototype_state_view.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/flutter/ui/afui_connected_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

/// Parameter uses to filter the tests shown on the screen.
@immutable
class AFUIPrototypeWidgetRouteParam extends AFRouteParam {
  final AFWidgetPrototype test;
  final AFRouteParam? routeParam;

  AFUIPrototypeWidgetRouteParam({
    required this.test, 
    required this.routeParam
  }): super(id: AFUIScreenID.screenPrototypeWidget);

  AFUIPrototypeWidgetRouteParam copyWith({
    AFWidgetPrototype? test,
    AFRouteParam? param
  }) {
    return AFUIPrototypeWidgetRouteParam(
      test: test ?? this.test,
      routeParam: param ?? this.routeParam
    );
  }
}

/// A screen used internally in prototype mode to render screens and widgets with test data,
/// and display them in a list.
class AFUIPrototypeWidgetScreen extends AFUIDefaultConnectedScreen<AFUIPrototypeWidgetRouteParam>{

  AFUIPrototypeWidgetScreen(): super(AFUIScreenID.screenPrototypeWidget);

  static AFNavigateAction navigatePush(AFWidgetPrototype test, {AFID? id}) {
    return AFNavigatePushAction(
      id: id,
      routeParam: AFUIPrototypeWidgetRouteParam(test: test, routeParam: AFRouteParamUnused.create(id: AFUIScreenID.screenPrototypeWidget)),
    );
  }

  @override
  Widget buildWithContext(AFUIBuildContext<AFUIPrototypeStateView, AFUIPrototypeWidgetRouteParam> context) {    
    /// Remember what screen we are on for testing purposes.  Maybe eventually try to do this in navigator observer.
    return _buildScreen(context);
  }

  Widget _buildScreen(AFUIBuildContext<AFUIPrototypeStateView, AFUIPrototypeWidgetRouteParam> context) {
    /*
    TODO: STATE VIEW REFACTOR FIX
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

      final themeChild = sourceWidget.findPrimaryTheme(AFibF.g.storeInternalOnly!.state);
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
    */
    return Text("TODO");
  }

  Widget _createScaffold(AFUIBuildContext<AFUIPrototypeStateView, AFUIPrototypeWidgetRouteParam> context, Widget resultWidget) {
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