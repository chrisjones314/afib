import 'dart:async';

import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/redux/actions/af_root_actions.dart';
import 'package:afib/src/dart/redux/actions/af_theme_actions.dart';
import 'package:afib/src/dart/redux/middleware/af_query_middleware.dart';
import 'package:afib/src/dart/redux/middleware/af_route_middleware.dart';
import 'package:afib/src/dart/redux/reducers/af_reducer.dart';
import 'package:afib/src/dart/redux/state/af_store.dart';
import 'package:afib/src/flutter/test/af_init_prototype_screen_map.dart';
import 'package:afib/src/flutter/ui/screen/afui_demo_mode_transition_screen.dart';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';

/// Used internally to indicate whether you are talking about the store that drives the UI,
/// or the background store, which holds a secondary state in demo mode that doesn't impact
/// the UI.
enum AFTargetStore {
  /// The store which is attached to the UI, and which modifies the navigation state
  /// when nav actions occur
  uiStore,

  /// A background state used in demo mode and testing which can be built without impacting
  /// the visible UI.
  backgroudStore,
}

/// Used internally to indicate whether you are the apps real store/data, or about demo mode
/// data.
enum AFConceptualStore {
  appStore,

  demoModeStore,
}


class AFibTestOnlyScreenElement {
  final AFScreenID screenId;
  BuildContext element;

  AFibTestOnlyScreenElement(this.screenId, this.element);
}

class AFWidgetsBindingObserver extends WidgetsBindingObserver {

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final dispatcher = AFibF.g.internalOnlyActiveDispatcher;
    AFibF.g.dispatchLifecycleActions(dispatcher, state);    
  }

  @override 
  void didChangeMetrics() {
    AFibD.logThemeAF?.d("Detected metrics change");
    rebuildTheme();
  }

  @override
  void didChangeLocales(List<Locale>? locale) {
    AFibD.logThemeAF?.d("Detected local change");
    rebuildTheme();
  }

  @override 
  void didChangePlatformBrightness() {
    AFibD.logThemeAF?.d("Detected dark-mode change");
    rebuildTheme();
  }

  @override 
  void didChangeTextScaleFactor() {
    AFibD.logThemeAF?.d("Detected text-scale change");
    rebuildTheme();
  }

  void rebuildTheme() {
    // rebuild our theme with the new values, and then update it.
    AFibF.g.internalOnlyActiveDispatcher.dispatch(AFRebuildThemeState());    
  }
}

class AFLibraryTestHolder {
  final AFStateTests afStateTests = AFStateTests();
  final AFUnitTests afUnitTests = AFUnitTests();
  final AFSingleScreenTests afScreenTests = AFSingleScreenTests();
  final AFWidgetTests afWidgetTests = AFWidgetTests();
  final AFDialogTests afDialogTests = AFDialogTests();
  final AFBottomSheetTests afBottomSheetTests = AFBottomSheetTests();
  final AFDrawerTests afDrawerTests = AFDrawerTests();
  final AFWorkflowStateTests afWorkflowStateTests = AFWorkflowStateTests();
  final AFWorkflowStateTests afWorkflowTestsForStateTests = AFWorkflowStateTests();
}

class AFTestMissingTranslations {
  final missing = <Locale, AFTranslationSet>{};

  int get totalCount {
    var result = 0;
    for(final setT in missing.values) {
      result += setT.count;
    }
    return result;
  }

  void register(Locale locale, dynamic idOrText) {
    var setT = missing[locale];
    if(setT == null) {
      setT = AFTranslationSet(locale);
      missing[locale] = setT;
    }
    setT.setTranslation(idOrText, "missing");
  }
}

class AFibStoreStackEntry {
  AFStore? store;
  AFDispatcher? dispatcher;
  final stateChangeController = StreamController<AFPublicStateChange>();
  Stream<AFPublicStateChange>? stageChangeStream;

  AFibStoreStackEntry({
    required this.store,
    required this.dispatcher,
  });

