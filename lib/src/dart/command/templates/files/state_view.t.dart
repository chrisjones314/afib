



import 'package:afib/src/dart/command/af_source_template.dart';

class AFStateViewT extends AFSourceTemplate {

  final String template = '''
import 'package:afib/afib_flutter.dart';
import 'package:[!af_package_path]/state/[!af_app_namespace]_state_model_access.dart';
import 'package:[!af_package_path]/state/[!af_app_namespace]_state.dart';
import 'package:[!af_package_path]/ui/[!af_app_namespace]_connected_base.dart';
[!af_import_statements]

//--------------------------------------------------------------------------------------
class [!af_state_view_name] extends [!af_app_namespace(upper)]FlexibleStateView with [!af_app_namespace(upper)]StateModelAccess {

  [!af_state_view_name]({
    required Map<String, Object> models, 
    AFCreateStateViewDelegate? creator
  }): super(models: models, create: creator ?? [!af_state_view_name].create);

  factory [!af_state_view_name].create(Map<String, Object> models) {
    return [!af_state_view_name](models: models);
  }

}

//--------------------------------------------------------------------------------------
mixin [!af_state_view_name]ModelsMixin<TRouteParam extends AFRouteParam> {

  //--------------------------------------------------------------------------------------
  Iterable<Object?> createStateModels(AFBuildStateViewContext<[!af_app_namespace(upper)]State, TRouteParam> context) {
    final state = context.stateApp;
    return state.allModels;
  }
}

//--------------------------------------------------------------------------------------
class [!af_state_view_prefix]ScreenConfig<TSPI extends AFScreenStateProgrammingInterface, TRouteParam extends AFRouteParam> extends [!af_app_namespace(upper)]ScreenConfig<TSPI, [!af_state_view_name], TRouteParam> with [!af_state_view_name]ModelsMixin<TRouteParam> {
  [!af_state_view_prefix]ScreenConfig({
    required AFCreateScreenSPIDelegate<TSPI, AFBuildContext<[!af_state_view_name], TRouteParam>, [!af_theme_type]> spiCreator,
    AFNavigateRoute? route
  }): super(
    stateViewCreator: [!af_state_view_name].create,
    spiCreator: spiCreator,
    route: route,
  );
}

//--------------------------------------------------------------------------------------
class [!af_state_view_prefix]DrawerConfig<TSPI extends AFDrawerStateProgrammingInterface, TRouteParam extends AFRouteParam> extends [!af_app_namespace(upper)]DrawerConfig<TSPI, [!af_state_view_name], TRouteParam> with [!af_state_view_name]ModelsMixin<TRouteParam> {
  [!af_state_view_prefix]DrawerConfig({
    required AFCreateScreenSPIDelegate<TSPI, AFBuildContext<[!af_state_view_name], TRouteParam>, [!af_theme_type]> spiCreator,
  }): super(
    stateViewCreator: [!af_state_view_name].create,
    spiCreator: spiCreator,
  );
}

//--------------------------------------------------------------------------------------
class [!af_state_view_prefix]DialogConfig<TSPI extends AFDialogStateProgrammingInterface, TRouteParam extends AFRouteParam> extends [!af_app_namespace(upper)]DialogConfig<TSPI, [!af_state_view_name], TRouteParam> with [!af_state_view_name]ModelsMixin<TRouteParam> {
  [!af_state_view_prefix]DialogConfig({
    required AFCreateScreenSPIDelegate<TSPI, AFBuildContext<[!af_state_view_name], TRouteParam>, [!af_theme_type]> spiCreator,
    AFNavigateRoute? route
  }): super(
    stateViewCreator: [!af_state_view_name].create,
    spiCreator: spiCreator,
    route: route,
  );
}

//--------------------------------------------------------------------------------------
class [!af_app_namespace(upper)][!af_state_view_prefix]WidgetConfig<TSPI extends AFWidgetStateProgrammingInterface, TRouteParam extends AFRouteParam> extends [!af_app_namespace(upper)]WidgetConfig<TSPI, [!af_state_view_name], TRouteParam> with [!af_state_view_name]ModelsMixin<TRouteParam> {

    [!af_app_namespace(upper)][!af_state_view_prefix]WidgetConfig({
      required AFCreateWidgetSPIDelegate<TSPI, AFBuildContext<[!af_state_view_name], TRouteParam>, [!af_theme_type]> spiCreator,
      AFNavigateRoute? route
    }): super(
      stateViewCreator: [!af_state_view_name].create,
      spiCreator: spiCreator,
      route: route,
    );
}

//--------------------------------------------------------------------------------------
class [!af_app_namespace(upper)][!af_state_view_prefix]BottomSheetConfig<TSPI extends AFBottomSheetStateProgrammingInterface, TRouteParam extends AFRouteParam> extends [!af_app_namespace(upper)]BottomSheetConfig<TSPI, [!af_state_view_name], TRouteParam> with [!af_state_view_name]ModelsMixin<TRouteParam> {

    [!af_app_namespace(upper)][!af_state_view_prefix]BottomSheetConfig({
      required AFCreateScreenSPIDelegate<TSPI, AFBuildContext<[!af_state_view_name], TRouteParam>, [!af_theme_type]> spiCreator,
    }): super(
      stateViewCreator: [!af_state_view_name].create,
      spiCreator: spiCreator,
    );
}
''';

}

