
import 'package:afib/src/dart/command/af_source_template.dart';

class ConnectedBaseT extends AFCoreFileSourceTemplate {

  ConnectedBaseT(): super(
    templateFileId: "connected_base",
  );

  String get template => '''
import 'package:afib/afib_flutter.dart';
import 'package:$insertPackageName/${insertAppNamespace}_id.dart';
import 'package:$insertPackagePath/state/${insertAppNamespace}_state.dart';
import 'package:$insertPackagePath/ui/themes/${insertAppNamespace}_default_theme.dart';

// a default screen programming interface while we transition to this new model.
class ${insertAppNamespaceUpper}ScreenSPI<TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFScreenStateProgrammingInterface<${insertAppNamespaceUpper}State, AFBuildContext<TStateView, TRouteParam>, ${insertAppNamespaceUpper}DefaultTheme> {
  ${insertAppNamespaceUpper}ScreenSPI(AFBuildContext<TStateView, TRouteParam> context, AFStandardSPIData standard): super(context, standard);
}

class ${insertAppNamespaceUpper}DialogSPI<TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFDialogStateProgrammingInterface<${insertAppNamespaceUpper}State, AFBuildContext<TStateView, TRouteParam>, ${insertAppNamespaceUpper}DefaultTheme> {
  ${insertAppNamespaceUpper}DialogSPI(AFBuildContext<TStateView, TRouteParam> context, AFStandardSPIData standard): super(context, standard);
}

class ${insertAppNamespaceUpper}DrawerSPI<TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFDrawerStateProgrammingInterface<${insertAppNamespaceUpper}State, AFBuildContext<TStateView, TRouteParam>, ${insertAppNamespaceUpper}DefaultTheme> {
  ${insertAppNamespaceUpper}DrawerSPI(AFBuildContext<TStateView, TRouteParam> context, AFStandardSPIData standard): super(context, standard);
}

class ${insertAppNamespaceUpper}BottomSheetSPI<TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFBottomSheetStateProgrammingInterface<${insertAppNamespaceUpper}State, AFBuildContext<TStateView, TRouteParam>, ${insertAppNamespaceUpper}DefaultTheme> {
  ${insertAppNamespaceUpper}BottomSheetSPI(AFBuildContext<TStateView, TRouteParam> context, AFStandardSPIData standard): super(context, standard);
}

// a default screen programming interface while we transition to this new model.
class ${insertAppNamespaceUpper}WidgetSPI<TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFWidgetStateProgrammingInterface<${insertAppNamespaceUpper}State, AFBuildContext<TStateView, TRouteParam>, ${insertAppNamespaceUpper}DefaultTheme> {
  ${insertAppNamespaceUpper}WidgetSPI(AFBuildContext<TStateView, TRouteParam> context, AFStandardSPIData standard): super(context, standard);
}

class ${insertAppNamespaceUpper}FlexibleStateView extends AFFlexibleStateView  {
  ${insertAppNamespaceUpper}FlexibleStateView({
    required Map<String, Object> models,
    required AFCreateStateViewDelegate create,
  }): super(models: models, create: create);
}

abstract class ${insertAppNamespaceUpper}ConnectedScreen<TSPI extends AFScreenStateProgrammingInterface, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFConnectedScreen<${insertAppNamespaceUpper}State, ${insertAppNamespaceUpper}DefaultTheme, TStateView, TRouteParam, TSPI> {
  ${insertAppNamespaceUpper}ConnectedScreen({
    required AFConnectedUIConfig<${insertAppNamespaceUpper}State, ${insertAppNamespaceUpper}DefaultTheme, TStateView, TRouteParam, TSPI>  config,
    required AFScreenID screenId,
    TRouteParam? launchParam,
  }): super(config: config, screenId: screenId, launchParam: launchParam);
}

abstract class ${insertAppNamespaceUpper}ConnectedDialog<TSPI extends AFDialogStateProgrammingInterface, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFConnectedDialog<${insertAppNamespaceUpper}State, ${insertAppNamespaceUpper}DefaultTheme, TStateView, TRouteParam, TSPI>  {

  ${insertAppNamespaceUpper}ConnectedDialog({
    required AFConnectedUIConfig<${insertAppNamespaceUpper}State, ${insertAppNamespaceUpper}DefaultTheme, TStateView, TRouteParam, TSPI> config,
    required AFScreenID screenId,
  }): super(config: config, screenId: screenId);
}

abstract class ${insertAppNamespaceUpper}ConnectedDrawer<TSPI extends AFScreenStateProgrammingInterface, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFConnectedDrawer<${insertAppNamespaceUpper}State, ${insertAppNamespaceUpper}DefaultTheme, TStateView, TRouteParam, TSPI>  {
  ${insertAppNamespaceUpper}ConnectedDrawer({
    required AFConnectedUIConfig<${insertAppNamespaceUpper}State, ${insertAppNamespaceUpper}DefaultTheme, TStateView, TRouteParam, TSPI> config,
    required AFScreenID screenId,
  }): super(config: config, screenId: screenId);
}

abstract class ${insertAppNamespaceUpper}ConnectedBottomSheet<TSPI extends AFBottomSheetStateProgrammingInterface, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFConnectedBottomSheet<${insertAppNamespaceUpper}State, ${insertAppNamespaceUpper}DefaultTheme, TStateView, TRouteParam, TSPI> {
  ${insertAppNamespaceUpper}ConnectedBottomSheet({
    required AFConnectedUIConfig<${insertAppNamespaceUpper}State, ${insertAppNamespaceUpper}DefaultTheme, TStateView, TRouteParam, TSPI> config,
    required AFScreenID screenId,
  }): super(config: config, screenId: screenId);
}


abstract class ${insertAppNamespaceUpper}ConnectedWidget<TSPI extends AFWidgetStateProgrammingInterface, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFConnectedWidget<${insertAppNamespaceUpper}State, ${insertAppNamespaceUpper}DefaultTheme, TStateView, TRouteParam, TSPI> {
  ${insertAppNamespaceUpper}ConnectedWidget({
    required AFConnectedUIConfig<${insertAppNamespaceUpper}State, ${insertAppNamespaceUpper}DefaultTheme, TStateView, TRouteParam, TSPI> config,
    AFScreenID? screenIdOverride,
    AFWidgetID? widOverride,
    required AFRouteParam launchParam,
  }): super(
    config: config,
    screenIdOverride: screenIdOverride, 
    widOverride: widOverride,
    launchParam: launchParam,
  );
}

abstract class ${insertAppNamespaceUpper}ScreenConfig<TSPI extends AFScreenStateProgrammingInterface, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFScreenConfig<TSPI, ${insertAppNamespaceUpper}State, ${insertAppNamespaceUpper}DefaultTheme, TStateView, TRouteParam> {
    ${insertAppNamespaceUpper}ScreenConfig({
      required AFCreateStateViewDelegate<TStateView> stateViewCreator,
      required AFCreateSPIDelegate<TSPI, AFBuildContext<TStateView, TRouteParam>, ${insertAppNamespaceUpper}DefaultTheme> spiCreator,
      AFAddScreenSpecificModelsDelegate? addModelsToStateView,      
      AFCreateDefaultRouteParamDelegate? createDefaultRouteParam,
    }): super(
      themeId: ${insertAppNamespaceUpper}ThemeID.defaultTheme,
      stateViewCreator: stateViewCreator,
      spiCreator: spiCreator,
      addModelsToStateView: addModelsToStateView,
      createDefaultRouteParam: createDefaultRouteParam,
    );
}

abstract class ${insertAppNamespaceUpper}DrawerConfig<TSPI extends AFDrawerStateProgrammingInterface, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFDrawerConfig<TSPI, ${insertAppNamespaceUpper}State, ${insertAppNamespaceUpper}DefaultTheme, TStateView, TRouteParam> {
    ${insertAppNamespaceUpper}DrawerConfig({
      required AFCreateStateViewDelegate<TStateView> stateViewCreator,
      required AFCreateSPIDelegate<TSPI, AFBuildContext<TStateView, TRouteParam>, ${insertAppNamespaceUpper}DefaultTheme> spiCreator,
      AFAddScreenSpecificModelsDelegate? addModelsToStateView,      
      required AFCreateDefaultRouteParamDelegate createDefaultRouteParam,
    }): super(
      themeId: ${insertAppNamespaceUpper}ThemeID.defaultTheme,
      stateViewCreator: stateViewCreator,
      spiCreator: spiCreator,
      addModelsToStateView: addModelsToStateView,
      createDefaultRouteParam: createDefaultRouteParam,
    );
}

abstract class ${insertAppNamespaceUpper}DialogConfig<TSPI extends AFDialogStateProgrammingInterface, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFDialogConfig<TSPI, ${insertAppNamespaceUpper}State, ${insertAppNamespaceUpper}DefaultTheme, TStateView, TRouteParam> {
    ${insertAppNamespaceUpper}DialogConfig({
      required AFCreateStateViewDelegate<TStateView> stateViewCreator,
      required AFCreateSPIDelegate<TSPI, AFBuildContext<TStateView, TRouteParam>, ${insertAppNamespaceUpper}DefaultTheme> spiCreator,
      AFAddScreenSpecificModelsDelegate? addModelsToStateView,      
      AFCreateDefaultRouteParamDelegate? createDefaultRouteParam,
    }): super(
      themeId: ${insertAppNamespaceUpper}ThemeID.defaultTheme,
      stateViewCreator: stateViewCreator,
      spiCreator: spiCreator,
      addModelsToStateView: addModelsToStateView,
      createDefaultRouteParam: createDefaultRouteParam,
    );
}

abstract class ${insertAppNamespaceUpper}BottomSheetConfig<TSPI extends AFBottomSheetStateProgrammingInterface, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFBottomSheetConfig<TSPI, ${insertAppNamespaceUpper}State, ${insertAppNamespaceUpper}DefaultTheme, TStateView, TRouteParam> {
  ${insertAppNamespaceUpper}BottomSheetConfig({
    required AFCreateStateViewDelegate<TStateView> stateViewCreator,
    required AFCreateSPIDelegate<TSPI, AFBuildContext<TStateView, TRouteParam>, ${insertAppNamespaceUpper}DefaultTheme> spiCreator,
    AFAddScreenSpecificModelsDelegate? addModelsToStateView,      
    AFCreateDefaultRouteParamDelegate? createDefaultRouteParam,
  }): super(
    themeId: ${insertAppNamespaceUpper}ThemeID.defaultTheme,
    stateViewCreator: stateViewCreator,
    spiCreator: spiCreator,
    addModelsToStateView: addModelsToStateView,
    createDefaultRouteParam: createDefaultRouteParam,
  );
}

abstract class ${insertAppNamespaceUpper}WidgetConfig<TSPI extends AFWidgetStateProgrammingInterface, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFWidgetConfig<TSPI, ${insertAppNamespaceUpper}State, ${insertAppNamespaceUpper}DefaultTheme, TStateView, TRouteParam> {
  ${insertAppNamespaceUpper}WidgetConfig({
    required AFCreateStateViewDelegate<TStateView> stateViewCreator,
    required AFCreateSPIDelegate<TSPI, AFBuildContext<TStateView, TRouteParam>, ${insertAppNamespaceUpper}DefaultTheme> spiCreator,
  }): super(
    themeId: ${insertAppNamespaceUpper}ThemeID.defaultTheme,
    stateViewCreator: stateViewCreator,
    spiCreator: spiCreator,
  );
}
''';
}

