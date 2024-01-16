import 'package:afib/afib_command.dart';
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
import 'package:redux/redux.dart';


class AFStateViewAugmentationContext with AFAccessStateSynchronouslyMixin {

  AFStateViewAugmentationContext();
}


@immutable
class AFStandardSPIData {
  final AFFunctionalTheme theme;
  final AFScreenID screenId;
  final AFWidgetID wid;
  const AFStandardSPIData({
    required this.theme,
    required this.screenId,
    required this.wid,
  });
}

abstract class AFConnectedUIConfig<TState extends AFComponentState, TTheme extends AFFunctionalTheme, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam, TSPI extends AFStateProgrammingInterface> {
  final AFThemeID themeId;
  final AFCreateStateViewDelegate<TStateView> stateViewCreator;
  final AFCreateSPIDelegate<TSPI, AFBuildContext<TStateView, TRouteParam>, TTheme> spiCreator;
  final AFUIType uiType;
  final AFCreateDefaultRouteParamDelegate? createDefaultRouteParam;
  final AFAddScreenSpecificModelsDelegate? addModelsToStateView;

  AFConnectedUIConfig({
    required this.themeId,
    required this.stateViewCreator,
    required this.spiCreator,
    required this.uiType,
    this.createDefaultRouteParam,
    required this.addModelsToStateView,
  });

  void addScreenSpecificModels(List<Object?> models) {

  }

  AFBuildContext<TStateView, TRouteParam>? createContextForDiff(AFStore store, AFScreenID screenId, AFWidgetID wid, { required AFRouteParam? launchParam }) {
    TRouteParam? actualLaunchParam;
    if(launchParam is TRouteParam) {
      actualLaunchParam = launchParam;
    } else if(launchParam is AFRouteParamRef) {
      final foundSeg = store.state.public.route.findRouteParamFull(screenId: launchParam.screenId, wid: launchParam.wid, routeLocation: launchParam.routeLocation);
      final foundParam = foundSeg?.param;
      if(foundParam != null && foundParam is TRouteParam) {
        actualLaunchParam = foundParam;
      } else {
        throw AFException("Invalid type ${foundParam?.runtimeType} for route param, expected $TRouteParam");
      }
    }

    if(AFibD.config.isTestContext) {
      final testContext = _createTestContext(store, screenId, wid, launchParam: actualLaunchParam);
      if(testContext != null) {
        return testContext;
      }
    }
    var paramSeg = findRouteSegment(store.state, screenId, wid, launchParam: actualLaunchParam);

    /// drawers can be dragged onto the screen spontaneously, without any kind of navigation.   In that case, we need to 
    /// dynamically create a launch param
    if(paramSeg == null) {
      final createDefault = createDefaultRouteParam;
      if(createDefault != null) {
        final source = AFRouteParamRef(screenId: screenId, wid: wid, routeLocation: AFRouteLocation.globalPool);
        launchParam = createDefault(source, store.state.public) as TRouteParam?;
        paramSeg = findRouteSegment(store.state, screenId, wid, launchParam: actualLaunchParam);
      }
    }

    // this is a super weird case where we are transitioning between the demo mode store and the real store,
    // with different route states in each one.
    if(screenId == AFUIScreenID.screenDemoModeEnter || screenId == AFUIScreenID.screenDemoModeExit) {
      paramSeg = AFRouteSegment.withParam(AFRouteParamUnused.unused, null, null);
    }
 
    if(paramSeg == null) {
      assert(false, "No route param was found for ${this.runtimeType}.  If you reached this in testing, you may not be on the screen you think you are on in your test scenario.  You might have forgotten to navigate to the screen.  Or, you might have failed to close a dialog/bottomsheet/drawer in a test that displays one, which can lead to this error.");
      return null;
    }

    var children = paramSeg.children;
    // this is a child widget, propagate its parent's children down.
    if(wid != AFUIWidgetID.useScreenParam) {
      final parentSeg = findRouteSegment(store.state, screenId, AFUIWidgetID.useScreenParam, launchParam: null);
      children = parentSeg?.children;      
    }

    final param = paramSeg.param as TRouteParam;
    // load in the state view.
    final stateModels = createStateViewAF(store.state, param, children);

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

    final context = createContext(standard, stateView, param, children);
    return context;
  }

  AFBuildContext<TStateView, TRouteParam>? _createTestContext(AFStore store, AFScreenID screenId, AFWidgetID wid, { required TRouteParam? launchParam }) {
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
    
    var paramSeg = findRouteSegment(store.state, screenId, wid, launchParam: launchParam);    
    var children = paramSeg?.children;
    if(wid != AFUIWidgetID.useScreenParam) {
      final parentSeg = findRouteSegment(store.state, screenId, AFUIWidgetID.useScreenParam, launchParam: null);
      children = parentSeg?.children;      
    }

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
    return createContext(standard, stateView, param, children);
  }