  Stream<AFPublicStateChange> get changeEvents {
    if(stageChangeStream == null) {
      stageChangeStream = stateChangeController.stream.asBroadcastStream();
    }
    return stageChangeStream!;
  }
}

class AFibStateStackEntry {
  final String name;
  final AFState state;

  AFibStateStackEntry({
    required this.name,
    required this.state,
  });
}


class AFibGlobalState {
  final AFAppExtensionContext appContext;

  final AFDefineTestDataContext _afTestData = AFDefineTestDataContext.create();
  final primaryUITests = AFLibraryTestHolder();
  final thirdPartyUITests = <AFLibraryID, AFLibraryTestHolder>{};
  final internalOnlyScreens = <AFScreenID, AFibTestOnlyScreenElement>{};
  AFibTestOnlyScreenElement? testOnlyMostRecentScreen;
  final _recentActions = <AFActionWithKey>[];
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final sharedTestContext = AFSharedTestExtensionContext();
  final widgetsBindingObserver = AFWidgetsBindingObserver();
  final testOnlyShowUIReturn = <AFScreenID, dynamic>{};
  final coreDefinitions = AFCoreDefinitionContext();
  final testMissingTranslations = AFTestMissingTranslations();
  final wireframes = AFWireframes();
  final testOnlyDialogCompleters = <AFScreenID, void Function(dynamic)>{}; 
  final testOnlyScreenSPIMap = <AFScreenID, AFStateProgrammingInterface>{};
  final testOnlyScreenBuildContextMap = <AFScreenID, BuildContext>{};
  
  AFibStoreStackEntry? uiStore;
  AFibStoreStackEntry? backgroundStore;
  AFConceptualStore activeConceptualStore = AFConceptualStore.appStore;

  final stateStack = <AFibStateStackEntry>[];
  AFStateTestContext? demoModeTest;
  AFRouteState? preDemoModeRoute;


  final _testOnlyShowBuildContext = <AFUIType, BuildContext?>{};

  AFScreenMap? _afPrototypeScreenMap;
  AFScreenID? forcedStartupScreen;
  int navDepth = 0;

  /// The redux store, which contains the application state, NOT FOR PUBLIC USE.
  /// 
  /// WARNING: You should never
  /// access this.  AFib's testing and prototyping systems sometimes operate in contexts
  /// with a specially modified store, without a store at all, or with a special dispatcher.  If you try to access
  /// the store directly, or dispatch actions on it directly, you will compromise these systems.   
  /// 
  /// If you need to dispatch an action, you should typically call [AFBuildContext.dispatch].
  /// If you need access to items from your reduce state, you should typically override
  /// [AFConnectedScreen.createStateView], [AFConnectedWidget.createStateView], or the same method
  /// for dialogs, bottom sheets, etc.
  AFStore get internalOnlyActiveStore {
    return internalOnlyStoreEntry(activeConceptualStore).store!;
  }

  StreamController<AFPublicStateChange> get activeStateChangeController {
    return internalOnlyStoreEntry(activeConceptualStore).stateChangeController;
  }
  
  Stream<AFPublicStateChange> get activeStageChangeStream {
    return internalOnlyStoreEntry(activeConceptualStore).changeEvents;
  }

  Stream<AFPublicStateChange> stateChangeStream(AFConceptualStore conceptual) {
    return internalOnlyStoreEntry(conceptual).changeEvents;
  }

  BuildContext? testOnlyShowBuildContext(AFUIType uiType) {
    return _testOnlyShowBuildContext[uiType];
  }

  void setTestOnlyShowBuildContext(AFUIType uiType, BuildContext? ctx) {
    _testOnlyShowBuildContext[uiType] = ctx;
  }

  /// WARNING: You should never call this.  See [internalOnlyStore] for details.
  AFDispatcher get internalOnlyActiveDispatcher {
    return internalOnlyStoreEntry(activeConceptualStore).dispatcher!;
  }

  AFibGlobalState({
    required this.appContext,
    required this.activeConceptualStore,
  });

