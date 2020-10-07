
import 'package:afib/src/dart/redux/actions/af_async_query.dart';
import 'package:afib/src/dart/redux/state/af_app_state.dart';
import 'package:afib/src/flutter/test/af_state_test.dart';
import 'package:afib/src/flutter/test/af_unit_tests.dart';
import 'package:flutter/material.dart';

import 'package:afib/src/dart/redux/actions/af_navigation_actions.dart';
import 'package:afib/src/dart/redux/state/af_state.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/flutter/af_app.dart';
import 'package:afib/src/flutter/core/af_screen_map.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/test/af_prototype_widget_screen.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:afib/src/flutter/test/af_test_data_registry.dart';
import 'package:afib/src/flutter/utils/af_custom_popup_route.dart';

/// Delegate used to populate the screen map used to associate keys with screens.
typedef AFInitScreenMapDelegate = void Function(AFScreenMap map);

/// Delegate used to create a query anytime the app has a lifecyle event, like coming to the foreground.
typedef AFCreateLifecycleQueryAction = dynamic Function(AppLifecycleState state);

/// Delegate used to handle a lifecycle event
typedef AFOnLifecycleEventDelegate = void Function(AppLifecycleState newState);

/// Delegate used to create an application specific [AFApp] subclass.
typedef AFCreateAFAppDelegate = AFApp Function();

/// Delegate used to populate widget tests.
typedef AFInitWidgetTestsDelegate = void Function(AFWidgetTests tests, AFTestDataRegistry testData);

/// Delegate used to populate single-screen tests.
typedef AFInitScreenTestsDelegate = void Function(AFSingleScreenTests tests, AFTestDataRegistry testData);

/// Delegate used to populate multi-screen tests.
typedef AFInitMultiScreenStateTestsDelegate = void Function(AFMultiScreenStateTests tests, AFTestDataRegistry testData);

/// Delegate used to perform an asynchronous operation (like an alert, and say whether it should continue).
typedef AFShouldContinueCheckDelegate = Future<int> Function();

/// Delegate used to update the route param
typedef AFUpdateParamDelegate<TRouteParam> = Function(AFDispatcher dispatcher, TRouteParam param, { AFID id });

/// Delegate used to extract one route param from another, useful in nesting cases where one route param
/// contains other route params that correspond to certain widgets within a screen.
typedef AFExtractParamDelegate = AFRouteParam Function(AFRouteParam original);

/// Delegate used to create data used by a screen or widget from the application state.
typedef AFCreateDataDelegate<TData, TState> = TData Function(TState state);

/// Delegate used to find the route parameter for a screen within the AFState
typedef AFFindParamDelegate = AFRouteParam Function(AFState state);

/// Delegate used in widget testing to wrap additional widgets around the widget being tested 
/// (e.g. to position that widget on the screen, limit its width, etc.)
typedef AFCreateWidgetWrapperDelegate = Widget Function(AFBuildContext<AFPrototypeWidgetData, AFPrototypeWidgetRouteParam> context, Widget testWidget);

/// Delegate used to create a push action that moves us into a test screen.
typedef AFTestCreatePushActionDelegate = AFNavigatePushAction Function(AFScreenPrototypeTest test);

/// Delegate used to implmeent the body of a single screen test.
typedef AFScreenTestBodyExecuteDelegate = Future<void> Function(AFScreenTestExecute ste);

/// Delegate used to create a widget in a widget test.
typedef AFCreateConnectedWidgetDelegate = AFConnectedWidgetWithParam Function(
  AFDispatcher dispatcher,
  AFFindParamDelegate findParamDelegate,
  AFUpdateParamDelegate updateParamDelegate,
);

/// Delegate used to implement the boyd of a multi screen test.
typedef AFMultiScreenTestBodyExecuteDelegate = Future<void> Function(AFMultiScreenTestExecute mse);

/// Delegate used to creatae a widget builder.
typedef AFWidgetBuilderDelegate<TData extends AFStoreConnectorData, TRouteParam extends AFRouteParam> = Widget Function(AFBuildContext<TData, TRouteParam> context);

/// Used to create a widget from a custom popup route.
typedef AFPopupRouteWidgetBuilderDelegate = Widget Function(BuildContext ctx, AFCustomPopupRoute route);

/// Delegate used to initialize test data 
typedef AFInitTestDataDelegate = void Function(AFTestDataRegistry registry);

/// Delegate used to initialize unit tests.
typedef AFInitUnitTestsDelegate = void Function(AFUnitTests tests, AFTestDataRegistry testData);

/// Delegate used to initialize state tests.
typedef AFInitStateTestsDelegate = void Function(AFStateTests tests, AFTestDataRegistry testData);

/// Delegate 
typedef AFProcessQueryDelegate = void Function(AFStateTestContext context, AFAsyncQuery query);

/// Delegate used to process a state test.
typedef AFProcessTestDelegate = void Function(AFStateTest test);

/// Delegate used to verify a state change, from before to after
typedef AFProcessVerifyDelegate = void Function(AFStateTestExecute execute, AFAppState stateBefore, AFAppState stateAfter);

/// Delegate used to implement the body of a unit test.
typedef AFUnitTestBodyExecuteDelegate = void Function(AFUnitTestExecute e);

/// Delegate used when an [AFAsyncQuery] results in a successful response.
typedef AFOnResponseDelegate<TState, TResponse> = void Function(AFFinishQuerySuccessContext<TState, TResponse> context);

/// Delegate used when an [AFAsyncQuery] results in an error.
typedef AFOnErrorDelegate<TState, TError> = void Function(AFFinishQueryErrorContext<TState, TError> context);

/// Delegate used to process an [AFAsyncQuery]
typedef AFAsyncQueryListenerDelegate = void Function(AFAsyncQuery query);

/// Delegate used to fill a list of widgets.
typedef AFFillWidgetListDelegate = void Function(List<Widget> widgets);
