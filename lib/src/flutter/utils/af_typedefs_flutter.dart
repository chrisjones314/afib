
import 'package:afib/src/dart/redux/actions/af_async_query.dart';
import 'package:afib/src/dart/redux/state/af_app_state.dart';
import 'package:afib/src/dart/redux/state/af_theme_state.dart';
import 'package:afib/src/dart/utils/af_should_continue_route_param.dart';
import 'package:afib/src/flutter/core/af_app_extension_context.dart';
import 'package:afib/src/flutter/test/af_state_test.dart';
import 'package:afib/src/flutter/test/af_unit_tests.dart';
import 'package:afib/src/flutter/ui/theme/af_prototype_theme.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/ui/screen/af_prototype_widget_screen.dart';
import 'package:afib/src/flutter/utils/af_dispatcher.dart';
import 'package:flutter/material.dart';

import 'package:afib/src/dart/redux/state/af_state.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/flutter/af_app.dart';
import 'package:afib/src/flutter/core/af_screen_map.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:afib/src/flutter/test/af_test_data_registry.dart';

/// Delegate used to populate the screen map used to associate keys with screens.
typedef AFInitScreenMapDelegate = void Function(AFScreenMap map);

/// Delegate used to create a query anytime the app has a lifecyle event, like coming to the foreground.
typedef AFCreateLifecycleQueryAction = dynamic Function(AppLifecycleState state);

/// Delegate used to handle a lifecycle event
typedef AFOnLifecycleEventDelegate = void Function(AppLifecycleState newState);

/// Delegate used to create an application specific [AFApp] subclass.
typedef AFCreateAFAppDelegate = AFApp Function();

/// Delegate used to populate widget tests.
typedef AFInitWidgetTestsDelegate = void Function(AFWidgetTestDefinitionContext definitions);

/// Delegate used to populate single-screen tests.
typedef AFInitScreenTestsDelegate = void Function(AFSingleScreenTestDefinitionContext definitions);

/// Delegate used to populate multi-screen tests.
typedef AFInitWorkflowStateTestsDelegate = void Function(AFWorkflowTestDefinitionContext definitions);

/// Delegate used to perform an asynchronous operation (like an alert, and say whether it should continue).
typedef AFShouldContinueCheckDelegate = Future<AFShouldContinue> Function();
typedef AFShouldContinueCheckDelegateObsolete = Future<int> Function();

/// Delegate used to update the route param
typedef AFUpdateParamDelegate<TRouteParam> = Function(AFDispatcher dispatcher, TRouteParam param, { AFID id });

/// Delegate used to extract one route param from another, useful in nesting cases where one route param
/// contains other route params that correspond to certain widgets within a screen.
typedef AFExtractParamDelegate = AFRouteParam Function(AFRouteParam original);

/// Delegate used to create data used by a screen or widget from the application state.
typedef AFCreateDataDelegate<TStateView, TState> = TStateView Function(TState state);

/// Delegate used to find the route parameter for a screen within the AFState
typedef AFFindParamDelegate = AFRouteParam Function(AFState state);

/// Used to pass in a functiont hat handles route parameter updates in AFEmbeddedWidget
typedef AFUpdateRouteParamDelegate = void Function(AFBuildContext context, AFRouteParam revised, { AFID id });

/// Delegate used in widget testing to wrap additional widgets around the widget being tested 
/// (e.g. to position that widget on the screen, limit its width, etc.)
typedef AFCreateWidgetWrapperDelegate = Widget Function(AFBuildContext<AFPrototypeWidgetStateView, AFPrototypeWidgetRouteParam, AFPrototypeTheme> context, Widget testWidget);

/// Delegate used to create a push action that moves us into a test screen.
typedef AFTestCreatePushActionDelegate = List<dynamic> Function(AFScreenPrototypeTest test);

/// Delegate used to implmeent the body of a single screen test.
typedef AFScreenTestBodyExecuteDelegate = Future<void> Function(AFScreenTestExecute ste);

/// Delegate used to implement the body of a reusable single screen test that 
typedef AFReusableScreenTestBodyExecuteDelegate1 = Future<void> Function(AFScreenTestExecute ste, dynamic param1);
typedef AFReusableScreenTestBodyExecuteDelegate2 = Future<void> Function(AFScreenTestExecute ste, dynamic param1, dynamic param2);
typedef AFReusableScreenTestBodyExecuteDelegate3 = Future<void> Function(AFScreenTestExecute ste, dynamic param1, dynamic param2, dynamic param3);

/// Delegate used to implement the boyd of a multi screen test.
typedef AFWorkflowTestBodyExecuteDelegate = Future<void> Function(AFWorkflowTestExecute mse);