  void _internalInitializeTestData() {
    // the app may re-use library test data, so initialize that first.
    final libraries = thirdPartyLibraries;
    for(final thirdParty in libraries) {
      thirdParty.test.initializeTestData(
        testData: testData
      );
    }

    appContext.test.initializeTestData(testData: testData);
  }

  void initializeForDemoMode() {
    if(testData.isNotEmpty) {
      return;
    }

    _internalInitializeTestData();

    appContext.test.initializeForDemoMode(
      testData: testData,
      stateTests: stateTests
    );

    final libraries = thirdPartyLibraries;
    for(final thirdParty in libraries) {
      final holder = thirdParty.createScreenTestHolder();
      thirdPartyUITests[thirdParty.id] = holder;
      thirdParty.test.initializeForDemoMode(
        testData: testData,
        stateTests: holder.afStateTests,
      );
    }

    sharedTestContext.mergeWith(appContext.test.sharedTestContext);
  }


  void initializeTests() {
    if(testData.isNotEmpty) {
      return;
    }

    _internalInitializeTestData();
    
    appContext.test.initializeTests(
      testData: testData, 
      unitTests: unitTests,
      stateTests: stateTests,
      widgetTests: widgetTests,
      dialogTests: dialogTests,
      bottomSheetTests: bottomSheetTests,
      drawerTests: drawerTests,
      screenTests: screenTests,
      workflowTests: workflowTests,
      wireframes: wireframes,
    );

    final libraries = thirdPartyLibraries;
    for(final thirdParty in libraries) {
      final holder = thirdParty.createScreenTestHolder();
      thirdPartyUITests[thirdParty.id] = holder;
      thirdParty.test.initializeTests(
        testData: testData,
        unitTests: holder.afUnitTests,
        stateTests: holder.afStateTests,
        widgetTests: holder.afWidgetTests,
        dialogTests: holder.afDialogTests,
        drawerTests: holder.afDrawerTests,
        bottomSheetTests: holder.afBottomSheetTests,
        screenTests: holder.afScreenTests,
        workflowTests: holder.afWorkflowStateTests,
        wireframes: wireframes
      );
    }
    sharedTestContext.mergeWith(appContext.test.sharedTestContext);

    final workflowBuild = workflowTestsForStateTests;
    for(final stateTest in stateTests.all) {
      final stateTestId = stateTest.id;
      final protoId = AFUIPrototypeID.workflowStateTest.with1(stateTestId);
      workflowBuild.addPrototype(id: protoId, stateTestId: stateTestId, actualDisplayId: stateTestId);
    }
  }

  void initialize() {
    final libraries = thirdPartyLibraries;
    screenMap.registerDialog(AFUIScreenID.dialogStandardChoice, (_) => AFUIStandardChoiceDialog());
    screenMap.registerScreen(AFUIScreenID.screenDemoModeEnter, (_) => AFUIDemoModeEnterScreen());
    screenMap.registerScreen(AFUIScreenID.screenDemoModeExit, (_) => AFUIDemoModeExitScreen());
    appContext.defineScreenMap(screenMap, libraries);

    appContext.initializeCore(coreDefinitions, libraries);
        
    if(AFibD.config.requiresTestData) {      
      initializeTests();
    }
    if(AFibD.config.requiresPrototypeData) {
      afInitPrototypeScreenMap(screenMap);
      setPrototypeScreenMap(screenMap);
    }


    uiStore = createStore(
      conceptual: AFConceptualStore.appStore,
      enableUIRouting: true,
    );

    backgroundStore = createStore(
      conceptual: AFConceptualStore.demoModeStore,
      enableUIRouting: false,
    );
  }

  void swapActiveAndBackgroundStores({
    required AFMergePublicStateDelegate mergePublicState,
  }) {
    // we need to actually swap public background state into the original state
    final stateUI = uiStore!.store!.state;
    final stateBackground = backgroundStore!.store!.state;
    final revisedPublic = mergePublicState(stateUI.public, stateBackground.public);

    final revisedUI = stateUI.revisePublic(revisedPublic);

    // now, the UI state becomes the background state with the merged public data.
    uiStore!.store!.dispatch(AFUpdateRootStateAction(revisedUI));

    // and the background state becomes the former UI state.
    backgroundStore!.store!.dispatch(AFUpdateRootStateAction(stateUI));
  }

