
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/redux/actions/af_async_query.dart';
import 'package:afib/src/dart/redux/state/af_app_state.dart';
import 'package:afib/src/dart/redux/state/af_theme_state.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/core/af_screen_map.dart';
import 'package:afib/src/flutter/test/af_test_data_registry.dart';
import 'package:afib/src/flutter/theme/af_prototype_area.dart';
import 'package:afib/src/flutter/theme/af_prototype_theme.dart';
import 'package:afib/src/flutter/utils/af_dispatcher.dart';
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
  final extractors = <AFExtractWidgetAction>[];
  final applicators = <AFApplyWidgetAction>[];

  void initializeTestFundamentals({
    @required AFInitTestDataDelegate initTestData,
    @required AFInitUnitTestsDelegate initUnitTests,
    @required AFInitStateTestsDelegate initStateTests,
    @required AFInitWidgetTestsDelegate initWidgetTests,
    @required AFInitScreenTestsDelegate initScreenTests,
    @required AFInitWorkflowStateTestsDelegate initWorkflowStateTests,
  }) {
    _registerDefaultApplicators();
    addInitTestData(initTestData);
    addInitUnitTest(initUnitTests);
    addInitStateTest(initStateTests);
    addInitWidgetTest(initWidgetTests);
    addInitScreenTest(initScreenTests);
    addInitWorkflowStateTest(initWorkflowStateTests);
  }

  void _registerDefaultApplicators() {
    registerApplicator(AFFlatButtonAction());
    registerApplicator(AFRaisedButtonAction());
    registerApplicator(AFTapChoiceChip());
    registerApplicator(AFSetChoiceChip());
    registerApplicator(AFApplyTextTextFieldAction());
    registerApplicator(AFApplyTextAFTextFieldAction());
    registerApplicator(AFRichTextGestureTapAction());
    registerApplicator(AFApplyCupertinoPicker());
    registerApplicator(AFIconButtonAction());
    registerApplicator(AFListTileTapAction());
    registerApplicator(AFGestureDetectorTapAction());
    registerApplicator(AFDismissibleSwipeAction());
    registerApplicator(AFSwitchTapAction());
    registerApplicator(AFSetSwitchValueAction());

    registerExtractor(AFSelectableChoiceChip());
    registerExtractor(AFExtractTextTextAction());
    registerExtractor(AFExtractTextTextFieldAction());
    registerExtractor(AFExtractTextAFTextFieldAction());
    registerExtractor(AFExtractRichTextAction());
    registerExtractor(AFSwitchExtractor());    
  }

  /// Register a way to tap or set a value on a particular kind of widget.
  /// 
  /// The intent is to allow the testing framework to be extended for
  /// arbitrary widgets that might get tapped.
  void registerApplicator(AFApplyWidgetAction apply) {
    applicators.add(apply);
  }

  void registerExtractor(AFExtractWidgetAction extract) {
    extractors.add(extract);
  }

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
  final createLifecycleQueryActions = <AFCreateLifecycleQueryAction>[];
  final querySuccessListenerDelegates = <AFQuerySuccessListenerDelegate>[];
  final test = AFTestExtensionContext();
  final initConceptualThemes = <AFCreateConceptualThemeDelegate>[];
  final initFundamentalThemeAreas = <AFInitPluginFundamentalThemeDelegate>[];


  /// Used by third parties to register extra query actions they'd like to take.
  void addPluginStartupAction(AFCreateStartupQueryActionDelegate createStartupQueryAction) {
    createStartupQueryActions.add(createStartupQueryAction);
  }

  /// Used by third parties to register screens that can be used by the app.
  void addPluginInitScreenMapAction(AFInitScreenMapDelegate initScreenMap) {
    initScreenMaps.add(initScreenMap);
  }

  /// Used by third parties to register screens that can be used by the app.
  void addPluginFundamentalThemeArea(AFInitPluginFundamentalThemeDelegate initArea) {
    initFundamentalThemeAreas.add(initArea);
  }

  /// Used by third parties to add an app state for themselves.
  void addPluginInitAppState(AFInitializeAppStateDelegate initAppState) {
    initialAppStates.add(initAppState);
  }

  void addCreateConceptualTheme(AFCreateConceptualThemeDelegate init) {
    initConceptualThemes.add(init);
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
  AFInitAppFundamentalThemeDelegate initFundamentalThemeArea;

  /// Used by the app to specify fundamental configuration/functionality
  /// that AFib requires.
  void initializeAppFundamentals({
    @required AFInitScreenMapDelegate initScreenMap,
    @required AFInitAppFundamentalThemeDelegate initFundamentalThemeArea,
    @required AFInitializeAppStateDelegate initializeAppState,
    @required AFCreateStartupQueryActionDelegate createStartupQueryAction,
    @required AFCreateAFAppDelegate createApp,
    @required AFCreateConceptualThemeDelegate createPrimaryTheme,
  }) {
    this.initScreenMaps.add(initScreenMap);
    this.initialAppStates.add(initializeAppState);
    this.createStartupQueryActions.add(createStartupQueryAction);
    this.createApp = createApp;
    this.initConceptualThemes.add(createPrimaryTheme);
    this.initFundamentalThemeArea = initFundamentalThemeArea;
    _verifyNotNull(initFundamentalThemeArea, "initFundamentalTheme");
    _verifyNotNull(initScreenMap, "initScreenMap");
    _verifyNotNull(initializeAppState, "initializeAppState");
    _verifyNotNull(createStartupQueryAction, "createStartupQueryAction");
    _verifyNotNull(createApp, "createApp");
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
    for(final listener in querySuccessListenerDelegates) {
      listener(query, successContext);
    }
  }

  AFFundamentalTheme createFundamentalTheme(AFFundamentalDeviceTheme device, AFAppStateAreas areas) {
    final builder = AFAppFundamentalThemeAreaBuilder.create();
    this.initFundamentalThemeArea(device, areas, builder);

    for(final init in this.initFundamentalThemeAreas) {
      init(device, areas, builder);
    }

    if(AFibD.config.requiresPrototypeData) {
      initPrototypeThemeArea(device, areas, builder);      
    }
    
    final primaryArea = builder.create();
    final marginSpacing = builder.createMarginSpacing();
    final paddingSpacing = builder.createPaddingSpacing();
    final borderRadius = builder.createBorderRadius();

    final result = AFFundamentalTheme(device: device, area: primaryArea, marginSpacing: marginSpacing, paddingSpacing: paddingSpacing, borderRadius: borderRadius);
    result.resolve();
    return result;
  }

  List<AFConceptualTheme> initializeConceptualThemes(AFFundamentalTheme fundamentals) {
    final result = <AFConceptualTheme>[];
    for(final init in initConceptualThemes) {
      result.add(init(fundamentals));
    }

    if(AFibD.config.requiresPrototypeData) {
      result.add(AFPrototypeTheme(fundamentals));
    }

    return result;
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
