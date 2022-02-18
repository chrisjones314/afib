import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/redux/actions/af_theme_actions.dart';
import 'package:afib/src/dart/redux/middleware/af_query_middleware.dart';
import 'package:afib/src/dart/redux/middleware/af_route_middleware.dart';
import 'package:afib/src/dart/redux/reducers/af_reducer.dart';
import 'package:afib/src/dart/redux/state/af_store.dart';
import 'package:afib/src/flutter/test/af_init_prototype_screen_map.dart';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';


class AFibTestOnlyScreenElement {
  final AFScreenID screenId;
  BuildContext element;

  AFibTestOnlyScreenElement(this.screenId, this.element);
}

class AFWidgetsBindingObserver extends WidgetsBindingObserver {

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final dispatcher = AFibF.g.storeDispatcherInternalOnly;
    assert(dispatcher != null);
    if(dispatcher == null) return;
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
    AFibF.g.storeDispatcherInternalOnly?.dispatch(AFRebuildThemeState());    
  }
}

class AFLibraryTestHolder<TState extends AFFlexibleState> {
  final AFStateTests afStateTests = AFStateTests<TState>();
  final AFUnitTests afUnitTests = AFUnitTests();
  final AFSingleScreenTests afScreenTests = AFSingleScreenTests();
  final AFWidgetTests afWidgetTests = AFWidgetTests();
  final AFDialogTests afDialogTests = AFDialogTests();
  final AFBottomSheetTests afBottomSheetTests = AFBottomSheetTests();
  final AFDrawerTests afDrawerTests = AFDrawerTests();
  final AFWorkflowStateTests afWorkflowStateTests = AFWorkflowStateTests<TState>();
  final AFWorkflowStateTests afWorkflowTestsForStateTests = AFWorkflowStateTests<TState>();
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


class AFibGlobalState<TState extends AFFlexibleState> {
  final AFAppExtensionContext appContext;

  final AFScreenMap screenMap = AFScreenMap();
  final AFCompositeTestDataRegistry _afTestData = AFCompositeTestDataRegistry.create();
  final primaryUITests = AFLibraryTestHolder<TState>();
  final thirdPartyUITests = <AFLibraryID, AFLibraryTestHolder>{};
  final internalOnlyScreens = <AFScreenID, AFibTestOnlyScreenElement>{};
  AFibTestOnlyScreenElement? testOnlyMostRecentScreen;
  final _recentActions = <AFActionWithKey>[];
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final sharedTestContext = AFSharedTestExtensionContext();
  final widgetsBindingObserver = AFWidgetsBindingObserver();
  final testOnlyShowUIReturn = <AFScreenID, dynamic>{};
  final themeFactories = AFFunctionalThemeDefinitionContext();
  final testMissingTranslations = AFTestMissingTranslations();
  final wireframes = AFWireframes();
  final testOnlyDialogCompleters = <AFScreenID, void Function(dynamic)>{}; 
  final testOnlyScreenSPIMap = <AFScreenID, AFStateProgrammingInterface>{};
  BuildContext? testOnlyShowBuildContext;

  AFScreenMap? _afPrototypeScreenMap;
  AFScreenID? forcedStartupScreen;
  int navDepth = 0;

  /// The redux store, which contains the application state, NOT FOR PUBLIC USE.
  /// 
  /// WARNING: You should never
  /// call this.  AFib's testing and prototyping systems sometimes operate in contexts
  /// with a specially modified store, without a store at all, or with a special dispatcher.  If you try to access
  /// the store directly, or dispatch actions on it directly, you will compromise these systems.   
  /// 
  /// If you need to dispatch an action, you should typically call [AFBuildContext.dispatch].
  /// If you need access to items from your reduce state, you should typically override
  /// [AFConnectedScreen.createStateView], [AFConnectedWidget.createStateView], or the same method
  /// for dialogs, bottom sheets, etc.
  AFStore? storeInternalOnly;

  /// WARNING: You should never call this.  See [internalOnlyStore] for details.
  AFStoreDispatcher? storeDispatcherInternalOnly;

  AFibGlobalState({
    required this.appContext
  });

