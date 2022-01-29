
import 'package:afib/src/dart/redux/state/af_state.dart';
import 'package:afib/src/dart/redux/state/models/af_route_state.dart';
import 'package:afib/src/dart/redux/state/models/afui_proto_state.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/dart/utils/af_typedefs_dart.dart';
import 'package:afib/src/flutter/ui/afui_connected_base.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/utils/af_state_view.dart';
import 'package:afib/src/flutter/utils/af_typedefs_flutter.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';

class AFUIPrototypeStateView extends AFUIFlexibleStateView with AFUIPrototypeStateModelAccess {
  static final AFCreateStateViewDelegate<AFUIPrototypeStateView> creator = (models) => AFUIPrototypeStateView(models: models, create: null);
  AFUIPrototypeStateView({
    required Map<String, Object> models, 
    AFCreateStateViewDelegate? create
  }): super(models: models, create: create ?? creator);

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

abstract class AFUIDefaultConnectedScreen<TSPI extends AFScreenStateProgrammingInterface, TRouteParam extends AFRouteParam> extends AFUIConnectedScreen<TSPI, AFUIPrototypeStateView, TRouteParam> with AFUIDefaultStateViewMixin<TRouteParam> {
  AFUIDefaultConnectedScreen(AFScreenID screen, AFCreateSPIDelegate<TSPI, AFUIBuildContext<AFUIPrototypeStateView, TRouteParam>> spiCreator): super(screen, AFUIPrototypeStateView.creator, spiCreator);
}

abstract class AFUIDefaultConnectedDialog<TSPI extends AFDialogStateProgrammingInterface, TRouteParam extends AFRouteParam> extends AFUIConnectedDialog<TSPI, AFUIPrototypeStateView, TRouteParam> with AFUIDefaultStateViewMixin<TRouteParam> {
  AFUIDefaultConnectedDialog(AFScreenID screen, AFCreateSPIDelegate<TSPI, AFUIBuildContext<AFUIPrototypeStateView, TRouteParam>> spiCreator): super(screen, AFUIPrototypeStateView.creator, spiCreator);
}
