import 'package:afib/id.dart';
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
class AFUIPrototypeDrawerRouteParam extends AFRouteParam {
  final AFDrawerPrototype test;
  final AFRouteParam? routeParam;

  AFUIPrototypeDrawerRouteParam({
    required this.test, 
    required this.routeParam
  }): super(id: AFUIScreenID.screenPrototypeDrawer);

  AFUIPrototypeDrawerRouteParam copyWith({
    AFDrawerPrototype? test,
    AFRouteParam? param
  }) {
    return AFUIPrototypeDrawerRouteParam(
      test: test ?? this.test,
      routeParam: param ?? this.routeParam
    );
  }
}

class AFUIPrototypeDrawerScreenSPI extends AFUIScreenSPI<AFUIDefaultStateView, AFUIPrototypeDrawerRouteParam> {
  AFUIPrototypeDrawerScreenSPI(AFBuildContext<AFUIDefaultStateView, AFUIPrototypeDrawerRouteParam> context, AFScreenID screenId, AFUIDefaultTheme theme): super(context, screenId, theme, );
  
  factory AFUIPrototypeDrawerScreenSPI.create(AFBuildContext<AFUIDefaultStateView, AFUIPrototypeDrawerRouteParam> context, AFUIDefaultTheme theme, AFScreenID screenId) {
    return AFUIPrototypeDrawerScreenSPI(context, screenId, theme,
    );
  }
}

/// A screen used internally in prototype mode to render screens and widgets with test data,
/// and display them in a list.
class AFUIPrototypeDrawerScreen extends AFUIConnectedScreen<AFUIPrototypeDrawerScreenSPI, AFUIDefaultStateView, AFUIPrototypeDrawerRouteParam>{

  static final config = AFUIDefaultScreenConfig<AFUIPrototypeDrawerScreenSPI, AFUIPrototypeDrawerRouteParam> (
    spiCreator: AFUIPrototypeDrawerScreenSPI.create,
  );

  AFUIPrototypeDrawerScreen(): super(screenId: AFUIScreenID.screenPrototypeDrawer, config: config);

  static AFNavigateAction navigatePush(AFDrawerPrototype test, {AFID? id}) {
    return AFNavigatePushAction(
      id: id,
      routeParam: AFUIPrototypeDrawerRouteParam(test: test, routeParam: AFRouteParamUnused.create(id: AFUIScreenID.screenPrototypeDrawer)),
    );
  }

  @override
  Widget buildWithSPI(AFUIPrototypeDrawerScreenSPI spi) {    
    /// Remember what screen we are on for testing purposes.  Maybe eventually try to do this in navigator observer.
    return _buildScreen(spi);
  }

  Widget _buildScreen(AFUIPrototypeDrawerScreenSPI spi) {
    final context = spi.context;
    final t = spi.t;
    final testStateSource = AFibF.g.storeInternalOnly?.state.private.testState;    

    if(testStateSource == null) {
      throw AFException("Missing test state");
    }
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
          spi.showDrawer(navigate: test.navigate);
        }
    ));
  }

  Widget _createScaffold(AFUIPrototypeDrawerScreenSPI spi) {
    final t = spi.t;
    final test = spi.context.p.test;
    final drawerBuilder = AFibF.g.screenMap.findBy(test.navigate.screenId);
    Widget? drawerWidget;
    if(drawerBuilder != null) {
      drawerWidget = drawerBuilder(spi.flutterContext);
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