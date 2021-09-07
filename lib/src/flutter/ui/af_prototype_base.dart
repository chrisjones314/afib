// @dart=2.9
import 'package:afib/src/dart/redux/state/af_app_state.dart';
import 'package:afib/src/dart/redux/state/af_theme_state.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/id.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/ui/theme/af_prototype_theme.dart';
import 'package:afib/src/flutter/utils/af_state_view.dart';

mixin AFUIConnectedUIMixin<TStateView extends AFStateView, TRouteParam extends AFRouteParam> {
  AFUIBuildContext<TStateView, TRouteParam> createContext(AFStandardBuildContextData standard, TStateView stateView, TRouteParam param, AFUITheme theme) {
    return AFUIBuildContext<TStateView, TRouteParam>(standard, stateView, param, theme);
  }
}


class AFUIBuildContext<TStateView extends AFStateView, TRouteParam extends AFRouteParam> extends AFBuildContext<AFAppStateArea, TStateView, TRouteParam, AFUITheme> {
  AFUIBuildContext(
    AFStandardBuildContextData standard, 
    AFStateView stateView,
    AFRouteParam routeParam,
    AFFunctionalTheme theme,
  ): super(standard, stateView, routeParam, theme);
}


abstract class AFUIConnectedScreen<TStateView extends AFStateView, TRouteParam extends AFRouteParam> extends AFConnectedScreen<AFAppStateArea, AFUITheme, AFUIBuildContext<TStateView, TRouteParam>, TStateView, TRouteParam> with AFUIConnectedUIMixin<TStateView, TRouteParam> {
  AFUIConnectedScreen(AFScreenID screen): super(screen, AFUIThemeID.conceptualUI);
}

abstract class AFProtoConnectedDrawer<TStateView extends AFStateView, TRouteParam extends AFRouteParam> extends AFConnectedDrawer<AFAppStateArea, AFUITheme, AFUIBuildContext<TStateView, TRouteParam>, TStateView, TRouteParam> with AFUIConnectedUIMixin<TStateView, TRouteParam> {
  AFProtoConnectedDrawer(
    AFScreenID screen,
  ): super(screen, AFUIThemeID.conceptualUI);
}

abstract class AFUIConnectedDialog<TStateView extends AFStateView, TRouteParam extends AFRouteParam> extends AFConnectedDialog<AFAppStateArea, AFUITheme, AFUIBuildContext<TStateView, TRouteParam>, TStateView, TRouteParam> with AFUIConnectedUIMixin<TStateView, TRouteParam> {
  AFUIConnectedDialog(AFScreenID screen): super(screen, AFUIThemeID.conceptualUI);
}