  AFStore internalOnlyStore(AFConceptualStore conceptual) {
    return internalOnlyStoreEntry(conceptual).store!;
  }

  AFDispatcher internalOnlyDispatcher(AFConceptualStore conceptual) {
    return internalOnlyStoreEntry(conceptual).dispatcher!;
  }

  void setActiveStore(AFConceptualStore conceptual) {
    this.activeConceptualStore = conceptual;
  }

  AFibStoreStackEntry get internalOnlyActive {
    return internalOnlyStoreEntry(activeConceptualStore);
  }

  AFibStoreStackEntry internalOnlyStoreEntry(AFConceptualStore conceptual) {

    if(uiStore!.store!.state.public.conceptualStore == conceptual) {
      return uiStore!;
    } else {
      assert(backgroundStore!.store!.state.public.conceptualStore == conceptual);
      return backgroundStore!;
    }
  }

  bool get isDemoMode {
    return demoModeTest != null;
  }

  void setPreDemoModeRoute(AFRouteState route) {
    preDemoModeRoute = route;
  }

  AFScreenMap get screenMap {
    return coreDefinitions.screenMap;
  }

  Iterable<AFCoreLibraryExtensionContext> get thirdPartyLibraries {
    return appContext.thirdParty.libraries.values;
  }

  bool get isPrototypeMode {
    return AFibD.config.requiresPrototypeData;    
  }

  AFibStoreStackEntry createStore({ 
    required AFConceptualStore conceptual,
    required bool enableUIRouting,
    AFPublicState? publicState,
  }) {


    final middleware = <Middleware<AFState>>[];
    if(enableUIRouting) {
      middleware.addAll(createRouteMiddleware());
    }
    middleware.add(AFQueryMiddleware());

    var initialState = AFState.initialState(conceptual);
    if(publicState != null) {
      initialState = initialState.copyWith(public: publicState);
    }

    final store = AFStore(
      afReducer,
      initialState: initialState,
      middleware: middleware
    );

    final dispatcher = AFStoreDispatcher(store);
    return AFibStoreStackEntry(store: store, dispatcher: dispatcher);
  }

  void pushState({
    required String name,
    AFPublicState? publicState,
    AFPrivateState? privateState,
  }) {

    final state = internalOnlyActiveStore.state;
    stateStack.add(AFibStateStackEntry(
      name: name,
      state: state,
    ));

    internalOnlyActiveDispatcher.dispatch(AFUpdateRootStateAction(
      AFState(
        public: publicState ?? state.public,
        private: privateState ?? state.private,
      )
    ));
  }

  void finishAsyncWithError(AFFinishQueryErrorContext context) {
    final handlers = coreDefinitions.errorListeners;
    for(final handler in handlers) {
      handler(context);
    }
  }

  void testOnlyVerifyActiveScreen(AFScreenID? screenId) {
    if(screenId == null) {
      return;
    }

    final state = internalOnlyActiveStore.state;
    final routeState = state.public.route;

    if(!routeState.isActiveScreen(screenId)) {
      throw AFException("Screen $screenId is not the currently active screen in route ${routeState.toString()}");
    }

    var info = AFibF.g.internalOnlyScreens[screenId];    
    if(info?.element == null) {
      throw AFException("Screen $screenId is active, but has not rendered (as there is no screen element), this might be an intenral problem in Afib.");
    }
  }


  AFPrototypeID? get testOnlyActivePrototypeId {
    final state = AFibF.g.internalOnlyActiveStore.state;
    final testId = state.private.testState.activePrototypeId;
    return testId;
  }

  AFScreenID get testOnlyActiveScreenId {
    final state = AFibF.g.internalOnlyActiveStore.state;
    final routeState = state.public.route;
    return routeState.activeScreenId;
  }

