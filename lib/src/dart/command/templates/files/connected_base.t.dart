
import 'package:afib/src/dart/command/af_source_template.dart';

class AFConnectedBaseT extends AFSourceTemplate {

  final String template = '''
import 'package:afib/afib_flutter.dart';
import 'package:[!af_package_name]/[!af_app_namespace]_id.dart';
import 'package:[!af_package_path]/state/[!af_app_namespace]_state.dart';
import 'package:[!af_package_path]/ui/themes/[!af_app_namespace]_default_theme.dart';

// a default screen programming interface while we transition to this new model.
class [!af_app_namespace(upper)]ScreenSPI<TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFScreenStateProgrammingInterface<[!af_app_namespace(upper)]State, AFBuildContext<TStateView, TRouteParam>, [!af_app_namespace(upper)]DefaultTheme> {
  [!af_app_namespace(upper)]ScreenSPI(AFBuildContext<TStateView, TRouteParam> context, AFScreenID screenId, [!af_app_namespace(upper)]DefaultTheme theme): super(context, screenId, theme);
}

class [!af_app_namespace(upper)]DialogSPI<TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFDialogStateProgrammingInterface<[!af_app_namespace(upper)]State, AFBuildContext<TStateView, TRouteParam>, [!af_app_namespace(upper)]DefaultTheme> {
  [!af_app_namespace(upper)]DialogSPI(AFBuildContext<TStateView, TRouteParam> context, AFScreenID screenId, [!af_app_namespace(upper)]DefaultTheme theme): super(context, screenId, theme);
}

class [!af_app_namespace(upper)]DrawerSPI<TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFDrawerStateProgrammingInterface<[!af_app_namespace(upper)]State, AFBuildContext<TStateView, TRouteParam>, [!af_app_namespace(upper)]DefaultTheme> {
  [!af_app_namespace(upper)]DrawerSPI(AFBuildContext<TStateView, TRouteParam> context, AFScreenID screenId, [!af_app_namespace(upper)]DefaultTheme theme): super(context, screenId, theme);
}

class [!af_app_namespace(upper)]BottomSheetSPI<TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFBottomSheetStateProgrammingInterface<[!af_app_namespace(upper)]State, AFBuildContext<TStateView, TRouteParam>, [!af_app_namespace(upper)]DefaultTheme> {
  [!af_app_namespace(upper)]BottomSheetSPI(AFBuildContext<TStateView, TRouteParam> context, AFScreenID screenId, [!af_app_namespace(upper)]DefaultTheme theme): super(context, screenId, theme);
}

// a default screen programming interface while we transition to this new model.
class [!af_app_namespace(upper)]WidgetSPI<TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFWidgetStateProgrammingInterface<[!af_app_namespace(upper)]State, AFBuildContext<TStateView, TRouteParam>, [!af_app_namespace(upper)]DefaultTheme> {
  [!af_app_namespace(upper)]WidgetSPI(AFBuildContext<TStateView, TRouteParam> context, AFScreenID screenId, AFID wid, AFWidgetParamSource paramSource, [!af_app_namespace(upper)]DefaultTheme theme): super(context, screenId, wid, paramSource, theme);
}

class [!af_app_namespace(upper)]FlexibleStateView extends AFFlexibleStateView  {
  [!af_app_namespace(upper)]FlexibleStateView({
    required Map<String, Object> models,
    required AFCreateStateViewDelegate create,
  }): super(models: models, create: create);
}

abstract class [!af_app_namespace(upper)]ConnectedScreen<TSPI extends AFScreenStateProgrammingInterface, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFConnectedScreen<[!af_app_namespace(upper)]State, [!af_app_namespace(upper)]DefaultTheme, TStateView, TRouteParam, TSPI> {
  [!af_app_namespace(upper)]ConnectedScreen({
    required AFConnectedUIConfig<[!af_app_namespace(upper)]State, [!af_app_namespace(upper)]DefaultTheme, TStateView, TRouteParam, TSPI>  uiConfig,
    required AFScreenID screenId,
    TRouteParam? launchParam,
  }): super(config: uiConfig, screenId: screenId, launchParam: launchParam);
}

abstract class [!af_app_namespace(upper)]ConnectedDialog<TSPI extends AFDialogStateProgrammingInterface, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFConnectedDialog<[!af_app_namespace(upper)]State, [!af_app_namespace(upper)]DefaultTheme, TStateView, TRouteParam, TSPI>  {

  [!af_app_namespace(upper)]ConnectedDialog({
    required AFConnectedUIConfig<[!af_app_namespace(upper)]State, [!af_app_namespace(upper)]DefaultTheme, TStateView, TRouteParam, TSPI> uiConfig,
    required AFScreenID screenId,
  }): super(config: uiConfig, screenId: screenId);
}

abstract class [!af_app_namespace(upper)]ConnectedDrawer<TSPI extends AFScreenStateProgrammingInterface, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFConnectedDrawer<[!af_app_namespace(upper)]State, [!af_app_namespace(upper)]DefaultTheme, TStateView, TRouteParam, TSPI>  {
  [!af_app_namespace(upper)]ConnectedDrawer({
    required AFConnectedUIConfig<[!af_app_namespace(upper)]State, [!af_app_namespace(upper)]DefaultTheme, TStateView, TRouteParam, TSPI> uiConfig,
    required AFScreenID screenId,
    required TRouteParam launchParam,
  }): super(config: uiConfig, screenId: screenId, launchParam: launchParam);
}

abstract class [!af_app_namespace(upper)]ConnectedBottomSheet<TSPI extends AFBottomSheetStateProgrammingInterface, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFConnectedBottomSheet<[!af_app_namespace(upper)]State, [!af_app_namespace(upper)]DefaultTheme, TStateView, TRouteParam, TSPI> {
  [!af_app_namespace(upper)]ConnectedBottomSheet({
    required AFConnectedUIConfig<[!af_app_namespace(upper)]State, [!af_app_namespace(upper)]DefaultTheme, TStateView, TRouteParam, TSPI> uiConfig,
    required AFScreenID screenId,
  }): super(config: uiConfig, screenId: screenId);
}


abstract class [!af_app_namespace(upper)]ConnectedWidget<TSPI extends AFWidgetStateProgrammingInterface, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFConnectedWidget<[!af_app_namespace(upper)]State, [!af_app_namespace(upper)]DefaultTheme, TStateView, TRouteParam, TSPI> {
  [!af_app_namespace(upper)]ConnectedWidget({
    required AFConnectedUIConfig<[!af_app_namespace(upper)]State, [!af_app_namespace(upper)]DefaultTheme, TStateView, TRouteParam, TSPI> uiConfig,
    required AFScreenID screenId,
    required AFWidgetID wid,
    TRouteParam? launchParam,
    AFWidgetParamSource paramSource = AFWidgetParamSource.child,
  }): super(
    uiConfig: uiConfig,
    screenId: screenId,
    wid: wid,
    paramSource: paramSource,
    launchParam: launchParam,
  );
}

abstract class [!af_app_namespace(upper)]ScreenConfig<TSPI extends AFScreenStateProgrammingInterface, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFScreenConfig<TSPI, [!af_app_namespace(upper)]State, [!af_app_namespace(upper)]DefaultTheme, TStateView, TRouteParam> {
    [!af_app_namespace(upper)]ScreenConfig({
      required AFCreateStateViewDelegate<TStateView> stateViewCreator,
      required AFCreateScreenSPIDelegate<TSPI, AFBuildContext<TStateView, TRouteParam>, [!af_app_namespace(upper)]DefaultTheme> spiCreator,
      AFNavigateRoute? route,
      AFAddScreenSpecificModelsDelegate? addModelsToStateView,      
      AFCreateDefaultRouteParamDelegate? createDefaultRouteParam,
    }): super(
      themeId: [!af_app_namespace(upper)]ThemeID.defaultTheme,
      stateViewCreator: stateViewCreator,
      spiCreator: spiCreator,
      route: route ?? AFNavigateRoute.routeHierarchy,
      addModelsToStateView: addModelsToStateView,
      createDefaultRouteParam: createDefaultRouteParam,
    );
}

abstract class [!af_app_namespace(upper)]DrawerConfig<TSPI extends AFDrawerStateProgrammingInterface, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFDrawerConfig<TSPI, [!af_app_namespace(upper)]State, [!af_app_namespace(upper)]DefaultTheme, TStateView, TRouteParam> {
    [!af_app_namespace(upper)]DrawerConfig({
      required AFCreateStateViewDelegate<TStateView> stateViewCreator,
      required AFCreateScreenSPIDelegate<TSPI, AFBuildContext<TStateView, TRouteParam>, [!af_app_namespace(upper)]DefaultTheme> spiCreator,
      AFAddScreenSpecificModelsDelegate? addModelsToStateView,      
      AFCreateDefaultRouteParamDelegate? createDefaultRouteParam,
    }): super(
      themeId: [!af_app_namespace(upper)]ThemeID.defaultTheme,
      stateViewCreator: stateViewCreator,
      spiCreator: spiCreator,
      addModelsToStateView: addModelsToStateView,
      createDefaultRouteParam: createDefaultRouteParam,
    );
}

abstract class [!af_app_namespace(upper)]DialogConfig<TSPI extends AFDialogStateProgrammingInterface, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFDialogConfig<TSPI, [!af_app_namespace(upper)]State, [!af_app_namespace(upper)]DefaultTheme, TStateView, TRouteParam> {
    [!af_app_namespace(upper)]DialogConfig({
      required AFCreateStateViewDelegate<TStateView> stateViewCreator,
      required AFCreateScreenSPIDelegate<TSPI, AFBuildContext<TStateView, TRouteParam>, [!af_app_namespace(upper)]DefaultTheme> spiCreator,
      AFNavigateRoute? route,
      AFAddScreenSpecificModelsDelegate? addModelsToStateView,      
      AFCreateDefaultRouteParamDelegate? createDefaultRouteParam,
    }): super(
      themeId: [!af_app_namespace(upper)]ThemeID.defaultTheme,
      stateViewCreator: stateViewCreator,
      spiCreator: spiCreator,
      addModelsToStateView: addModelsToStateView,
      createDefaultRouteParam: createDefaultRouteParam,
    );
}

abstract class [!af_app_namespace(upper)]BottomSheetConfig<TSPI extends AFBottomSheetStateProgrammingInterface, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFBottomSheetConfig<TSPI, [!af_app_namespace(upper)]State, [!af_app_namespace(upper)]DefaultTheme, TStateView, TRouteParam> {
  [!af_app_namespace(upper)]BottomSheetConfig({
    required AFCreateStateViewDelegate<TStateView> stateViewCreator,
    required AFCreateScreenSPIDelegate<TSPI, AFBuildContext<TStateView, TRouteParam>, [!af_app_namespace(upper)]DefaultTheme> spiCreator,
    AFAddScreenSpecificModelsDelegate? addModelsToStateView,      
    AFCreateDefaultRouteParamDelegate? createDefaultRouteParam,
  }): super(
    themeId: [!af_app_namespace(upper)]ThemeID.defaultTheme,
    stateViewCreator: stateViewCreator,
    spiCreator: spiCreator,
    addModelsToStateView: addModelsToStateView,
    createDefaultRouteParam: createDefaultRouteParam,
  );
}

abstract class [!af_app_namespace(upper)]WidgetConfig<TSPI extends AFWidgetStateProgrammingInterface, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFWidgetConfig<TSPI, [!af_app_namespace(upper)]State, [!af_app_namespace(upper)]DefaultTheme, TStateView, TRouteParam> {
  [!af_app_namespace(upper)]WidgetConfig({
    required AFCreateStateViewDelegate<TStateView> stateViewCreator,
    required AFCreateWidgetSPIDelegate<TSPI, AFBuildContext<TStateView, TRouteParam>, [!af_app_namespace(upper)]DefaultTheme> spiCreator,
    AFNavigateRoute? route,
  }): super(
    themeId: [!af_app_namespace(upper)]ThemeID.defaultTheme,
    stateViewCreator: stateViewCreator,
    spiCreator: spiCreator,
    route: route ?? AFNavigateRoute.routeHierarchy,
  );
}
''';
}

