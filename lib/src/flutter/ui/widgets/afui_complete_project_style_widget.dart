
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/ui/afui_connected_base.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/ui/stateviews/afui_default_state_view.dart';
import 'package:flutter/material.dart';

//--------------------------------------------------------------------------------------
class AFUICompleteProjectStyleWidgetSPI extends AFUIWidgetSPI<AFUIDefaultStateView, AFRouteParamUnused> {

  //--------------------------------------------------------------------------------------
  AFUICompleteProjectStyleWidgetSPI(AFBuildContext<AFUIDefaultStateView, AFRouteParamUnused> context, AFStandardSPIData standard): super(context, standard);
  factory AFUICompleteProjectStyleWidgetSPI.create(AFBuildContext<AFUIDefaultStateView, AFRouteParamUnused> context, AFStandardSPIData standard) {
    return AFUICompleteProjectStyleWidgetSPI(context, standard);
  }

}


@immutable
class AFUICompleteProjectStyleWidget extends AFUIConnectedWidget<AFUICompleteProjectStyleWidgetSPI, AFUIDefaultStateView, AFRouteParamUnused> {
  final String projectStyle;

  //--------------------------------------------------------------------------------------
  static final config = AFUIDefaultWidgetConfig<AFUICompleteProjectStyleWidgetSPI, AFRouteParamUnused> (
    spiCreator: AFUICompleteProjectStyleWidgetSPI.create,
  );

  //--------------------------------------------------------------------------------------
  AFUICompleteProjectStyleWidget({
    AFScreenID? screenIdOverride,
    AFWidgetID? widOverride,
    required this.projectStyle,
  }): super(
    uiConfig: config,
    screenIdOverride: screenIdOverride, 
    widOverride: widOverride,
    launchParam: AFRouteParamUnused.unused,
  );

  @override
  Widget buildWithSPI(AFUICompleteProjectStyleWidgetSPI spi) {
    final t = spi.t;
    final rows = t.column();
    rows.add(t.childMargin(
      margin: t.margin.b.size5,
      child: t.childText("Opps, project style not complete", style: t.styleOnCard.headline6)
    ));
    rows.add(Text("Run", style: t.styleOnCard.bodyText2));
    rows.add(t.childMargin(
      margin: t.margin.v.standard,
      child: t.childText("dart bin/${AFibD.config.appNamespace}_afib.dart integrate project-style $projectStyle", style: t.styleOnCard.bodyText1)
    ));
    rows.add(t.childMargin(
      margin: t.margin.b.s5,
      child: Text("from the project root folder to complete setup.", style: t.styleOnCard.bodyText2)
    ));

    return Card(child: 
      t.childMargin(
        margin: t.margin.standard,
        child: Column(children: rows)
      ));
  }
}
