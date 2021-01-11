
import 'dart:core';
import 'package:afib/src/dart/redux/actions/af_route_actions.dart';
import 'package:afib/src/dart/redux/state/af_route_state.dart';
import 'package:afib/src/dart/redux/state/af_state.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:redux/redux.dart';

//---------------------------------------------------------------------------
List<Middleware<AFState>> createRouteMiddleware() {
  return [
    TypedMiddleware<AFState, AFNavigateReplaceAction>(_navigateReplaceAction),
    TypedMiddleware<AFState, AFNavigateReplaceAllAction>(_navigateReplaceAllAction),
    TypedMiddleware<AFState, AFNavigatePushAction>(_navigatePushAction),
    TypedMiddleware<AFState, AFNavigatePopAction>(_navigatePopAction),
    TypedMiddleware<AFState, AFNavigatePopNAction>(_navigatePopNAction),
    TypedMiddleware<AFState, AFNavigatePopToAction>(_navigatePopToAction),
    TypedMiddleware<AFState, AFNavigateExitTestAction>(_navigateExitTestAction),
    TypedMiddleware<AFState, AFNavigatePopNavigatorOnlyAction>(_navigatePopNavOnlyAction),
  ];
}



//---------------------------------------------------------------------------
AFRouteState _getRouteState(Store<AFState> store) {
  final state = store.state;
  return state.public.route;
}

//---------------------------------------------------------------------------
void _navigatePushAction(Store<AFState> store, action, NextDispatcher next) {

  AFibF.g.doMiddlewareNavigation((navState) {
    Future<dynamic> ret = navState.pushNamed(action.screen.code);
    if(ret != null && action.onReturn != null) {
      ret.then( (msg) {
        action.onReturn(msg);
      });
    }
  });
  next(action);
}

//---------------------------------------------------------------------------
void _navigatePopAction(Store<AFState> store, action, NextDispatcher next) {

  final route = _getRouteState(store);

  /// If the segment count is 1
  if(route.segmentCount == 1) {
    throw AFException("You popped the topmost screen.  This is an error.  You need to use AFNavigateReplace action to pop/push at the same time in this case");
  }

  AFibF.g.doMiddlewareNavigation((navState) {
    navState.pop(action.returnData);
  });
  next(action);
}

//---------------------------------------------------------------------------
void _navigatePopNAction(Store<AFState> store, action, NextDispatcher next) {
  final AFNavigatePopNAction popN = action;
  final route = _getRouteState(store);

  /// If the segment count is 1
  if(route.segmentCount <= popN.popCount) {
    throw AFException("You popped ${popN.popCount} screen but the route only has ${route.segmentCount} segments");
  }

  AFibF.g.doMiddlewareNavigation( (navState) {
    for(var i = 0; i < popN.popCount; i++) {
      navState.pop(action.returnData);
    }
  });
  next(action);
}

//---------------------------------------------------------------------------
void _navigatePopToAction(Store<AFState> store, action, NextDispatcher next) {
  final AFNavigatePopToAction popTo = action;
  final route = _getRouteState(store);

  final popCountTo = route.popCountToScreen(popTo.popTo);
  /// If the segment count is 1
  if(popCountTo < 0) {
    throw AFException("Could not pop to ${popTo.popTo} because that screen is not in the route.");
  }

  AFibF.g.doMiddlewareNavigation( (navState) {
    for(var i = 0; i < popCountTo; i++) {
      navState.pop(action.returnData);
    }
    if(popTo.push != null) {
      navState.pushNamed(popTo.push.screen.code);
    }
  });
  next(action);
}


//---------------------------------------------------------------------------
void _navigateReplaceAction(Store<AFState> store, action, NextDispatcher next) {
  final String screen = action.screen.code;

  // first, we do the navigation itself
  AFibF.g.doMiddlewareNavigation( (navState) {
    navState.popAndPushNamed(screen);
  });

  // then, let the reducer integrate that state into the store.
  next(action);

}

//---------------------------------------------------------------------------
void _navigateReplaceAllAction(Store<AFState> store, action, NextDispatcher next) {
  final String screen = action.screen.code;
  
  // In prototype mode, we don't want to remove any afib screens, so we need to remove only those screens
  // below test.
  final route = _getRouteState(store);
  AFibF.g.doMiddlewareNavigation((navState) {
    final popCount = route.popCountToRoot;
    for(var i = 0; i < popCount - 1; i++) {
      navState.pop();
    }
    navState.popAndPushNamed(screen);
  });


  // then, let the reducer integrate that state into the store.
  next(action);

}

//---------------------------------------------------------------------------
void _navigatePopNavOnlyAction(Store<AFState> store, action, NextDispatcher next) {
  AFibF.g.doMiddlewareNavigation((navState) {
    navState.pop();
  });
}

//---------------------------------------------------------------------------
void _navigateExitTestAction(Store<AFState> store, action, NextDispatcher next) {
  /// Clear out our cache of screen info for the next test.
  //AFibF.g.resetTestScreens();

  final route = _getRouteState(store);
  final popCount = route.popCountToRoot;
  AFibF.g.doMiddlewareNavigation( (navState) {
    for(var i = 0; i < popCount; i++) {
      navState.pop();
    }
  });
  next(action);
}
