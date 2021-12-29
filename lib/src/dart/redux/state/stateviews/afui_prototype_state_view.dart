
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/redux/state/models/afui_proto_state.dart';
import 'package:afib/src/dart/redux/state/stateviews/afui_flexible_state_view.dart';

class AFUIPrototypeStateView extends AFUIFlexibleStateView with AFUIPrototypeStateModelAccess {
  static final AFCreateStateViewDelegate<AFUIPrototypeStateView> creator = (models) => AFUIPrototypeStateView(models: models, create: null);
  AFUIPrototypeStateView({
    required Map<String, Object> models, 
    AFCreateStateViewDelegate? create
  }): super(models: models, create: create ?? creator);

}