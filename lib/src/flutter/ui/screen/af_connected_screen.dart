import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/command/af_standard_configs.dart';
import 'package:afib/src/dart/redux/actions/af_theme_actions.dart';
import 'package:afib/src/dart/redux/state/af_store.dart';
import 'package:afib/src/flutter/test/af_test_dispatchers.dart';
import 'package:afib/src/flutter/utils/af_api_mixins.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_redux/flutter_redux.dart';
import 'package:logger/logger.dart';
import 'package:quiver/core.dart';

abstract class AFConnectedUIConfig<TState extends AFFlexibleState, TTheme extends AFFunctionalTheme, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam, TSPI extends AFStateProgrammingInterface> {
  final AFThemeID themeId;
  final AFCreateStateViewDelegate<TStateView> stateViewCreator;
  final AFCreateWidgetSPIDelegate<TSPI, AFBuildContext<TStateView, TRouteParam>, TTheme> spiCreator;
  final AFNavigateRoute route;
  final AFUIType uiType;

  AFConnectedUIConfig({
    required this.themeId,
    required this.stateViewCreator,
    required this.spiCreator,
    required this.route,
    required this.uiType
  });

  AFBuildContext<TStateView, TRouteParam>? createContextForDiff(AFStore store, AFScreenID screenId, AFID wid, { required AFWidgetParamSource paramSource, required TRouteParam? launchParam }) {
    if(AFibD.config.isTestContext) {
      final testContext = _createTestContext(store, screenId, wid, paramSource: paramSource, launchParam: launchParam);
      if(testContext != null) {
        return testContext;
      }
    }
    var paramSeg = findRouteSegment(store.state, screenId, wid, paramSource: paramSource, launchParam: launchParam);

    // this is a super weird case where we are transitioning between the demo mode store and the real store,
    // with different route states in each one.
    if(screenId == AFUIScreenID.screenDemoModeEnter || screenId == AFUIScreenID.screenDemoModeExit) {
      paramSeg = AFRouteSegment.withParam(AFRouteParamUnused.unused, null, null);
    }

 
    if(paramSeg == null) {
      assert(false, "If you reached this in testing, you may not be on the screen you think you are on in your test scenario.");
      return null;
    }
    final param = paramSeg.param as TRouteParam;
    // load in the state view.
    final stateModels = createStateViewAF(store.state, param, paramSeg.children);

    // lookup all the themes

    final standard = AFStandardBuildContextData(
      screenId: screenId,
      context: null,
      config: this,
      dispatcher:  createDispatcher(store),
      themes: store.state.public.themes,
    );

    final sourceModels = stateModels.where((e) => e != null);
    final models = List<Object>.from(sourceModels);


    // now, create the state view.
    final modelMap = AFFlexibleStateView.createModels(models);
    final stateView = stateViewCreator(modelMap);

    final context = createContext(standard, stateView, param, paramSeg.children);
    return context;
  }

  AFBuildContext<TStateView, TRouteParam>? _createTestContext(AFStore store, AFScreenID screenId, AFID wid, { required AFWidgetParamSource paramSource, required TRouteParam? launchParam }) {
    // find the test state.
    if(AFibF.g.testOnlyIsInWorkflowTest || AFStateTestContext.currentTest != null || AFibF.g.demoModeTest != null) {
      return null;
    }    

    final testState = store.state.private.testState;
    final activeTestId = testState.findTestForScreen(screenId);
    if(activeTestId == null) {
      return null;
    }
    final testContext = testState.findContext(activeTestId);
    final activeState = testState.findState(activeTestId);
    if(activeState == null) {
      return null;
    }

    final screen = activeState.navigate.screenId;
    if(testState.activeWireframe == null && uiType == AFUIType.screen && screen != screenId) {
      return null;
    }
    if(screenId == AFUIScreenID.drawerPrototype) {
      return null;
    }
    

    final paramSeg = findRouteSegment(store.state, screenId, wid, paramSource: paramSource, launchParam: launchParam);

    final mainDispatcher = AFStoreDispatcher(store);
    final dispatcher = AFSingleScreenTestDispatcher(activeTestId, mainDispatcher, testContext);
    final standard = AFStandardBuildContextData(
      screenId: screenId,
      context: null,
      config: this,
      dispatcher: dispatcher,
      themes: store.state.public.themes,
    );

    var models = activeState.models ?? <String, Object>{};
    if(activeState.timeHandling == AFTestTimeHandling.running) {
      final currentTime = store.state.public.time;
      models = Map<String, Object>.from(models);
      models["AFTimeState"] = currentTime;
    }
    final stateView = this.stateViewCreator(models);

    final param = paramSeg?.param as TRouteParam;
    return createContext(standard, stateView, param, paramSeg?.children);
  }

  TTheme findPrimaryTheme(AFState state) {
    final themes = state.public.themes;
    final theme = themes.findById(themeId) as TTheme?; 
    if(theme == null) throw AFException("Missing theme for $themeId");    
    return theme;
  }

  AFDispatcher createDispatcher(AFStore store) {
    return AFStoreDispatcher(store);
  }

