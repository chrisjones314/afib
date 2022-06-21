import 'package:afib/src/dart/command/af_command.dart';
import 'package:afib/src/dart/redux/actions/af_action_with_key.dart';
import 'package:afib/src/dart/redux/state/models/af_app_state.dart';
import 'package:afib/src/dart/utils/af_config.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/flutter/utils/af_state_view.dart';

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
typedef AFInitializeComponentStateDelegate = AFComponentState? Function();

/// Delegate use to define commands that are part of the afib command-line app.
typedef AFExtendCommandsDelegate = void Function(AFCommandAppExtensionContext context);

/// Used by third party extensions to defined commands for the command-line app.
typedef AFExtendCommandsLibraryDelegate = void Function(AFCommandUILibraryExtensionContext context);

/// Just a typed sort function.
typedef AFTypedSortDelegate<TSort> = int Function(TSort left, TSort right);

// Used to work around inability to instantiate templated types
typedef AFCreateStateViewDelegate<TStateView extends AFFlexibleStateView> = TStateView Function(Map<String, Object> models);

// Used to work around inability to instantiate templated types
typedef AFCreateComponentStateDelegate = AFComponentState Function(Map<String, Object> models);

/// Used to create a default child param the first time a particular child wid is used.
typedef AFCreateDefaultChildParamDelegate = AFRouteParam? Function(AFID wid, dynamic public, dynamic segParent);

