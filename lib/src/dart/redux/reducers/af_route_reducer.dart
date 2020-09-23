import 'package:afib/src/dart/redux/actions/af_navigation_actions.dart';
import 'package:afib/src/dart/redux/state/af_route_state.dart';
import 'package:redux/redux.dart';

//---------------------------------------------------------------------------
final routeReducer = combineReducers<AFRouteState>([
  TypedReducer<AFRouteState, AFNavigateReplaceAction>(_navReplace),
  TypedReducer<AFRouteState, AFNavigateReplaceAllAction>(_navReplaceAll),
  TypedReducer<AFRouteState, AFNavigatePushPopupAction>(_navPushPopup),
  TypedReducer<AFRouteState, AFNavigatePushAction>(_navPush),
  TypedReducer<AFRouteState, AFNavigatePopAction>(_navPop),
  TypedReducer<AFRouteState, AFNavigatePopNAction>(_navPopN),
  TypedReducer<AFRouteState, AFNavigatePopToAction>(_navPopTo),
  TypedReducer<AFRouteState, AFNavigateSetParamAction>(_navSetParam),
  TypedReducer<AFRouteState, AFNavigateExitTestAction>(_navExitTest),
  TypedReducer<AFRouteState, AFNavigatePopPopupAction>(_navPopPopup),
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
AFRouteState _navPushPopup(AFRouteState state, AFNavigatePushPopupAction action) {
  return state.pushPopup(action.screen, action.param);
}

//---------------------------------------------------------------------------
AFRouteState _navPopPopup(AFRouteState state, AFNavigatePopPopupAction action) {
  return state.popPopup(action.screen, action.param);
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
  return state.popTo(action.popTo, action.returnData);
}


//---------------------------------------------------------------------------
AFRouteState _navSetParam(AFRouteState state, AFNavigateSetParamAction action) {
  return state.setParam(action.screen, action.param);
}

//---------------------------------------------------------------------------
AFRouteState _navExitTest(AFRouteState state, AFNavigateExitTestAction action) {
  return state.exitTest();
}

