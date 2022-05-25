

import 'package:afib/src/dart/redux/reducers/af_app_area_state_reducer.dart';
import 'package:afib/src/dart/redux/reducers/af_query_state_reducer.dart';
import 'package:afib/src/dart/redux/reducers/af_route_reducer.dart';
import 'package:afib/src/dart/redux/reducers/af_theme_state_reducer.dart';
import 'package:afib/src/dart/redux/reducers/af_time_state_reducer.dart';
import 'package:afib/src/dart/redux/state/af_state.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';

AFPublicState afPublicStateReducer(AFPublicState state, dynamic action) {

  final revised = state.copyWith(
    route: routeReducer(state.route, action),
    themes: afThemeStateReducer(state.themes, action),
    components: afComponentStateReducer(state.components, action),
    queries: afQueryStateReducer(state.queries, action),
    time: afTimeStateReducer(state.time, action),
  );

  AFibF.g.activeStateChangeController.add(AFPublicStateChange(
    action: action,
    before: state,
    after: revised
  ));
  
  return revised;
}