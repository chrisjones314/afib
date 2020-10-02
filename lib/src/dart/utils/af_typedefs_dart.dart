

import 'package:afib/src/dart/redux/actions/af_action_with_key.dart';
import 'package:afib/src/dart/utils/af_config.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';

/// Delegate used in various subclasses of [AFNavigateAction] to return data from a child screen to a parent.
typedef AFActionOnReturnDelegate = void Function(dynamic returnData);

/// Delegate used to populate a configuration object with values.
typedef AFInitConfigurationDelegate = void Function(AFConfig config);

/// Delegate used to create a reducer for the overall app state.
typedef AFAppReducerDelegate<TAppState> = TAppState Function(TAppState appState, dynamic action);

/// Delegate used to create an app-specific query that is run when the app first starts.
typedef AFCreateStartupQueryActionDelegate = dynamic Function();

/// Delegate used to process a list of actions.
typedef AFActionListenerDelegate = void Function(List<AFActionWithKey> actions);

/// Delegate used to process a route parameter
typedef AFParamListenerDelegate = void Function(AFRouteParam param);

/// Delegate used to create the initial applications state.
typedef AFInitializeAppStateDelegate = dynamic Function();
