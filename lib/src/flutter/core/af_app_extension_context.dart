
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/redux/actions/af_async_query.dart';
import 'package:afib/src/dart/redux/state/af_app_state.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/flutter/core/af_screen_map.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/test/af_test_data_registry.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:afib/src/dart/utils/af_typedefs_dart.dart';
import 'package:afib/src/flutter/utils/af_typedefs_flutter.dart';

class AFTestExtensionContext {
  final initTestDatas = <AFInitTestDataDelegate>[];
  final initUnitTests = <AFInitUnitTestsDelegate>[];
  final initStateTests = <AFInitStateTestsDelegate>[];
  final initWidgetTests = <AFInitWidgetTestsDelegate>[];
  final initScreenTests = <AFInitScreenTestsDelegate>[];
  final initWorkflowStateTests = <AFInitWorkflowStateTestsDelegate>[];

  void addInitTestData(AFInitTestDataDelegate init) {
    initTestDatas.add(init);
  }

  void addInitUnitTest(AFInitUnitTestsDelegate init) {
    initUnitTests.add(init);
  }

  void addInitStateTest(AFInitStateTestsDelegate init) {
    initStateTests.add(init);
  }

  void addInitWidgetTest(AFInitWidgetTestsDelegate init) {
    initWidgetTests.add(init);
  }

  void addInitScreenTest(AFInitScreenTestsDelegate init) {
    initScreenTests.add(init);
  }

  void addInitWorkflowStateTest(AFInitWorkflowStateTestsDelegate init) {
    initWorkflowStateTests.add(init);
  }

  void _initTestData(AFTestDataRegistry testData) {
    for(final init in initTestDatas) {
      init(testData);
    }
  }

  void _initUnitTests(AFUnitTestDefinitionContext context) {
    for(final init in initUnitTests) {
      init(context);
    }
  }

  void _initStateTests(AFStateTestDefinitionContext context) {
    for(final init in initStateTests) {
      init(context);
    }
  }

  void _initWidgetTests(AFWidgetTestDefinitionContext context) {
    for(final init in initWidgetTests) {
      init(context);
    }
  }

  void _initScreenTests(AFSingleScreenTestDefinitionContext context) {
    for(final init in initScreenTests) {
      init(context);
    }
  }

  void _initWorkflowStateTests(AFWorkflowTestDefinitionContext context) {
    for(final init in initWorkflowStateTests) {
      init(context);
    }
  }

  void initialize({
    @required AFTestDataRegistry testData, 
    @required AFUnitTests unitTests,
    @required AFStateTests stateTests,
    @required AFWidgetTests widgetTests,
    @required AFSingleScreenTests screenTests,
    @required AFWorkflowStateTests workflowTests,

  }) {
      _initTestData(testData);
      
      final unitTestDefineContext = AFUnitTestDefinitionContext(
        tests: unitTests,
        testData: testData,
      );
      _initUnitTests(unitTestDefineContext);
      
      final stateTestDefineContext = AFStateTestDefinitionContext(
        tests: stateTests,
        testData: testData
      );
      _initStateTests(stateTestDefineContext);

      final widgetTestDefineContext = AFWidgetTestDefinitionContext(
        tests: widgetTests,
        testData: testData
      );
      _initWidgetTests(widgetTestDefineContext);
      
      final singleTestDefineContext = AFSingleScreenTestDefinitionContext(
        tests: screenTests,
        testData: testData
      );
      _initScreenTests(singleTestDefineContext);

      final workflowTestDefineContext = AFWorkflowTestDefinitionContext(
        tests: workflowTests,
        testData: testData
      );

      _initWorkflowStateTests(workflowTestDefineContext);

  }
}

class AFPluginExtensionContext {
  final initScreenMaps = <AFInitScreenMapDelegate>[];
  final initialAppStates = <AFInitializeAppStateDelegate>[];
  final createStartupQueryActions = <AFCreateStartupQueryActionDelegate>[];
  final createThemeDatas = <AFCreateThemeDataDelegate>[];
  final createLifecycleQueryActions = <AFCreateLifecycleQueryAction>[];
  final querySuccessListenerDelegates = <AFQuerySuccessListenerDelegate>[];
  final test = AFTestExtensionContext();