  AFBuildContext<TStateView, TRouteParam> createContext(AFStandardBuildContextData standard, TStateView stateView, TRouteParam param, AFRouteSegmentChildren? children) {
    return AFBuildContext<TStateView, TRouteParam>(standard, stateView, param, children);
  }

  bool get isHierarchyRoute {
    return route == AFNavigateRoute.routeHierarchy;
  }

  bool get isGlobalRoute {
    return route == AFNavigateRoute.routeGlobalPool;
  } 

  /// Find the route parameter for the specified named screen
  AFRouteSegment? findRouteSegment(AFState state, AFScreenID parentScreen, AFID wid, { required AFWidgetParamSource paramSource, required TRouteParam? launchParam }) {
    final route = state.public.route;
    if(isHierarchyRoute) {
      return _findHierarchyRouteSegment(state, route, parentScreen, wid, paramSource: paramSource, launchParam: launchParam);
    } else {
      assert(isGlobalRoute);
      return _findGlobalRouteSegment(route, parentScreen, wid, launchParam: launchParam);
    }
  }

  TStateView createStateView(Map<String, Object> models) {
    return stateViewCreator(models);
  }

  AFRouteSegment? _findGlobalRouteSegment(AFRouteState route, AFScreenID parentScreen, AFID wid, { required TRouteParam? launchParam }) {
    final idLookup = wid == AFUIWidgetID.unused ? parentScreen : wid;
    var seg = route.findGlobalParam(idLookup);
    if(seg == null) {
      seg = _createDefaultRouteSegment(newParam: null, launchParam: launchParam);
    }
    return seg;
  }

  AFRouteSegment? _findScreenHierarchyRouteSegment(AFState state, AFRouteState route, AFScreenID screenId, {
    required TRouteParam? launchParam,
  }) {
      var seg = route.findParamFor(screenId, includePrior: true);
      if(seg == null) {
        seg = _createDefaultRouteSegment(newParam: null, launchParam: launchParam);
      }
      return seg;
  }

  AFRouteSegment? _createDefaultRouteSegment({
    required TRouteParam? newParam,
    required TRouteParam? launchParam,
  }) {
    AFRouteParam? actualParam = newParam;
    if(actualParam == null) {
      actualParam = launchParam;
    }
    if(actualParam == null && (TRouteParam == AFRouteParamUnused || TRouteParam == AFRouteParam)) {
      actualParam = AFRouteParamUnused.unused;
    } 

    if(actualParam == null) {
      return null;
    }

    return AFRouteSegment(param: actualParam, children: null, createDefaultChildParam: null);
  }

  AFRouteSegment? _findWidgetHierarchyRouteSegment(AFState state, AFRouteState route, AFScreenID screenId, AFID wid, { 
    required AFWidgetParamSource paramSource,
    required TRouteParam? launchParam 
  }) {
      final paramParent = route.findParamFor(screenId);
      assert(paramParent != null);
      if(paramParent == null) {
        return null;
      }

      if(paramSource == AFWidgetParamSource.parent) {
        assert(paramParent.param is TRouteParam);
        return paramParent;
      }

      var seg = paramParent.findChild(wid);
      if(seg == null) {
        var newParam;
        final createDefault = paramParent.createDefaultChildParam;
        if(createDefault != null) {
          newParam = createDefault(wid, state.public, paramParent);
        }
        seg = _createDefaultRouteSegment(newParam: newParam, launchParam: launchParam);
      } 
      return seg;

  }

  AFRouteSegment? _findHierarchyRouteSegment(AFState state, AFRouteState route, AFScreenID screenId, AFID wid, { required AFWidgetParamSource paramSource, required TRouteParam? launchParam }) {
    if(wid == AFUIWidgetID.unused) {
      return _findScreenHierarchyRouteSegment(state, route, screenId, launchParam: launchParam);
    } else {
      return _findWidgetHierarchyRouteSegment(state, route, screenId, wid, paramSource: paramSource, launchParam: launchParam);
    }

  }

  Iterable<Object?> createStateViewAF(AFState state, TRouteParam param, AFRouteSegmentChildren? children) {
    final public = state.public;
    final stateApp = public.componentStateOrNull<TState>();
    if(stateApp == null) {
      throw AFException("Root application state $TState cannot be null");
    }
    final stateViewCtx = AFBuildStateViewContext<TState, TRouteParam>(stateApp: stateApp, routeParam: param, statePublic: public, children: children, private: state.private);
    return createStateModels(stateViewCtx);
  }

  TSPI createSPI(BuildContext? buildContext, AFBuildContext dataContext, AFScreenID parentScreenId, AFWidgetID wid, AFWidgetParamSource paramSource) {
    final standard = AFStandardBuildContextData(
      screenId: parentScreenId,
      context: buildContext,
      config: this,
      dispatcher: dataContext.d,
      themes: dataContext.standard.themes,
    );

    final theme = standard.themes.findById(themeId);
    _updateFundamentalThemeState(buildContext);
    final withContext = createContext(standard, dataContext.s as TStateView, dataContext.p as TRouteParam, dataContext.children);
    final spiCreatorOverride = AFibF.g.findSPICreatorOverride<TSPI, AFBuildContext<TStateView, TRouteParam>, TTheme>() ?? spiCreator;
    final spi = spiCreatorOverride(withContext, theme as TTheme, parentScreenId, wid, paramSource);
    return spi;
  }

