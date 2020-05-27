
import 'dart:core';
import 'package:afib/src/dart/redux/actions/af_navigation_actions.dart';
import 'package:afib/src/dart/redux/state/af_state.dart';
import 'package:afib/src/flutter/af.dart';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';

//---------------------------------------------------------------------------
List<Middleware<AFState>> createRouteMiddleware() {
  return [
    TypedMiddleware<AFState, AFNavigateReplaceAction>(_navigateReplaceAction),
    TypedMiddleware<AFState, AFNavigateReplaceAllAction>(_navigateReplaceAllAction),
    TypedMiddleware<AFState, AFNavigatePushAction>(_navigatePushAction),
    TypedMiddleware<AFState, AFNavigatePopAction>(_navigatePopAction)
  ];
}

// AsyncAction
//   onStart
//   onReduce

//   onStartAsync
//   onFinishAsync
//   onErrorAsync


//final dfMiddleware = createMiddleware();

//---------------------------------------------------------------------------
void _navigatePushAction(Store<AFState> store, action, NextDispatcher next) {

  Future<dynamic> ret = AF.navigatorKey.currentState?.pushNamed(action.screen);
  if(ret != null && action.onReturn != null) {
    ret.then( (msg) {
      action.onReturn(msg);
    });
  }
  next(action);
}

//---------------------------------------------------------------------------
void _navigatePopAction(Store<AFState> store, action, NextDispatcher next) {
  AF.navigatorKey.currentState?.pop(action.returnData);
  next(action);
}

//---------------------------------------------------------------------------
void _navigateReplaceAction(Store<AFState> store, action, NextDispatcher next) {
  final String screen = action.screen;

  // first, we do the navigation itself
  AF.navigatorKey.currentState?.popAndPushNamed(screen);

  // then, let the reducer integrate that state into the store.
  next(action);

}

//---------------------------------------------------------------------------
void _navigateReplaceAllAction(Store<AFState> store, action, NextDispatcher next) {
  final String screen = action.screen;

  // first, we do the navigation itself
  AF.navigatorKey.currentState?.pushNamedAndRemoveUntil(screen, (Route<dynamic> route) => false);

  // then, let the reducer integrate that state into the store.
  next(action);

}