  AFDispatcher createDispatcher(AFStore store) {
    return AFStoreDispatcher(store);
  }

  AFBuildContext<TStateView, TRouteParam> createContext(AFStandardBuildContextData standard, TStateView stateView, TRouteParam param, AFRouteSegmentChildren? children) {
    return AFBuildContext<TStateView, TRouteParam>(standard, stateView, param, children);
  }

  /// Find the route parameter for the specified named screen
  AFRouteSegment? findRouteSegment(AFState state, AFScreenID parentScreen, AFWidgetID wid, { required TRouteParam? launchParam }) {
    final route = state.public.route;
    if(launchParam != null) {
      if(launchParam is AFRouteParamRef) {
        return route.findRouteParamFull(screenId: launchParam.screenId, wid: launchParam.wid, routeLocation: launchParam.routeLocation);
      } else if(launchParam is AFRouteParamUnused) {
        return route.findUnusedParam();
      }
    }
    if(wid == AFUIWidgetID.unused) {
      return route.findUnusedParam();
    }

    var seg = route.findRouteParamFull(
      screenId: parentScreen, 
      wid: wid,
      routeLocation: AFRouteLocation.screenHierarchy,
      includePrior: true
    );
    seg ??= _createDefaultRouteSegment(screenId: parentScreen, newParam: null, launchParam: launchParam);
    return seg;    
  }

  TStateView createStateView(Map<String, Object> models) {
    return stateViewCreator(models);
  }


  AFRouteSegment? _createDefaultRouteSegment({
    required AFScreenID screenId,
    required TRouteParam? newParam,
    required TRouteParam? launchParam,
  }) {
    AFRouteParam? actualParam = newParam;
    actualParam ??= launchParam;
    if(actualParam == null && (TRouteParam == AFRouteParamUnused || TRouteParam == AFRouteParam)) {
      actualParam = AFRouteParamUnused.unused;
    } 

    if(actualParam == null) {
      // in general, don't create the default parameter dynamically, as there is really no reasons to, but
      // for drawers, which can be dragged onto the screen, it is necessary.
      if(this is AFDrawerConfig) {
        final createDefault = this.createDefaultRouteParam;
        if(createDefault != null) {
          actualParam = createDefault(AFRouteParamRef(
            screenId: screenId,
            wid: AFUIWidgetID.useScreenParam,
            routeLocation: AFRouteLocation.screenHierarchy,
          ), AFibF.g.internalOnlyActiveStore.state.public);
        }
      } 

      if(actualParam == null) {
        return null;
      }
    }

    return AFRouteSegment(param: actualParam, children: null, createDefaultChildParam: null);
  }

  /*
  AFRouteSegment? _findWidgetHierarchyRouteSegment(AFState state, AFRouteState route, AFScreenID screenId, AFID wid, { 
    required TRouteParam? launchParam 
  }) {
      final paramParent = route.findRouteParamFull(
        screenId: screenId,
        routeLocation: AFRouteLocation.screenHierarchy,
        wid: AFUIWidgetID.useScreenParam
      );
      assert(paramParent != null);
      if(paramParent == null) {
        return null;
      }

      if(wid == AFUIWidgetID.useScreenParam) {
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
  */

  Iterable<Object?> createStateViewAF(AFState state, TRouteParam param, AFRouteSegmentChildren? children) {
    final public = state.public;
    final stateApp = public.componentStateOrNull<TState>();
    if(stateApp == null) {
      throw AFException("Root application state $TState cannot be null");
    }
    final stateViewCtx = AFBuildStateViewContext<TState, TRouteParam>(stateApp: stateApp, routeParam: param, statePublic: public, children: children, private: state.private);
    final result = createStateModels(stateViewCtx);
    _augmentStateViewModels(result);
    final addModels = addModelsToStateView;
    if(addModels != null) {
      addModels(stateViewCtx, result);
    }
    return result;
  }

  void _augmentStateViewModels(List<Object?> result) {
    AFibF.g.coreDefinitions.augmentStateViewModels<TStateView>(result);
  }

  TSPI createSPI(BuildContext? buildContext, AFBuildContext dataContext, AFScreenID parentScreenId, AFWidgetID wid) {
    final standard = AFStandardBuildContextData(
      screenId: parentScreenId,
      context: buildContext,
      config: this,
      dispatcher: dataContext.d,
      themes: dataContext.standard.themes,
    );

    _updateFundamentalThemeState(buildContext);
    final withContext = createContext(standard, dataContext.s as TStateView, dataContext.p as TRouteParam, dataContext.children);
    final theme = standard.themes.createFunctionalTheme(themeId, withContext);
    final spiCreatorOverride = AFibF.g.findSPICreatorOverride<TSPI, AFBuildContext<TStateView, TRouteParam>, TTheme>() ?? spiCreator;

    final spiStandard = AFStandardSPIData(
      theme: theme, 
      screenId: parentScreenId, 
      wid: wid
    );
    final spi = spiCreatorOverride(withContext, spiStandard);
    return spi;
  }

