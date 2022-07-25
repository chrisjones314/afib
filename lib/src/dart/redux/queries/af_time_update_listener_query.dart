import 'dart:async';

import 'package:afib/afui_id.dart';
import 'package:afib/src/dart/redux/actions/af_async_query.dart';
import 'package:afib/src/dart/redux/actions/af_route_actions.dart';
import 'package:afib/src/dart/redux/actions/af_time_actions.dart';
import 'package:afib/src/dart/redux/state/models/af_time_state.dart';
import 'package:afib/src/flutter/utils/af_dispatcher.dart';
import 'package:afib/src/flutter/utils/af_typedefs_flutter.dart';

class AFTimeUpdateListenerQuery extends AFAsyncListenerQuery<AFTimeState> {
  final AFTimeState baseTime;
  Timer? timer;

  AFTimeUpdateListenerQuery({
    required this.baseTime,
    AFOnResponseDelegate<AFTimeState>? onSuccess
  }):
    super(id: AFUIQueryID.time, onSuccess: onSuccess, onPreExecuteResponse: () => baseTime);

  @override
  void startAsync(AFStartQueryContext<AFTimeState> context) {
    timer = Timer.periodic(baseTime.pushUpdateFrequency, (timer) { 
      final updatedTime = baseTime.reviseForActualNow(DateTime.now());
      if(baseTime.pauseTime == null) {
        context.onSuccess(updatedTime);
      }
    });
  }

  @override 
  void shutdown() {
    timer?.cancel();
  }

  static void processUpdatedTime(AFDispatcher dispatcher, AFTimeState time) {
    dispatcher.dispatch(AFUpdateTimeStateAction(time));
    dispatcher.dispatch(AFUpdateTimeRouteParametersAction(time));
  }

  @override
  void finishAsyncWithResponse(AFFinishQuerySuccessContext<AFTimeState> context) {  
    processUpdatedTime(context.dispatcher, context.r,);

  }
}
