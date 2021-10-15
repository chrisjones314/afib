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
  TypedReducer<AFRouteState, AFNavigateSetChildParamAction>(_navSetChildParam),
  TypedReducer<AFRouteState, AFNavigateAddChildParamAction>(_navAddChildParam),
  TypedReducer<AFRouteState, AFNavigateRemoveChildParamAction>(_navRemoveChildParam),
  TypedReducer<AFRouteState, AFShutdownOngoingQueriesAction>(_shutdownQueries),
  TypedReducer<AFRouteState, AFResetToInitialRouteAction>(_resetToInitialRoute),
]);

//---------------------------------------------------------------------------
AFRouteState _navReplace(AFRouteState state, AFNavigateReplaceAction action) {
  return state.popAndPushNamed(action.param, action.children);
}

//---------------------------------------------------------------------------
AFRouteState _navReplaceAll(AFRouteState state, AFNavigateReplaceAllAction action) {
  return state.replaceAll(action.param, action.children);
}

//---------------------------------------------------------------------------
AFRouteState _navPush(AFRouteState state, AFNavigatePushAction action) {

  return state.pushNamed(action.param, action.children);
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
  return state.popTo(action.popTo, action.push?.param, action.push?.children, action.returnData);
}

//---------------------------------------------------------------------------
AFRouteState _navSetParam(AFRouteState state, AFNavigateSetParamAction action) {
  final screen = action.param.id as AFScreenID;
  return state.setParam(screen, action.param, action.route);
}

//---------------------------------------------------------------------------
AFRouteState _navSetChildParam(AFRouteState state, AFNavigateSetChildParamAction action) {
  return state.setChildParam(action.screen, action.route, action.param, useParentParam: action.useParentParam);
}

//---------------------------------------------------------------------------
AFRouteState _navAddChildParam(AFRouteState state, AFNavigateAddChildParamAction action) {
  return state.addChildParam(action.screen, action.route, action.param);
}

//---------------------------------------------------------------------------
AFRouteState _navRemoveChildParam(AFRouteState state, AFNavigateRemoveChildParamAction action) {
  return state.removeChildParam(action.screen, action.widget, action.route);
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
AFRouteState _resetToInitialRoute(AFRouteState state, AFResetToInitialRouteAction action) {
  return state.resetToInitialRoute();
}