  void updateRouteParam(AFBuildContext context, AFRouteParam revised, { AFID? id }) {
    context.dispatch(AFNavigateSetParamAction(param: revised));
  }
  void updateAddChildParam<TChildRouteParam extends AFRouteParam>(AFBuildContext context, TChildRouteParam revised, { AFID? id }) {
    context.dispatch(AFNavigateAddChildParamAction(
      id: id,
      param: revised,
    ));
  }

  void updateRemoveChildParam(AFBuildContext context, AFScreenID screenId, AFID wid, AFRouteLocation route, { AFID? id }) {
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

  List<Object?> createStateModels(AFBuildStateViewContext<TState, TRouteParam> routeParam);
}

abstract class AFScreenConfig<TSPI extends AFScreenStateProgrammingInterface, TState extends AFComponentState, TTheme extends AFFunctionalTheme, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFConnectedUIConfig<TState, TTheme, TStateView, TRouteParam, TSPI> {
    AFScreenConfig({
      required AFThemeID themeId,
      required AFCreateStateViewDelegate<TStateView> stateViewCreator,
      required AFCreateSPIDelegate<TSPI, AFBuildContext<TStateView, TRouteParam>, TTheme> spiCreator,
      AFAddScreenSpecificModelsDelegate? addModelsToStateView,
      AFCreateDefaultRouteParamDelegate? createDefaultRouteParam,
    }): super(
      themeId: themeId,
      stateViewCreator: stateViewCreator,
      uiType: AFUIType.screen,
      spiCreator: spiCreator,
      addModelsToStateView: addModelsToStateView,
      createDefaultRouteParam: createDefaultRouteParam,
    );
}

abstract class AFDrawerConfig<TSPI extends AFDrawerStateProgrammingInterface, TState extends AFComponentState, TTheme extends AFFunctionalTheme, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFConnectedUIConfig<TState, TTheme, TStateView, TRouteParam, TSPI> {
    AFDrawerConfig({
      required AFThemeID themeId,
      required AFCreateStateViewDelegate<TStateView> stateViewCreator,
      required AFCreateSPIDelegate<TSPI, AFBuildContext<TStateView, TRouteParam>, TTheme> spiCreator,
      AFCreateDefaultRouteParamDelegate? createDefaultRouteParam,
      AFAddScreenSpecificModelsDelegate? addModelsToStateView,
    }): super(
      themeId: themeId,
      stateViewCreator: stateViewCreator,
      uiType: AFUIType.drawer,
      spiCreator: spiCreator,
      createDefaultRouteParam: createDefaultRouteParam,
      addModelsToStateView: addModelsToStateView,
    );
}

abstract class AFDialogConfig<TSPI extends AFDialogStateProgrammingInterface, TState extends AFComponentState, TTheme extends AFFunctionalTheme, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFConnectedUIConfig<TState, TTheme, TStateView, TRouteParam, TSPI> {
    AFDialogConfig({
      required AFThemeID themeId,
      required AFCreateStateViewDelegate<TStateView> stateViewCreator,
      required AFCreateSPIDelegate<TSPI, AFBuildContext<TStateView, TRouteParam>, TTheme> spiCreator,
      AFCreateDefaultRouteParamDelegate? createDefaultRouteParam,
      AFAddScreenSpecificModelsDelegate? addModelsToStateView,
    }): super(
      themeId: themeId,
      stateViewCreator: stateViewCreator,
      uiType: AFUIType.dialog,
      spiCreator: spiCreator,
      createDefaultRouteParam: createDefaultRouteParam,
      addModelsToStateView: addModelsToStateView,
    );
}

abstract class AFBottomSheetConfig<TSPI extends AFBottomSheetStateProgrammingInterface, TState extends AFComponentState, TTheme extends AFFunctionalTheme, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFConnectedUIConfig<TState, TTheme, TStateView, TRouteParam, TSPI> {
    AFBottomSheetConfig({
      required AFThemeID themeId,
      required AFCreateStateViewDelegate<TStateView> stateViewCreator,
      required AFCreateSPIDelegate<TSPI, AFBuildContext<TStateView, TRouteParam>, TTheme> spiCreator,
      AFCreateDefaultRouteParamDelegate? createDefaultRouteParam,
      AFAddScreenSpecificModelsDelegate? addModelsToStateView,
    }): super(
      themeId: themeId,
      stateViewCreator: stateViewCreator,
      uiType: AFUIType.bottomSheet,
      spiCreator: spiCreator,
      createDefaultRouteParam: createDefaultRouteParam,
      addModelsToStateView: addModelsToStateView,
    );
}


abstract class AFWidgetConfig<TSPI extends AFWidgetStateProgrammingInterface, TState extends AFComponentState, TTheme extends AFFunctionalTheme, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFConnectedUIConfig<TState, TTheme, TStateView, TRouteParam, TSPI> {
  AFWidgetConfig({
    required AFThemeID themeId,
    required AFCreateStateViewDelegate<TStateView> stateViewCreator,
    required AFCreateSPIDelegate<TSPI, AFBuildContext<TStateView, TRouteParam>, TTheme> spiCreator,
    AFRouteLocation? route,
    AFAddScreenSpecificModelsDelegate? addModelsToStateView,
  }): super(
    themeId: themeId,
    stateViewCreator: stateViewCreator,
    uiType: AFUIType.widget,
    spiCreator: spiCreator,
    addModelsToStateView: addModelsToStateView,
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
abstract class AFConnectedUIBase<TState extends AFComponentState, TTheme extends AFFunctionalTheme, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam, TSPI extends AFStateProgrammingInterface> extends material.StatelessWidget {
  final AFConnectedUIConfig<TState, TTheme, TStateView, TRouteParam, TSPI> uiConfig;
  final AFScreenID screenId;
  final AFWidgetID wid;
  final AFRouteParam? launchParam;
    
  //--------------------------------------------------------------------------------------
  AFConnectedUIBase({
    required this.uiConfig,
    required this.screenId,
    required this.wid,
    required this.launchParam,
  }): super(key: AFFunctionalTheme.keyForWIDStatic(wid != AFUIWidgetID.unused ? wid : screenId));

  //--------------------------------------------------------------------------------------
  @override
  material.Widget build(material.BuildContext context) {
    return StoreConnector<AFState, AFBuildContext<TStateView, TRouteParam>?>(
        converter: (store) {    
          final context = uiConfig.createContextForDiff(store as AFStore, screenId, wid, launchParam: launchParam);
          return context;
        },
        distinct: true,
        builder: (buildContext, dataContext) {
          if(dataContext == null) {
            return const material.Text("Loading...");
          }
          var screenIdRegister = wid == AFUIWidgetID.useScreenParam ? screenId : null;          
          if(screenIdRegister != null) {            
            AFibF.g.registerScreen(screenIdRegister, buildContext, this);
            AFibD.logUIAF?.d("Rebuilding screen $screenIdRegister");
          } else {
            AFibD.logUIAF?.d("Rebuilding widget $runtimeType");
          }

          final spi = uiConfig.createSPI(buildContext, dataContext, screenId, wid);
          if(AFibD.config.isTestContext && wid == AFUIWidgetID.useScreenParam) {
            AFibF.g.testOnlyScreenSPIMap[screenId] = spi;
            AFibF.g.testOnlyScreenBuildContextMap[screenId] = buildContext;
          }
          final widgetResult = buildWithSPI(spi);
          return widgetResult;
        },
        onInit: onInitAfib,
        onDispose: onDisposeAfib,
        onInitialBuild: onInitialBuildAFib,
        onWillChange: onWillChangeAFib,
        onDidChange: onDidChangeAFib,
    );
  }

  void onInitAfib(Store<AFState> store) {
    onInit(store);
  }

  void onDisposeAfib(Store<AFState> store) {
    onDispose(store);
  }

  void onInitialBuildAFib(AFBuildContext<TStateView, TRouteParam>? context) {
    if(context == null) {
      return;
    }

    onInitialBuild(context);
  }

  void onWillChangeAFib(AFBuildContext<TStateView, TRouteParam>? previous, AFBuildContext<TStateView, TRouteParam>? next) {
    if(previous == null || next == null) {
      return;
    }

    onWillChange(previous, next);
  }

  void onDidChangeAFib(AFBuildContext<TStateView, TRouteParam>? previous, AFBuildContext<TStateView, TRouteParam>? next) {
    if(previous == null || next == null) {
      return;
    }

    onDidChange(previous, next);
  }

  void onInit(Store<AFState> store) {

  }

  void onDispose(Store<AFState> store) {
    
  }

  void onInitialBuild(AFBuildContext<TStateView, TRouteParam> context) {
  }

  void onWillChange(AFBuildContext<TStateView, TRouteParam> previous, AFBuildContext<TStateView, TRouteParam> next) {
  }

  void onDidChange(AFBuildContext<TStateView, TRouteParam> previous, AFBuildContext<TStateView, TRouteParam> next) {
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
abstract class AFConnectedScreen<TState extends AFComponentState, TTheme extends AFFunctionalTheme, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam, TSPI extends AFScreenStateProgrammingInterface> extends AFConnectedUIBase<TState, TTheme, TStateView, TRouteParam, TSPI> {

  AFConnectedScreen({
    required AFConnectedUIConfig<TState, TTheme, TStateView, TRouteParam, TSPI> config,
    required AFScreenID screenId,
    required TRouteParam? launchParam,
  }): super(uiConfig: config, screenId: screenId, wid: AFUIWidgetID.useScreenParam, launchParam: launchParam);


  @override
  bool get testOnlyRequireScreenIdMatchForTestContext { return true; }
  @override
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

abstract class AFConnectedWidget<TState extends AFComponentState, TTheme extends AFFunctionalTheme, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam, TSPI extends AFStateProgrammingInterface> extends AFConnectedUIBase<TState, TTheme, TStateView, TRouteParam, TSPI> { 

  AFConnectedWidget({
    required AFConnectedUIConfig<TState, TTheme, TStateView, TRouteParam, TSPI> config,
    required AFScreenID? screenIdOverride,
    required AFWidgetID? widOverride,
    required AFRouteParam launchParam,
  }): super(
    uiConfig: config, 
    screenId: screenIdOverride ?? launchParam.screenId, 
    wid: widOverride ?? launchParam.wid, 
    launchParam: launchParam
  );

  AFScreenID? get primaryScreenId {
    return null;
  }

}

/// Use this to connect a drawer to the store.
/// 
/// Drawers are special because the user can drag in from the left or right to open them.
/// Consequently, AFib creates a default version of their route parameter in the global state, 
/// which is used if the drawer is dragged onto the screen.
abstract class AFConnectedDrawer<TState extends AFComponentState, TTheme extends AFFunctionalTheme, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam, TSPI extends AFScreenStateProgrammingInterface> extends AFConnectedScreen<TState, TTheme, TStateView, TRouteParam, TSPI> {
  AFConnectedDrawer({
    required AFConnectedUIConfig<TState, TTheme, TStateView, TRouteParam, TSPI> config,
    required AFScreenID screenId,
  }): super(config: config, screenId: screenId, launchParam: null);

}


/// Use this to connect a dialog to the store.
/// 
/// You can open a dialog with [AFBuildContext.showDialogAFib].
abstract class AFConnectedDialog<TState extends AFComponentState, TTheme extends AFFunctionalTheme, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam, TSPI extends AFDialogStateProgrammingInterface> extends AFConnectedScreen<TState, TTheme, TStateView, TRouteParam, TSPI> {
  AFConnectedDialog({
    required AFConnectedUIConfig<TState, TTheme, TStateView, TRouteParam, TSPI> config,
    required AFScreenID screenId,
  }): super(config: config, screenId: screenId, launchParam: null);
}

/// Use this to connect a bottom sheet to the store.
/// 
/// You can open a bottom sheet with [AFContextShowMixin.showBottomSheet]
abstract class AFConnectedBottomSheet<TState extends AFComponentState, TTheme extends AFFunctionalTheme, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam, TSPI extends AFBottomSheetStateProgrammingInterface> extends AFConnectedScreen<TState, TTheme, TStateView, TRouteParam, TSPI> {
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

class AFBuildStateViewContext<TState extends AFComponentState?, TRouteParam extends AFRouteParam> {
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

  AFAppPlatformInfoState get accessPlatformInfo {
    return statePublic.appPlatformInfo;
  }

  AFTimeState get accessCurrentTime {
    return statePublic.time;
  }

  TOtherState accessComponentState<TOtherState extends AFComponentState>() {
    return statePublic.components.findState<TOtherState>()!;
  }

  Map<String, Object> createModelsByType(Iterable<Object> toIntegrate) {
    return AFFlexibleStateView.createModels(toIntegrate);
  }

}

/// A utility providing access to all the functionality that can be used in an event 
/// that occurs at a specific instant in time, as in an event, as opposed to a rendering context.
abstract class AFOnEventContext with AFContextShowMixin  {
  //TRouteParam? accessRouteParam<TRouteParam extends AFRouteParam>(AFRouteParamRef ref);
  TState accessComponentState<TState extends AFComponentState>();

  /// Pull the exact current time, which should only be used from event handlers.
  AFTimeState accessPullTime() {
    final pushTime = AFibF.g.internalOnlyActiveStore.state.public.time;
    return pushTime.reviseForActualNow(DateTime.now());
  }

}

class AFPublicStateOnEventContext extends AFOnEventContext {
  final AFPublicState public;
  @override
  final AFDispatcher dispatcher;

  AFPublicStateOnEventContext({
    required this.dispatcher,
    required this.public,
  });

  @override
  TState accessComponentState<TState extends AFComponentState>() {
    return public.components.findState<TState>()!;
  }

}

class AFBuildOnEventContext extends AFOnEventContext {
  
  @override
  final AFDispatcher dispatcher;
  final AFBuildContext buildContext;


  AFBuildOnEventContext({
    required this.dispatcher,
    required this.buildContext,
  });

  @override
  TState accessComponentState<TState extends AFComponentState>() {
    final stateView = buildContext.stateView;
    return createStateFromModels<TState>(stateView.models);
  }
  
  static TState createStateFromModels<TState extends AFComponentState>(Map<String, Object> models) {
    final creator = AFibF.g.findComponentStateCreator<TState>();
    if(creator == null) {
      throw AFException("No component state registered for $TState?  It should be registered in ..._define_core.dart");
    }
    final compState = creator(models);    
    if(compState is! TState) {
      throw AFException ("Wrong type returned by state creator registerd in ..._define_core.dart?");
    }
    return compState;    
  }

}

class AFTestOnEventContext extends AFOnEventContext {
  @override
  final AFDispatcher dispatcher;
  final Object stateView;

  AFTestOnEventContext({
    required this.dispatcher,
    required this.stateView
  });

  /*
  @override
  TRouteParam? accessRouteParam<TRouteParam extends AFRouteParam>(AFRouteParamRef ref) {
    final seg = accessRouteParamSegment(ref);
    return seg?.param as TRouteParam?;
  }
  */

  @override
  TState accessComponentState<TState extends AFComponentState>() {
    final registry = AFibF.g.testData;
    final models = registry.resolveStateViewModels(stateView);
    return AFBuildOnEventContext.createStateFromModels<TState>(models);
  }
}


/// A utility class which you can use when you have a complex screen which passes the dispatcher,
/// screen data and param to many functions, to make things more concise.  
/// 
/// The framework cannot pass you this itself because 
class AFBuildContext<TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> with AFContextShowMixin, AFStandardAPIContextMixin, AFStandardNavigateMixin implements AFStandardAPIContextInterface {
  AFStandardBuildContextData standard;
  TStateView stateView;
  TRouteParam routeParam;
  AFRouteSegmentChildren? children;
  bool compareChildren;

  AFBuildContext(this.standard, this.stateView, this.routeParam, this.children, { this.compareChildren = true });

  /// Shorthand for accessing the route param.
  TRouteParam get p { return routeParam; }

  @override
  AFConceptualStore get targetStore {
    return AFibF.g.activeConceptualStore;
  }

  AFTimeState accessCurrentTime() {
    return AFibF.g.internalOnlyActiveStore.state.public.time;
  }


  /// Provides access the full AFPublicState, which can be accessed in a UI event handler,
  /// but not as part of your actual build logic.
  /// 
  /// Note that the build logic should only reference data in your route parameter and state view,
  /// because your UI only re-builds when data in those objects changes.
  /// 
  /// However, in an event handler, like that for a button press, you can and should be able to access
  /// any data in the entire AFib state.   This call lets you do so, while clarifying that it should not
  /// be used as part of your build logic.
  /// 
  /// There are parallel versions in the finish query context and in the context within your default theme
  /// and LPIs, for easy-of-use with shared functions that expect an [AFOnEventContext].
  /// 
  /// Note that when defining a screen prototype, you can use the navigateWithEventContext parameter, rather
  /// than navigate, to gain access to an eventContext and pass it to a navigatePush function, or other shared function.
  AFOnEventContext accessOnEventContext() {
    return AFBuildOnEventContext(
      dispatcher: dispatcher,
      buildContext: this
    );
  }

  TRootModel findRootType<TRootModel extends Object>() {
    return s.findType<TRootModel>();
  }

  /// Shorthand for accessing data from the store
  TStateView get s { return stateView; }

  AFScreenID get screenId {
    return accessScreenId;
  }

  AFRouteLocation get routeLocation {
    return p.routeLocation;
  }

  AFScreenID get accessScreenId {
    return standard.screenId!;
  }

  void updateRouteParam(AFRouteParam param) {
    final config = standard.config;
    config.updateRouteParam(this, param);
  }

  /// Access the push time in your state view, which is only accurate to your state view's time specificity.
  AFTimeState accessPushTime() {
    final pushTime = s.findTypeOrNull<AFTimeState>();
    if(pushTime == null) {
      throw AFException("No push time in state view.  Make sure you added an AFTimeState in your ...state_view.dart");
    }
    return pushTime;
  }

  /// Access platform-related info like you app versions, and what OS you are running on.   
  /// 
  /// Note that this information does not need to be in your state view, because none of it can change during the course
  /// of your app's execution.  It is all static.
  AFAppPlatformInfoState accessAppPlatformInfo() {
    
    final publicState = AFibF.g.internalOnlyActiveStore.state.public;
    return publicState.appPlatformInfo;
  }

  Logger? get log {
    return AFibD.log(AFConfigEntryLogArea.ui);
  }

  void updateAddChildRouteParam(AFRouteParam revised) {
    final config = standard.config;
    config.updateAddChildParam(this, revised);
  }

  void updateRemoveChildRouteParam(AFWidgetID wid, { AFRouteLocation routeLocation = AFRouteLocation.screenHierarchy }) {
    final config = standard.config;
    config.updateRemoveChildParam(this, accessScreenId, wid, routeLocation);
  }

  void closeBottomSheetFromScreen(AFScreenID sheetId, dynamic result) {
    closeBottomSheet(sheetId, result);
  }
  void closeBottomDialogFromScreen(AFScreenID dialogId, dynamic result) {
    closeDialog(dialogId, result);
  }

  void updateTextField(AFWidgetID wid, String text) {
    final param = p;
    
    final flutterState = param.flutterStatePrivate as AFFlutterRouteParamState?;
    final controllers = flutterState?.textControllers;
    if(controllers == null) {
      throw AFException(AFStateProgrammingInterface.errNeedTextControllers);
    }
    controllers.update(wid, text);
  }

  @override
  void executeWireframeEvent(AFID widget, Object? eventData, {
    AFPressedDelegate? onSuccess,
  }) {
    if(!AFibD.config.isPrototypeMode || AFibF.g.internalOnlyActiveStore.state.private.testState.activeWireframe == null) {
      return;
    }
    dispatch(AFWireframeEventAction(
      screen: accessScreenId,
      widget: widget,
      eventParam: eventData,
      stateView: stateView,
      onSuccess: onSuccess,
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
  
  @override
  material.BuildContext? get flutterContext { 
    // there is a brief time where we don't have a context internally, as the AFBuildContext is 
    // being constructed.   But, for the purposes of users of the framework, there will always
    // be a build context for any case where they have access to an AFBuildContext. 
    return standard.context; 
  }  

  @override
  AFDispatcher get dispatcher { return standard.dispatcher; }
  AFScreenPrototype? get screenTest { return standard.screenTest; }

  /// Shorthand for accessing the dispatcher
  AFDispatcher get d { return standard.dispatcher; }

  /// Shorthand for accessing the flutter build context
  material.BuildContext get c { return flutterContext!; }

  /// Dispatch an action or query.
  @override
  void dispatch(dynamic action) {

    final wireframe = activeWireframe;
    if(wireframe != null) {
      if(action is AFNavigateAction) {
        final isNavigate = (action is AFNavigatePopAction || 
           action is AFNavigatePushAction || 
           action is AFNavigatePopNAction || 
           action is AFNavigatePopToAction || 
           action is AFNavigateReplaceAction || 
           action is AFNavigateReplaceAllAction);

        // the default test dispatcher won't do this, so we need to go direct to the real dispatcher.
        if(isNavigate && wireframe.enableUINavigation) {
          AFibF.g.internalOnlyActiveDispatcher.dispatch(action);
          return;
        }

        if(isNavigate) {
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

  @override
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

  AFWireframe? get activeWireframe {
    if(!AFibD.config.isTestContext) {
      return null;
    }
    return AFibF.g.internalOnlyActiveStore.state.private.testState.activeWireframe;
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
    // ignore: unused_local_variable
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

  @override
  bool operator==(dynamic other) {
    if(other is! AFBuildContext<TStateView, TRouteParam>) {
      return false;
    }
    var result = (routeParam == other.routeParam && stateView == other.stateView);
    if(compareChildren) {
      result &= (children == other.children);
    }
    return result;
  }

  @override
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
class AFStateProgrammingInterface<TState extends AFComponentState, TBuildContext extends AFBuildContext, TTheme extends AFFunctionalTheme> {
  static const errFlutterStateRequired = "You can only call this method if your route param is derived from AFRouteParamWithFlutterState";
  static const errNeedTextControllers = "When constructing the AFFlutterRouteParamState for your route parameter, you must make textControllers non-null";
  static const errNeedScrollControllers = "When constructing the AFFlutterRouteParamState for your route parameter, you must make scrollControllers non-null";
  static const errNeedTapRecognizers = "When constructing the AFFlutterRouteParamState for your route parameter, you must make tapRecognizers non-null";
  final TBuildContext context;
  final AFStandardSPIData standard;

  const AFStateProgrammingInterface(this.context, this.standard);

  bool get hasFlutterContext {
    return context.flutterContext != null;
  }

  /// Provided for consistency with [AFBuildContext.accessOnEventContext], so that
  /// you can pass an [AFOnEventContext] to any shared function that requires one.
  AFOnEventContext accessOnEventContext() {
    return context.accessOnEventContext();
  }

  AFRouteLocation get routeLocation {
    return context.p.routeLocation;
  }

  BuildContext? get flutterContext {
    return context.flutterContext;
  }

  TTheme get theme {
    return t;
  }

  TTheme get t {
    return standard.theme as TTheme;
  }

  AFScreenID get screenId {
    return standard.screenId;
  }

  AFWidgetID get wid {
    return standard.wid;
  }

  Logger? get log {
    return AFibD.log(AFConfigEntryLogArea.ui);
  }

  AFRouteParamRef launchParamForWidget(
    AFWidgetID wid,
  ) {
    return AFRouteParamRef(screenId: screenId, routeLocation: routeLocation, wid: wid);
  }

  AFRouteParamRef launchParamForParentScreen() {
    return AFRouteParamRef(screenId: screenId, routeLocation: routeLocation, wid: AFUIWidgetID.useScreenParam);
  }

  AFRouteParamRef launchParamUnused() {
    return const AFRouteParamRef(screenId: AFUIScreenID.unused, routeLocation: AFRouteLocation.globalPool, wid: AFUIWidgetID.useScreenParam);
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
}

@immutable
class AFScreenStateProgrammingInterface<TState extends AFComponentState, TBuildContext extends AFBuildContext, TTheme extends AFFunctionalTheme> extends AFStateProgrammingInterface<TState, TBuildContext, TTheme> {
  const AFScreenStateProgrammingInterface(
    TBuildContext context,
    AFStandardSPIData standard,
  ): super(context, standard);

  void onPressedStandardBackButton({
    bool worksInSingleScreenTest = true
  }) {
    context.navigatePop(worksInSingleScreenTest: worksInSingleScreenTest);
  }
}

@immutable
class AFDialogStateProgrammingInterface<TState extends AFComponentState, TBuildContext extends AFBuildContext, TTheme extends AFFunctionalTheme> extends AFScreenStateProgrammingInterface<TState, TBuildContext, TTheme> {
  const AFDialogStateProgrammingInterface(
    TBuildContext context,
    AFStandardSPIData standard,
  ): super(context, standard);

  @override
  void onPressedStandardBackButton({
    bool worksInSingleScreenTest = true
  }) {
    context.dispatch(AFNavigatePopAction(worksInSingleScreenTest: worksInSingleScreenTest));
  }

  void onCloseDialog(dynamic result) {
    context.closeDialog(standard.screenId, result);
  }
}


@immutable
class AFBottomSheetStateProgrammingInterface<TState extends AFComponentState, TBuildContext extends AFBuildContext, TTheme extends AFFunctionalTheme> extends AFScreenStateProgrammingInterface<TState, TBuildContext, TTheme> {
  const AFBottomSheetStateProgrammingInterface(
    TBuildContext context,
    AFStandardSPIData standard,
  ): super(context, standard);


  void onCloseBottomSheet(dynamic result) {
    context.closeBottomSheet(screenId, result);
  }
}

@immutable
class AFDrawerStateProgrammingInterface<TState extends AFComponentState, TBuildContext extends AFBuildContext, TTheme extends AFFunctionalTheme> extends AFScreenStateProgrammingInterface<TState, TBuildContext, TTheme> {
  const AFDrawerStateProgrammingInterface(
    TBuildContext context,
    AFStandardSPIData standard
  ): super(context, standard);

  void onCloseDrawer() {
    context.closeDrawer();
  }
}


@immutable
class AFWidgetStateProgrammingInterface<TState extends AFComponentState, TBuildContext extends AFBuildContext, TTheme extends AFFunctionalTheme> extends AFStateProgrammingInterface<TState, TBuildContext, TTheme> {
  const AFWidgetStateProgrammingInterface(
    TBuildContext context,
    AFStandardSPIData standard,
  ): super(context, standard);
}

class AFBuilder<TSPI extends AFStateProgrammingInterface> extends StatelessWidget {
  final AFConnectedUIConfig config;
  final TSPI spiParent;
  final AFBuildWithSPIDelegate<TSPI> builder;

  const AFBuilder({Key? key, 
    required this.config,
    required this.spiParent,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(
        builder: (revisedCtx) {
          final spi = config.createSPI(revisedCtx, spiParent.context, spiParent.screenId, AFUIWidgetID.unused);
          return builder(spi as TSPI);
        }
    );
  }
}
