
import 'dart:core';
import 'package:afib/src/dart/redux/actions/af_navigation_actions.dart';
import 'package:afib/src/dart/redux/state/af_route_state.dart';
import 'package:afib/src/dart/redux/state/af_state.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/utils/af_custom_popup_route.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';

//---------------------------------------------------------------------------
List<Middleware<AFState>> createRouteMiddleware() {
  return [
    TypedMiddleware<AFState, AFNavigateReplaceAction>(_navigateReplaceAction),
    TypedMiddleware<AFState, AFNavigateReplaceAllAction>(_navigateReplaceAllAction),
    TypedMiddleware<AFState, AFNavigatePushAction>(_navigatePushAction),
    TypedMiddleware<AFState, AFNavigatePushPopupAction>(_navigatePushPopupAction),
    TypedMiddleware<AFState, AFNavigatePopAction>(_navigatePopAction),
    TypedMiddleware<AFState, AFNavigateExitTestAction>(_navigateExitTestAction)
  ];
}

//---------------------------------------------------------------------------
AFRouteState _getRouteState(Store<AFState> store) {
  final state = store.state;
  return state.route;
}

//---------------------------------------------------------------------------
void _navigatePushPopupAction(Store<AFState> store, act, NextDispatcher next) {
  AFNavigatePushPopupAction action = act;

  Future<dynamic> ret = Navigator.push(
        action.context,
        new AFCustomPopupRoute(
            //dispatcher: dispatcher,
            //param: param,
            //onChanged: onChanged,
            //onConfirm: onConfirm,
            childBuilder: action.popupBuilder,
            theme: action.theme,
            barrierLabel: "Dismiss",
        )
  );
  if(ret != null && action.onReturn != null) {
    ret.then( (msg) {
      action.onReturn(msg);
    });
  }
  next(action);
}

//---------------------------------------------------------------------------
void _navigatePushAction(Store<AFState> store, action, NextDispatcher next) {


  Future<dynamic> ret = AFibF.navigatorKey.currentState?.pushNamed(action.screen.code);
  if(ret != null && action.onReturn != null) {
    ret.then( (msg) {
      action.onReturn(msg);
    });
  }
  next(action);
}

//---------------------------------------------------------------------------
void _navigatePopAction(Store<AFState> store, action, NextDispatcher next) {

  final route = _getRouteState(store);

  /// If the segment count is 1
  if(route.segmentCount == 1) {
    throw AFException("You popped the topmost screen.  This is an error.  You need to use AFNavigateReplace action to pop/push at the same time in this case");
  }

  AFibF.navigatorKey.currentState?.pop(action.returnData);
  next(action);
}

//---------------------------------------------------------------------------
void _navigateReplaceAction(Store<AFState> store, action, NextDispatcher next) {
  final String screen = action.screen.code;

  // first, we do the navigation itself
  AFibF.navigatorKey.currentState?.popAndPushNamed(screen);

  // then, let the reducer integrate that state into the store.
  next(action);

}

//---------------------------------------------------------------------------
void _navigateReplaceAllAction(Store<AFState> store, action, NextDispatcher next) {
  final String screen = action.screen.code;
  final navState = AFibF.navigatorKey.currentState;
  
  // In prototype mode, we don't want to remove any afib screens, so we need to remove only those screens
  // below test.
  final route = _getRouteState(store);
  final popCount = route.popCountToRoot;
  for(int i = 0; i < popCount - 1; i++) {
    navState?.pop();
  }
  navState?.popAndPushNamed(screen);

  // then, let the reducer integrate that state into the store.
  next(action);

}


//---------------------------------------------------------------------------
void _navigateExitTestAction(Store<AFState> store, action, NextDispatcher next) {
  final navState = AFibF.navigatorKey.currentState;
  final route = _getRouteState(store);
  final popCount = route.popCountToRoot;
  for(int i = 0; i < popCount; i++) {
    navState?.pop();
  }
  next(action);
}