  void updateRouteParam(AFBuildContext context, AFScreenID screenId, AFID? wid, TRouteParam revised, { required AFWidgetParamSource paramSource, AFID? id }) {
    if(wid != null && route == AFNavigateRoute.routeHierarchy) {
      context.dispatch(AFNavigateSetChildParamAction(
        id: id,
        screen: screenId, 
        param: revised,
        route: route,
        paramSource: paramSource,
      ));
    } else {
      context.dispatch(AFNavigateSetParamAction(param: revised, route: route));
    }
  }

  void updateChildRouteParam<TChildRouteParam extends AFRouteParam>(AFBuildContext context, AFScreenID screenId, TChildRouteParam revised, { AFID? id }) {
    context.dispatch(AFNavigateSetChildParamAction(
      id: id,
      screen: screenId,
      param: revised,
      route: route,
      paramSource: AFWidgetParamSource.child
    ));
  }

  void updateAddChildParam<TChildRouteParam extends AFRouteParam>(AFBuildContext context, AFScreenID screenId, TChildRouteParam revised, { AFID? id }) {
    context.dispatch(AFNavigateAddChildParamAction(
      id: id,
      screen: screenId,
      param: revised,
      route: route
    ));
  }

  void updateRemoveChildParam(AFBuildContext context, AFScreenID screenId, AFID wid, { AFID? id }) {
    context.dispatch(AFNavigateRemoveChildParamAction(
      screen: screenId,
      route: route,
      widget: wid,
    ));
  }

  void _updateFundamentalThemeState(BuildContext? context) {
    if(context != null) {
      final theme = Theme.of(context);
      AFibF.g.updateFundamentalThemeData(theme);
    }
  }

  Iterable<Object?> createStateModels(AFBuildStateViewContext<TState, TRouteParam> routeParam);
}

abstract class AFScreenConfig<TSPI extends AFScreenStateProgrammingInterface, TState extends AFFlexibleState, TTheme extends AFFunctionalTheme, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFConnectedUIConfig<TState, TTheme, TStateView, TRouteParam, TSPI> {
    AFScreenConfig({
      required AFThemeID themeId,
      required AFCreateStateViewDelegate<TStateView> stateViewCreator,
      required AFCreateScreenSPIDelegate<TSPI, AFBuildContext<TStateView, TRouteParam>, TTheme> spiCreator,
      AFNavigateRoute? route,
      
    }): super(
      themeId: themeId,
      stateViewCreator: stateViewCreator,
      uiType: AFUIType.screen,
      spiCreator: (context, theme, screenId, wid, paramSource) => spiCreator(context, theme, screenId),
      route: route ?? AFNavigateRoute.routeHierarchy,
    );
}

abstract class AFDrawerConfig<TSPI extends AFDrawerStateProgrammingInterface, TState extends AFFlexibleState, TTheme extends AFFunctionalTheme, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFConnectedUIConfig<TState, TTheme, TStateView, TRouteParam, TSPI> {
    AFDrawerConfig({
      required AFThemeID themeId,
      required AFCreateStateViewDelegate<TStateView> stateViewCreator,
      required AFCreateScreenSPIDelegate<TSPI, AFBuildContext<TStateView, TRouteParam>, TTheme> spiCreator,
    }): super(
      themeId: themeId,
      stateViewCreator: stateViewCreator,
      uiType: AFUIType.drawer,
      spiCreator: (context, theme, screenId, wid, paramSource) => spiCreator(context, theme, screenId),
      // has to be, because it can be dragged onto the screen dynamically.
      route: AFNavigateRoute.routeGlobalPool,
    );
}

abstract class AFDialogConfig<TSPI extends AFDialogStateProgrammingInterface, TState extends AFFlexibleState, TTheme extends AFFunctionalTheme, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFConnectedUIConfig<TState, TTheme, TStateView, TRouteParam, TSPI> {
    AFDialogConfig({
      required AFThemeID themeId,
      required AFCreateStateViewDelegate<TStateView> stateViewCreator,
      required AFCreateScreenSPIDelegate<TSPI, AFBuildContext<TStateView, TRouteParam>, TTheme> spiCreator,
    }): super(
      themeId: themeId,
      stateViewCreator: stateViewCreator,
      uiType: AFUIType.dialog,
      spiCreator: (context, theme, screenId, wid, paramSource) => spiCreator(context, theme, screenId),
      route: AFNavigateRoute.routeGlobalPool,
    );
}

