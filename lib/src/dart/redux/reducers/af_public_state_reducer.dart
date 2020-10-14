

import 'package:afib/src/dart/redux/state/af_state.dart';
import 'package:afib/src/dart/redux/reducers/af_app_state_reducer.dart';
import 'package:afib/src/dart/redux/reducers/af_route_reducer.dart';

AFPublicState afPublicStateReducer(AFPublicState state, dynamic action) {

  return state.copyWith(
    route: routeReducer(state.route, action),
    app: afAppStateReducer(state.app, action)
  );
}