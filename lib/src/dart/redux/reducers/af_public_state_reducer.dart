

import 'package:afib/src/dart/redux/reducers/af_app_area_state_reducer.dart';
import 'package:afib/src/dart/redux/reducers/af_query_state_reducer.dart';
import 'package:afib/src/dart/redux/reducers/af_route_reducer.dart';
import 'package:afib/src/dart/redux/reducers/af_theme_state_reducer.dart';
import 'package:afib/src/dart/redux/state/af_state.dart';

AFPublicState afPublicStateReducer(AFPublicState state, dynamic action) {

  return state.copyWith(
    route: routeReducer(state.route, action),
    themes: afThemeStateReducer(state.themes, action),
    components: afComponentStateReducer(state.components, action),
    queries: afQueryStateReducer(state.queries, action)
  );
}