abstract class AFBottomSheetConfig<TSPI extends AFBottomSheetStateProgrammingInterface, TState extends AFFlexibleState, TTheme extends AFFunctionalTheme, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFConnectedUIConfig<TState, TTheme, TStateView, TRouteParam, TSPI> {
    AFBottomSheetConfig({
      required AFThemeID themeId,
      required AFCreateStateViewDelegate<TStateView> stateViewCreator,
      required AFCreateScreenSPIDelegate<TSPI, AFBuildContext<TStateView, TRouteParam>, TTheme> spiCreator,
    }): super(
      themeId: themeId,
      stateViewCreator: stateViewCreator,
      uiType: AFUIType.bottomSheet,
      spiCreator: (context, theme, screenId, wid, paramSource) => spiCreator(context, theme, screenId),
      route: AFNavigateRoute.routeGlobalPool,
    );
}


abstract class AFWidgetConfig<TSPI extends AFWidgetStateProgrammingInterface, TState extends AFFlexibleState, TTheme extends AFFunctionalTheme, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFConnectedUIConfig<TState, TTheme, TStateView, TRouteParam, TSPI> {
  AFWidgetConfig({
    required AFThemeID themeId,
    required AFCreateStateViewDelegate<TStateView> stateViewCreator,
    required AFCreateWidgetSPIDelegate<TSPI, AFBuildContext<TStateView, TRouteParam>, TTheme> spiCreator,
    AFNavigateRoute? route,
  }): super(
    themeId: themeId,
    stateViewCreator: stateViewCreator,
    uiType: AFUIType.widget,
    spiCreator: spiCreator,
    route: route ?? AFNavigateRoute.routeHierarchy,
  );
}

/// Base call for all screens, widgets, drawers, dialogs and bottom sheets
/// that connect to the store/state.
/// 
/// You should usually subclass on of its subclasses:
/// * [AFConnectedScreen]
/// * [AFConnectedWidget]
/// * [AFConnectedDrawer]
/// * [AFConnectedDialog]
/// * [AFConnectedBottomSheet]
abstract class AFConnectedUIBase<TState extends AFFlexibleState, TTheme extends AFFunctionalTheme, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam, TSPI extends AFStateProgrammingInterface> extends material.StatelessWidget {
  final AFConnectedUIConfig<TState, TTheme, TStateView, TRouteParam, TSPI> uiConfig;
  final AFScreenID screenId;
  final AFWidgetID wid;
  final AFWidgetParamSource paramSource;
  final TRouteParam? launchParam;
    
  //--------------------------------------------------------------------------------------
  AFConnectedUIBase({
    required this.uiConfig,
    required this.screenId,
    required this.wid,
    required this.paramSource,
    required this.launchParam,
  }): super(key: AFFunctionalTheme.keyForWIDStatic(wid != AFUIWidgetID.unused ? wid : screenId));

  //--------------------------------------------------------------------------------------
  @override
  material.Widget build(material.BuildContext context) {
    return StoreConnector<AFState, AFBuildContext?>(
        converter: (store) {          
          final context = uiConfig.createContextForDiff(store as AFStore, screenId, wid, paramSource: paramSource, launchParam: launchParam);
          return context;
        },
        distinct: true,
        builder: (buildContext, dataContext) {
          if(dataContext == null) {
            return material.Container(child: material.Text("Loading..."));
          }
          var screenIdRegister = wid == AFUIWidgetID.unused ? screenId : null;          
          if(screenIdRegister != null) {            
            AFibF.g.registerScreen(screenIdRegister, buildContext, this);
            AFibD.logUIAF?.d("Rebuilding screen $screenIdRegister");
          } else {
            AFibD.logUIAF?.d("Rebuilding widget $runtimeType");
          }

          final spi = uiConfig.createSPI(buildContext, dataContext, screenId, wid, paramSource);
          if(AFibD.config.isTestContext && wid == AFUIWidgetID.unused) {
            AFibF.g.testOnlyScreenSPIMap[screenId] = spi;
            AFibF.g.testOnlyScreenBuildContextMap[screenId] = buildContext;
          }
          final widgetResult = buildWithSPI(spi);
          return widgetResult;
        }
    );
  }

  // Returns the root parent screen, searching up the hierarchy if necessary.
  //AFScreenID get parentScreenId;

  /// Screens that have their own element tree in testing must return their screen id here,
  /// otherwise return null.
  //AFScreenID? get primaryScreenId;

  /// Returns true if this is a screen that takes up the full screen, as opposed to a subclass like 
  /// drawer, dialog, bottom sheet, etc.
  bool get isPrimaryScreen { return false; }

  /// Uggg. In general, when looking up test data for a screen in prototype mode, you expect
  /// the screen id to match.  However, when we popup little screens on top of the main screen
  /// e.g. a dialog, bottomsheet, or drawer, that is not the case.
  bool get testOnlyRequireScreenIdMatchForTestContext { return false; }

  bool routeEntryExists(AFState state) { return true; }

  /// Builds a Widget using the data extracted from the state.
  material.Widget buildWithSPI(TSPI spi);

}

/// Superclass for a screen Widget, which combined data from the store with data from
/// the route in order to render itself.
abstract class AFConnectedScreen<TState extends AFFlexibleState, TTheme extends AFFunctionalTheme, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam, TSPI extends AFScreenStateProgrammingInterface> extends AFConnectedUIBase<TState, TTheme, TStateView, TRouteParam, TSPI> {

