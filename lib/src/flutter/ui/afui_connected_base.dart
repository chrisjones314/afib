import 'package:afib/id.dart';
import 'package:afib/src/dart/redux/state/af_state.dart';
import 'package:afib/src/dart/redux/state/models/af_route_state.dart';
import 'package:afib/src/dart/redux/state/models/afui_proto_state.dart';
import 'package:afib/src/dart/redux/state/stateviews/afui_prototype_state_view.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/dart/utils/af_typedefs_dart.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/ui/theme/af_prototype_theme.dart';
import 'package:afib/src/flutter/utils/af_state_view.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';

mixin AFUIConnectedUIMixin<TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> {
  AFUIBuildContext<TStateView, TRouteParam> createContext(AFStandardBuildContextData standard, TStateView stateView, TRouteParam param, AFRouteSegmentChildren? children, AFUITheme theme) {
    return AFUIBuildContext<TStateView, TRouteParam>(standard, stateView, param, children, theme);
  }
}

mixin AFUIDefaultStateViewMixin<TRouteParam extends AFRouteParam> {


  //--------------------------------------------------------------------------------------
  AFUIStateView<AFUIPrototypeStateView> createStateViewAF(AFState state, TRouteParam param, AFRouteSegmentChildren? withChildren) {
    final tests = AFibF.g.screenTests;
    return AFUIStateView<AFUIPrototypeStateView>(
      models: [
        tests
      ]);
  }

  //--------------------------------------------------------------------------------------
  AFUIStateView<AFUIPrototypeStateView> createStateView(AFBuildStateViewContext<AFUIPrototypeState, TRouteParam> context) {
    throw UnimplementedError();
  }

}

class AFUIBuildContext<TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFBuildContext<TStateView, TStateView, TRouteParam, AFUITheme> {
  AFUIBuildContext(
    AFStandardBuildContextData standard, 
    TStateView stateView,
    TRouteParam routeParam,
    AFRouteSegmentChildren? children,
    AFUITheme theme,
  ): super(standard, stateView, routeParam, children, theme);
}



abstract class AFUIDefaultConnectedScreen<TRouteParam extends AFRouteParam> extends AFConnectedScreen<AFUIPrototypeState, AFUITheme, AFUIBuildContext<AFUIPrototypeStateView, TRouteParam>, AFUIPrototypeStateView, TRouteParam> with AFUIConnectedUIMixin<AFUIPrototypeStateView, TRouteParam>, AFUIDefaultStateViewMixin<TRouteParam> {
  AFUIDefaultConnectedScreen(AFScreenID screen): super(screen, AFUIThemeID.conceptualUI, AFUIPrototypeStateView.creator);
}

abstract class AFUIConnectedScreen<TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFConnectedScreen<TStateView, AFUITheme, AFUIBuildContext<TStateView, TRouteParam>, TStateView, TRouteParam> with AFUIConnectedUIMixin<TStateView, TRouteParam> {
  AFUIConnectedScreen(AFScreenID screen, AFCreateStateViewDelegate<TStateView> creator): super(screen, AFUIThemeID.conceptualUI, creator);
}

abstract class AFUIConnectedDrawer<TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFConnectedDrawer<AFUIPrototypeState, AFUITheme, AFUIBuildContext<TStateView, TRouteParam>, TStateView, TRouteParam> with AFUIConnectedUIMixin<TStateView, TRouteParam> {
  AFUIConnectedDrawer(
    AFScreenID screen,
    AFCreateStateViewDelegate<TStateView> creator
  ): super(screen, AFUIThemeID.conceptualUI, creator);
}

abstract class AFUIDefaultConnectedDialog<TRouteParam extends AFRouteParam> extends AFConnectedDialog<AFUIPrototypeState, AFUITheme, AFUIBuildContext<AFUIPrototypeStateView, TRouteParam>, AFUIPrototypeStateView, TRouteParam> with AFUIConnectedUIMixin<AFUIPrototypeStateView, TRouteParam>, AFUIDefaultStateViewMixin<TRouteParam> {
  AFUIDefaultConnectedDialog(AFScreenID screen): super(screen, AFUIThemeID.conceptualUI, AFUIPrototypeStateView.creator);
}

abstract class AFUIConnectedDialog<TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFConnectedDialog<AFUIPrototypeStateView, AFUITheme, AFUIBuildContext<TStateView, TRouteParam>, TStateView, TRouteParam> with AFUIConnectedUIMixin<TStateView, TRouteParam> {
  AFUIConnectedDialog(AFScreenID screen, AFCreateStateViewDelegate<TStateView> creator): super(screen, AFUIThemeID.conceptualUI, creator);
}
