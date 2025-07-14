
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/ui/afui_connected_base.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/ui/stateviews/afui_default_state_view.dart';
import 'package:flutter/material.dart';

//--------------------------------------------------------------------------------------
class AFUIWelcomeWidgetSPI extends AFUIWidgetSPI<AFUIDefaultStateView, AFRouteParamUnused> {

  //--------------------------------------------------------------------------------------
  const AFUIWelcomeWidgetSPI(super.context, super.standard);
  factory AFUIWelcomeWidgetSPI.create(AFBuildContext<AFUIDefaultStateView, AFRouteParamUnused> context, AFStandardSPIData standard) {
    return AFUIWelcomeWidgetSPI(context, standard);
  }

}

class AFUIAlphaWarningWidget extends AFUIConnectedWidget<AFUIWelcomeWidgetSPI, AFUIDefaultStateView, AFRouteParamUnused> {

  static final config = AFUIDefaultWidgetConfig<AFUIWelcomeWidgetSPI, AFRouteParamUnused> (
    spiCreator: AFUIWelcomeWidgetSPI.create,
  );

  final bool roundBottom;


  AFUIAlphaWarningWidget({
    super.screenIdOverride,
    super.widOverride,
    this.roundBottom = false,
  }): super(
    uiConfig: config,
    launchParam: AFRouteParamUnused.unused,
  );

  @override
  Widget buildWithSPI(AFUIWelcomeWidgetSPI spi) {
    return _buildAlphaWarningCard(spi);
  }


  Widget _buildAlphaWarningCard(AFUIWelcomeWidgetSPI spi) {
    final t = spi.t;
    final rows = t.column();
    rows.add(t.childText(text: "AFib is alpha software.  Please report bugs on github.", textColor: t.colorOnAlert));
    final borderRadius = roundBottom ? t.borderRadius.standard : t.borderRadius.t.standard;

    // ignore: avoid_unnecessary_containers
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: t.colorAlert
      ),
      child: t.childMarginStandard(
        child: Column(children: rows)
      )
    );        
  }

}

@immutable
class AFUIWelcomeWidget extends AFUIConnectedWidget<AFUIWelcomeWidgetSPI, AFUIDefaultStateView, AFRouteParamUnused> {
  
  static final config = AFUIDefaultWidgetConfig<AFUIWelcomeWidgetSPI, AFRouteParamUnused> (
    spiCreator: AFUIWelcomeWidgetSPI.create,
  );

  AFUIWelcomeWidget({
    super.screenIdOverride,
    super.widOverride,
  }): super(
    uiConfig: config,
    launchParam: AFRouteParamUnused.unused,
  );


  Widget _buildWelcomeCard(AFUIWelcomeWidgetSPI spi) {
    final t = spi.t;
    final rowsCentered = t.column();
    rowsCentered.add(t.childMargin(
      margin: t.margin.b.size5,
      child: t.childText(text: "Welcome to AFib!", style: t.styleOnCard.bodyLarge)
    ));
    rowsCentered.add(Text("See", style: t.styleOnCard.bodyMedium));
    rowsCentered.add(t.childMargin(
      margin: t.margin.v.standard,
      child: t.childText(text: "afibframework.io", style: t.styleOnCard.titleLarge)
    ));
    rowsCentered.add(t.childMargin(
      margin: t.margin.b.s5,
      child: Text("for tutorials and documentation.", style: t.styleOnCard.bodyMedium)
    ));

    rowsCentered.add(t.childText(text: "Try changing to ", style: t.styleOnCard.bodyMedium));
    rowsCentered.add(t.childMarginStandard(child: t.childText(text: "AFEnvironment.prototype", style: t.styleOnCard.bodyLarge)));
    rowsCentered.add(t.childText(text: "in", style: t.styleOnCard.bodyMedium));
    rowsCentered.add(t.childMarginStandard(child: t.childText(text: "${AFibD.config.appNamespace}_config.g.dart", style: t.styleOnCard.bodyLarge)));
    
    rowsCentered.add(t.childText(text: "to use prototype mode.", style: t.styleOnCard.bodyMedium));

    final rows = t.column();
    rows.add(AFUIAlphaWarningWidget());
    rows.add(t.childMargin(
      margin: t.margin.standard,
      child: Column(
        children: rowsCentered
      )
    ));

    return Card(
      child:  t.childMargin(
        margin: t.margin.none,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: rows
        )
      )
    );
  }

  @override
  Widget buildWithSPI(AFUIWelcomeWidgetSPI spi) {
    final t = spi.t;
    final rows = t.column();
    rows.add(_buildWelcomeCard(spi));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows
    );
  }
}