  bool get testOnlyIsInWorkflowTest {
    final activePrototypeId = testOnlyActivePrototypeId;
    if(activePrototypeId == null) {
      return false;
    }

    final test = AFibF.g.findScreenTestById(activePrototypeId);
    if(test == null) {
      return false;
    }

    return test is AFWorkflowStatePrototype;
    
  }

  AFLibraryProgrammingInterface createLPI(AFLibraryProgrammingInterfaceID id, AFDispatcher dispatcher, AFConceptualStore targetStore) {
      final factory = coreDefinitions.lpiFactories[id];
      if(factory == null) {
        throw AFException("No factory for LPI $id");
      }
      final context = AFLibraryProgrammingInterfaceContext(
        dispatcher: dispatcher,
        targetStore: targetStore,
      );
      return factory(id, context);
  }

  AFCreateWidgetSPIDelegate<TSPI, TBuildContext, TTheme>? findSPICreatorOverride<TSPI extends AFStateProgrammingInterface, TBuildContext extends AFBuildContext, TTheme extends AFFunctionalTheme>() {
    final found = coreDefinitions.spiOverrides[TSPI];
    return found as AFCreateWidgetSPIDelegate<TSPI, TBuildContext, TTheme>?;    
  }

  void testOnlySimulateCloseDialogOrSheet<TResult>(AFScreenID screenId, TResult result) {
    final completer = testOnlyDialogCompleters[screenId];
    if(completer == null) {
      throw AFException("No dialog completer for $screenId, did you try to close a dialog you didn't open in a state test?");
    }
    completer(result);
  }

  void testOnlySimulateShowDialogOrSheet<TResult>(AFScreenID screenId, Function(dynamic) onReturn) async {
    testOnlyDialogCompleters[screenId] = onReturn;
  }

  bool doMiddlewareNavigation( Function(NavigatorState) underHere ) {
    navDepth++;
    AFibD.logUIAF?.d("enter navDepth: $navDepth");
    if(navDepth > 1) {
      throw AFException("Unexpected navigation depth greater than 1");
    }
    final navState = AFibF.g.navigatorKey.currentState;
    if(navState != null) {
      underHere(navState);
    }
    navDepth--;
    AFibD.logUIAF?.d("exit navDepth: $navDepth");

    if(navDepth < 0) {
      throw AFException("Unexpected navigation depth less than 0");
    }
    return navState != null;
  }

  bool get withinMiddewareNavigation {
    return navDepth > 0;
  }

  void testOnlyShowUIRegisterReturn(AFScreenID screen, dynamic result) {
    if(AFibD.config.isTestContext) {
      this.testOnlyShowUIReturn[screen] = result;
    }
  }

  void testRegisterMissingTranslations(Locale locale, dynamic textOrId) {
    testMissingTranslations.register(locale, textOrId);
  }

  /// Used internally in tests to find widgets on the screen.  Not for public use.
  AFibTestOnlyScreenElement registerScreen(AFScreenID screenId, BuildContext screenElement, AFConnectedUIBase source) {
    var info = internalOnlyScreens[screenId];
    if(info == null) {
      info = AFibTestOnlyScreenElement(screenId, screenElement);
      internalOnlyScreens[screenId] = info;
    }
    info.element = screenElement;
    if(source is AFConnectedScreen && source is! AFConnectedDrawer) {
      testOnlyMostRecentScreen = info;
    }
    return info;
  }

  AFLibraryTestHolder? libraryTests(AFLibraryID id) {
    return thirdPartyUITests[id];
  }

  List<AFScreenPrototype> findScreenTestByTokens(List<String> tokens) {
    final result = <AFScreenPrototype>[];
    _findUITestInSetByTokens(tokens, primaryUITests, result);

    for(final thirdParty in thirdPartyUITests.values) {
      _findUITestInSetByTokens(tokens, thirdParty, result);
    }
    return result;
  }


  AFScreenPrototype? findScreenTestById(AFBaseTestID testId) {
    var test = _findTestInSet(testId, primaryUITests);
    if(test != null) {
      return test;
    }

    for(final thirdParty in thirdPartyUITests.values) {
      test = _findTestInSet(testId, thirdParty);
      if(test != null) {
        return test;
      }
    }
    return null;
  }

