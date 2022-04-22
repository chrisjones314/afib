
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/flutter/ui/afui_connected_base.dart';
import 'package:afib/src/flutter/ui/stateviews/afui_default_state_view.dart';
import 'package:afib/src/flutter/ui/theme/afui_default_theme.dart';
import 'package:flutter/material.dart';

class AFUIUnimplementedScreenRouteParam extends AFRouteParam {
  final String message;

  AFUIUnimplementedScreenRouteParam({
    required this.message,
  }): super(id: AFUIScreenID.screenUnimplemented);
}


class AFUIUnimplementedScreenSPI extends AFUIScreenSPI<AFUIDefaultStateView, AFUIUnimplementedScreenRouteParam> {
  AFUIUnimplementedScreenSPI(AFBuildContext<AFUIDefaultStateView, AFUIUnimplementedScreenRouteParam> context, AFScreenID screenId, AFUIDefaultTheme theme): super(context, screenId, theme, );
  
  factory AFUIUnimplementedScreenSPI.create(AFBuildContext<AFUIDefaultStateView, AFUIUnimplementedScreenRouteParam> context, AFUIDefaultTheme theme, AFScreenID screenId) {
    return AFUIUnimplementedScreenSPI(context, screenId, theme,
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
    return AFNavigatePushAction(routeParam: AFUIUnimplementedScreenRouteParam(message: message));
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
      child: t.childText(spi.message),
    ));

    
    final leading = t.childButtonStandardBack(spi, screen: screenId);
    return spi.t.buildPrototypeScaffold(AFUITranslationID.afibUnimplemented, rows, leading: leading);
  }


}