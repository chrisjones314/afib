import 'dart:async';

import 'package:afib/id.dart';
import 'package:afib/src/dart/redux/actions/af_async_query.dart';
import 'package:afib/src/dart/redux/actions/af_time_actions.dart';
import 'package:afib/src/dart/redux/state/models/af_app_state.dart';
import 'package:afib/src/dart/redux/state/models/af_time_state.dart';
import 'package:afib/src/flutter/utils/af_typedefs_flutter.dart';

class AFTimeUpdateListenerQuery<AFUIState extends AFFlexibleState> extends AFAsyncListenerQuery<AFUIState, AFTimeState> {
  final AFTimeState baseTime;
  Timer? timer;

  AFTimeUpdateListenerQuery({
    required this.baseTime,
    AFOnResponseDelegate<AFUIState, AFTimeState>? onSuccessDelegate
  }):
    super(id: AFUIQueryID.time, onSuccessDelegate: onSuccessDelegate, onPreExecuteResponseDelegate: () => baseTime);

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

  @override
  void finishAsyncWithResponse(AFFinishQuerySuccessContext<AFUIState, AFTimeState> context) {  
    context.dispatch(AFUpdateTimeStateAction(context.r));

  }
}
