import 'package:afib/src/dart/redux/state/af_app_state.dart';
import 'package:afib/src/dart/redux/state/af_theme_state.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/ui/theme/af_prototype_theme.dart';
import 'package:afib/src/flutter/utils/af_dispatcher.dart';
import 'package:afib/src/flutter/utils/af_state_view.dart';
import 'package:flutter/material.dart';

mixin AFProtoConnectedUIMixin<TStateView extends AFStateView, TRouteParam extends AFRouteParam> {
  AFProtoBuildContext<TStateView, TRouteParam> createContext(BuildContext context, AFDispatcher dispatcher, TStateView stateView, TRouteParam param, AFRouteParamWithChildren paramWithChildren, AFPrototypeTheme theme, AFConnectedUIBase container) {
    return AFProtoBuildContext<TStateView, TRouteParam>(context, dispatcher, stateView, param, paramWithChildren, theme, container);
  }
}


class AFProtoBuildContext<TStateView extends AFStateView, TRouteParam extends AFRouteParam> extends AFBuildContext<TStateView, TRouteParam, AFPrototypeTheme> {
  AFProtoBuildContext(
    BuildContext context, 
    AFDispatcher dispatcher, 
    AFStateView stateView,
    AFRouteParam routeParam,
    AFRouteParamWithChildren paramWithChildren, 
    AFConceptualTheme theme,
    AFConnectedUIBase container
  ): super(context, dispatcher, stateView, routeParam, paramWithChildren, theme, container);
}


abstract class AFProtoConnectedScreen<TStateView extends AFStateView, TRouteParam extends AFRouteParam> extends AFConnectedScreen<AFAppStateArea, AFPrototypeTheme, AFProtoBuildContext<TStateView, TRouteParam>, TStateView, TRouteParam> with AFProtoConnectedUIMixin<TStateView, TRouteParam> {
  AFProtoConnectedScreen(AFScreenID screen): super(screen);
}

abstract class AFProtoConnectedDrawer<TStateView extends AFStateView, TRouteParam extends AFRouteParam> extends AFConnectedDrawer<AFAppStateArea, AFPrototypeTheme, AFProtoBuildContext<TStateView, TRouteParam>, TStateView, TRouteParam> with AFProtoConnectedUIMixin<TStateView, TRouteParam> {
  AFProtoConnectedDrawer(
    AFScreenID screen,
  ): super(screen);
}

abstract class AFProtoConnectedDialog<TStateView extends AFStateView, TRouteParam extends AFRouteParam> extends AFConnectedDialog<AFAppStateArea, AFPrototypeTheme, AFProtoBuildContext<TStateView, TRouteParam>, TStateView, TRouteParam> with AFProtoConnectedUIMixin<TStateView, TRouteParam> {
  AFProtoConnectedDialog(AFScreenID screen): super(screen);
}
