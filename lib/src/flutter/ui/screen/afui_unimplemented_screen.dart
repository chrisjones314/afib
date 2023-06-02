
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/flutter/ui/afui_connected_base.dart';
import 'package:afib/src/flutter/ui/stateviews/afui_default_state_view.dart';
import 'package:flutter/material.dart';

class AFUIUnimplementedScreenRouteParam extends AFScreenRouteParam {
  final String message;

  AFUIUnimplementedScreenRouteParam({
    required this.message,
  }): super(screenId: AFUIScreenID.screenUnimplemented);
}


class AFUIUnimplementedScreenSPI extends AFUIScreenSPI<AFUIDefaultStateView, AFUIUnimplementedScreenRouteParam> {
  const AFUIUnimplementedScreenSPI(AFBuildContext<AFUIDefaultStateView, AFUIUnimplementedScreenRouteParam> context, AFStandardSPIData standard): super(context, standard, );
  
  factory AFUIUnimplementedScreenSPI.create(AFBuildContext<AFUIDefaultStateView, AFUIUnimplementedScreenRouteParam> context, AFStandardSPIData standard) {
    return AFUIUnimplementedScreenSPI(context, standard,
    );
  }

  String get message {
    return context.p.message;
  }
}

/// A screen used internally in prototype mode to render screens and widgets with test data,
/// and display them in a list.
class AFUIUnimplementedScreen extends AFUIConnectedScreen<AFUIUnimplementedScreenSPI, AFUIDefaultStateView, AFUIUnimplementedScreenRouteParam>{

  static final config =  AFUIDefaultScreenConfig<AFUIUnimplementedScreenSPI, AFUIUnimplementedScreenRouteParam> (
    spiCreator: AFUIUnimplementedScreenSPI.create,
  );

  AFUIUnimplementedScreen(): super(screenId: AFUIScreenID.screenUnimplemented, config: config);

  static AFNavigatePushAction navigatePush(String message) {
    return AFNavigatePushAction(launchParam: AFUIUnimplementedScreenRouteParam(message: message));
  }

  @override
  Widget buildWithSPI(AFUIUnimplementedScreenSPI spi) {
    return _buildHome(spi);
  }

  /// 
  Widget _buildHome(AFUIUnimplementedScreenSPI spi) {
    final t = spi.t;
    final rows = t.column();

    rows.add(t.childMargin(
      margin: t.margin.standard,
      child: t.childText(text: spi.message),
    ));

    
    final leading = t.childButtonStandardBack(spi, screen: screenId);
    final main = ListView(children: rows);
    return spi.t.buildPrototypeScaffold(spi, AFUITranslationID.afibUnimplemented, main, leading: leading);
  }


}