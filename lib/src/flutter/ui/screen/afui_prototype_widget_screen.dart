import 'package:afib/id.dart';
import 'package:afib/src/dart/redux/actions/af_route_actions.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:afib/src/flutter/test/af_test_dispatchers.dart';
import 'package:afib/src/flutter/ui/afui_connected_base.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/ui/stateviews/afui_default_state_view.dart';
import 'package:afib/src/flutter/ui/theme/afui_default_theme.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:flutter/material.dart';

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

class AFUIPrototypeWidgetScreenSPI extends AFUIScreenSPI<AFUIDefaultStateView, AFUIPrototypeWidgetRouteParam> {
  AFUIPrototypeWidgetScreenSPI(AFBuildContext<AFUIDefaultStateView, AFUIPrototypeWidgetRouteParam> context, AFScreenID screenId, AFUIDefaultTheme theme): super(context, screenId, theme, );
  
  factory AFUIPrototypeWidgetScreenSPI.create(AFBuildContext<AFUIDefaultStateView, AFUIPrototypeWidgetRouteParam> context, AFUIDefaultTheme theme, AFScreenID screenId) {
    return AFUIPrototypeWidgetScreenSPI(context, screenId, theme,
    );
  }
}

/// A screen used internally in prototype mode to render screens and widgets with test data,
/// and display them in a list.
class AFUIPrototypeWidgetScreen extends AFUIConnectedScreen<AFUIPrototypeWidgetScreenSPI, AFUIDefaultStateView, AFUIPrototypeWidgetRouteParam>{

  static final config = AFUIDefaultScreenConfig<AFUIPrototypeWidgetScreenSPI, AFUIPrototypeWidgetRouteParam> (
    spiCreator: AFUIPrototypeWidgetScreenSPI.create,
  );

  AFUIPrototypeWidgetScreen(): super(screenId: AFUIScreenID.screenPrototypeWidget, config: config);

  static AFNavigateAction navigatePush(AFWidgetPrototype test, {AFID? id}) {
    return AFNavigatePushAction(
      id: id,
      routeParam: AFUIPrototypeWidgetRouteParam(test: test, routeParam: AFRouteParamUnused.create(id: AFUIScreenID.screenPrototypeWidget)),
    );
  }

  @override
  Widget buildWithSPI(AFUIPrototypeWidgetScreenSPI spi) {    
    /// Remember what screen we are on for testing purposes.  Maybe eventually try to do this in navigator observer.
    return _buildScreen(spi);
  }

  Widget _buildScreen(AFUIPrototypeWidgetScreenSPI spi) {
    final context = spi.context;
    final test = context.p.test;
    final testStateSource = AFibF.g.storeInternalOnly?.state.private.testState;    

    if(testStateSource == null) {
      throw AFException("Missing test state");
    }

    final testContext = testStateSource.findContext(test.id);
    final testState = testStateSource.findState(test.id);
    final testModels = testState?.models ?? test.models;

    final sourceWidget = test.render(screenId, AFUIWidgetID.widgetPrototypeTest);
    Widget resultWidget;
    if(test is AFConnectedWidgetPrototype && sourceWidget is AFConnectedWidget) {
      var paramChild = context.p.routeParam;
      if(paramChild is AFRouteParamUnused) {
        paramChild = test.routeParam;
      }
      if(paramChild == null) throw AFException("Missing route param in test");
      final dispatcher = AFWidgetScreenTestDispatcher(context: testContext, main: context.d, originalParam: context.p);
      final config = sourceWidget.uiConfig;

      final standard = AFStandardBuildContextData(
        screenId: this.primaryScreenId,
        context: context.c,
        dispatcher: dispatcher,
        themes: context.standard.themes,
        config: config
      );

      final stateView = config.createStateView(testModels);

      final childContext = config.createContext(standard, stateView, paramChild, context.children);
      final childSpi = config.createSPI(spi.context.c, childContext, screenId,  AFUIWidgetID.widgetPrototypeTest, AFWidgetParamSource.child);
      resultWidget = sourceWidget.buildWithSPI(childSpi);
    } else {
      resultWidget = sourceWidget;
    }
    return _createScaffold(spi, resultWidget);
  }

  Widget _createScaffold(AFUIPrototypeWidgetScreenSPI spi, Widget resultWidget) {
    final context = spi.context;
    final createWidget = context.p.test.createWidgetWrapperDelegate;
    if(createWidget != null) {
      return createWidget(context, resultWidget);
    }

    final t = spi.t;

    final widgets = [resultWidget];
    return t.childScaffold(
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