import 'package:afib/id.dart';
import 'package:afib/src/dart/redux/state/af_app_state.dart';
import 'package:afib/src/dart/redux/state/af_route_state.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/ui/theme/af_prototype_theme.dart';
import 'package:afib/src/flutter/utils/af_state_view.dart';

mixin AFUIConnectedUIMixin<TStateView extends AFStateView, TRouteParam extends AFRouteParam> {
  AFUIBuildContext<TStateView, TRouteParam> createContext(AFStandardBuildContextData standard, TStateView stateView, TRouteParam param, AFRouteSegmentChildren? children, AFUITheme theme) {
    return AFUIBuildContext<TStateView, TRouteParam>(standard, stateView, param, children, theme);
  }
}


class AFUIBuildContext<TStateView extends AFStateView, TRouteParam extends AFRouteParam> extends AFBuildContext<AFAppStateAreaUnused, TStateView, TRouteParam, AFUITheme> {
  AFUIBuildContext(
    AFStandardBuildContextData standard, 
    TStateView stateView,
    TRouteParam routeParam,
    AFRouteSegmentChildren? children,
    AFUITheme theme,
  ): super(standard, stateView, routeParam, children, theme);
}


abstract class AFUIConnectedScreen<TStateView extends AFStateView, TRouteParam extends AFRouteParam> extends AFConnectedScreen<AFAppStateAreaUnused, AFUITheme, AFUIBuildContext<TStateView, TRouteParam>, TStateView, TRouteParam> with AFUIConnectedUIMixin<TStateView, TRouteParam> {
  AFUIConnectedScreen(AFScreenID screen): super(screen, AFUIThemeID.conceptualUI);
}

abstract class AFProtoConnectedDrawer<TStateView extends AFStateView, TRouteParam extends AFRouteParam> extends AFConnectedDrawer<AFAppStateAreaUnused, AFUITheme, AFUIBuildContext<TStateView, TRouteParam>, TStateView, TRouteParam> with AFUIConnectedUIMixin<TStateView, TRouteParam> {
  AFProtoConnectedDrawer(
    AFScreenID screen,
  ): super(screen, AFUIThemeID.conceptualUI);
}

abstract class AFUIConnectedDialog<TStateView extends AFStateView, TRouteParam extends AFRouteParam> extends AFConnectedDialog<AFAppStateAreaUnused, AFUITheme, AFUIBuildContext<TStateView, TRouteParam>, TStateView, TRouteParam> with AFUIConnectedUIMixin<TStateView, TRouteParam> {
  AFUIConnectedDialog(AFScreenID screen): super(screen, AFUIThemeID.conceptualUI);
}
