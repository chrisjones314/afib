// @dart=2.9
import 'package:afib/src/dart/redux/state/af_app_state.dart';
import 'package:afib/src/dart/redux/state/af_theme_state.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/id.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/ui/theme/af_prototype_theme.dart';
import 'package:afib/src/flutter/utils/af_dispatcher.dart';
import 'package:afib/src/flutter/utils/af_state_view.dart';
import 'package:flutter/material.dart';

mixin AFUIConnectedUIMixin<TStateView extends AFStateView, TRouteParam extends AFRouteParam> {
  AFUIBuildContext<TStateView, TRouteParam> createContext(BuildContext context, AFDispatcher dispatcher, TStateView stateView, TRouteParam param, AFRouteParamWithChildren paramWithChildren, AFUITheme theme, AFConnectedUIBase container) {
    return AFUIBuildContext<TStateView, TRouteParam>(context, dispatcher, stateView, param, paramWithChildren, theme, container);
  }
}


class AFUIBuildContext<TStateView extends AFStateView, TRouteParam extends AFRouteParam> extends AFBuildContext<AFAppStateArea, TStateView, TRouteParam, AFUITheme> {
  AFUIBuildContext(
    BuildContext context, 
    AFDispatcher dispatcher, 
    AFStateView stateView,
    AFRouteParam routeParam,
    AFRouteParamWithChildren paramWithChildren, 
    AFFunctionalTheme theme,
    AFConnectedUIBase container
  ): super(context, dispatcher, stateView, routeParam, paramWithChildren, theme, container);
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
