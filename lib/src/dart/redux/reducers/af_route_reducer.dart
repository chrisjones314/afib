import 'package:afib/src/dart/redux/actions/af_app_state_actions.dart';
import 'package:afib/src/dart/redux/actions/af_route_actions.dart';
import 'package:afib/src/dart/redux/state/models/af_route_state.dart';
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
  TypedReducer<AFRouteState, AFNavigateAddChildParamAction>(_navAddChildParam),
  TypedReducer<AFRouteState, AFNavigateRemoveChildParamAction>(_navRemoveChildParam),
  TypedReducer<AFRouteState, AFResetToInitialRouteAction>(_resetToInitialRoute),
  TypedReducer<AFRouteState, AFUpdateTimeRouteParametersAction>(_updateTimeRouteParameters),
  TypedReducer<AFRouteState, AFNavigateShowScreenBeginAction>(_navShowScreenBegin),
  TypedReducer<AFRouteState, AFNavigateShowScreenEndAction>(_navShowScreenEnd),
]);

//---------------------------------------------------------------------------
AFRouteState _navReplace(AFRouteState state, AFNavigateReplaceAction action) {
  return state.popAndPushNamed(action.param, action.children, action.createDefaultChildParam);
}

//---------------------------------------------------------------------------
AFRouteState _navReplaceAll(AFRouteState state, AFNavigateReplaceAllAction action) {
  return state.replaceAll(action.param, action.children, action.createDefaultChildParam);
}

//---------------------------------------------------------------------------
AFRouteState _navPush(AFRouteState state, AFNavigatePushAction action) {

  return state.pushNamed(action.param, action.children, action.createDefaultChildParam);
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
  return state.popTo(action.popTo, action.push?.param, action.push?.children, action.push?.createDefaultChildParam, action.returnData);
}

//---------------------------------------------------------------------------
AFRouteState _navSetParam(AFRouteState state, AFNavigateSetParamAction action) {
  return state.updateRouteParam(action.param, action.children, action.createDefaultChildParam);
}

//---------------------------------------------------------------------------
AFRouteState _navAddChildParam(AFRouteState state, AFNavigateAddChildParamAction action) {
  return state.addChildParam(action.param);
}

//---------------------------------------------------------------------------
AFRouteState _navRemoveChildParam(AFRouteState state, AFNavigateRemoveChildParamAction action) {
  return state.removeChildParam(
    screenId: action.screen, 
    wid: action.widget, 
    routeLocation: action.route);
}

//---------------------------------------------------------------------------
AFRouteState _navExitTest(AFRouteState state, AFNavigateExitTestAction action) {
  return state.exitTest();
}

//---------------------------------------------------------------------------
AFRouteState _resetToInitialRoute(AFRouteState state, AFResetToInitialRouteAction action) {
  return state.resetToInitialRoute();
}

//---------------------------------------------------------------------------
AFRouteState _updateTimeRouteParameters(AFRouteState state, AFUpdateTimeRouteParametersAction action) {
  return state.updateTimeRouteParameters(action.now);
}

//---------------------------------------------------------------------------
AFRouteState _navShowScreenBegin(AFRouteState state, AFNavigateShowScreenBeginAction action) {
  return state.showScreenBegin(action.screen, action.uiType);
}

//---------------------------------------------------------------------------
AFRouteState _navShowScreenEnd(AFRouteState state, AFNavigateShowScreenEndAction action) {
  return state.showScreenEnd(action.screen);
}
