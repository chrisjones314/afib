
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/redux/actions/af_async_query.dart';
import 'package:afib/src/dart/redux/state/af_app_state.dart';
import 'package:afib/src/dart/redux/state/af_theme_state.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/core/af_screen_map.dart';
import 'package:afib/src/flutter/test/af_test_data_registry.dart';
import 'package:afib/src/flutter/ui/theme/af_prototype_area.dart';
import 'package:afib/src/flutter/ui/theme/af_prototype_theme.dart';
import 'package:afib/src/flutter/utils/af_dispatcher.dart';
import 'package:afib/src/flutter/utils/af_typedefs_flutter.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:afib/src/dart/utils/af_typedefs_dart.dart';

class AFSharedTestExtensionContext {
  final extractors = <AFExtractWidgetAction>[];
  final applicators = <AFApplyWidgetAction>[];
  final scrollers = <AFScrollerAction>[];

  void initializeApp() {
    _registerDefaultApplicators();
  }

  bool get _needWidgetActions {
    return AFibD.config.isTestContext || AFibD.config.isPrototypeMode;
  }

  void _registerDefaultApplicators() {
    if(!_needWidgetActions) {
      return;
    }
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

    registerScroller(AFScrollableScrollerAction());
  }

  /// Register a way to tap or set a value on a particular kind of widget.
  /// 
  /// The intent is to allow the testing framework to be extended for
  /// arbitrary widgets that might get tapped.
  void registerApplicator(AFApplyWidgetAction apply) {
    if(_needWidgetActions) {
      applicators.add(apply);
    }
  }

  void registerExtractor(AFExtractWidgetAction extract) {
    if(_needWidgetActions) {
      extractors.add(extract);
    }
  }

  void registerScroller(AFScrollerAction scroller) {
    if(_needWidgetActions) {
      scrollers.add(scroller);
    }
  }

  void mergeWith(AFSharedTestExtensionContext other) {
    //extractors.clear();
    extractors.addAll(_merge<AFExtractWidgetAction>(extractors, other.extractors));

    //applicators.clear();
    applicators.addAll(_merge<AFApplyWidgetAction>(applicators, other.applicators));

    //scrollers.clear();
    scrollers.addAll(_merge<AFScrollerAction>(scrollers, other.scrollers));
  }

  Iterable<TAction> _merge<TAction>(List<TAction> source1, List<TAction> source2) {
    final map = <String, TAction>{};
    for(final action in source1) {
      final id = action.runtimeType.toString();
      map[id] = action;
    }

    for(final action in source2) {
      final id = action.runtimeType.toString();
      map[id] = action;
    }

    return map.values;
  }
}

class AFTestExtensionContext {
  final initTestDatas = <AFInitTestDataDelegate>[];
  final initUnitTests = <AFInitUnitTestsDelegate>[];
  final initStateTests = <AFInitStateTestsDelegate>[];
  final initWidgetTests = <AFInitWidgetTestsDelegate>[];
  final initScreenTests = <AFInitScreenTestsDelegate>[];
  final initWorkflowStateTests = <AFInitWorkflowStateTestsDelegate>[];
  final initWireframes = <AFInitWireframesDelegate>[];
  final sharedTestContext = AFSharedTestExtensionContext();

  void initializeTestFundamentals({
    @required AFInitTestDataDelegate initTestData,
    @required AFInitUnitTestsDelegate initUnitTests,
    @required AFInitStateTestsDelegate initStateTests,
    @required AFInitWidgetTestsDelegate initWidgetTests,
    @required AFInitScreenTestsDelegate initScreenTests,
    @required AFInitWorkflowStateTestsDelegate initWorkflowStateTests,
    @required AFInitWireframesDelegate initWireframes,
  }) {
    addInitTestData(initTestData);
    addInitUnitTest(initUnitTests);
    addInitStateTest(initStateTests);
    addInitWidgetTest(initWidgetTests);
    addInitScreenTest(initScreenTests);
    addInitWorkflowStateTest(initWorkflowStateTests);
    addInitWireframe(initWireframes);
  }

