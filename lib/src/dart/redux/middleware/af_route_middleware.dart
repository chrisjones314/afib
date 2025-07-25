import 'dart:core';

import 'package:afib/src/dart/redux/actions/af_route_actions.dart';
import 'package:afib/src/dart/redux/state/af_state.dart';
import 'package:afib/src/dart/redux/state/models/af_route_state.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';

//---------------------------------------------------------------------------
List<Middleware<AFState>> createRouteMiddleware() {
  return [
    TypedMiddleware<AFState, AFNavigateReplaceAction>(_navigateReplaceAction).call,
    TypedMiddleware<AFState, AFNavigateReplaceAllAction>(_navigateReplaceAllAction).call,
    TypedMiddleware<AFState, AFNavigatePushAction>(_navigatePushAction).call,
    TypedMiddleware<AFState, AFNavigatePopAction>(_navigatePopAction).call,
    TypedMiddleware<AFState, AFNavigatePopNAction>(_navigatePopNAction).call,
    TypedMiddleware<AFState, AFNavigatePopToAction>(_navigatePopToAction).call,
    TypedMiddleware<AFState, AFNavigateExitTestAction>(_navigateExitTestAction).call,
    TypedMiddleware<AFState, AFWireframeEventAction>(_navigateWireframe).call,
    TypedMiddleware<AFState, AFNavigateSyncNavigatorStateWithRoute>(_navigateSyncNavigatorState).call,
  ];
}

//---------------------------------------------------------------------------
AFRouteState _getRouteState(Store<AFState> store) {
  final state = store.state;
  return state.public.route;
}

//---------------------------------------------------------------------------
String _screenIdToNavigatorName(AFID id) {
  return id.code;
}

//---------------------------------------------------------------------------
void _navigatePushAction(Store<AFState> store, AFNavigatePushAction action, NextDispatcher next) {

  AFibF.g.doMiddlewareNavigation((navState) {
    final transition = action.transitionsBuilder;
    if(transition == null) {
      Future<dynamic> ret = navState.pushNamed(_screenIdToNavigatorName(action.param.screenId));
      final onReturn = action.onReturn;
      if(onReturn != null) {
        ret.then( (msg) {
          onReturn(msg);
        });
      }
    } else {
      final pageBuilder = _createPageRouteBuilder(action, transition);
      navState.push(pageBuilder);
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
    final screenCode = action.push?.param.screenId.code;
    if(screenCode != null) {
      navState.pushNamed(screenCode);
    }
  });
  next(action);
}


//---------------------------------------------------------------------------
void _navigateReplaceAction(Store<AFState> store, AFNavigateReplaceAction action, NextDispatcher next) {
  final screen = _screenIdToNavigatorName(action.param.screenId);

  // first, we do the navigation itself
  AFibF.g.doMiddlewareNavigation( (navState) {
    navState.popAndPushNamed(screen);
  });

  // then, let the reducer integrate that state into the store.
  next(action);

}


//---------------------------------------------------------------------------
PageRouteBuilder _createPageRouteBuilder(AFNavigateAction action, RouteTransitionsBuilder transition) {
  return PageRouteBuilder(
    pageBuilder: ((context, animation, secondaryAnimation) {
      // we need to lookup the builder in the screen map
      final screenBuilder = AFibF.g.screenMap.findBy(action.param.screenId);
      if(screenBuilder == null) {
        throw AFException("Missing screen builder for screen ${action.param.screenId}");
      }
      return screenBuilder(context);
    }),
    transitionsBuilder: transition,
  );
}

//---------------------------------------------------------------------------
void _navigateReplaceAllAction(Store<AFState> store, AFNavigateReplaceAllAction action, NextDispatcher next) {
  final screen = _screenIdToNavigatorName(action.param.screenId);
  
  // In prototype mode, we don't want to remove any afib screens, so we need to remove only those screens
  // below test.
  final route = _getRouteState(store);
  AFibF.g.doMiddlewareNavigation((navState) {
    final popCount = route.popCountToRoot;
    for(var i = 0; i < popCount - 1; i++) {
      navState.pop();
    }
    final transition = action.transitionsBuilder;
    if(transition == null) {
      navState.popAndPushNamed(screen);
    } else {
      final pageBuilder = _createPageRouteBuilder(action, transition);
      navState.pushReplacement(pageBuilder);
    }
  });


  // then, let the reducer integrate that state into the store.
  next(action);

}

//---------------------------------------------------------------------------
void _navigateExitTestAction(Store<AFState> store, AFNavigateExitTestAction action, NextDispatcher next) {
  /// Clear out our cache of screen info for the next test.
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
    wireframe.onEvent(action.screen, action.widget, action.eventParam, action.stateView, action.onSuccess);
  }
  next(action);
}

//---------------------------------------------------------------------------
void _navigateSyncNavigatorState(Store<AFState> store, AFNavigateSyncNavigatorStateWithRoute action, NextDispatcher next) {
  final route = action.route;
  final hierarchy = route.screenHierarchy.active;
  
  AFibF.g.doMiddlewareNavigation( (navState) {
    // first, pop off all but one screen.
    while(navState.canPop()) {
      navState.pop();
    }
    for(var i = 0; i < hierarchy.length; i++) {
      final segment = hierarchy[i];
      final screenName = _screenIdToNavigatorName(segment.screen);
      if(i == 0) {
        navState.popAndPushNamed(screenName);
      } else {
        navState.pushNamed(screenName);
      }
    }
  });

  next(action);
}