  AFConnectedScreen({
    required AFConnectedUIConfig<TState, TTheme, TStateView, TRouteParam, TSPI> config,
    required AFScreenID screenId,
    required TRouteParam? launchParam,
  }): super(uiConfig: config, screenId: screenId, wid: AFUIWidgetID.unused, paramSource: AFWidgetParamSource.child, launchParam: launchParam);


  bool get testOnlyRequireScreenIdMatchForTestContext { return true; }
  bool get isPrimaryScreen { return true; }

  AFScreenID? get primaryScreenId {
    return screenId;
  }

  AFScreenID get parentScreenId {
    return screenId;
  }

  @override
  bool routeEntryExists(AFState state) {
    return state.public.route.routeEntryExists(this.screenId, includePrior: true);
  }

}

abstract class AFConnectedWidget<TState extends AFFlexibleState, TTheme extends AFFunctionalTheme, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam, TSPI extends AFStateProgrammingInterface> extends AFConnectedUIBase<TState, TTheme, TStateView, TRouteParam, TSPI> { 
  
  AFConnectedWidget({
    required AFConnectedUIConfig<TState, TTheme, TStateView, TRouteParam, TSPI> uiConfig,
    required AFScreenID screenId,
    required AFWidgetID wid,
    required TRouteParam? launchParam,
    AFWidgetParamSource paramSource = AFWidgetParamSource.child,
  }): super(uiConfig: uiConfig, screenId: screenId, wid: wid, paramSource: paramSource, launchParam: launchParam);

  AFScreenID? get primaryScreenId {
    return null;
  }

}

/// Use this to connect a drawer to the store.
/// 
/// Drawers are special because the user can drag in from the left or right to open them.
/// Consequently, you will need to override [AFConnectedScreenWithGlobalParam.createDefaultRouteParam],
/// which will be used to create your route parameter if the drawer was dragged onto the
/// screen without you explicitly calling [AFBuildContext.showLeftSideDrawer].
abstract class AFConnectedDrawer<TState extends AFFlexibleState, TTheme extends AFFunctionalTheme, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam, TSPI extends AFScreenStateProgrammingInterface> extends AFConnectedScreen<TState, TTheme, TStateView, TRouteParam, TSPI> {
  AFConnectedDrawer({
    required AFConnectedUIConfig<TState, TTheme, TStateView, TRouteParam, TSPI> config,
    required AFScreenID screenId,
    required TRouteParam launchParam,
  }): super(config: config, screenId: screenId, launchParam: launchParam);

  /*
  /// Look for this screens route parameter in the global pool, 
  /// rather than in the navigational hierarchy.
  @override
  AFRouteSegment? findRouteSegment(AFState state) {
    var current = super.findRouteSegment(state);
    // Note that because the user can slide a drawer on screen without the
    // application explictly opening it, we need to have the drawer create a default
    // route parameter if one does not already exist. 
    if(current == null) {
      current = AFRouteSegment(param: createDefaultRouteParam(state), children: null, createDefaultChildParam: null);
    }
    return current;
  }
  */

}


/// Use this to connect a dialog to the store.
/// 
/// You can open a dialog with [AFBuildContext.showDialogAFib].
abstract class AFConnectedDialog<TState extends AFFlexibleState, TTheme extends AFFunctionalTheme, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam, TSPI extends AFDialogStateProgrammingInterface> extends AFConnectedScreen<TState, TTheme, TStateView, TRouteParam, TSPI> {
  AFConnectedDialog({
    required AFConnectedUIConfig<TState, TTheme, TStateView, TRouteParam, TSPI> config,
    required AFScreenID screenId,
  }): super(config: config, screenId: screenId, launchParam: null);
}

/// Use this to connect a bottom sheet to the store.
/// 
/// You can open a bottom sheet with [AFBuildContext.showBottomSheet]
/// or [AFBuildContext.showModalBottomSheeet].
abstract class AFConnectedBottomSheet<TState extends AFFlexibleState, TTheme extends AFFunctionalTheme, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam, TSPI extends AFBottomSheetStateProgrammingInterface> extends AFConnectedScreen<TState, TTheme, TStateView, TRouteParam, TSPI> {
  AFConnectedBottomSheet({
    required AFConnectedUIConfig<TState, TTheme, TStateView, TRouteParam, TSPI> config,
    required AFScreenID screenId,
  }): super(config: config, screenId: screenId, launchParam: null);

}



/// A utility that reduces the number of parameters passed in AF client code, and enhances flexibility
class AFStandardBuildContextData {
  AFScreenID? screenId;
  material.BuildContext? context;
  AFDispatcher dispatcher;
  AFScreenPrototype? screenTest;
  AFConnectedUIConfig config;
  AFThemeState themes;

  AFStandardBuildContextData({
    required this.screenId,
    required this.context,
    required this.dispatcher,
    required this.config,
    this.screenTest,
    //required this.container,
    required this.themes,
  });
}

class AFBuildStateViewContext<TState extends AFFlexibleState?, TRouteParam extends AFRouteParam> {
  final AFPublicState statePublic;
  final TState stateApp;
  final AFRouteSegmentChildren? children;
  final TRouteParam routeParam;
  final AFPrivateState private;
  AFBuildStateViewContext({
    required this.stateApp,
    required this.statePublic,
    required this.routeParam,
    required this.children,
    required this.private,
  });