  void _findUITestInSetByTokens(List<String> tokens, AFLibraryTestHolder tests, List<AFScreenPrototype> results) {
    tests.afScreenTests.findByTokens(tokens, results);
    tests.afDialogTests.findByTokens(tokens, results);
    tests.afBottomSheetTests.findByTokens(tokens, results);
    tests.afDrawerTests.findByTokens(tokens, results);
    tests.afWidgetTests.findByTokens(tokens, results);
    tests.afWorkflowTestsForStateTests.findByTokens(tokens, results);
  }


  AFScreenPrototype? _findTestInSet(AFBaseTestID testId, AFLibraryTestHolder tests) {
    final single = tests.afScreenTests.findById(testId);
    if(single != null) {
      return single;
    }

    final dialog = tests.afDialogTests.findById(testId);
    if(dialog != null) {
      return dialog;
    }

    final bottomSheet = tests.afBottomSheetTests.findById(testId);
    if(bottomSheet != null) {
      return bottomSheet;
    }

    final drawer = tests.afDrawerTests.findById(testId);
    if(drawer != null) {
      return drawer;
    }

    final multi = tests.afWorkflowStateTests.findById(testId);
    if(multi != null) {
      return multi;
    }

    final multiState = tests.afWorkflowTestsForStateTests.findById(testId);
    if(multiState != null) {
      return multiState;
    }

    final widget = tests.afWidgetTests.findById(testId);
    if(widget != null) {
      return widget;
    }

    return null;
  }

  /// Used internally to reset widget tracking between tests.
  void resetTestScreens() {
    internalOnlyScreens.clear();
    _recentActions.clear();
  }

  Duration get testDelayOnNewScreen {
    return Duration(milliseconds: 500);
  }


  /// Used internally in tests to find widgets on the screen.  Not for public use.
  AFibTestOnlyScreenElement? internalOnlyFindScreen(AFScreenID screenId) {
    return internalOnlyScreens[screenId];
  }

  /// Used internally in tests to keep track of recently dispatched actions
  /// so that we can verify their contents.
  void testOnlyRegisterRegisterAction(AFActionWithKey action) {
    // uggg!  So, with all the different cases we have to handle, it is hard 
    // to register each action exactly once.   Instead, we allow them to be 
    // registered redundantly, and if it already exists we don't add it twice.
    final idxOf = _recentActions.indexWhere((x) => x == action);
    if(idxOf < 0) {
      _recentActions.add(action);
    }
  }

  /// Used internally to get the most recent action with the specified key.
  List<AFActionWithKey> get testOnlyRecentActions {
    return _recentActions;
  }

  void testOnlyClearRecentActions() {
    _recentActions.clear();
  }
 
  /// The screen map to use given the mode we are running in (its different in prototype mode, for example)
  AFScreenMap? get effectiveScreenMap {
    if(AFibD.config.requiresPrototypeData) {
      return _afPrototypeScreenMap;
    }
    return screenMap;
  }

  /// returns the screen id of the startup screen.
  /// 
  /// This varies depending on the afib mode (e.g. prototype mode has a different starutp screen than debug/production)
  AFScreenID get effectiveStartupScreenId {
    final forced = forcedStartupScreen;
    if(forced != null) {
      return forced;
    }
    return AFUIScreenID.screenStartupWrapper;
  }

  AFScreenID? get actualStartupScreenId {
    return screenMap.startupScreenId;
  }

  List<Locale> testEnabledLocales(AFConfig config) {
    final fundamentals = internalOnlyActiveStore.state.public.themes.fundamentals;
    if(AFConfigEntries.testsEnabled.isI18NEnabled(config)) {
      return fundamentals.supportedLocales.sublist(1);
    }

    return [fundamentals.supportedLocales.first];
  }


  /// Returns the route parameter used by the startup screen.
  AFCreateRouteParamDelegate? get startupRouteParamFactory {
    return screenMap.startupRouteParamFactory;
  }

