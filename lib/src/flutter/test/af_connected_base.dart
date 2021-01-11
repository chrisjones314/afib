import 'package:afib/src/dart/redux/state/af_app_state.dart';
import 'package:afib/src/dart/redux/state/af_theme_state.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/theme/af_prototype_theme.dart';
import 'package:afib/src/flutter/utils/af_dispatcher.dart';
import 'package:afib/src/flutter/utils/af_state_view.dart';
import 'package:flutter/material.dart';

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


abstract class AFProtoConnectedScreen<TStateView extends AFStateView, TRouteParam extends AFRouteParam> extends AFConnectedScreen<AFAppStateArea, AFPrototypeTheme, AFProtoBuildContext<TStateView, TRouteParam>, TStateView, TRouteParam> {
  AFProtoConnectedScreen(AFScreenID screen): super(screen);

  AFProtoBuildContext<TStateView, TRouteParam> createContext(BuildContext context, AFDispatcher dispatcher, TStateView stateView, TRouteParam param, AFRouteParamWithChildren paramWithChildren, AFConceptualTheme theme, AFConnectedUIBase container) {
    return AFProtoBuildContext<TStateView, TRouteParam>(context, dispatcher, stateView, param, paramWithChildren, theme, container);
  }
}

abstract class AFProtoConnectedDrawer<TStateView extends AFStateView, TRouteParam extends AFRouteParam> extends AFConnectedDrawer<AFAppStateArea, AFPrototypeTheme, AFProtoBuildContext<TStateView, TRouteParam>, TStateView, TRouteParam> {

  AFProtoConnectedDrawer(
    AFScreenID screen,
  ): super(screen);

  AFProtoBuildContext<TStateView, TRouteParam> createContext(BuildContext context, AFDispatcher dispatcher, TStateView stateView, TRouteParam param, AFRouteParamWithChildren paramWithChildren, AFPrototypeTheme theme, AFConnectedUIBase container) {
    return AFProtoBuildContext<TStateView, TRouteParam>(context, dispatcher, stateView, param, paramWithChildren, theme, container);
  }
}
