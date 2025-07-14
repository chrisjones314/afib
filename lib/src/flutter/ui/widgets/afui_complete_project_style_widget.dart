
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/ui/afui_connected_base.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/ui/stateviews/afui_default_state_view.dart';
import 'package:flutter/material.dart';

//--------------------------------------------------------------------------------------
class AFUICompleteProjectStyleWidgetSPI extends AFUIWidgetSPI<AFUIDefaultStateView, AFRouteParamUnused> {

  //--------------------------------------------------------------------------------------
  const AFUICompleteProjectStyleWidgetSPI(super.context, super.standard);
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
    super.screenIdOverride,
    super.widOverride,
    required this.projectStyle,
  }): super(
    uiConfig: config,
    launchParam: AFRouteParamUnused.unused,
  );

  @override
  Widget buildWithSPI(AFUICompleteProjectStyleWidgetSPI spi) {
    final t = spi.t;
    final rows = t.column();
    rows.add(t.childMargin(
      margin: t.margin.b.size5,
      child: t.childText(text: "Opps, project style not complete", style: t.styleOnCard.titleLarge)
    ));
    rows.add(Text("Run", style: t.styleOnCard.bodyMedium));
    rows.add(t.childMargin(
      margin: t.margin.v.standard,
      child: t.childText(text: "dart bin/${AFibD.config.appNamespace}_afib.dart integrate project-style $projectStyle", style: t.styleOnCard.bodyLarge)
    ));
    rows.add(t.childMargin(
      margin: t.margin.b.s5,
      child: Text("from the project root folder to complete setup.", style: t.styleOnCard.bodyMedium)
    ));

    return Card(child: 
      t.childMargin(
        margin: t.margin.standard,
        child: Column(children: rows)
      ));
  }
}
