
import 'package:afib/src/dart/redux/state/models/af_time_state.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/utils/af_param_ui_state_holder.dart';

class AFFlutterRouteParamState {
  final AFTextEditingControllers? textControllers;

  AFFlutterRouteParamState({
    this.textControllers,
  });

  void dispose() {
    textControllers?.dispose();
  }
}

class AFRouteParamWithFlutterState extends AFRouteParam {
  final AFFlutterRouteParamState flutterState;

  AFRouteParamWithFlutterState({
    required AFID id,
    required this.flutterState,
    AFTimeStateUpdateSpecificity? timeSpecificity,
  }): super(id: id, timeSpecificity: timeSpecificity);

  void updateTextField(AFWidgetID wid, String text) {
    final tc = flutterState.textControllers;
    if(tc == null) {
      throw AFException(AFStateProgrammingInterface.errNeedTextControllers);
    }
    tc.update(wid, text);
  }

  @override
  void dispose() {
    flutterState.dispose();
  }

}
