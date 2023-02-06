
import 'package:afib/src/dart/command/af_command_enums.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/ui/afui_connected_base.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/ui/stateviews/afui_default_state_view.dart';
import 'package:flutter/material.dart';

//--------------------------------------------------------------------------------------
class AFUIWelcomeWidgetSPI extends AFUIWidgetSPI<AFUIDefaultStateView, AFRouteParamUnused> {

  //--------------------------------------------------------------------------------------
  AFUIWelcomeWidgetSPI(AFBuildContext<AFUIDefaultStateView, AFRouteParamUnused> context, AFStandardSPIData standard): super(context, standard);
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
    AFScreenID? screenIdOverride,
    AFWidgetID? widOverride,
    this.roundBottom = false,
  }): super(
    uiConfig: config,
    screenIdOverride: screenIdOverride, 
    widOverride: widOverride,
    launchParam: AFRouteParamUnused.unused,
  );

  Widget buildWithSPI(AFUIWelcomeWidgetSPI spi) {
    return _buildAlphaWarningCard(spi);
  }


  Widget _buildAlphaWarningCard(AFUIWelcomeWidgetSPI spi) {
    final t = spi.t;
    final rows = t.column();
    rows.add(t.childText("AFib is alpha software.  Please report bugs on github.", textColor: t.colorOnAlert));
    final borderRadius = roundBottom ? t.borderRadius.standard : t.borderRadius.t.standard;

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
    AFScreenID? screenIdOverride,
    AFWidgetID? widOverride,
  }): super(
    uiConfig: config,
    screenIdOverride: screenIdOverride, 
    widOverride: widOverride,
    launchParam: AFRouteParamUnused.unused,
  );


  Widget _buildWelcomeCard(AFUIWelcomeWidgetSPI spi) {
    final t = spi.t;
    final rowsCentered = t.column();
    rowsCentered.add(t.childMargin(
      margin: t.margin.b.size5,
      child: t.childText("Welcome to AFib!", style: t.styleOnCard.bodyText1)
    ));
    rowsCentered.add(Text("See", style: t.styleOnCard.bodyText2));
    rowsCentered.add(t.childMargin(
      margin: t.margin.v.standard,
      child: t.childText("afibframework.io", style: t.styleOnCard.headline6)
    ));
    rowsCentered.add(t.childMargin(
      margin: t.margin.b.s5,
      child: Text("for tutorials and documentation.", style: t.styleOnCard.bodyText2)
    ));

    rowsCentered.add(t.childText("Try changing to ", style: t.styleOnCard.bodyText2));
    rowsCentered.add(t.childMarginStandard(child: t.childText("AFEnvironment.prototype", style: t.styleOnCard.bodyText1)));
    rowsCentered.add(t.childText("in", style: t.styleOnCard.bodyText2));
    rowsCentered.add(t.childMarginStandard(child: t.childText("${AFibD.config.appNamespace}_config.g.dart", style: t.styleOnCard.bodyText1)));
    
    rowsCentered.add(t.childText("to use prototype mode.", style: t.styleOnCard.bodyText2));

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
