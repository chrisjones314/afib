import 'package:afib/src/dart/redux/actions/af_time_actions.dart';
import 'package:afib/src/dart/redux/queries/af_time_update_listener_query.dart';
import 'package:afib/src/dart/redux/state/models/af_time_state.dart';

AFTimeState afTimeStateReducer(AFTimeState state, dynamic action) {
  if(action is AFUpdateTimeStateAction) {
    return action.revised;
  } else if (action is AFTimeUpdateListenerQuery) {
    return action.baseTime;
  }

  return state;
}