import 'package:afib/afui_id.dart';
import 'package:afib/src/dart/redux/actions/af_route_actions.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:afib/src/flutter/ui/afui_connected_base.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/ui/stateviews/afui_default_state_view.dart';
import 'package:afib/src/flutter/ui/theme/afui_default_theme.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:flutter/material.dart';

/// Parameter uses to filter the tests shown on the screen.
@immutable
class AFUIPrototypeDrawerScreenRouteParam extends AFRouteParam {
  final AFDrawerPrototype test;
  final AFRouteParam? routeParam;

  AFUIPrototypeDrawerScreenRouteParam({
    required this.test, 
    required this.routeParam
  }): super(id: AFUIScreenID.screenPrototypeDrawer);

  AFUIPrototypeDrawerScreenRouteParam copyWith({
    AFDrawerPrototype? test,
    AFRouteParam? param
  }) {
    return AFUIPrototypeDrawerScreenRouteParam(
      test: test ?? this.test,
      routeParam: param ?? this.routeParam
    );
  }
}

class AFUIPrototypeDrawerScreenSPI extends AFUIScreenSPI<AFUIDefaultStateView, AFUIPrototypeDrawerScreenRouteParam> {
  AFUIPrototypeDrawerScreenSPI(AFBuildContext<AFUIDefaultStateView, AFUIPrototypeDrawerScreenRouteParam> context, AFScreenID screenId, AFUIDefaultTheme theme): super(context, screenId, theme, );
  
  factory AFUIPrototypeDrawerScreenSPI.create(AFBuildContext<AFUIDefaultStateView, AFUIPrototypeDrawerScreenRouteParam> context, AFUIDefaultTheme theme, AFScreenID screenId) {
    return AFUIPrototypeDrawerScreenSPI(context, screenId, theme,
    );
  }
}

/// A screen used internally in prototype mode to render screens and widgets with test data,
/// and display them in a list.
class AFUIPrototypeDrawerScreen extends AFUIConnectedScreen<AFUIPrototypeDrawerScreenSPI, AFUIDefaultStateView, AFUIPrototypeDrawerScreenRouteParam>{

  static final config = AFUIDefaultScreenConfig<AFUIPrototypeDrawerScreenSPI, AFUIPrototypeDrawerScreenRouteParam> (
    spiCreator: AFUIPrototypeDrawerScreenSPI.create,
  );

  AFUIPrototypeDrawerScreen(): super(screenId: AFUIScreenID.screenPrototypeDrawer, config: config);

  static AFNavigateAction navigatePush(AFDrawerPrototype test, {AFID? id}) {
    return AFNavigatePushAction(
      id: id,
      routeParam: AFUIPrototypeDrawerScreenRouteParam(test: test, routeParam: AFRouteParamUnused.create(id: AFUIScreenID.screenPrototypeDrawer)),
    );
  }

  @override
  Widget buildWithSPI(AFUIPrototypeDrawerScreenSPI spi) {    
    /// Remember what screen we are on for testing purposes.  Maybe eventually try to do this in navigator observer.
    return _buildScreen(spi);
  }

  Widget _buildScreen(AFUIPrototypeDrawerScreenSPI spi) {
    return _createScaffold(spi);
  }

  Widget _childShowButton(AFUIPrototypeDrawerScreenSPI spi) {
    final t = spi.t;
    final test = spi.context.p.test;
    //final sourceWidget = test.render(screenId, AFUIWidgetID.widgetPrototypeTest);
    return Center(
      child: t.childButtonPrimaryText(
        text: "Show Drawer",
        onPressed: () {
          spi.context.showDrawer(navigate: test.navigate);
        }
    ));
  }

  Widget _createScaffold(AFUIPrototypeDrawerScreenSPI spi) {
    final t = spi.t;
    final test = spi.context.p.test;
    final drawerBuilder = AFibF.g.screenMap.findBy(test.navigate.screenId);
    Widget? drawerWidget;
    final fc = spi.flutterContext;
    if(drawerBuilder != null && fc != null) {
      drawerWidget = drawerBuilder(fc);
    } 

    return t.childScaffold(
      spi: spi,
      appBar: AppBar(title: t.childText('Drawer Test Screen')),
      drawer: drawerWidget,
      body: AFBuilder<AFUIPrototypeDrawerScreenSPI>(
        spiParent: spi,
        config: config,
        builder: (spiUnder) {
          AFibF.g.testOnlyShowBuildContext = spiUnder.flutterContext;
          return _childShowButton(spiUnder);
        }
      )
    );
  }
}