  TState get accessAppState {
    return stateApp;
  }

  TOtherState accessComponentState<TOtherState extends AFFlexibleState>() {
    return statePublic.components.findState<TOtherState>()!;
  }

  Map<String, Object> createModelsByType(Iterable<Object> toIntegrate) {
    return AFFlexibleStateView.createModels(toIntegrate);
  }

}


/// A utility class which you can use when you have a complex screen which passes the dispatcher,
/// screen data and param to many functions, to make things more concise.  
/// 
/// The framework cannot pass you this itself because 
class AFBuildContext<TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> with AFContextShowMixin, AFStandardAPIContextMixin {
  AFStandardBuildContextData standard;
  TStateView stateView;
  TRouteParam routeParam;
  AFRouteSegmentChildren? children;
  bool compareChildren;

  AFBuildContext(this.standard, this.stateView, this.routeParam, this.children, { this.compareChildren = true });

  /// Shorthand for accessing the route param.
  TRouteParam get p { return routeParam; }

  AFConceptualStore get targetStore {
    return AFibF.g.activeConceptualStore;
  }

  /// Shorthand for accessing data from the store
  TStateView get s { return stateView; }

  AFScreenID get accessScreenId {
    return standard.screenId!;
  }

  void updateRouteParam(AFRouteParam param) {
    final config = standard.config;
    config.updateRouteParam(this, accessScreenId, null, param, paramSource: AFWidgetParamSource.child);
  }

  void updateChildRouteParam(AFRouteParam revised) {
    final config = standard.config;
    config.updateChildRouteParam(this, accessScreenId, revised);
  }

  void updateAddChildRouteParam(AFRouteParam revised) {
    final config = standard.config;
    config.updateAddChildParam(this, accessScreenId, revised);
  }

  void updateRemoveChildRouteParam(AFWidgetID wid) {
    final config = standard.config;
    config.updateRemoveChildParam(this, accessScreenId, wid);
  }

  void closeBottomSheetFromScreen(AFScreenID sheetId, dynamic result) {
    closeBottomSheet(sheetId, result);
  }
  void closeBottomDialogFromScreen(AFScreenID dialogId, dynamic result) {
    closeDialog(dialogId, result);
  }

  void updateTextField(AFWidgetID wid, String text) {
    final param = p;
    if(param is! AFRouteParamWithFlutterState) {
      throw AFException(AFStateProgrammingInterface.errFlutterStateRequired);
    }
    final controllers = param.flutterState.textControllers;
    if(controllers == null) {
      throw AFException(AFStateProgrammingInterface.errNeedTextControllers);
    }
    controllers.update(wid, text);
  }

  void executeWireframeEvent(AFStateProgrammingInterface spi, AFID widget, Object? eventData) {
    if(!AFibD.config.isPrototypeMode || AFibF.g.internalOnlyActiveStore.state.private.testState.activeWireframe == null) {
      return;
    }
    dispatch(AFWireframeEventAction(
      spi: spi,
      screen: accessScreenId,
      widget: widget,
      eventParam: eventData
    ));
  }

  AFBuildContext<TNewStateView, TRouteParam> castToStateView<TNewStateView extends AFFlexibleStateView>(AFCreateStateViewDelegate<TNewStateView> creator) {
    return AFBuildContext<TNewStateView, TRouteParam>(
      standard,
      stateView.castToStateView<TNewStateView>(creator),
      routeParam,
      children,
    );
  }
  
  material.BuildContext? get flutterContext { 
    // there is a brief time where we don't have a context internally, as the AFBuildContext is 
    // being constructed.   But, for the purposes of users of the framework, there will always
    // be a build context for any case where they have access to an AFBuildContext. 
    return standard.context; 
  }  

  AFDispatcher get dispatcher { return standard.dispatcher; }
  AFScreenPrototype? get screenTest { return standard.screenTest; }

  /// Shorthand for accessing the dispatcher
  AFDispatcher get d { return standard.dispatcher; }

  /// Shorthand for accessing the flutter build context
  material.BuildContext get c { return flutterContext!; }

  /// Dispatch an action or query.
  void dispatch(dynamic action) {

    if(_isInWireframe) {
      if(action is AFNavigateAction) {
        if(action is AFNavigatePopAction || 
           action is AFNavigatePushAction || 
           action is AFNavigatePopNAction || 
           action is AFNavigatePopToAction || 
           action is AFNavigateReplaceAction || 
           action is AFNavigateReplaceAllAction) {
          return;
        }
      }
      if(action is AFUpdateAppStateAction || action is AFAsyncQuery) {
        return;
      } 
    }
    standard.dispatcher.dispatch(action); 
  }

  TChildRouteParam? accessChildParam<TChildRouteParam extends AFRouteParam>(AFWidgetID wid) {
    final childrenN = children;
    if(childrenN == null) {
      return null;
    }
    for(final child in childrenN.values) {
      final param = child.param;
      if(param is TChildRouteParam) {
        return param;
      }
    }
    return null;
  }