/// Delegate used to creatae a widget builder.
typedef AFWidgetBuilderDelegate<TBuildContext extends AFBuildContext> = Widget Function(TBuildContext context);

/// Delegate used to initialize test data 
typedef AFInitTestDataDelegate = void Function(AFTestDataRegistry registry);

/// Delegate used to initialize unit tests.
typedef AFInitUnitTestsDelegate = void Function(AFUnitTestDefinitionContext definitions);

/// Delegate used to initialize state tests.
typedef AFInitStateTestsDelegate = void Function(AFStateTestDefinitionContext definitions);

/// Delegate 
typedef AFProcessQueryDelegate = void Function(AFStateTestContext context, AFAsyncQuery query);

/// Delegate used in state tests to create a mock result from a query.
typedef AFCreateQueryResultDelegate = dynamic Function(AFStateTestContext context, AFAsyncQuery query);

/// Delegate used to process a state test.
typedef AFProcessTestDelegate = void Function(AFStateTest test);

/// Delegate used to verify a state change, from before to after
typedef AFProcessVerifyDifferenceDelegate = void Function(AFStateTestExecute execute, AFStateTestDifference diff);

/// Delegate used to implement the body of a unit test.
typedef AFUnitTestBodyExecuteDelegate = void Function(AFUnitTestExecute e);

/// Delegate used when an [AFAsyncQuery] results in a successful response.
typedef AFOnResponseDelegate<TState extends AFAppStateArea, TResponse> = void Function(AFFinishQuerySuccessContext<TState, TResponse> context);

/// Delegate used when an [AFAsyncQuery] results in an error.
typedef AFOnErrorDelegate<TState extends AFAppStateArea> = void Function(AFFinishQueryErrorContext<TState> context);

/// Delegate used to process an [AFAsyncQuery]
typedef AFAsyncQueryListenerDelegate = void Function(AFAsyncQuery query);

/// Delegate used to fill a list of widgets.
typedef AFFillWidgetListDelegate = void Function(List<Widget> widgets);

/// Delegate used to register to listen to all queries on success.
typedef AFQuerySuccessListenerDelegate = void Function(AFAsyncQuery query, AFFinishQuerySuccessContext context);

/// Delegate used to create a route parameter.
typedef AFCreateRouteParamDelegate = AFRouteParam Function();

typedef AFChangedTextDelegate = void Function(String);

typedef AFPressedDelegate = void Function();
typedef AFOnTapDelegate = void Function();

typedef AFExtendUILibraryDelegate = void Function(AFUILibraryExtensionContext context);
typedef AFExtendAppDelegate = void Function(AFAppExtensionContext context);
typedef AFExtendTestDelegate = void Function(AFTestExtensionContext context);
typedef AFExtendThirdPartyDelegate = void Function(AFAppThirdPartyExtensionContext context);

/// Allows plug-ins to contribute fundamental theme values
typedef AFInitPluginFundamentalThemeDelegate = void Function(AFFundamentalDeviceTheme device, AFAppStateAreas appState, AFPluginFundamentalThemeAreaBuilder builder);

/// Allows the app to contribute fundamental theme values
typedef AFInitAppFundamentalThemeDelegate = void Function(AFFundamentalDeviceTheme device, AFAppStateAreas appState, AFAppFundamentalThemeAreaBuilder builder);

/// Create a conceptual theme used by a subset of the app, or used by a third party plugin.
typedef AFInitConceptualThemeDelegate = void Function(AFConceptualThemeDefinitionContext context);

/// Optional delegate used to create the flutter ThemeData, rather than allowing AFib to do it for you based on the primary fundamental theme.
typedef AFOverrideCreateThemeDataDelegate = ThemeData Function(AFFundamentalDeviceTheme device, AFAppStateAreas appState, AFFundamentalThemeArea primary);

typedef AFCreateDynamicDelegate = dynamic Function();

typedef AFReturnValueDelegate = void Function(dynamic param);

typedef AFRenderConnectedChildDelegate = Widget Function(AFScreenID screenParent, AFWidgetID widChild);

typedef AFRenderEmbeddedChildDelegate = Widget Function();

typedef AFBuildBodyDelegate<TBuildContext extends AFBuildContext> = Widget Function(TBuildContext context);

typedef AFOnChangedBoolDelegate = void Function(bool);

typedef AFOnChangedStringDelegate = void Function(String);

typedef AFCreateConceptualThemeDelegate = AFConceptualTheme Function(AFFundamentalTheme fundamentals, ThemeData themeData);