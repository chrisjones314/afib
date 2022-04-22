
import 'package:afib/afui_id.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/ui/afui_connected_base.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/ui/stateviews/afui_default_state_view.dart';
import 'package:afib/src/flutter/ui/theme/afui_default_theme.dart';
import 'package:flutter/material.dart';

//--------------------------------------------------------------------------------------
class AFUIWelcomeWidgetSPI extends AFUIWidgetSPI<AFUIDefaultStateView, AFRouteParamUnused> {

  //--------------------------------------------------------------------------------------
  AFUIWelcomeWidgetSPI(AFBuildContext<AFUIDefaultStateView, AFRouteParamUnused> context, AFScreenID screenId, AFID wid, AFWidgetParamSource paramSource, AFUIDefaultTheme theme): super(context, screenId, wid, paramSource, theme);
  factory AFUIWelcomeWidgetSPI.create(AFBuildContext<AFUIDefaultStateView, AFRouteParamUnused> context, AFUIDefaultTheme theme, AFScreenID screenId, AFID wid, AFWidgetParamSource paramSource) {
    return AFUIWelcomeWidgetSPI(context, screenId, wid, paramSource, theme);
  }

}


@immutable
class AFUIWelcomeWidget extends AFUIConnectedWidget<AFUIWelcomeWidgetSPI, AFUIDefaultStateView, AFRouteParamUnused> {
  
  //--------------------------------------------------------------------------------------
  static final config = AFUIDefaultWidgetConfig<AFUIWelcomeWidgetSPI, AFRouteParamUnused> (
    spiCreator: AFUIWelcomeWidgetSPI.create,
  );

  //--------------------------------------------------------------------------------------
  AFUIWelcomeWidget({
    required AFScreenID screenId,
    AFWidgetParamSource paramSource = AFWidgetParamSource.child,
  }): super(
    uiConfig: config,
    screenId: screenId,
    wid: AFUIWidgetID.widgetWelcome,
    paramSource: paramSource,
  );

  @override
  Widget buildWithSPI(AFUIWelcomeWidgetSPI spi) {
    final t = spi.t;
    final rows = t.column();
    rows.add(t.childMargin(
      margin: t.margin.b.size5,
      child: t.childText("Welcome to AFib!", style: t.styleOnCard.bodyText1)
    ));
    rows.add(Text("See", style: t.styleOnCard.bodyText2));
    rows.add(t.childMargin(
      margin: t.margin.v.standard,
      child: t.childText("afibframework.io/start", style: t.styleOnCard.headline6)
    ));
    rows.add(t.childMargin(
      margin: t.margin.b.s5,
      child: Text("for tutorials and documentation.", style: t.styleOnCard.bodyText2)
    ));

    rows.add(Text("Try changing to AFEnvironment.prototype in", style: t.styleOnCard.bodyText2));
    rows.add(Text("in ${AFibD.config.appNamespace}_config.g.dart", style: t.styleOnCard.bodyText2));
    rows.add(Text("to use prototype mode.", style: t.styleOnCard.bodyText2));


    return Card(child: 
      t.childMargin(
        margin: t.margin.standard,
        child: Column(children: rows)
      ));
  }
}
