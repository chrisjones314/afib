

import 'package:afib/src/dart/redux/reducers/af_theme_state_reducer.dart';
import 'package:afib/src/dart/redux/state/af_state.dart';
import 'package:afib/src/dart/redux/reducers/af_app_area_state_reducer.dart';
import 'package:afib/src/dart/redux/reducers/af_route_reducer.dart';

AFPublicState afPublicStateReducer(AFPublicState state, dynamic action) {

  return state.copyWith(
    route: routeReducer(state.route, action),
    themes: afThemeStateReducer(state.themes, action),
    areas: afAppAreaStateReducer(state.areas, action)
  );
}