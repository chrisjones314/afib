import 'package:afib/src/dart/command/af_source_template.dart';

/// Any class that ends in "T" is a source template used in code generation.
class StateViewT extends AFCoreFileSourceTemplate {
  static const insertStateViewPrefix = AFSourceTemplateInsertion("state_view_prefix");
  static const insertThemeType = AFSourceTemplateInsertion("theme_type");

  StateViewT(): super(
    templateFileId: "state_view",
  );  

  @override
  String get template => '''
import 'package:afib/afib_command.dart';
import 'package:afib/afib_flutter.dart';
import 'package:$insertPackagePath/state/${insertAppNamespace}_state_model_access.dart';
import 'package:$insertPackagePath/state/${insertAppNamespace}_state.dart';
import 'package:$insertPackagePath/ui/${insertAppNamespace}_connected_base.dart';

//--------------------------------------------------------------------------------------
class $insertMainType extends ${insertAppNamespaceUpper}FlexibleStateView with ${insertAppNamespaceUpper}StateModelAccess {

  $insertMainType({
    required Map<String, Object> models, 
    AFCreateStateViewDelegate? creator
  }): super(models: models, create: creator ?? $insertMainType.create);

  factory $insertMainType.create(Map<String, Object> models) {
    return $insertMainType(models: models);
  }

}

//--------------------------------------------------------------------------------------
mixin ${insertMainType}ModelsMixin<TRouteParam extends AFRouteParam> {

  //--------------------------------------------------------------------------------------
  List<Object?> createStateModels(AFBuildStateViewContext<${insertAppNamespaceUpper}State, TRouteParam> context) {
    final state = context.stateApp;
    final models = state.allModels.toList();
    models.add(context.accessCurrentTime.reviseSpecificity(AFTimeStateUpdateSpecificity.day));
    return models;
  }
}

//--------------------------------------------------------------------------------------
class ${insertStateViewPrefix}ScreenConfig<TSPI extends AFScreenStateProgrammingInterface, TRouteParam extends AFRouteParam> extends ${insertAppNamespaceUpper}ScreenConfig<TSPI, $insertMainType, TRouteParam> with ${insertMainType}ModelsMixin<TRouteParam> {
  ${insertStateViewPrefix}ScreenConfig({
    required AFCreateSPIDelegate<TSPI, AFBuildContext<$insertMainType, TRouteParam>, $insertThemeType> spiCreator,
    AFCreateDefaultRouteParamDelegate? createDefaultRouteParam,
    AFAddScreenSpecificModelsDelegate? addModelsToStateView,
  }): super(
    stateViewCreator: $insertMainType.create,
    spiCreator: spiCreator,
    createDefaultRouteParam: createDefaultRouteParam,
    addModelsToStateView: addModelsToStateView,
  );
}

//--------------------------------------------------------------------------------------
class ${insertStateViewPrefix}DrawerConfig<TSPI extends AFDrawerStateProgrammingInterface, TRouteParam extends AFRouteParam> extends ${insertAppNamespaceUpper}DrawerConfig<TSPI, $insertMainType, TRouteParam> with ${insertMainType}ModelsMixin<TRouteParam> {
  ${insertStateViewPrefix}DrawerConfig({
    required AFCreateSPIDelegate<TSPI, AFBuildContext<$insertMainType, TRouteParam>, $insertThemeType> spiCreator,
    required AFCreateDefaultRouteParamDelegate createDefaultRouteParam,
    AFAddScreenSpecificModelsDelegate? addModelsToStateView,
  }): super(
    stateViewCreator: $insertMainType.create,
    spiCreator: spiCreator,
    createDefaultRouteParam: createDefaultRouteParam,
    addModelsToStateView: addModelsToStateView,
  );
}

//--------------------------------------------------------------------------------------
class ${insertStateViewPrefix}DialogConfig<TSPI extends AFDialogStateProgrammingInterface, TRouteParam extends AFRouteParam> extends ${insertAppNamespaceUpper}DialogConfig<TSPI, $insertMainType, TRouteParam> with ${insertMainType}ModelsMixin<TRouteParam> {
  ${insertStateViewPrefix}DialogConfig({
    required AFCreateSPIDelegate<TSPI, AFBuildContext<$insertMainType, TRouteParam>, $insertThemeType> spiCreator,
    AFCreateDefaultRouteParamDelegate? createDefaultRouteParam,
    AFAddScreenSpecificModelsDelegate? addModelsToStateView,
  }): super(
    stateViewCreator: $insertMainType.create,
    spiCreator: spiCreator,
    createDefaultRouteParam: createDefaultRouteParam,
    addModelsToStateView: addModelsToStateView,
  );
}

//--------------------------------------------------------------------------------------
class ${insertStateViewPrefix}WidgetConfig<TSPI extends AFWidgetStateProgrammingInterface, TRouteParam extends AFRouteParam> extends ${insertAppNamespaceUpper}WidgetConfig<TSPI, $insertMainType, TRouteParam> with ${insertMainType}ModelsMixin<TRouteParam> {

    ${insertStateViewPrefix}WidgetConfig({
      required AFCreateSPIDelegate<TSPI, AFBuildContext<$insertMainType, TRouteParam>, $insertThemeType> spiCreator,
    }): super(
      stateViewCreator: $insertMainType.create,
      spiCreator: spiCreator,
    );
}

//--------------------------------------------------------------------------------------
class ${insertStateViewPrefix}BottomSheetConfig<TSPI extends AFBottomSheetStateProgrammingInterface, TRouteParam extends AFRouteParam> extends ${insertAppNamespaceUpper}BottomSheetConfig<TSPI, $insertMainType, TRouteParam> with ${insertMainType}ModelsMixin<TRouteParam> {

    ${insertStateViewPrefix}BottomSheetConfig({
      required AFCreateSPIDelegate<TSPI, AFBuildContext<$insertMainType, TRouteParam>, $insertThemeType> spiCreator,
      AFCreateDefaultRouteParamDelegate? createDefaultRouteParam,
      AFAddScreenSpecificModelsDelegate? addModelsToStateView,
    }): super(
      stateViewCreator: $insertMainType.create,
      spiCreator: spiCreator,
      createDefaultRouteParam: createDefaultRouteParam,
      addModelsToStateView: addModelsToStateView,
    );
}
''';

}

