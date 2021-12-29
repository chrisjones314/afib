import 'dart:core';

import 'package:afib/id.dart';
import 'package:afib/src/dart/redux/actions/af_route_actions.dart';
import 'package:afib/src/dart/redux/state/af_state.dart';
import 'package:afib/src/dart/redux/state/models/af_route_state.dart';
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
    TypedMiddleware<AFState, AFWireframeEventAction>(_navigateWireframe),
  ];
}



//---------------------------------------------------------------------------
AFRouteState _getRouteState(Store<AFState> store) {
  final state = store.state;
  return state.public.route;
}

//---------------------------------------------------------------------------
void _navigatePushAction(Store<AFState> store, AFNavigatePushAction action, NextDispatcher next) {

  AFibF.g.doMiddlewareNavigation((navState) {
    Future<dynamic> ret = navState.pushNamed(action.param.id.code);
    final onReturn = action.onReturn;
    if(onReturn != null) {
      ret.then( (msg) {
        onReturn(msg);
      });
    }
  });
  next(action);
}

//---------------------------------------------------------------------------
void _navigatePopAction(Store<AFState> store, AFNavigatePopAction action, NextDispatcher next) {

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
void _navigatePopNAction(Store<AFState> store, AFNavigatePopNAction action, NextDispatcher next) {
  final route = _getRouteState(store);

  /// If the segment count is 1
  if(route.segmentCount <= action.popCount) {
    throw AFException("You popped ${action.popCount} screen but the route only has ${route.segmentCount} segments");
  }

  AFibF.g.doMiddlewareNavigation( (navState) {
    for(var i = 0; i < action.popCount; i++) {
      navState.pop(action.returnData);
    }
  });
  next(action);
}

//---------------------------------------------------------------------------
void _navigatePopToAction(Store<AFState> store, AFNavigatePopToAction action, NextDispatcher next) {
  final route = _getRouteState(store);

  final popCountTo = route.popCountToScreen(action.popTo);
  /// If the segment count is 1
  if(popCountTo < 0) {
    throw AFException("Could not pop to ${action.popTo} because that screen is not in the route.");
  }

  AFibF.g.doMiddlewareNavigation( (navState) {
    for(var i = 0; i < popCountTo; i++) {
      navState.pop(action.returnData);
    }
    final screenCode = action.push?.param.id.code;
    if(screenCode != null) {
      navState.pushNamed(screenCode);
    }
  });
  next(action);
}


//---------------------------------------------------------------------------
void _navigateReplaceAction(Store<AFState> store, AFNavigateReplaceAction action, NextDispatcher next) {
  final screen = action.param.id.code;

  // first, we do the navigation itself
  AFibF.g.doMiddlewareNavigation( (navState) {
    navState.popAndPushNamed(screen);
  });

  // then, let the reducer integrate that state into the store.
  next(action);

}

//---------------------------------------------------------------------------
void _navigateReplaceAllAction(Store<AFState> store, AFNavigateReplaceAllAction action, NextDispatcher next) {
  final screen = action.param.id.code;
  
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
void _navigateExitTestAction(Store<AFState> store, AFNavigateExitTestAction action, NextDispatcher next) {
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

//---------------------------------------------------------------------------
void _navigateWireframe(Store<AFState> store, AFWireframeEventAction action, NextDispatcher next) {
  /// see if we are under a wireframe.
  final testStateSource = store.state.private.testState;
  final wireframe = testStateSource.activeWireframe;
  if(wireframe != null) {
    final testState = testStateSource.findState(AFUIReusableTestID.wireframe);
    wireframe.onEvent(action.screen, action.widget, action.eventParam, testState?.models ?? <String, Object>{});
  }
  next(action);
}
