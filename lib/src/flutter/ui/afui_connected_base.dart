import 'package:afib/id.dart';
import 'package:afib/src/dart/redux/actions/af_route_actions.dart';
import 'package:afib/src/dart/redux/state/models/afui_proto_state.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/dart/utils/af_typedefs_dart.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/ui/theme/afui_default_theme.dart';
import 'package:afib/src/flutter/utils/af_state_view.dart';
import 'package:afib/src/flutter/utils/af_typedefs_flutter.dart';


class AFUIFlexibleStateView extends AFFlexibleStateView  {
  
  AFUIFlexibleStateView({
    required Map<String, Object> models,
    required AFCreateStateViewDelegate create,
  }): super(models: models, create: create);  
}

class AFUIScreenSPI<TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFScreenStateProgrammingInterface<AFBuildContext<TStateView, TRouteParam>, AFUIDefaultTheme> {
  AFUIScreenSPI(AFBuildContext<TStateView, TRouteParam> context, AFScreenID screenId, AFUIDefaultTheme theme): super(context, screenId, theme);
}

class AFUIDialogSPI<TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFDialogStateProgrammingInterface<AFBuildContext<TStateView, TRouteParam>, AFUIDefaultTheme> {
  AFUIDialogSPI(AFBuildContext<TStateView, TRouteParam> context, AFScreenID screenId, AFUIDefaultTheme theme): super(context, screenId, theme);
}

class AFUIDrawerSPI<TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFDrawerStateProgrammingInterface<AFBuildContext<TStateView, TRouteParam>, AFUIDefaultTheme> {
  AFUIDrawerSPI(AFBuildContext<TStateView, TRouteParam> context, AFScreenID screenId, AFUIDefaultTheme theme): super(context, screenId, theme);
}

abstract class AFUIConnectedScreen<TSPI extends AFScreenStateProgrammingInterface, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFConnectedScreen<AFUIState, AFUIDefaultTheme, TStateView, TRouteParam, TSPI> {
  AFUIConnectedScreen({
    required AFConnectedUIConfig<AFUIState, AFUIDefaultTheme, TStateView, TRouteParam, TSPI>  config,
    required AFScreenID screenId,
    TRouteParam? launchParam,
  }): super(config: config, screenId: screenId, launchParam: launchParam);
}

abstract class AFUIConnectedDialog<TSPI extends AFDialogStateProgrammingInterface, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFConnectedDialog<AFUIState, AFUIDefaultTheme, TStateView, TRouteParam, TSPI>  {

  AFUIConnectedDialog({
    required AFConnectedUIConfig<AFUIState, AFUIDefaultTheme, TStateView, TRouteParam, TSPI> config,
    required AFScreenID screenId,
  }): super(config: config, screenId: screenId);
}

abstract class AFUIConnectedDrawer<TSPI extends AFScreenStateProgrammingInterface, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFConnectedDrawer<AFUIState, AFUIDefaultTheme, TStateView, TRouteParam, TSPI>  {
  AFUIConnectedDrawer({
    required AFConnectedUIConfig<AFUIState, AFUIDefaultTheme, TStateView, TRouteParam, TSPI> config,
    required AFScreenID screenId,
    required TRouteParam launchParam,
  }): super(config: config, screenId: screenId, launchParam: launchParam);
}

abstract class AFUIScreenConfig<TSPI extends AFScreenStateProgrammingInterface, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFScreenConfig<TSPI, AFUIState, AFUIDefaultTheme, TStateView, TRouteParam> {
    AFUIScreenConfig({
      required AFCreateStateViewDelegate<TStateView> stateViewCreator,
      required AFCreateSPIDelegate<TSPI, AFBuildContext<TStateView, TRouteParam>, AFUIDefaultTheme> spiCreator,
      AFNavigateRoute? route,
    }): super(
      themeId: AFUIThemeID.defaultTheme,
      stateViewCreator: stateViewCreator,
      spiCreator: spiCreator,
      route: route ?? AFNavigateRoute.routeHierarchy,
    );
}

abstract class AFUIDialogConfig<TSPI extends AFDialogStateProgrammingInterface, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFDialogConfig<TSPI, AFUIState, AFUIDefaultTheme, TStateView, TRouteParam> {

    AFUIDialogConfig({
      required AFCreateStateViewDelegate<TStateView> stateViewCreator,
      required AFCreateSPIDelegate<TSPI, AFBuildContext<TStateView, TRouteParam>, AFUIDefaultTheme> spiCreator,
      AFNavigateRoute? route,
    }): super(
      themeId: AFUIThemeID.defaultTheme,
      stateViewCreator: stateViewCreator,
      spiCreator: spiCreator,
    );
}

abstract class AFUIDrawerConfig<TSPI extends AFDrawerStateProgrammingInterface, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFDrawerConfig<TSPI, AFUIState, AFUIDefaultTheme, TStateView, TRouteParam> {
    AFUIDrawerConfig({
      required AFCreateStateViewDelegate<TStateView> stateViewCreator,
      required AFCreateSPIDelegate<TSPI, AFBuildContext<TStateView, TRouteParam>, AFUIDefaultTheme> spiCreator,
      AFNavigateRoute? route,
    }): super(
      themeId: AFUIThemeID.defaultTheme,
      stateViewCreator: stateViewCreator,
      spiCreator: spiCreator,
    );
}