  void initialize() {
    final libraries = thirdPartyLibraries;
    screenMap.registerDialog(AFUIScreenID.dialogStandardChoice, (_) => AFUIStandardChoiceDialog());
    appContext.initScreenMap(screenMap, libraries);

    appContext.initializeFunctionalThemeFactories(themeFactories, libraries);
    
    final middleware = <Middleware<AFState>>[];
    middleware.addAll(createRouteMiddleware());
    middleware.add(AFQueryMiddleware());
    
    if(AFibD.config.requiresTestData) {      
      appContext.test.initialize(
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

      for(final thirdParty in libraries) {
        final holder = thirdParty.createScreenTestHolder();
        thirdPartyUITests[thirdParty.id] = holder;
        thirdParty.test.initialize(
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
        final protoId = AFUIPrototypeID.workflowStateTest.with1(stateTestId, stateTestId.tags);
        workflowBuild.addPrototype(id: protoId, stateTestId: stateTestId, actualDisplayId: stateTestId);
      }
    }
    if(AFibD.config.requiresPrototypeData) {
      afInitPrototypeScreenMap(screenMap);
      setPrototypeScreenMap(screenMap);
    }

    storeInternalOnly = AFStore(
      afReducer,
      initialState: AFState.initialState(),
      middleware: middleware
    );
    storeDispatcherInternalOnly = AFStoreDispatcher(storeInternalOnly!);
  }

  Iterable<AFUILibraryExtensionContext> get thirdPartyLibraries {
    return appContext.thirdParty.libraries.values;
  }

  void finishAsyncWithError<TState extends AFFlexibleState>(AFFinishQueryErrorContext context) {
    final handler = appContext.errorHandlerForState<TState>();
    if(handler != null) {
      handler(context as AFFinishQueryErrorContext<TState>);
    }
  }

  void testOnlyVerifyActiveScreen(AFScreenID? screenId) {
    if(screenId == null) {
      return;
    }

    final state = storeInternalOnly?.state;
    final routeState = state?.public.route;
    if(routeState == null) throw AFException("Missing route state");

    if(!routeState.isActiveScreen(screenId)) {
      throw AFException("Screen $screenId is not the currently active screen in route ${routeState.toString()}");
    }

    var info = AFibF.g.internalOnlyScreens[screenId];    
    if(info?.element == null) {
      throw AFException("Screen $screenId is active, but has not rendered (as there is no screen element), this might be an intenral problem in Afib.");
    }
  }


  AFPrototypeID? get testOnlyActivePrototypeId {
    final state = AFibF.g.storeInternalOnly?.state;
    final testId = state?.private.testState.activePrototypeId;
    return testId;
  }

  AFScreenID get testOnlyActiveScreenId {
    final state = AFibF.g.storeInternalOnly?.state;
    final routeState = state?.public.route;
    if(routeState == null) throw AFException("Missing route state");
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
    _recentActions.add(action);
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
    final fundamentals = storeInternalOnly!.state.public.themes.fundamentals;
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
    return appContext.createInitialComponentStates(thirdPartyLibraries);
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
    final fundamentals = storeInternalOnly!.state.public.themes.fundamentals;
    fundamentals.updateThemeData(themeData);
  }

  AFThemeState initializeThemeState({AFComponentStates? components}) {
    AFibD.logThemeAF?.d("Rebuild fundamental and functional themes");
    if(components == null) {
      components = storeInternalOnly!.state.public.components;
    }
    final device = AFFundamentalDeviceTheme.create();
    
    var fundamentals = appContext.createFundamentalTheme(device, components, thirdPartyLibraries);
    if(AFibD.config.startInDarkMode) {
      fundamentals = fundamentals.reviseOverrideThemeValue(AFUIThemeID.brightness, Brightness.dark);
    }

    final functionals = themeFactories.createFunctionals(fundamentals);
    return AFThemeState.create(
      fundamentals: fundamentals,
      functionals: functionals,
    );
  }


  AFThemeState rebuildFunctionalThemes({AFThemeState? initial}) {
    AFibD.logThemeAF?.d("Rebuild functional themes only");
    final themes = initial ?? storeInternalOnly!.state.public.themes;
    final functionals = themeFactories.createFunctionals(themes.fundamentals);
    return themes.copyWith(
      functionals: functionals
    );   
  }

  /// Used internally by the framework.
  /// 
  /// If you'd like to dispatch a startup action, see [AFAppExtensionContext.initializeAppFundamentals]
  /// or [AFAppExtensionContext.addStartupAction]
  void dispatchStartupQueries(AFDispatcher dispatcher) {
    appContext.dispatchStartupQueries(dispatcher);
  }

  Iterable<AFAsyncQuery> createStartupQueries() {
    final factories = appContext.createStartupQueries;
    final result = <AFAsyncQuery>[];
    for(final factory in factories) {
      result.add(factory());
    }
    return result;
  }

  /// Used internally by the framework.
  void dispatchLifecycleActions(AFDispatcher dispatcher, AppLifecycleState lifecycle) {
    appContext.dispatchLifecycleActions(dispatcher, lifecycle);
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
        if((reusable && test.hasReusable) || addAll || (area.length > 2 && testCode.contains(area)) || test.id.hasTagLike(area)) {
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
  AFCompositeTestDataRegistry get testData {
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

  /// Called internally when a query finishes successfully, see [AFFlutterParams.querySuccessDelegate] 
  /// to listen for query success.
  void onQuerySuccess(AFAsyncQuery query, AFFinishQuerySuccessContext successContext) {
    appContext.updateQueryListeners(query, successContext);
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
  static AFibGlobalState? global;

  static void initialize<TState extends AFFlexibleState>(AFAppExtensionContext appContext) {
    global = AFibGlobalState<TState>(
      appContext: appContext
    );

    global?.initialize();
  }

  static AFibGlobalState get g { 
    return global!;
  }
}