  void initializeForApp() {
    sharedTestContext.initializeApp();
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

  void addInitWireframe(AFInitWireframesDelegate init) {
    if(init != null) {
      initWireframes.add(init);
    }
  }

  /// Register a way to tap or set a value on a particular kind of widget.
  /// 
  /// The intent is to allow the testing framework to be extended for
  /// arbitrary widgets that might get tapped.
  void registerApplicator(AFApplyWidgetAction apply) {
    sharedTestContext.registerApplicator(apply);
  }

  void registerExtractor(AFExtractWidgetAction extract) {
    sharedTestContext.registerExtractor(extract);
  }

  void _initTestData(AFCompositeTestDataRegistry testData) {
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

  void _initWireframes(AFWireframeDefinitionContext context) {
    for(final init in initWireframes) {
      init(context);
    }
  }

  void initialize({
    @required AFCompositeTestDataRegistry testData, 
    @required AFUnitTests unitTests,
    @required AFStateTests stateTests,
    @required AFWidgetTests widgetTests,
    @required AFSingleScreenTests screenTests,
    @required AFWorkflowStateTests workflowTests,
    @required AFWireframes wireframes,
  }) {
      _initTestData(testData);
      testData.regenerate();
      
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

      final wireframeContext = AFWireframeDefinitionContext(
        wireframes: wireframes,
        testData: testData
      );

      _initWireframes(wireframeContext);
  }
}

class AFFunctionalThemeDefinitionContext {
  final themeFactories = <AFThemeID, AFCreateFunctionalThemeDelegate>{};

  AFFunctionalThemeDefinitionContext();

  void initUnlessPresent(AFThemeID id, { @required AFCreateFunctionalThemeDelegate createTheme }) {
    if(themeFactories.containsKey(id)) {
      return;
    }
    themeFactories[id] = createTheme;
  }

  AFFunctionalTheme create(AFThemeID id, AFFundamentalThemeState fundamentals) {
    final create = themeFactories[id];
    assert(create != null, "No theme registered with id $id");
    return create(fundamentals);
  }

  AFCreateFunctionalThemeDelegate factoryFor(AFThemeID id) {
    return themeFactories[id];
  }


  Map<AFThemeID, AFFunctionalTheme> createFunctionals(AFFundamentalThemeState fundamentals) {
    final result = <AFThemeID, AFFunctionalTheme>{};
    for(final id in themeFactories.keys) {
      final create = themeFactories[id];
      result[id] = create(fundamentals);
    }

    return result;
  }

}

class AFPluginExtensionContext {
  AFCreateAFAppDelegate createApp;
  AFInitAppFundamentalThemeDelegate initFundamentalThemeArea;
  final initScreenMaps = <AFInitScreenMapDelegate>[];
  final initialAppStates = <AFInitializeAppStateDelegate>[];
  final createStartupQueryActions = <AFCreateStartupQueryActionDelegate>[];
  final createLifecycleQueryActions = <AFCreateLifecycleQueryAction>[];
  final querySuccessListenerDelegates = <AFQuerySuccessListenerDelegate>[];
  AFTestExtensionContext test = AFTestExtensionContext();
  final thirdParty = AFAppThirdPartyExtensionContext();
  final initFunctionalThemes = <AFInitFunctionalThemeDelegate>[];
  final initFundamentalThemeAreas = <AFInitPluginFundamentalThemeDelegate>[];
  final errorListenerByState = <Type, AFOnErrorDelegate>{};

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

  void addCreateFunctionalTheme(AFInitFunctionalThemeDelegate init) {
    initFunctionalThemes.add(init);
  }

  /// Used by the app or third parties to create a query that runs on lifecycle actions.
  void addLifecycleQueryAction(AFCreateLifecycleQueryAction createLifecycleQueryAction) {
    createLifecycleQueryActions.add(createLifecycleQueryAction);
  }

  /// Used by app or third parties to listen in to all successful queries.
  void addQuerySuccessListener(AFQuerySuccessListenerDelegate queryListenerDelegate) {
    querySuccessListenerDelegates.add(queryListenerDelegate);
  } 

  void addQueryErrorListener<TState extends AFAppStateArea>(AFOnErrorDelegate onError) {
    errorListenerByState[TState] = onError;
  }

  void initScreenMap(AFScreenMap screenMap, Iterable<AFUILibraryExtensionContext> libraries) {
    for(final init in this.initScreenMaps) {
      init(screenMap);
    }
  }

  void initFunctional(AFFunctionalThemeDefinitionContext context) {
    for(final init in this.initFunctionalThemes) {
      init(context);
    }
  }

  void initAppStates(List<AFAppStateArea> appStates) {
    for(final initState in this.initialAppStates) {
      appStates.add(initState());
    }
  }

  void _verifyNotNull(dynamic item, String setterName) {
    if(item == null) {
      throw AFException("You must specify a value using $setterName in extend_app.dart");
    }
  }

}

class AFAppThirdPartyExtensionContext {
  final libraries = <AFLibraryID, AFUILibraryExtensionContext>{};
  
  AFUILibraryExtensionContext register(AFLibraryID id) {
    final context = AFUILibraryExtensionContext(id: id);
    assert(!libraries.containsKey(id), "Duplicate library key $id");
    libraries[id] = context;
    return context;
  }
}

class AFUILibraryExtensionContext<TState extends AFAppStateArea> extends AFPluginExtensionContext {
  final AFLibraryID id;

  AFUILibraryExtensionContext({
    @required this.id,
  });

  AFLibraryTestHolder<TState> createScreenTestHolder() {
    return AFLibraryTestHolder<TState>();
  }

  void initializeLibraryFundamentals<TState extends AFAppStateArea>({
    @required AFInitScreenMapDelegate initScreenMap,
    @required AFInitPluginFundamentalThemeDelegate initFundamentalThemeArea,
    @required AFInitializeAppStateDelegate initializeAppState,
    @required AFInitFunctionalThemeDelegate initFunctionalTheme,
  }) {
    this.initScreenMaps.add(initScreenMap);
    this.initialAppStates.add(initializeAppState);
    this.initFunctionalThemes.add(initFunctionalTheme);
    if(initFundamentalThemeAreas != null) {
      this.initFundamentalThemeAreas.add(initFundamentalThemeArea);
    } 
    _verifyNotNull(initScreenMap, "initScreenMap");
    _verifyNotNull(initializeAppState, "initializeAppState");
  }
  
}

/// Enables you, or third parties, to register extensions
//  recognized by AFib.
class AFAppExtensionContext extends AFPluginExtensionContext {
  final libraries = AFAppThirdPartyExtensionContext();

  /// Used by the app to specify fundamental configuration/functionality
  /// that AFib requires.
  void initializeAppFundamentals<TState extends AFAppStateArea>({
    @required AFInitScreenMapDelegate initScreenMap,
    @required AFInitAppFundamentalThemeDelegate initFundamentalThemeArea,
    @required AFInitializeAppStateDelegate initializeAppState,
    @required AFCreateStartupQueryActionDelegate createStartupQueryAction,
    @required AFCreateAFAppDelegate createApp,
    @required AFInitFunctionalThemeDelegate initFunctionalThemes,
    @required AFOnErrorDelegate<TState> queryErrorHandler,
  }) {
    this.test.initializeForApp();
    this.initScreenMaps.add(initScreenMap);
    this.initialAppStates.add(initializeAppState);
    this.createStartupQueryActions.add(createStartupQueryAction);
    this.errorListenerByState[TState] = queryErrorHandler;
    this.createApp = createApp;
    this.initFunctionalThemes.add(initFunctionalThemes);
    this.initFundamentalThemeArea = initFundamentalThemeArea;
    _verifyNotNull(initFundamentalThemeArea, "initFundamentalTheme");
    _verifyNotNull(initScreenMap, "initScreenMap");
    _verifyNotNull(initializeAppState, "initializeAppState");
    _verifyNotNull(createStartupQueryAction, "createStartupQueryAction");
    _verifyNotNull(createApp, "createApp");
  }

  void fromUILibrary(AFUILibraryExtensionContext source, {
    @required AFInitAppFundamentalThemeDelegate initFundamentalThemeArea,
    @required AFCreateAFAppDelegate createApp,
  }) {
    this.initScreenMaps.addAll(source.initScreenMaps);
    this.initialAppStates.addAll(source.initialAppStates);
    this.createStartupQueryActions.addAll(source.createStartupQueryActions);
    this.errorListenerByState.addAll(source.errorListenerByState);
    this.createApp = createApp;
    this.test = source.test;
    this.test.initializeForApp();
    this.createApp = createApp;
    this.initFundamentalThemeArea = source.initFundamentalThemeArea ?? initFundamentalThemeArea;
    this.initFundamentalThemeAreas.addAll(source.initFundamentalThemeAreas);
    this.initFunctionalThemes.addAll(source.initFunctionalThemes);    
  }

  AFOnErrorDelegate<TState> errorHandlerForState<TState extends AFAppStateArea>() {
    return errorListenerByState[TState];
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

  AFFundamentalThemeState createFundamentalTheme(AFFundamentalDeviceTheme device, AFAppStateAreas areas, Iterable<AFUILibraryExtensionContext> libraries) {
    final builder = AFAppFundamentalThemeAreaBuilder.create();
    this.initFundamentalThemeArea(device, areas, builder);

    for(final init in this.initFundamentalThemeAreas) {
      init(device, areas, builder);
    }

    if(AFibD.config.requiresPrototypeData) {
      initPrototypeThemeArea(device, areas, builder);      
    }

    for(final library in libraries) {
      final inits = library.initFundamentalThemeAreas;
      for(final init in inits) {
        init(device, areas, builder);
      }
    }

        
    final primaryArea = builder.create();
    final marginSpacing = builder.createMarginSpacing();
    final paddingSpacing = builder.createPaddingSpacing();
    final borderRadius = builder.createBorderRadius();

    builder.setTranslations(AFUILocaleID.universal, {
      AFUITranslationID.appTitle: "App Title",
      AFUITranslationID.notTranslated: "{0}",
      AFUITranslationID.widgetPrototypes: "Widget Prototypes",
      AFUITranslationID.screenPrototypes: "Screen Prototypes",
      AFUITranslationID.workflowPrototypes: "Workflow Prototypes",
      AFUITranslationID.thirdParty: "Third Party",
      AFUITranslationID.searchResults: "Search Results",
      AFUITranslationID.testResults: "Test Results",
      AFUITranslationID.run: "Run {0}",
      AFUITranslationID.prototypesAndTests: "Prototypes and Tests",
      AFUITranslationID.searchAndRun: "Search and Run",
      AFUITranslationID.afibPrototypeMode: "AFib Prototype Mode",
      AFUITranslationID.wireframes: "Wireframes",
    });

    final result = AFFundamentalThemeState(
      device: device, 
      area: primaryArea, 
      marginSpacing: marginSpacing, 
      paddingSpacing: paddingSpacing, 
      borderRadius: borderRadius,
      themeData: null,
    );
    result.resolve();
    return result;
  }

  void initializeFunctionalThemeFactories(AFFunctionalThemeDefinitionContext context, Iterable<AFUILibraryExtensionContext> libraries) {
    for(final init in initFunctionalThemes) {
      init(context);
    }

    if(AFibD.config.requiresPrototypeData) {
      context.initUnlessPresent(AFUIThemeID.conceptualPrototype, createTheme: (f) => AFPrototypeTheme(f));
    }

    for(final thirdParty in libraries) {
      thirdParty.initFunctional(context);
    }
  }

  AFAppStateAreas createInitialAppStateAreas(Iterable<AFUILibraryExtensionContext> libraries) {
    final appStates = <AFAppStateArea>[];
    for(final initState in initialAppStates) {
      appStates.add(initState());
    }    

    for(final thirdParty in libraries) {
      thirdParty.initAppStates(appStates);
    }

    return AFAppStateAreas.createFrom(appStates);
  }
 
  void initScreenMap(AFScreenMap screenMap, Iterable<AFUILibraryExtensionContext> libraries) {
    for(final init in initScreenMaps) {
      init(screenMap);
    }    

    for(final thirdParty in libraries) {
      for(final init in thirdParty.initScreenMaps) {
        init(screenMap);
      }
    }
  }
}
