import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/redux/actions/af_deferred_query.dart';
import 'package:afib/src/dart/redux/actions/af_route_actions.dart';
import 'package:afib/src/dart/redux/state/af_route_state.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:redux/redux.dart';

//---------------------------------------------------------------------------
final routeReducer = combineReducers<AFRouteState>([
  TypedReducer<AFRouteState, AFNavigateReplaceAction>(_navReplace),
  TypedReducer<AFRouteState, AFNavigateReplaceAllAction>(_navReplaceAll),
  TypedReducer<AFRouteState, AFNavigatePushAction>(_navPush),
  TypedReducer<AFRouteState, AFNavigatePopAction>(_navPop),
  TypedReducer<AFRouteState, AFNavigatePopNAction>(_navPopN),
  TypedReducer<AFRouteState, AFNavigatePopToAction>(_navPopTo),
  TypedReducer<AFRouteState, AFNavigateSetParamAction>(_navSetParam),
  TypedReducer<AFRouteState, AFNavigateExitTestAction>(_navExitTest),
  TypedReducer<AFRouteState, AFShutdownOngoingQueriesAction>(_shutdownQueries),
  TypedReducer<AFRouteState, AFNavigateAddConnectedChildAction>(_addConnectedChild),
  TypedReducer<AFRouteState, AFNavigateRemoveConnectedChildAction>(_removeConnectedChild),
  TypedReducer<AFRouteState, AFNavigateSortConnectedChildrenAction>(_sortConnectedChildren),
  TypedReducer<AFRouteState, AFNavigateSetChildParamAction>(_setChildParam),
  TypedReducer<AFRouteState, AFResetToInitialRouteAction>(_resetToInitialRoute),
]);

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
  return state.addConnectedChild(action.screen, action.widget, action.param);
}

//---------------------------------------------------------------------------
AFRouteState _removeConnectedChild(AFRouteState state, AFNavigateRemoveConnectedChildAction action) {
  return state.removeConnectedChild(action.screen, action.widget);
}

//---------------------------------------------------------------------------
AFRouteState _sortConnectedChildren(AFRouteState state, AFNavigateSortConnectedChildrenAction action) {
  return state.sortConnectedChildren(action.screen, action.sort, action.typeToSort);
}

//---------------------------------------------------------------------------
AFRouteState _setChildParam(AFRouteState state, AFNavigateSetChildParamAction action) {
  return state.setConnectedChildParam(action.screen, action.widget, action.param);
}

//---------------------------------------------------------------------------
AFRouteState _resetToInitialRoute(AFRouteState state, AFResetToInitialRouteAction action) {
  return state.resetToInitialRoute();
}