  BuildContext get contextNullCheck {
    final ctx = flutterContext;
    if(ctx == null) { throw AFException("Missing build context"); }
    return ctx;
  }


  Iterable<TChildRouteParam> accessChildrenParamsOfType<TChildRouteParam extends AFRouteParam>() {
    final result = <TChildRouteParam>[];
    final childrenN = children;
    if(childrenN == null) {
      return result;
    }
    for(final child in childrenN.values) {
      final param = child.param;
      if(param is TChildRouteParam) {
        result.add(param);
      }
    }
    return result;
  }

  bool get _isInWireframe {
    if(!AFibD.config.isTestContext) {
      return false;
    }
    return AFibF.g.internalOnlyActiveStore.state.private.testState.activeWireframe != null;
  }


  /// Called to close a drawer.
  /// 
  /// Important: If you call this method, and a drawer isn't open, it will
  /// pop the current screen and mess up the navigational state.   This method
  /// is usally called from within a drawer, in response to a user action that should
  /// close the drawer, and then do something else, like navigate to a new screen.
  void closeDrawer() {
    AFibF.g.doMiddlewareNavigation( (navState) {
      if(flutterContext != null) {
        material.Navigator.pop(contextNullCheck);
      }
    });
  }

  /// Closes the dialog, and returns the [returnValue] to the callback function that was
  /// passed to [showDialog].
  /// 
  /// This is intended to be called from within an AFConnectedDialog.  If you call it 
  /// and a dialog is not open, it will mess up the navigation state.
  void closeDialog(AFScreenID dialogId, dynamic returnValue) {
    final ctx = flutterContext;
    final didNav = (ctx != null && AFibF.g.doMiddlewareNavigation( (navState) {
        material.Navigator.pop(ctx, returnValue); 
      }));

    // Uggg.  Leaving this in but commented out for now.   Originally, this only followed
    // the test path if we weren't in the real UI (command line tests, etc).   However,
    // the problem is that the navigator pop/return is async.  So, the return handler won't
    // be called synchronously, and tests will fail because the verification code gets called
    // before the return logic gets called and does what it was supposed to do.   So, now
    // we always execute the test path, which forces the return to happen synchronously, in
    // any test context, even a real UI test context.
    //if(!didNav) {
    if(AFibD.config.isTestContext) {
      AFibF.g.testOnlySimulateCloseDialogOrSheet(dialogId, returnValue); 
    }
    //} else {
      //AFibF.g.testOnlyShowUIReturn[dialogId] = returnValue;
    //}
  }

  /// Closes the dialog, and returns the [returnValue] to the callback function that was
  /// passed to [showDialog].
  /// 
  /// This is intended to be called from within an AFConnectedDialog.  If you call it 
  /// and a dialog is not open, it will mess up the navigation state.
  void closeBottomSheet(AFScreenID sheetId, dynamic returnValue) {
    final ctx = flutterContext;
    final didNav = (ctx != null && AFibF.g.doMiddlewareNavigation( (navState) {
      material.Navigator.pop(ctx, returnValue); 
    }));

    if(!didNav) {
      AFibF.g.testOnlySimulateCloseDialogOrSheet(sheetId, returnValue);      
    } else {
      AFibF.g.testOnlyShowUIReturn[sheetId] = returnValue;
    }
  }

  bool operator==(dynamic o) {
    if(o is! AFBuildContext<TStateView, TRouteParam>) {
      return false;
    }
    var result = (routeParam == o.routeParam && stateView == o.stateView);
    if(compareChildren) {
      result &= (children == o.children);
    }
    return result;
  }

  int get hashCode {
    return hash2(routeParam.hashCode, stateView.hashCode);
  }

  /// This rebuilds the entire theme state. 
  /// 
  /// It  should almost never be used, if you are using
  /// it regularly, something is wrong.   It should be used only if:
  /// 
  /// 1. Your fundamental theme state depends on some setting in your application state (for example, a compact mode setting)
  /// 2. The user has just changed that value in the application state (e.g. from the settings area of the app)
  /// 
  /// In that case, the theme state won't refresh automatically, and you need to call this method to force
  /// it to refresh.
  void dispatchRebuildThemeState() {
    dispatch(AFRebuildThemeState());
  }

  /// Returns the number of connected children that have a route parameter
  /// of the specified type.
  int childrenCountConnected<TChildRouteParam extends AFRouteParam>() {
    final childrenN = children;
    if(childrenN == null) {
      return 0;
    }
    return childrenN.countOfChildren<TChildRouteParam>();
  }

  /// Meant to make the public state visible in the debugger, absolutely not for runtime use.
  AFPublicState? get debugOnlyPublicState {
    return AFibF.g.internalOnlyActiveStore.state.public;
  }

}

