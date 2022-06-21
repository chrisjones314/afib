import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/redux/state/models/afui_proto_state.dart';
import 'package:afib/src/flutter/ui/theme/af_prototype_area.dart';
import 'package:afib/src/flutter/ui/theme/afui_default_theme.dart';
import 'package:flutter/material.dart';

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
    registerApplicator(AFTextButtonAction());
    registerApplicator(AFOutlinedButtonAction());
    registerApplicator(AFRaisedButtonAction());
    registerApplicator(AFTapChoiceChip());
    registerApplicator(AFSetChoiceChip());
    registerApplicator(AFApplyTextTextFieldAction());
    registerApplicator(AFApplySliderAction());
    registerApplicator(AFRichTextGestureTapAction());
    registerApplicator(AFApplyCupertinoPicker());
    registerApplicator(AFIconButtonAction());
    registerApplicator(AFListTileTapAction());
    registerApplicator(AFGestureDetectorTapAction());
    registerApplicator(AFDismissibleSwipeAction());
    registerApplicator(AFSwitchTapAction());
    registerApplicator(AFSetSwitchValueAction());
    registerApplicator(AFCheckboxTapAction());

    registerExtractor(AFSelectableChoiceChip());
    registerExtractor(AFExtractTextTextAction());
    registerExtractor(AFExtractTextTextFieldAction());
    registerExtractor(AFExtractSliderAction());
    registerExtractor(AFExtractRichTextAction());
    registerExtractor(AFSwitchExtractor());    
    registerExtractor(AFExtractColumnChildrenAction());
    registerExtractor(AFExtractWidgetListAction());

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
  final initScreenTests = <AFInitScreenTestsDelegate>[];
  final initWorkflowStateTests = <AFInitWorkflowStateTestsDelegate>[];
  final initWireframes = <AFInitWireframesDelegate>[];
  final sharedTestContext = AFSharedTestExtensionContext();

  void installTests({
    required AFInitTestDataDelegate defineTestData,
    required AFInitUnitTestsDelegate defineUnitTests,
    required AFInitStateTestsDelegate defineStateTests,
    required AFInitScreenTestsDelegate defineScreenTests,
    AFInitWorkflowStateTestsDelegate? defineWorkflowStateTests,
    AFInitWireframesDelegate? defineWireframes,
  }) {
    addInitTestData(defineTestData);
    addInitUnitTest(defineUnitTests);
    addInitStateTest(defineStateTests);
    addInitScreenTest(defineScreenTests);
    addInitWireframe(defineWireframes);
    if(defineWorkflowStateTests != null) {
      addInitWorkflowStateTest(defineWorkflowStateTests);
    }
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

  void addInitScreenTest(AFInitScreenTestsDelegate init) {
    initScreenTests.add(init);
  }

  void addInitWorkflowStateTest(AFInitWorkflowStateTestsDelegate init) {
    initWorkflowStateTests.add(init);
  }

  void addInitWireframe(AFInitWireframesDelegate? init) {
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

  void _initTestData(AFDefineTestDataContext testData) {
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

  void _initScreenTests(AFUIPrototypeDefinitionContext context) {
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

  void initializeForDemoMode({
    required AFDefineTestDataContext testData, 
    required AFStateTests stateTests,
  }) {
      _initTestData(testData);
      
      final stateTestDefineContext = AFStateTestDefinitionContext(
        tests: stateTests,
        testData: testData
      );
      _initStateTests(stateTestDefineContext);
  }

  void initialize({
    required AFDefineTestDataContext testData, 
    required AFUnitTests unitTests,
    required AFStateTests stateTests,
    required AFWidgetTests widgetTests,
    required AFBottomSheetTests bottomSheetTests,
    required AFDrawerTests drawerTests,
    required AFSingleScreenTests screenTests,
    required AFDialogTests dialogTests,
    required AFWorkflowStateTests workflowTests,
    required AFWireframes wireframes,
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
      
      final singleTestDefineContext = AFUIPrototypeDefinitionContext(
        screenTests: screenTests,
        widgetTests: widgetTests,
        dialogTests: dialogTests,
        bottomSheetTests: bottomSheetTests,
        drawerTests: drawerTests,
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

class AFCoreDefinitionContext {
  final spiOverrides = <Type, AFCreateWidgetSPIDelegate>{};
  final lpiFactories = <AFLibraryProgrammingInterfaceID, AFCreateLibraryProgrammingInterfaceDelegate>{};
  final themeFactories = <AFThemeID, AFCreateFunctionalThemeDelegate>{};
  final AFScreenMap screenMap = AFScreenMap();
  final componentStateInitializers = <AFInitializeComponentStateDelegate>[];
  
  AFCoreDefinitionContext();

  void defineScreenSPIOverride<TSPI extends AFStateProgrammingInterface, TBuildContext extends AFBuildContext, TTheme extends AFFunctionalTheme>({ required AFCreateScreenSPIDelegate<TSPI, TBuildContext, TTheme> createSPI }) {
    spiOverrides[TSPI] = ((context, theme, screenId, wid, paramSource) {
      return createSPI(context as TBuildContext, theme as TTheme, screenId);
    });
  }

  void defineLPI(AFLibraryProgrammingInterfaceID id, { required AFCreateLibraryProgrammingInterfaceDelegate createLPI }) {
    if(lpiFactories.containsKey(id)) {
      return;
    }
    lpiFactories[id] = createLPI;
  }

  void defineComponentStateInitializer(AFInitializeComponentStateDelegate define) {
    componentStateInitializers.add(define);
  }

  void defineStartupScreen(AFScreenID screenId, AFCreateRouteParamDelegate createParam) {    
    screenMap.registerStartupScreen(screenId, createParam);
  }

  void defineScreen(AFScreenID screenKey, AFConnectedUIBuilderDelegate screenBuilder) {
    screenMap.registerScreen(screenKey, screenBuilder);
  }

  void defineDrawer(AFScreenID screenKey, AFConnectedUIBuilderDelegate screenBuilder) {
    screenMap.registerDrawer(screenKey, screenBuilder);
  }

  void defineDialog(AFScreenID screenKey, AFConnectedUIBuilderDelegate screenBuilder) {
    screenMap.registerDialog(screenKey, screenBuilder);
  }

  void defineBottomSheet(AFScreenID screenKey, AFConnectedUIBuilderDelegate screenBuilder) {
    screenMap.registerBottomSheet(screenKey, screenBuilder);
  }


  void defineTheme(AFThemeID id, { required AFCreateFunctionalThemeDelegate createTheme }) {
    if(themeFactories.containsKey(id)) {
      return;
    }
    themeFactories[id] = createTheme;
  }

  AFFunctionalTheme create(AFThemeID id, AFFundamentalThemeState fundamentals) {
    final create = themeFactories[id];
    if(create == null) throw AFException("No theme registered with id $id");

    return create(id, fundamentals);
  }

  AFCreateFunctionalThemeDelegate factoryFor(AFThemeID id) {
    final factory = themeFactories[id];
    if(factory == null) throw AFException("No theme factory registered for $id");
    return factory;
  }


  Map<AFThemeID, AFFunctionalTheme> createFunctionals(AFFundamentalThemeState fundamentals) {
    final result = <AFThemeID, AFFunctionalTheme>{};
    for(final id in themeFactories.keys) {
      final create = themeFactories[id];
      if(create != null) {
        result[id] = create(id, fundamentals);
      }
    }

    return result;
  }

}

class AFPluginExtensionContext {
  AFCreateAFAppDelegate? createApp;
  AFInitAppFundamentalThemeDelegate? defineFundamentalThemeArea;
  final defineScreenMaps = <AFInitScreenMapDelegate>[];
  final createStartupQueries = <AFCreateStartupQueryActionDelegate>[];
  final createLifecycleQueryActions = <AFCreateLifecycleQueryAction>[];
  final querySuccessListenerDelegates = <AFQuerySuccessListenerDelegate>[];
  AFTestExtensionContext test = AFTestExtensionContext();
  final thirdParty = AFAppLibraryExtensionContext();
  final defineCore = <AFInitCoreDelegate>[];
  final defineFundamentalThemeAreas = <AFInitPluginFundamentalThemeDelegate>[];
  final errorListeners = <AFOnErrorDelegate>[];

  /// Used by third parties to register extra query actions they'd like to take.
  void addPluginStartupQuery(AFCreateStartupQueryActionDelegate createStartupQueryAction) {
    createStartupQueries.add(createStartupQueryAction);
  }

  /// Used by third parties to register screens that can be used by the app.
  void addPluginInitScreenMapAction(AFInitScreenMapDelegate defineScreenMap) {
    defineScreenMaps.add(defineScreenMap);
  }

  /// Used by third parties to register screens that can be used by the app.
  void addPluginFundamentalThemeArea(AFInitPluginFundamentalThemeDelegate initArea) {
    defineFundamentalThemeAreas.add(initArea);
  }

  void addCreateFunctionalTheme(AFInitCoreDelegate init) {
    defineCore.add(init);
  }

  /// Used by the app or third parties to create a query that runs on lifecycle actions.
  void addLifecycleQueryAction(AFCreateLifecycleQueryAction createLifecycleQueryAction) {
    createLifecycleQueryActions.add(createLifecycleQueryAction);
  }

  /// Used by app or third parties to listen in to all successful queries.
  void addQuerySuccessListener(AFQuerySuccessListenerDelegate queryListenerDelegate) {
    querySuccessListenerDelegates.add(queryListenerDelegate);
  } 

  void addQueryErrorListener(AFOnErrorDelegate onError) {
    errorListeners.add(onError);
  }

  void defineScreenMap(AFScreenMap screenMap, Iterable<AFCoreLibraryExtensionContext> libraries) {
    for(final init in this.defineScreenMaps) {
      init(screenMap);
    }
  }

  void defineAllCore(AFCoreDefinitionContext context) {
    for(final init in this.defineCore) {
      init(context);
    }
  }

  /*
  void initComponentStates(List<AFComponentState> componentStates) {
    for(final initState in this.componentStateInitializers) {
      final s = initState();
      if(s != null) {
        componentStates.add(s);
      }
    }
  }
  */

  void _verifyNotNull(dynamic item, String setterName) {
    if(item == null) {
      throw AFException("You must specify a value using $setterName in extend_app.dart");
    }
  }

}

class AFAppLibraryExtensionContext {
  final libraries = <AFLibraryID, AFCoreLibraryExtensionContext>{};
  
  AFCoreLibraryExtensionContext register(AFLibraryID id) {
    final context = AFCoreLibraryExtensionContext(id: id);
    assert(!libraries.containsKey(id), "Duplicate library key $id");
    libraries[id] = context;
    return context;
  }
}

class AFCoreLibraryExtensionContext extends AFPluginExtensionContext {
  final AFLibraryID id;

  AFCoreLibraryExtensionContext({
    required this.id,
  });

  AFLibraryTestHolder createScreenTestHolder() {
    return AFLibraryTestHolder();
  }

  void installCoreLibrary({
    AFInitCoreDelegate? defineCore,
    AFInitPluginFundamentalThemeDelegate? defineFundamentalThemeArea,
  }) {
    if(defineCore != null) {
      this.defineCore.add(defineCore);
    }
    if(defineFundamentalThemeArea != null) {
      this.defineFundamentalThemeAreas.add(defineFundamentalThemeArea);
    }
    _verifyNotNull(defineScreenMap, "defineScreenMap");
  }
  
}

/// Enables you, or third parties, to register extensions
//  recognized by AFib.
class AFAppExtensionContext extends AFPluginExtensionContext {
  final libraries = AFAppLibraryExtensionContext();

  /// Used by the app to specify fundamental configuration/functionality
  /// that AFib requires.
  void installApp({
    required AFInitAppFundamentalThemeDelegate defineFundamentalThemeArea,
    required AFCreateStartupQueryActionDelegate createStartupQuery,
    required AFCreateAFAppDelegate createApp,
    required AFInitCoreDelegate defineCore,
    required AFOnErrorDelegate queryErrorHandler,
  }) {
    this.test.initializeForApp();
    this.defineCore.add(defineCore);
    this.createStartupQueries.add(createStartupQuery);
    this.errorListeners.add(queryErrorHandler);
    this.createApp = createApp;
    this.defineFundamentalThemeArea = defineFundamentalThemeArea;
    _verifyNotNull(defineFundamentalThemeArea, "defineFundamentalTheme");
    _verifyNotNull(defineScreenMap, "defineScreenMap");
    _verifyNotNull(createStartupQuery, "createStartupQueryAction");
    _verifyNotNull(createApp, "createApp");
  }

  void fromUILibrary(AFCoreLibraryExtensionContext source, {
    required AFInitAppFundamentalThemeDelegate defineFundamentalThemeArea,
    required AFCreateAFAppDelegate createApp,
  }) {
    this.defineScreenMaps.addAll(source.defineScreenMaps);
    this.createStartupQueries.addAll(source.createStartupQueries);
    this.errorListeners.addAll(source.errorListeners);
    this.createApp = createApp;
    this.test = source.test;
    this.test.initializeForApp();
    this.createApp = createApp;
    this.defineFundamentalThemeArea = source.defineFundamentalThemeArea ?? defineFundamentalThemeArea;
    this.defineFundamentalThemeAreas.addAll(source.defineFundamentalThemeAreas);
    this.defineCore.addAll(source.defineCore);    
  }

  List<AFOnErrorDelegate> get errorHandlers {
    return errorListeners;
  }

  void dispatchStartupQueries(AFDispatcher dispatcher) {
    for(final creator in this.createStartupQueries) {
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

  AFFundamentalThemeState createFundamentalTheme(AFFundamentalDeviceTheme device, AFComponentStates areas, Iterable<AFCoreLibraryExtensionContext> libraries) {
    final builder = AFAppFundamentalThemeAreaBuilder.create();
    final initThemeArea = this.defineFundamentalThemeArea;
    if(initThemeArea != null) {
      initThemeArea(device, areas, builder);
    }

    for(final init in this.defineFundamentalThemeAreas) {
      init(device, areas, builder);
    }

    if(AFibD.config.requiresPrototypeData) {
      initPrototypeThemeArea(device, areas, builder);      
    }

    for(final library in libraries) {
      final inits = library.defineFundamentalThemeAreas;
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
      AFUITranslationID.screenPrototypes: "UI Prototypes",
      AFUITranslationID.workflowTests: "Workflow Tests",
      AFUITranslationID.stateTests: "State Tests",
      AFUITranslationID.libraries: "Libraries",
      AFUITranslationID.searchResults: "Search Results",
      AFUITranslationID.testResults: "Test Results",
      AFUITranslationID.run: "Run {0}",
      AFUITranslationID.prototype: "Prototype",
      AFUITranslationID.release: "Release",
      AFUITranslationID.recent: "Recent",
      AFUITranslationID.favorites: "Favorites",
      AFUITranslationID.afibPrototypeMode: "${AFibD.config.appNamespace.toUpperCase()} Prototype Mode",
      AFUITranslationID.afibPrototypeLoading: "",
      AFUITranslationID.wireframes: "Wireframes",
      AFUITranslationID.afibUnimplemented: "Unimplemented",
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

  void initializeCore(AFCoreDefinitionContext context, Iterable<AFCoreLibraryExtensionContext> libraries) {
    for(final init in defineCore) {
      init(context);
    }

    context.defineTheme(AFUIThemeID.defaultTheme, createTheme: AFUIDefaultTheme.create);

    for(final thirdParty in libraries) {
      thirdParty.defineAllCore(context);
    }
  }



  AFComponentStates createInitialComponentStates(AFCoreDefinitionContext core, Iterable<AFCoreLibraryExtensionContext> libraries) {
    final componentStates = <AFComponentState>[];
    for(final initState in core.componentStateInitializers) {
      final s = initState();
      if(s != null) {
        componentStates.add(s);
      }
    }    
    componentStates.add(AFUIState.initialValue());
    
    if(AFibD.config.requiresPrototypeData) {
      componentStates.add(AFUIState.initialValue());
    }

    componentStates.add(AFComponentStateUnused.initialValue());

    return AFComponentStates.createFrom(componentStates);
  }
 
  void defineScreenMap(AFScreenMap screenMap, Iterable<AFCoreLibraryExtensionContext> libraries) {
    for(final init in defineScreenMaps) {
      init(screenMap);
    }    

    for(final thirdParty in libraries) {
      for(final init in thirdParty.defineScreenMaps) {
        init(screenMap);
      }
    }
  }
}
