import 'package:afib/src/dart/redux/actions/af_deferred_query.dart';
import 'package:afib/src/dart/redux/actions/af_navigation_actions.dart';
import 'package:afib/src/dart/redux/state/af_route_state.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:redux/redux.dart';

//---------------------------------------------------------------------------
final routeReducer = combineReducers<AFRouteState>([
  TypedReducer<AFRouteState, AFNavigateReplaceAction>(_navReplace),
  TypedReducer<AFRouteState, AFNavigateReplaceAllAction>(_navReplaceAll),
  TypedReducer<AFRouteState, AFNavigatePushPopupAction>(_navPushPopup),
  TypedReducer<AFRouteState, AFNavigatePopPopupAction>(_navPopPopup),
  TypedReducer<AFRouteState, AFNavigatePushAction>(_navPush),
  TypedReducer<AFRouteState, AFNavigatePopAction>(_navPop),
  TypedReducer<AFRouteState, AFNavigatePopNAction>(_navPopN),
  TypedReducer<AFRouteState, AFNavigatePopToAction>(_navPopTo),
  TypedReducer<AFRouteState, AFNavigateSetPopupParamAction>(_navSetPopupParam),
  TypedReducer<AFRouteState, AFNavigateSetParamAction>(_navSetParam),
  TypedReducer<AFRouteState, AFNavigateExitTestAction>(_navExitTest),
  TypedReducer<AFRouteState, AFNavigatePopFromFlutterAction>(_navPopFromFlutter),
  TypedReducer<AFRouteState, AFShutdownOngoingQueriesAction>(_shutdownQueries),
  TypedReducer<AFRouteState, AFNavigateAddConnectedChildAction>(_addConnectedChild),
  TypedReducer<AFRouteState, AFNavigateRemoveConnectedChildAction>(_removeConnectedChild),
]);

//---------------------------------------------------------------------------
AFRouteState _navPopFromFlutter(AFRouteState state, AFNavigatePopFromFlutterAction action) {
  return state.popFromFlutter();
}

//---------------------------------------------------------------------------
AFRouteState _navReplace(AFRouteState state, AFNavigateReplaceAction action) {
  return state.popAndPushNamed(action.screen, action.param);
}

//---------------------------------------------------------------------------
AFRouteState _navReplaceAll(AFRouteState state, AFNavigateReplaceAllAction action) {
  return state.replaceAll(action.screen, action.param);
}

//---------------------------------------------------------------------------
AFRouteState _navPush(AFRouteState state, AFNavigatePushAction action) {

  return state.pushNamed(action.screen, action.param);
}

//---------------------------------------------------------------------------
AFRouteState _navPushPopup(AFRouteState state, AFNavigatePushPopupAction action) {
  return state.pushPopup(action.screen, action.param);
}

//---------------------------------------------------------------------------
AFRouteState _navPopPopup(AFRouteState state, AFNavigatePopPopupAction action) {
  return state.popPopup();
}

//---------------------------------------------------------------------------
AFRouteState _navPop(AFRouteState state, AFNavigatePopAction action) {
  return state.pop(action.returnData);
}

//---------------------------------------------------------------------------
AFRouteState _navPopN(AFRouteState state, AFNavigatePopNAction action) {
  return state.popN(action.popCount, action.returnData);
}

//---------------------------------------------------------------------------
AFRouteState _navPopTo(AFRouteState state, AFNavigatePopToAction action) {
  return state.popTo(action.popTo, action.push?.screen, action.push?.param, action.returnData);
}

//---------------------------------------------------------------------------
AFRouteState _navSetParam(AFRouteState state, AFNavigateSetParamAction action) {
  return state.setParam(action.screen, action.param, action.route);
}

//---------------------------------------------------------------------------
AFRouteState _navSetPopupParam(AFRouteState state, AFNavigateSetPopupParamAction action) {
  return state.setPopupParam(action.screen, action.param);
}

//---------------------------------------------------------------------------
AFRouteState _navExitTest(AFRouteState state, AFNavigateExitTestAction action) {
  return state.exitTest();
}

//---------------------------------------------------------------------------
AFRouteState _shutdownQueries(AFRouteState state, AFShutdownOngoingQueriesAction action) {
  AFibF.g.shutdownOutstandingQueries();
  return state;
}

//---------------------------------------------------------------------------
AFRouteState _addConnectedChild(AFRouteState state, AFNavigateAddConnectedChildAction action) {
  return state.addConnectedChild(action.screen, action.widget, action.route, action.param);
}

//---------------------------------------------------------------------------
AFRouteState _removeConnectedChild(AFRouteState state, AFNavigateRemoveConnectedChildAction action) {
  return state.removeConnectedChild(action.screen, action.widget, action.route);
}