  /// Used by third parties to register extra query actions they'd like to take.
  void addPluginStartupAction(AFCreateStartupQueryActionDelegate createStartupQueryAction) {
    createStartupQueryActions.add(createStartupQueryAction);
  }

  /// Used by third parties to register screens that can be used by the app.
  void addPluginInitScreenMapAction(AFInitScreenMapDelegate initScreenMap) {
    initScreenMaps.add(initScreenMap);
  }

  /// Used by third parties to add an app state for themselves.
  void addPluginInitAppState(AFInitializeAppStateDelegate initAppState) {
    initialAppStates.add(initAppState);
  }

  /// Used by third parties to create their own theme data.
  void addPluginCreateThemeData(AFCreateThemeDataDelegate createThemeData) {
    createThemeDatas.add(createThemeData);    
  }

  /// Used by the app or third parties to create a query that runs on lifecycle actions.
  void addLifecycleQueryAction(AFCreateLifecycleQueryAction createLifecycleQueryAction) {
    createLifecycleQueryActions.add(createLifecycleQueryAction);
  }

  /// Used by app or third parties to listen in to all successful queries.
  void addQuerySuccessListener(AFQuerySuccessListenerDelegate queryListenerDelegate) {
    querySuccessListenerDelegates.add(queryListenerDelegate);
  }
}



/// Enables you, or third parties, to register extensions
//  recognized by AFib.
class AFAppExtensionContext extends AFPluginExtensionContext {
  AFCreateAFAppDelegate createApp;

  /// Used by the app to specify fundamental configuration/functionality
  /// that AFib requires.
  void initializeAppFundamentals({
    @required AFInitScreenMapDelegate initScreenMap,
    @required AFCreateThemeDataDelegate createThemeData,
    @required AFInitializeAppStateDelegate initializeAppState,
    @required AFCreateStartupQueryActionDelegate createStartupQueryAction,
    @required AFCreateAFAppDelegate createApp,
  }) {
    this.initScreenMaps.add(initScreenMap);
    this.initialAppStates.add(initializeAppState);
    this.createThemeDatas.add(createThemeData);
    this.createStartupQueryActions.add(createStartupQueryAction);
    this.createApp = createApp;
    _verifyNotNull(createThemeData, "createThemeData");
    _verifyNotNull(initScreenMap, "initScreenMap");
    _verifyNotNull(initializeAppState, "initializeAppState");
    _verifyNotNull(createStartupQueryAction, "createStartupQueryAction");
    _verifyNotNull(createApp, "createApp");
  }

  void initializeTestFundamentals({
    @required AFInitTestDataDelegate initTestData,
    @required AFInitUnitTestsDelegate initUnitTests,
    @required AFInitStateTestsDelegate initStateTests,
    @required AFInitWidgetTestsDelegate initWidgetTests,
    @required AFInitScreenTestsDelegate initScreenTests,
    @required AFInitWorkflowStateTestsDelegate initWorkflowStateTests,
  }) {
    test.addInitTestData(initTestData);
    test.addInitUnitTest(initUnitTests);
    test.addInitStateTest(initStateTests);
    test.addInitWidgetTest(initWidgetTests);
    test.addInitScreenTest(initScreenTests);
    test.addInitWorkflowStateTest(initWorkflowStateTests);
  }

  void dispatchStartupActions(AFDispatcher dispatcher) {
    for(final creator in this.createStartupQueryActions) {
      final action = creator();
      dispatcher.dispatch(action);
    }
  }

  void dispatchLifecycleActions(AFDispatcher dispatcher, AppLifecycleState lifecycle) {
    for(final creator in createLifecycleQueryActions) {
      final action = creator(lifecycle);
      dispatcher.dispatch(action);  
    }
  }

  void updateQueryListeners(AFAsyncQuery query, AFFinishQuerySuccessContext successContext) {
    
  }

  AFAppStateAreas createInitialAppStateAreas() {
    final appStates = <AFAppStateArea>[];
    for(final initState in initialAppStates) {
      appStates.add(initState());
    }    
    
    return AFAppStateAreas.createFrom(appStates);
  }
 
  void _verifyNotNull(dynamic item, String setterName) {
    if(item == null) {
      throw AFException("You must specify a value using $setterName in extend_app.dart");
    }
  }

  void initScreenMap(AFScreenMap screenMap) {
    for(final init in initScreenMaps) {
      init(screenMap);
    }    
  }
}
