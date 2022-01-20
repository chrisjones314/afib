import 'package:afib/id.dart';
import 'package:afib/src/dart/redux/state/models/af_route_state.dart';
import 'package:afib/src/dart/redux/state/models/afui_proto_state.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/dart/utils/af_typedefs_dart.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/ui/theme/af_prototype_theme.dart';
import 'package:afib/src/flutter/utils/af_state_view.dart';
import 'package:afib/src/flutter/utils/af_typedefs_flutter.dart';


class AFUIFlexibleStateView extends AFFlexibleStateView  {
  
  AFUIFlexibleStateView({
    required Map<String, Object> models,
    required AFCreateStateViewDelegate create,
  }): super(models: models, create: create);  
}

mixin AFUICreateContextMixin<TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> {
  AFUIBuildContext<TStateView, TRouteParam> createContext(AFStandardBuildContextData standard, TStateView stateView, TRouteParam param, AFRouteSegmentChildren? children, AFUITheme theme) {
    return AFUIBuildContext<TStateView, TRouteParam>(standard, stateView, param, children, theme);
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

class AFUIDefaultSPI<TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFStateProgrammingInterface<AFUIBuildContext<TStateView, TRouteParam>> {
  AFUIDefaultSPI(AFUIBuildContext<TStateView, TRouteParam> context, AFConnectedUIBase screen): super(context, screen);
}

abstract class AFUIConnectedScreen<TSPI extends AFStateProgrammingInterface, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFConnectedScreen<AFUIPrototypeState, AFUITheme, AFUIBuildContext<TStateView, TRouteParam>, TStateView, TRouteParam, TSPI> with AFUICreateContextMixin<TStateView, TRouteParam> {
  AFUIConnectedScreen(AFScreenID screen, AFCreateStateViewDelegate<TStateView> creator, AFCreateSPIDelegate<TSPI, AFUIBuildContext<TStateView, TRouteParam>> spiCreator): super(screen, AFUIThemeID.conceptualUI, creator, spiCreator);
}

abstract class AFUIConnectedDrawer<TSPI extends AFStateProgrammingInterface, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFConnectedDrawer<AFUIPrototypeState, AFUITheme, AFUIBuildContext<TStateView, TRouteParam>, TStateView, TRouteParam, TSPI> with AFUICreateContextMixin<TStateView, TRouteParam> {
  AFUIConnectedDrawer(
    AFScreenID screen,
    AFCreateStateViewDelegate<TStateView> creator,
    AFCreateSPIDelegate<TSPI, AFUIBuildContext<TStateView, TRouteParam>> spiCreator
  ): super(screen, AFUIThemeID.conceptualUI, creator, spiCreator);
}


abstract class AFUIConnectedDialog<TSPI extends AFStateProgrammingInterface, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFConnectedDialog<AFUIPrototypeState, AFUITheme, AFUIBuildContext<TStateView, TRouteParam>, TStateView, TRouteParam, TSPI> with AFUICreateContextMixin<TStateView, TRouteParam> {
  AFUIConnectedDialog(AFScreenID screen, AFCreateStateViewDelegate<TStateView> creator, AFCreateSPIDelegate<TSPI, AFUIBuildContext<TStateView, TRouteParam>> spiCreator): super(screen, AFUIThemeID.conceptualUI, creator, spiCreator);
}