  /// Returns a function that creates the initial applications state, used to reset the state.
  AFComponentStates createInitialComponentStates() {
    return appContext.createInitialComponentStates(coreDefinitions, thirdPartyLibraries);
  }



  /// This is called internally by AFib and should not really exist.
  /// 
  /// It appears it is only possible to get a valid themeData using an actual [BuildContext],
  /// which fills in certain typography information based on the locale.  As a result, we need
  /// to update the state during the actual render, which shouldn't really be necessary.   
  /// 
  /// I initially tried re-creating all the theming info during every render, which is the 
  /// redux/immutable way to go about it, but it caused my test suite execution time to double.
  /// Manually updating the themeData works because the themeData is constant across all the renders,
  /// and we recreate the fundamental and conceptual themes any time the themeData would actually change.
  void updateFundamentalThemeData(ThemeData themeData) {
    final fundamentals = internalOnlyActiveStore.state.public.themes.fundamentals;
    fundamentals.updateThemeData(themeData);
  }

  AFThemeState initializeThemeState({AFComponentStates? components}) {
    AFibD.logThemeAF?.d("Rebuild fundamental and functional themes");
    if(components == null) {
      components = internalOnlyActiveStore.state.public.components;
    }
    final device = AFFundamentalDeviceTheme.create();
    
    var fundamentals = appContext.createFundamentalTheme(device, components, thirdPartyLibraries);
    if(AFibD.config.startInDarkMode) {
      fundamentals = fundamentals.reviseOverrideThemeValue(AFUIThemeID.brightness, Brightness.dark);
    }

    return AFThemeState.create(
      fundamentals: fundamentals
    );
  }

  BuildContext? get currentFlutterContext {
    return navigatorKey.currentContext;
  }

  /// Used internally by the framework.
  /// 
  /// If you'd like to dispatch a startup action, see [AFAppExtensionContext.installCoreApp]
  /// or [AFAppExtensionContext.addStartupAction]
  void dispatchStartupQueries(AFDispatcher dispatcher) {
    final queries = createStartupQueries();
    for(final query in queries) {
      dispatcher.dispatch(query);
    }
  }

  List<AFAsyncQuery> createStartupQueries() {

    final factories2 = appContext.createStartupQueries;
    final result = <AFAsyncQuery>[];

    // always do the package info query at startup.
    result.add(AFAppPlatformInfoQuery());

    for(final factory in factories2) {
      result.add(factory());
    }

    final factories = coreDefinitions.createStartupQueries;
    for(final factory in factories) {
      result.add(factory());
    }


    return result;
  }

  /// Used internally by the framework.
  void dispatchLifecycleActions(AFDispatcher dispatcher, AppLifecycleState lifecycle) {
    coreDefinitions.dispatchLifecycleActions(dispatcher, lifecycle);
  }

  /// Retrieves screen/data pairings used for prototyping and for screen-specific
  /// testing.
  AFSingleScreenTests get screenTests {
    return primaryUITests.afScreenTests;
  }

  AFDialogTests get dialogTests {
    return primaryUITests.afDialogTests;
  }

  AFBottomSheetTests get bottomSheetTests {
    return primaryUITests.afBottomSheetTests;
  }

  AFDrawerTests get drawerTests {
    return primaryUITests.afDrawerTests;
  }

  List<AFScreenPrototype> findTestsForAreas(List<String> areas) {
    final results = <AFScreenPrototype>[];
    _addTestsForTestSet(AFibF.g.primaryUITests, areas, results);
    for(final library in AFibF.g.thirdPartyUITests.values) {
      _addTestsForTestSet(library, areas, results);
      
    }
    return results;
  }

  List<AFScreenPrototype> get allScreenTests {
    final result = <AFScreenPrototype>[];
    result.addAll(widgetTests.all);
    result.addAll(dialogTests.all);
    result.addAll(bottomSheetTests.all);
    result.addAll(drawerTests.all);
    result.addAll(screenTests.all);
    result.addAll(workflowTests.all);
    return result;
  }

