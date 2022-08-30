
import 'package:afib/afui_id.dart';
import 'package:afib/src/dart/redux/state/models/af_app_state.dart';
import 'package:afib/src/dart/redux/state/models/afui_proto_state.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/dart/utils/af_typedefs_dart.dart';
import 'package:afib/src/flutter/ui/afui_connected_base.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/ui/theme/afui_default_theme.dart';
import 'package:afib/src/flutter/utils/af_typedefs_flutter.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';

class AFUIDefaultStateView extends AFUIFlexibleStateView with AFUIStateModelAccess {
  static final AFCreateStateViewDelegate<AFUIDefaultStateView> creator = (models) => AFUIDefaultStateView(models: models, create: null);
  AFUIDefaultStateView({
    required Map<String, Object> models, 
    AFCreateStateViewDelegate? create
  }): super(models: models, create: create ?? creator);

  factory AFUIDefaultStateView.create(Map<String, Object> models) {
    return AFUIDefaultStateView(models: models);
  }

}

//--------------------------------------------------------------------------------------
mixin AFUIDefaultStateViewModelsMixin<TRouteParam extends AFRouteParam> {

  //--------------------------------------------------------------------------------------
  List<Object?> createStateModels(AFBuildStateViewContext<AFUIState, TRouteParam> context) {
    final result = <Object?>[]; 
    result.addAll(context.stateApp.allModels);
    final time = context.statePublic.time;

    // afib protoypes need to work whether the calling app/library uses the time state or not.
    if(time.isInitialized) {
      result.add(context.statePublic.time);
      result.add(context.statePublic.queries.findListenerQueryById(AFUIQueryID.time.toString()));
    }

    final testState = context.private.testState;
    final activeTestId = testState.activeTestId;
    if(activeTestId != null) {
      final test = AFibF.g.findScreenTestById(activeTestId);
      if(test == null) throw AFException("Missing test for $activeTestId");
      final testContext = testState.findContext(test.id);
      final testSubState = testState.findState(test.id);
      if(testSubState == null) throw AFException("unexpected null context or state for ${test.id}");
      result.add(AFWrapModelWithCustomID(AFUIState.prototypeModel, test));
      result.add(testSubState);
      result.add(testContext);
    }
    return result;

  }
}

//--------------------------------------------------------------------------------------
class AFUIDefaultScreenConfig<TSPI extends AFScreenStateProgrammingInterface, TRouteParam extends AFRouteParam> extends AFUIScreenConfig<TSPI, AFUIDefaultStateView, TRouteParam> with AFUIDefaultStateViewModelsMixin<TRouteParam> {
  AFUIDefaultScreenConfig({
    required AFCreateScreenSPIDelegate<TSPI, AFBuildContext<AFUIDefaultStateView, TRouteParam>, AFUIDefaultTheme> spiCreator,
    AFRouteLocation? route
  }): super(
    stateViewCreator: AFUIDefaultStateView.create,
    spiCreator: spiCreator,
    route: route,
  );
}

//--------------------------------------------------------------------------------------
class AFUIDefaultDrawerConfig<TSPI extends AFDrawerStateProgrammingInterface, TRouteParam extends AFRouteParam> extends AFUIDrawerConfig<TSPI, AFUIDefaultStateView, TRouteParam> with AFUIDefaultStateViewModelsMixin<TRouteParam> {
  AFUIDefaultDrawerConfig({
    required AFCreateScreenSPIDelegate<TSPI, AFBuildContext<AFUIDefaultStateView, TRouteParam>, AFUIDefaultTheme> spiCreator,
    AFRouteLocation? route,
    AFCreateDefaultRouteParamDelegate? createDefaultRouteParam
  }): super(
    stateViewCreator: AFUIDefaultStateView.create,
    spiCreator: spiCreator,
    route: route,
    createDefaultRouteParam: createDefaultRouteParam,
  );
}

//--------------------------------------------------------------------------------------
class AFUIDefaultDialogConfig<TSPI extends AFDialogStateProgrammingInterface, TRouteParam extends AFRouteParam> extends AFUIDialogConfig<TSPI, AFUIDefaultStateView, TRouteParam> with AFUIDefaultStateViewModelsMixin<TRouteParam> {
  AFUIDefaultDialogConfig({
    required AFCreateScreenSPIDelegate<TSPI, AFBuildContext<AFUIDefaultStateView, TRouteParam>, AFUIDefaultTheme> spiCreator,
    AFRouteLocation? route,
  }): super(
    stateViewCreator: AFUIDefaultStateView.create,
    spiCreator: spiCreator,
    route: route,
  );
}

//--------------------------------------------------------------------------------------
class AFUIDefaultWidgetConfig<TSPI extends AFWidgetStateProgrammingInterface, TRouteParam extends AFRouteParam> extends AFUIWidgetConfig<TSPI, AFUIDefaultStateView, TRouteParam> with AFUIDefaultStateViewModelsMixin<TRouteParam> {

    AFUIDefaultWidgetConfig({
      required AFCreateWidgetSPIDelegate<TSPI, AFBuildContext<AFUIDefaultStateView, TRouteParam>, AFUIDefaultTheme> spiCreator,
      AFRouteLocation? route
    }): super(
      stateViewCreator: AFUIDefaultStateView.create,
      spiCreator: spiCreator,
      route: route,
    );
}
