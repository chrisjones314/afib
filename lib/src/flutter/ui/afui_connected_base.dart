import 'package:afib/afib_uiid.dart';
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

class AFUIScreenSPI<TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFScreenStateProgrammingInterface<AFUIState, AFBuildContext<TStateView, TRouteParam>, AFUIDefaultTheme> {
  const AFUIScreenSPI(AFBuildContext<TStateView, TRouteParam> context, AFStandardSPIData standard): super(context, standard);
}

class AFUIDialogSPI<TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFDialogStateProgrammingInterface<AFUIState, AFBuildContext<TStateView, TRouteParam>, AFUIDefaultTheme> {
  const AFUIDialogSPI(AFBuildContext<TStateView, TRouteParam> context, AFStandardSPIData standard): super(context, standard);
}

class AFUIDrawerSPI<TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFDrawerStateProgrammingInterface<AFUIState, AFBuildContext<TStateView, TRouteParam>, AFUIDefaultTheme> {
  const AFUIDrawerSPI(AFBuildContext<TStateView, TRouteParam> context, AFStandardSPIData standard): super(context, standard);
}

// a default screen programming interface while we transition to this new model.
class AFUIWidgetSPI<TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFWidgetStateProgrammingInterface<AFUIState, AFBuildContext<TStateView, TRouteParam>, AFUIDefaultTheme> {
  const AFUIWidgetSPI(AFBuildContext<TStateView, TRouteParam> context, AFStandardSPIData standard): super(context, standard);
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
  }): super(config: config, screenId: screenId);
}

abstract class AFUIConnectedWidget<TSPI extends AFWidgetStateProgrammingInterface, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFConnectedWidget<AFUIState, AFUIDefaultTheme, TStateView, TRouteParam, TSPI> {
  AFUIConnectedWidget({
    required AFConnectedUIConfig<AFUIState, AFUIDefaultTheme, TStateView, TRouteParam, TSPI> uiConfig,
    AFScreenID? screenIdOverride,
    AFWidgetID? widOverride,
    required AFRouteParam launchParam,
  }): super(
    config: uiConfig,
    screenIdOverride: screenIdOverride,
    widOverride: widOverride,
    launchParam: launchParam,
  );
}


abstract class AFUIScreenConfig<TSPI extends AFScreenStateProgrammingInterface, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFScreenConfig<TSPI, AFUIState, AFUIDefaultTheme, TStateView, TRouteParam> {
    AFUIScreenConfig({
      required AFCreateStateViewDelegate<TStateView> stateViewCreator,
      required AFCreateSPIDelegate<TSPI, AFBuildContext<TStateView, TRouteParam>, AFUIDefaultTheme> spiCreator,
    }): super(
      themeId: AFUIThemeID.defaultTheme,
      stateViewCreator: stateViewCreator,
      spiCreator: spiCreator,
    );
}

abstract class AFUIDialogConfig<TSPI extends AFDialogStateProgrammingInterface, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFDialogConfig<TSPI, AFUIState, AFUIDefaultTheme, TStateView, TRouteParam> {

    AFUIDialogConfig({
      required AFCreateStateViewDelegate<TStateView> stateViewCreator,
      required AFCreateSPIDelegate<TSPI, AFBuildContext<TStateView, TRouteParam>, AFUIDefaultTheme> spiCreator,
      AFRouteLocation? route,
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
      AFRouteLocation? route,
      AFCreateDefaultRouteParamDelegate? createDefaultRouteParam,
    }): super(
      themeId: AFUIThemeID.defaultTheme,
      stateViewCreator: stateViewCreator,
      spiCreator: spiCreator,
      createDefaultRouteParam: createDefaultRouteParam,
    );
}

abstract class AFUIWidgetConfig<TSPI extends AFWidgetStateProgrammingInterface, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFWidgetConfig<TSPI, AFUIState, AFUIDefaultTheme, TStateView, TRouteParam> {
  AFUIWidgetConfig({
    required AFCreateStateViewDelegate<TStateView> stateViewCreator,
    required AFCreateSPIDelegate<TSPI, AFBuildContext<TStateView, TRouteParam>, AFUIDefaultTheme> spiCreator,
    AFRouteLocation? route,
  }): super(
    themeId: AFUIThemeID.defaultTheme,
    stateViewCreator: stateViewCreator,
    spiCreator: spiCreator,
    route: route ?? AFRouteLocation.screenHierarchy,
  );
}

