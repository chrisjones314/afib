import 'package:afib/afib_uiid.dart';
import 'package:afib/src/dart/redux/state/models/afui_proto_state.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/ui/theme/afui_default_theme.dart';
import 'package:afib/src/flutter/utils/af_state_view.dart';


class AFUIFlexibleStateView extends AFFlexibleStateView  {
  
  AFUIFlexibleStateView({
    required super.models,
    required super.create,
  });  
}

class AFUIScreenSPI<TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFScreenStateProgrammingInterface<AFUIState, AFBuildContext<TStateView, TRouteParam>, AFUIDefaultTheme> {
  const AFUIScreenSPI(super.context, super.standard);
}

class AFUIDialogSPI<TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFDialogStateProgrammingInterface<AFUIState, AFBuildContext<TStateView, TRouteParam>, AFUIDefaultTheme> {
  const AFUIDialogSPI(super.context, super.standard);
}

class AFUIDrawerSPI<TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFDrawerStateProgrammingInterface<AFUIState, AFBuildContext<TStateView, TRouteParam>, AFUIDefaultTheme> {
  const AFUIDrawerSPI(super.context, super.standard);
}

// a default screen programming interface while we transition to this new model.
class AFUIWidgetSPI<TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFWidgetStateProgrammingInterface<AFUIState, AFBuildContext<TStateView, TRouteParam>, AFUIDefaultTheme> {
  const AFUIWidgetSPI(super.context, super.standard);
}


abstract class AFUIConnectedScreen<TSPI extends AFScreenStateProgrammingInterface, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFConnectedScreen<AFUIState, AFUIDefaultTheme, TStateView, TRouteParam, TSPI> {
  AFUIConnectedScreen({
    required super.config,
    required super.screenId,
    super.launchParam,
  });
}

abstract class AFUIConnectedDialog<TSPI extends AFDialogStateProgrammingInterface, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFConnectedDialog<AFUIState, AFUIDefaultTheme, TStateView, TRouteParam, TSPI>  {

  AFUIConnectedDialog({
    required super.config,
    required super.screenId,
  });
}

abstract class AFUIConnectedDrawer<TSPI extends AFScreenStateProgrammingInterface, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFConnectedDrawer<AFUIState, AFUIDefaultTheme, TStateView, TRouteParam, TSPI>  {
  AFUIConnectedDrawer({
    required super.config,
    required super.screenId,
  });
}

abstract class AFUIConnectedWidget<TSPI extends AFWidgetStateProgrammingInterface, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFConnectedWidget<AFUIState, AFUIDefaultTheme, TStateView, TRouteParam, TSPI> {
  AFUIConnectedWidget({
    required AFConnectedUIConfig<AFUIState, AFUIDefaultTheme, TStateView, TRouteParam, TSPI> uiConfig,
    super.screenIdOverride,
    super.widOverride,
    required super.launchParam,
  }): super(
    config: uiConfig,
  );
}


abstract class AFUIScreenConfig<TSPI extends AFScreenStateProgrammingInterface, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFScreenConfig<TSPI, AFUIState, AFUIDefaultTheme, TStateView, TRouteParam> {
    AFUIScreenConfig({
      required super.stateViewCreator,
      required super.spiCreator,
    }): super(
      themeId: AFUIThemeID.defaultTheme,
    );
}

abstract class AFUIDialogConfig<TSPI extends AFDialogStateProgrammingInterface, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFDialogConfig<TSPI, AFUIState, AFUIDefaultTheme, TStateView, TRouteParam> {

    AFUIDialogConfig({
      required super.stateViewCreator,
      required super.spiCreator,
      AFRouteLocation? route,
    }): super(
      themeId: AFUIThemeID.defaultTheme,
    );
}

abstract class AFUIDrawerConfig<TSPI extends AFDrawerStateProgrammingInterface, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFDrawerConfig<TSPI, AFUIState, AFUIDefaultTheme, TStateView, TRouteParam> {
    AFUIDrawerConfig({
      required super.stateViewCreator,
      required super.spiCreator,
      AFRouteLocation? route,
      super.createDefaultRouteParam,
    }): super(
      themeId: AFUIThemeID.defaultTheme,
    );
}

abstract class AFUIWidgetConfig<TSPI extends AFWidgetStateProgrammingInterface, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFWidgetConfig<TSPI, AFUIState, AFUIDefaultTheme, TStateView, TRouteParam> {
  AFUIWidgetConfig({
    required super.stateViewCreator,
    required super.spiCreator,
    AFRouteLocation? route,
  }): super(
    themeId: AFUIThemeID.defaultTheme,
    route: route ?? AFRouteLocation.screenHierarchy,
  );
}