  static void _addTestsForTestSet(AFLibraryTestHolder testSet, List<String> areas, List<AFScreenPrototype> results) {
    final addAllWidget = areas.contains("widget");
    final addAllScreen = areas.contains("screen");
    final addAllWorkflow  = areas.contains("workflow");
    _addTestsForAreas(testSet.afWidgetTests.all, areas, addAllWidget, results);
    _addTestsForAreas(testSet.afScreenTests.all, areas, addAllScreen, results);
    _addTestsForAreas(testSet.afWorkflowStateTests.all, areas, addAllWorkflow, results);
  }

  static void _addTestsForAreas(List<AFScreenPrototype> tests, List<String> areas, bool addAll, List<AFScreenPrototype> results) {
    final reusable = areas.indexWhere((element) => element.startsWith("reuse")) >= 0;
    for(final test in tests) {
      for(final area in areas) {        
        final testCode = test.id.code;
        if((reusable && test.hasReusable) || addAll || (area.length > 2 && testCode.contains(area))) {
          if(!results.contains(test)) {
            results.add(test);
          }
        }
      }
    } 
  }

  /// Retrieves widget/data pairings for connected and unconnected widget tests.
  AFWidgetTests get widgetTests {
    return primaryUITests.afWidgetTests;
  }

  /// Retrieves tests which pair an initial state, and then multiple screen/state tests
  /// to produce a higher-level multi-screen test.
  AFWorkflowStateTests get workflowTests {
    return primaryUITests.afWorkflowStateTests;
  }

  AFWorkflowStateTests get workflowTestsForStateTests {
    return primaryUITests.afWorkflowTestsForStateTests;
  }

  /// Retrieves unit/calculation tests
  AFUnitTests get unitTests {
    return primaryUITests.afUnitTests;
  }

  /// Mapping from string ids to builders for specific screens for the real app.
  AFDefineTestDataContext get testData {
    return _afTestData;
  }

  // Retrieves tests used to manipulate the redux state and verify that it 
  // changed as expected.
  AFStateTests get stateTests {
    return primaryUITests.afStateTests;
  }

  AFCreateAFAppDelegate? get createApp {
    return appContext.createApp;
  }

  AFPrototypeID prototypeIdForStartupId(AFID startupId) {
    final workflowTests = workflowTestsForStateTests;
    if(startupId is AFPrototypeID) {
      return startupId;
    }
    if(startupId is! AFStateTestID) {
      throw AFException("Unknown id type ${startupId.runtimeType}");
    }

    final found = workflowTests.findByStateTestId(startupId);
    if(found == null) {
      throw AFException("Could not find prototype for state test $startupId");
    }
  
    return found.id;
  }

  /// Called internally when a query finishes successfully, see [AFFlutterParams.querySuccessDelegate] 
  /// to listen for query success.
  void onQuerySuccess(AFAsyncQuery query, AFFinishQuerySuccessContext successContext) {
    coreDefinitions.updateQueryListeners(query, successContext);
  }


  /// testOnlySetForcedStartupScreen
  void testOnlySetForcedStartupScreen(AFScreenID id) {
    forcedStartupScreen = id;
  }

  /// Do not call this method, AFApp.initialize will do it for you.
  void setPrototypeScreenMap(AFScreenMap screens) {
    _afPrototypeScreenMap = screens;
  }  
}

/// A class for finding accessing global utilities in AFib. 
/// 
/// Never use the globals to track or change state in your
/// application.  Globals contain debugging utilities (e.g. logging)
/// and configuration that is immutable after startup (e.g. configuration).
class AFibF {
  static final context = AFAppExtensionContext();

  static AFibGlobalState? global;

  static void initialize(
    AFAppExtensionContext appContext,
    AFConceptualStore activeConceptualStore) {
    global = AFibGlobalState(
      appContext: appContext,
      activeConceptualStore: activeConceptualStore,
    );

    global?.initialize();
  }

  static AFibGlobalState get g { 
    return global!;
  }
}
