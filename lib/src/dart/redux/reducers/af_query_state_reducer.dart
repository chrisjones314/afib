

import 'package:afib/src/dart/redux/actions/af_query_actions.dart';
import 'package:afib/src/dart/redux/state/af_query_state.dart';

AFQueryState afQueryStateReducer(AFQueryState state, dynamic action) {
  if(action is AFRegisterListenerQueryAction) {
    return state.reviseAddListener(action.query);
  } else if(action is AFRegisterDeferredQueryAction) {
    return state.reviseAddDeferred(action.query);
  } else if(action is AFShutdownOngoingQueriesAction) {
    return state.shutdownOutstandingQueries();
  } else if(action is AFShutdownDeferredQueryAction) {
    return state.reviseShutdownDeferred(action.key);
  } else if(action is AFShutdownListenerQueryAction) {
    return state.reviseShutdownListener(action.key);
  }
  return state;
}