@immutable
class AFStateProgrammingInterface<TState extends AFFlexibleState, TBuildContext extends AFBuildContext, TTheme extends AFFunctionalTheme> {
  static const errFlutterStateRequired = "You can only call this method if your route param is derived from AFRouteParamWithFlutterState";
  static const errNeedTextControllers = "When constructing the AFFlutterRouteParamState for your route parameter, you must make textControllers non-null";
  static const errNeedScrollControllers = "When constructing the AFFlutterRouteParamState for your route parameter, you must make scrollControllers non-null";
  static const errNeedTapRecognizers = "When constructing the AFFlutterRouteParamState for your route parameter, you must make tapRecognizers non-null";
  final TBuildContext context;
  final AFScreenID screenId;
  final TTheme theme;
  final AFWidgetParamSource paramSource;

  AFStateProgrammingInterface(this.context, this.screenId, this.theme, this.paramSource);

  bool get hasFlutterContext {
    return context.flutterContext != null;
  }

  BuildContext? get flutterContext {
    return context.flutterContext;
  }

  TTheme get t {
    return theme;
  }

  Logger? get log {
    return AFibD.log(AFConfigEntryLogArea.ui);
  }


  TChildRouteParam? findChild<TChildRouteParam extends AFRouteParam>(AFWidgetID wid) {
    return context.accessChildParam<TChildRouteParam>(wid);
  }

  Iterable<TChildRouteParam> childrenOfType<TChildRouteParam extends AFRouteParam>() {
    return context.accessChildrenParamsOfType<TChildRouteParam>();
  }

  AFPublicState? get debugOnlyPublicState {
    return context.debugOnlyPublicState;
  }

  TState? get debugOnlyAppState {
    return context.debugOnlyPublicState?.components.findState<TState>();
  }

  TFunctionalTheme findTheme<TFunctionalTheme extends AFFunctionalTheme>(AFThemeID themeId) {
    final themes = context.standard.themes;
    return themes.findById(themeId) as TFunctionalTheme;
  }


}

@immutable
class AFScreenStateProgrammingInterface<TState extends AFFlexibleState, TBuildContext extends AFBuildContext, TTheme extends AFFunctionalTheme> extends AFStateProgrammingInterface<TState, TBuildContext, TTheme> {
  AFScreenStateProgrammingInterface(
    TBuildContext context,
    AFScreenID screenId,
    TTheme theme,
  ): super(context, screenId, theme, AFWidgetParamSource.notApplicable);

  void onPressedStandardBackButton() {
    context.navigatePop();
  }
}

@immutable
class AFDialogStateProgrammingInterface<TState extends AFFlexibleState, TBuildContext extends AFBuildContext, TTheme extends AFFunctionalTheme> extends AFScreenStateProgrammingInterface<TState, TBuildContext, TTheme> {
  AFDialogStateProgrammingInterface(
    TBuildContext context,
    AFScreenID screenId,
    TTheme theme,
  ): super(context, screenId, theme);

  void onPressedStandardBackButton() {
    context.dispatch(AFNavigatePopAction());
  }

  void closeDialog(dynamic result) {
    context.closeDialog(screenId, result);
  }
}


@immutable
class AFBottomSheetStateProgrammingInterface<TState extends AFFlexibleState, TBuildContext extends AFBuildContext, TTheme extends AFFunctionalTheme> extends AFScreenStateProgrammingInterface<TState, TBuildContext, TTheme> {
  AFBottomSheetStateProgrammingInterface(
    TBuildContext context,
    AFScreenID screenId,
    TTheme theme,
  ): super(context, screenId, theme);


  void closeBottomSheet(dynamic result) {
    context.closeBottomSheet(screenId, result);
  }
}

@immutable
class AFDrawerStateProgrammingInterface<TState extends AFFlexibleState, TBuildContext extends AFBuildContext, TTheme extends AFFunctionalTheme> extends AFScreenStateProgrammingInterface<TState, TBuildContext, TTheme> {
  AFDrawerStateProgrammingInterface(
    TBuildContext context,
    AFScreenID screenId,
    TTheme theme,
  ): super(context, screenId, theme);
}


@immutable
class AFWidgetStateProgrammingInterface<TState extends AFFlexibleState, TBuildContext extends AFBuildContext, TTheme extends AFFunctionalTheme> extends AFStateProgrammingInterface<TState, TBuildContext, TTheme> {
  final AFID wid;
  AFWidgetStateProgrammingInterface(
    TBuildContext context,
    AFScreenID screenId,
    this.wid,
    AFWidgetParamSource paramSource,
    TTheme theme,
  ): super(context, screenId, theme, paramSource);

  void updateRouteParam(AFRouteParam param) {
    final config = context.standard.config;
    config.updateRouteParam(context, screenId, wid, param, paramSource: paramSource);
  }

}

class AFBuilder<TSPI extends AFStateProgrammingInterface> extends StatelessWidget {
  final AFConnectedUIConfig config;
  final TSPI spiParent;
  final AFBuildWithSPIDelegate<TSPI> builder;

  AFBuilder({
    required this.config,
    required this.spiParent,
    required this.builder,
  });

  Widget build(BuildContext ctx) {
    return Builder(
        builder: (revisedCtx) {
          final spi = config.createSPI(revisedCtx, spiParent.context, spiParent.screenId, AFUIWidgetID.unused, spiParent.paramSource);
          return builder(spi as TSPI);
        }
    );
  }
}
