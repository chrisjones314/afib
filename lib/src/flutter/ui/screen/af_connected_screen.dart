import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/command/af_standard_configs.dart';
import 'package:afib/src/dart/redux/actions/af_route_actions.dart';
import 'package:afib/src/dart/redux/actions/af_theme_actions.dart';
import 'package:afib/src/dart/redux/state/af_state.dart';
import 'package:afib/src/dart/redux/state/af_store.dart';
import 'package:afib/src/dart/utils/af_context_dispatcher_mixin.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:afib/src/flutter/test/af_test_dispatchers.dart';
import 'package:afib/src/flutter/ui/drawer/afui_prototype_drawer.dart';
import 'package:afib/src/flutter/utils/af_dispatcher.dart';
import 'package:afib/src/flutter/utils/af_state_view.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_redux/flutter_redux.dart';
import 'package:logger/logger.dart';
import 'package:quiver/core.dart';

/// Base call for all screens, widgets, drawers, dialogs and bottom sheets
/// that connect to the store/state.
/// 
/// You should usually subclass on of its subclasses:
/// * [AFConnectedScreen]
/// * [AFConnectedWidget]
/// * [AFConnectedDrawer]
/// * [AFConnectedDialog]
/// * [AFConnectedBottomSheet]
abstract class AFConnectedUIBase<TState extends AFFlexibleState, TTheme extends AFFunctionalTheme, TBuildContext extends AFBuildContext, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends material.StatelessWidget {
  final AFThemeID themeId;
  final AFCreateStateViewDelegate<TStateView> stateViewCreator;
    
  //--------------------------------------------------------------------------------------
  AFConnectedUIBase({
    Key? key, 
    required this.themeId,
    required this.stateViewCreator,
  }): super(key: key);

  //--------------------------------------------------------------------------------------
  @override
  material.Widget build(material.BuildContext context) {
    return StoreConnector<AFState, AFBuildContext?>(
        converter: (store) {          
          final context = _createNonBuildContext(store as AFStore);
          return context;
        },
        distinct: true,
        builder: (buildContext, dataContext) {
          if(dataContext == null) {
            return material.Container(child: material.Text("Loading..."));
          }
          final standard = AFStandardBuildContextData(
            screenId: this.primaryScreenId,
            context: buildContext,
            dispatcher: dataContext.d,
            container: this,
            themes: dataContext.standard.themes,
          );

          var screenIdRegister = this.primaryScreenId;          
          if(screenIdRegister != null) {            
            AFibF.g.registerScreen(screenIdRegister, buildContext, this);
            AFibD.logUIAF?.d("Rebuilding screen $screenIdRegister");
          } else {
            AFibD.logUIAF?.d("Rebuilding widget $runtimeType");
          }

          _updateFundamentalThemeState(buildContext);
          final withContext = createContext(standard, dataContext.s as TStateView, dataContext.p as TRouteParam, dataContext.children, dataContext.theme as TTheme);
          final widgetResult = buildWithContext(withContext);
          return widgetResult;
        }
    );
  }

  TBuildContext createContext(AFStandardBuildContextData standard, TStateView stateView, TRouteParam param, AFRouteSegmentChildren? children, TTheme theme);

  // Returns the root parent screen, searching up the hierarchy if necessary.
  AFScreenID get parentScreenId;

  // Returns the area where the route parameter should live in the route
  AFNavigateRoute get parentRoute;

  /// Screens that have their own element tree in testing must return their screen id here,
  /// otherwise return null.
  AFScreenID? get primaryScreenId;

  /// Returns true if this is a screen that takes up the full screen, as opposed to a subclass like 
  /// drawer, dialog, bottom sheet, etc.
  bool get isPrimaryScreen { return false; }

  /// Uggg. In general, when looking up test data for a screen in prototype mode, you expect
  /// the screen id to match.  However, when we popup little screens on top of the main screen
  /// e.g. a dialog, bottomsheet, or drawer, that is not the case.
  bool get testOnlyRequireScreenIdMatchForTestContext { return false; }

  TBuildContext? _createNonBuildContext(AFStore store) {
    if(AFibD.config.isTestContext) {
      final testContext = _createTestContext(store);
      if(testContext != null) {
        return testContext;
      }
    }

    var paramSeg = findRouteSegment(store.state);
    //if(TRouteParam == AFRouteParamUnused && param == null) {
    //  param = AFRouteParamUnused.unused;
    //}
    if(paramSeg == null) {
      assert(false);
      return null;
    }
    final param = paramSeg.param as TRouteParam;
    // load in the state view.
    final stateView = createStateViewAF(store.state, param, paramSeg.children);

    // lookup all the themes
    final primaryTheme = findPrimaryTheme(store.state);


    final standard = AFStandardBuildContextData(
      screenId: this.primaryScreenId,
      context: null,
      dispatcher:  createDispatcher(store),
      container: this,
      themes: store.state.public.themes,
    );
    final state = store.state;
    final sourceModels = stateView.models.where((e) => e != null);
    final models = List<Object>.from(sourceModels);

    // we need to augment the models with any data required by the themes.
    primaryTheme.augmentModels(state.public, models);
    final secondaryThemeIds = stateView.secondaryThemeIds;
    final secondaryThemes = <AFFunctionalTheme>[];
    if(secondaryThemeIds != null) {
      final themes = state.public.themes;
      for(final themeId in secondaryThemeIds) {
        final theme = themes.findById(themeId);
        if(theme != null) {
          theme.augmentModels(state.public, models); 
          secondaryThemes.add(theme);
        }
      }
    }

    // now, create the state view.
    final modelMap = AFFlexibleStateView.createModels(models);
    final data = stateViewCreator(modelMap) as TStateView;

    final context = createContext(standard, data, param, paramSeg.children, primaryTheme);
    return context;
  }

  TBuildContext? _createTestContext(AFStore store) {
    // find the test state.
    final testState = store.state.private.testState;
    final activeTestId = testState.findTestForScreen(primaryScreenId);
    if(activeTestId == null) {
      return null;
    }

    if(AFibF.g.testOnlyIsWorkflowTest(activeTestId)) {
      return null;
    }

    
    final testContext = testState.findContext(activeTestId);
    final activeState = testState.findState(activeTestId);
    if(activeState == null) {
      return null;
    }

    final screen = activeState.navigate.screenId;
    if(this.testOnlyRequireScreenIdMatchForTestContext && screen != this.primaryScreenId) {
      return null;
    }
    if(this is AFUIPrototypeDrawer) {
      return null;
    }

    final paramSeg = findRouteSegment(store.state);

    final mainDispatcher = AFStoreDispatcher(store);
    final dispatcher = AFSingleScreenTestDispatcher(activeTestId, mainDispatcher, testContext);
    final tempTheme = findPrimaryTheme(store.state);
    final standard = AFStandardBuildContextData(
      screenId: this.primaryScreenId,
      context: null,
      dispatcher: dispatcher,
      container: this,
      themes: store.state.public.themes,
    );

    var models = activeState.models ?? <String, Object>{};
    final stateView = this.stateViewCreator(models) as TStateView;

    final param = paramSeg?.param as TRouteParam;
    return createContext(standard, stateView, param, paramSeg?.children, tempTheme);
  }

  TTheme findPrimaryTheme(AFState state) {
    final themes = state.public.themes;
    final theme = themes.findById(themeId) as TTheme?; 
    if(theme == null) throw AFException("Missing theme for $themeId");    
    return theme;
  }

  void _updateFundamentalThemeState(BuildContext context) {
    final theme = Theme.of(context);
    AFibF.g.updateFundamentalThemeData(theme);
  }


  AFDispatcher createDispatcher(AFStore store) {
    return AFStoreDispatcher(store);
  }

  /// Find the route param for this screen. 
  AFRouteSegment? findRouteSegment(AFState state) { return null; }

  bool routeEntryExists(AFState state) { return true; }

  AFUIStateView<TStateView> createStateViewAF(AFState state, TRouteParam param, AFRouteSegmentChildren? children) {
    final public = state.public;
    final stateApp = public.componentStateOrNull<TState>();
    if(stateApp == null) {
      throw AFException("Root application state $TState cannot be null");
    }
    final stateViewCtx = AFBuildStateViewContext<TState, TRouteParam>(stateApp: stateApp, routeParam: param, statePublic: public, children: children, private: state.private);
    return createStateView(stateViewCtx);
  }

  /// Override this to create an [AFFlexibleStateView] with the required data from the state.
  AFUIStateView<TStateView> createStateView(AFBuildStateViewContext<TState, TRouteParam> state);

  /// Builds a Widget using the data extracted from the state.
  material.Widget buildWithContext(TBuildContext context);

  /// Update the route parameter for this screen, widget, etc.
  void updateRouteParam(AFBuildContext context,TRouteParam revised, { AFID? id });

  void updateChildRouteParam<TChildRouteParam extends AFRouteParam>(AFBuildContext context, TChildRouteParam revised, { AFID? id }) {
    context.dispatch(AFNavigateSetChildParamAction(
      id: id,
      screen: parentScreenId,
      param: revised,
      route: parentRoute,
      useParentParam: false
    ));
  }



  void updateAddChildParam<TChildRouteParam extends AFRouteParam>(AFBuildContext context, TChildRouteParam revised, { AFID? id }) {
    context.dispatch(AFNavigateAddChildParamAction(
      id: id,
      screen: parentScreenId,
      param: revised,
      route: parentRoute
    ));
  }

  void updateRemoveChildParam(AFBuildContext context, AFWidgetID widgetId, { AFID? id }) {
    context.dispatch(AFNavigateRemoveChildParamAction(
      screen: parentScreenId,
      route: parentRoute,
      widget: widgetId,
    ));
  }
}

/// Superclass for a screen Widget, which combined data from the store with data from
/// the route in order to render itself.
abstract class AFConnectedScreen<TState extends AFFlexibleState, TTheme extends AFFunctionalTheme, TBuildContext extends AFBuildContext, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFConnectedUIBase<TState, TTheme, TBuildContext, TStateView, TRouteParam> {
  final AFScreenID screenId;
  final AFNavigateRoute route;

  AFConnectedScreen(this.screenId, AFThemeID themeId, AFCreateStateViewDelegate<TStateView> stateViewCreator, { Key? key, this.route = AFNavigateRoute.routeHierarchy }): super(key: key, themeId: themeId, stateViewCreator: stateViewCreator);

  bool get testOnlyRequireScreenIdMatchForTestContext { return true; }
  bool get isPrimaryScreen { return true; }

  AFScreenID? get primaryScreenId {
    return screenId;
  }

  AFScreenID get parentScreenId {
    return screenId;
  }

  AFNavigateRoute get parentRoute {
    return route;
  }

  /// Utility for updating the route parameter for this screen.
  /// 
  /// Your route parameter should contain the data that your screen is editing.
  /// When a user action causes data on the screen, you will typically do 
  /// something like:
  /// 
  /// ### Example
  ///   final revisedParam = screenData.param.copyWith(someField: myRevisedValue);
  ///   updateRouteParam(screenData, revisedParam);
  void updateRouteParam(AFBuildContext context, TRouteParam revised, { AFID? id }) {
    context.dispatch(AFNavigateSetParamAction(
      id: id,
      param: revised,
      route: route
    ));
  }


  /// Find the route parameter for the specified named screen
  AFRouteSegment? findRouteSegment(AFState state) {
    final route = state.public.route;
    final pTest = route.findParamFor(this.screenId, includePrior: true);
    //if(pTest is AFRouteParamWithChildren) {
    //  return AFConnectedWidget.findChildParam<TRouteParam>(state, this.screenId, this.screenId);
    //}

    //var p = pTest as TRouteParam?;
    //if(p == null && this.screenId == AFibF.g.actualStartupScreenId) {
    //p = route.findParamFor(AFUIScreenID.screenStartupWrapper) as TRouteParam?;
    //}
    //return p;
    return pTest;
  }

  @override
  bool routeEntryExists(AFState state) {
    return state.public.route.routeEntryExists(this.screenId, includePrior: true);
  }

}

abstract class AFEmbeddedWidget<TState extends AFFlexibleState,  TTheme extends AFFunctionalTheme, TBuildContext extends AFBuildContext, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends StatelessWidget { 
  final AFBuildContext parentContext;
  final TStateView? stateViewOverride;
  final TRouteParam? routeParamOverride;
  final TRouteParam? paramWithChildren;
  final TTheme? themeOverride;
  final AFUpdateRouteParamDelegate<TRouteParam>? updateRouteParamDelegate;
  
  AFEmbeddedWidget({
    AFWidgetID? wid,
    required this.parentContext,
    this.stateViewOverride,
    this.routeParamOverride,
    this.paramWithChildren,
    this.themeOverride,
    this.updateRouteParamDelegate,

  }): super(key: AFFunctionalTheme.keyForWIDStatic(wid));

  @override
  material.Widget build(material.BuildContext context) {
    final standard = AFStandardBuildContextData(
      screenId: null,
      context: context,
      dispatcher: parentContext.d,
      container: null,
      themes: parentContext.standard.themes
    );

    final afContext = createContext(
      standard,
      stateViewOverride ?? parentContext.stateView as TStateView,
      routeParamOverride ?? parentContext.routeParam as TRouteParam,
      parentContext.children,
      themeOverride ?? parentContext.theme as TTheme,
    );

    return buildWithContext(afContext);    
  }

  TBuildContext createContext(AFStandardBuildContextData standard, TStateView stateView, TRouteParam param, AFRouteSegmentChildren? children, TTheme theme);

  material.Widget buildWithContext(TBuildContext context);

  
  void updateRouteParam(AFBuildContext context, TRouteParam revised, { AFID? id }) {
    final update = updateRouteParamDelegate;
    if(update == null) throw AFException("If you want to call updateRouteParam from an AFEmbeddedWidget, you need to pass an updateRouteParamDelegate to it's constructor, or us an AFConnectedWidget instead.");
    update(context, revised, id: id);
  }
}

abstract class AFConnectedWidget<TState extends AFFlexibleState, TTheme extends AFFunctionalTheme, TBuildContext extends AFBuildContext, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFConnectedUIBase<TState, TTheme, TBuildContext, TStateView, TRouteParam> { 
  final AFConnectedUIBase parent;
  final AFWidgetID widgetId;
  final AFNavigateRoute route;
  final bool useParentParam;
  
  AFConnectedWidget({
    required this.parent,
    required this.widgetId,
    required AFThemeID themeId,
    required AFCreateStateViewDelegate<TStateView> stateViewCreator, 
    this.useParentParam = false,
    this.route = AFNavigateRoute.routeHierarchy,
  }): super(key: AFFunctionalTheme.keyForWIDStatic(widgetId), themeId: themeId, stateViewCreator: stateViewCreator);

  AFScreenID? get primaryScreenId {
    return null;
  }

  AFScreenID get parentScreenId {
    return parent.parentScreenId;
  }

  AFNavigateRoute get parentRoute {
    return parent.parentRoute;
  }


  /// Find the route param for this child widget.
  /// 
  /// The parent screen must have a route param of type AFRouteParamWithChildren.
  /// Which this widget used to find its specific child route param in that screen's
  /// overall route param.
  AFRouteSegment? findRouteSegment(AFState state) { 
    final route = state.public.route;
    final paramParent = route.findParamFor(parentScreenId);
    assert(paramParent != null);
    if(paramParent == null) {
      return null;
    }
    if(useParentParam) {
      assert(paramParent.param is TRouteParam);
      return paramParent;
    }
    return paramParent.findChild(widgetId);
  }

  void updateRouteParam(AFBuildContext context, TRouteParam revised, { AFID? id }) {
      context.dispatch(AFNavigateSetChildParamAction(
        id: id,
        screen: parent.parentScreenId, 
        param: revised,
        route: route,
        useParentParam: useParentParam,
      ));
  }

}

abstract class AFConnectedScreenWithGlobalParam<TState extends AFFlexibleState, TTheme extends AFFunctionalTheme, TBuildContext extends AFBuildContext, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFConnectedScreen<TState, TTheme, TBuildContext, TStateView, TRouteParam> {
  AFConnectedScreenWithGlobalParam(
    AFScreenID screenId,
    AFThemeID themeId,
    AFCreateStateViewDelegate<TStateView> creator
  ): super(screenId, themeId, creator, route: AFNavigateRoute.routeGlobalPool);

  bool get testOnlyRequireScreenIdMatchForTestContext { return false; }
  bool get isPrimaryScreen { return false; }

  /// Look for this screens route parameter in the global pool, 
  /// rather than in the navigational hierarchy
  @override
  AFRouteSegment? findRouteSegment(AFState state) {
    var current = state.public.route.findGlobalParam(screenId);
    return current;
  }

  /// Update this screens route parameter in the global pool, rather than in the
  /// route hiearchy.
  @override
  void updateRouteParam(AFBuildContext context, TRouteParam revised, { AFID? id }) {
    context.dispatch(AFNavigateSetParamAction(
      id: id,
      param: revised,
      route: AFNavigateRoute.routeGlobalPool)
    );
  }
}

/// Use this to connect a drawer to the store.
/// 
/// Drawers are special because the user can drag in from the left or right to open them.
/// Consequently, you will need to override [AFConnectedScreenWithGlobalParam.createDefaultRouteParam],
/// which will be used to create your route parameter if the drawer was dragged onto the
/// screen without you explicitly calling [AFBuildContext.openDrawer].
abstract class AFConnectedDrawer<TState extends AFFlexibleState, TTheme extends AFFunctionalTheme, TBuildContext extends AFBuildContext, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFConnectedScreenWithGlobalParam<TState, TTheme, TBuildContext, TStateView, TRouteParam> {
  AFConnectedDrawer(
    AFScreenID screenId,
    AFThemeID themeId,
    AFCreateStateViewDelegate<TStateView> creator
  ): super(screenId, themeId, creator);

  /// Look for this screens route parameter in the global pool, 
  /// rather than in the navigational hierarchy.
  @override
  AFRouteSegment? findRouteSegment(AFState state) {
    var current = super.findRouteSegment(state);
    // Note that because the user can slide a drawer on screen without the
    // application explictly opening it, we need to have the drawer create a default
    // route parameter if one does not already exist. 
    if(current == null) {
      current = AFRouteSegment(param: createDefaultRouteParam(state), children: null);
    }
    return current;
  }

  /// Create the initial default route parameter for the screen.
  /// 
  /// Note that because the user can slide a drawer on screen without the
  /// application explictly opening it, we need to have the drawer create a default
  /// route parameter if one does not already exist. 
  TRouteParam createDefaultRouteParam(AFState state);

}


/// Use this to connect a dialog to the store.
/// 
/// You can open a dialog with [AFBuildContext.showDialog].
abstract class AFConnectedDialog<TState extends AFFlexibleState, TTheme extends AFFunctionalTheme, TBuildContext extends AFBuildContext, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFConnectedScreenWithGlobalParam<TState, TTheme, TBuildContext, TStateView, TRouteParam> {
  AFConnectedDialog(
    AFScreenID screenId,
    AFThemeID themeId,
    AFCreateStateViewDelegate<TStateView> creator
  ): super(screenId, themeId, creator);


  @override
  material.Widget buildWithContext(TBuildContext context) {
    return buildDialogWithContext(context);
  }

  material.Widget buildDialogWithContext(TBuildContext context);
}

/// Use this to connect a bottom sheet to the store.
/// 
/// You can open a bottom sheet with [AFBuildContext.showBottomSheet]
/// or [AFBuildContext.showModalBottomSheeet].
abstract class AFConnectedBottomSheet<TState extends AFFlexibleState, TTheme extends AFFunctionalTheme, TBuildContext extends AFBuildContext, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam> extends AFConnectedScreenWithGlobalParam<TState, TTheme, TBuildContext, TStateView, TRouteParam> {
  AFConnectedBottomSheet(
    AFScreenID screenId,
    AFThemeID themeId,
    AFCreateStateViewDelegate<TStateView> creator
  ): super(screenId, themeId, creator);

  @override
  material.Widget buildWithContext(TBuildContext context) {
    return buildBottomSheetWithContext(context);
  }

  material.Widget buildBottomSheetWithContext(TBuildContext context);
}

mixin AFContextShowMixin {
  /// Open a dialog with the specified screen id and param
  /// 
  /// You must either specify a screen id and param, or you
  /// can specify an AFNavigatePushAction that contains those 
  /// two items instead.
  /// 
  /// Note that you will close the bottom sheet inside your bottomsheet screen
  /// using [AFBuildContext.closeDialog] and pass it a return value.  You
  /// can capture that return value by passing in an onReturn delegate to this
  /// function.
  /// 
  /// A very common pattern is to pass back the route parameter for the bottom 
  /// sheet, which looks like:
  /// ```dart
  /// context.closeDialog(context.p);
  /// ```
  /// inside the dialog screen.
  void showDialog<TReturn>({
    AFScreenID? screenId,
    AFRouteParam? param,
    AFNavigatePushAction? navigate,
    void Function(TReturn?)? onReturn,
    bool barrierDismissible = true,
    material.Color? barrierColor,
    bool useSafeArea = true,
    bool useRootNavigator = true,
    material.RouteSettings? routeSettings
  }) async {
    if(navigate != null) {
      assert(screenId == null);
      assert(param == null);
      screenId = navigate.param.id as AFScreenID;
      param = navigate.param;
    }

    final verifiedScreenId = _nullCheckScreenId(screenId);
    _updateOptionalGlobalParam(verifiedScreenId, param);

    final builder = AFibF.g.screenMap.findBy(verifiedScreenId);
    if(builder == null) {
      throw AFException("The screen $screenId is not registered in the screen map");
    }
    final ctx = contextNullCheck;
    final result = await material.showDialog<TReturn>(
      context: ctx,
      builder: builder,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      useSafeArea: useSafeArea,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings
    );

    AFibF.g.testOnlyDialogRegisterReturn(verifiedScreenId, result);
    if(onReturn != null) {
      onReturn(result);
    }
  }

  AFScreenID _nullCheckScreenId(AFScreenID? screenId) {
    if(screenId == null) throw AFException("You must either specify a screenId, or the navigate param with a screen id");
    return screenId;
  }

  /// Show a snackbar.
  /// 
  /// Shows a snackbar containing the specified [text].   
  /// 
  /// See also [showSnackbarText]
  void showSnackbarText(String text, { Duration duration = const Duration(seconds: 2)}) {
    ScaffoldMessenger.of(contextNullCheck).showSnackBar(SnackBar(content: Text(text), duration: duration));
  }

  /// Show a snackbar.
  /// 
  /// Shows the specified snackbar.
  /// 
  /// See also [showSnackbarText]
  void showSnackbar(SnackBar snackbar) {
    final ctx = contextNullCheck;
    ScaffoldMessenger.of(ctx).showSnackBar(snackbar);
  }

  /// Show a modal bottom sheet.
  /// 
  /// Note that you will close the bottom sheet inside your bottomsheet screen
  /// using [AFBuildContext.closeBottomSheet] and pass it a return value.  You
  /// can capture that return value by passing in an onReturn delegate to this
  /// function.
  /// 
  /// A very common pattern is to pass back the route parameter for the bottom 
  /// sheet, which looks like:
  /// ```dart
  /// context.closeBottomSheet(context.p);
  /// ```
  /// inside the bottom sheet screen.
  void showModalBottomSheet({
    AFScreenID? screenId,
    AFRouteParam? param,
    AFNavigatePushAction? navigate,
    AFReturnValueDelegate? onReturn,
    material.Color? backgroundColor,
    double? elevation,
    material.ShapeBorder? shape,
    material.Clip? clipBehavior,
    material.Color? barrierColor,
    bool isScrollControlled = false,
    bool useRootNavigator = false,
    bool isDismissible = true,
    bool enableDrag = true,
    material.RouteSettings? routeSettings,  
  }) async {
    if(navigate != null) {
      assert(screenId == null);
      assert(param == null);
      screenId = navigate.param.id as AFScreenID;
      param = navigate.param;
    }

    final verifiedScreenId = _nullCheckScreenId(screenId);
    _updateOptionalGlobalParam(verifiedScreenId, param);

    final builder = AFibF.g.screenMap.findBy(verifiedScreenId);
    if(builder == null) {
      throw AFException("The screen $screenId is not registered in the screen map");
    }

    final ctx = contextNullCheck;
    final result = await material.showModalBottomSheet<dynamic>(
      context: ctx,
      builder: builder,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
      barrierColor: barrierColor,
      isScrollControlled: isScrollControlled,
      useRootNavigator: useRootNavigator,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      routeSettings: routeSettings,
    );

    AFibF.g.testOnlyBottomSheetRegisterReturn(verifiedScreenId, result);

    if(onReturn != null) {
      onReturn(result);
    }
  }

  /// Shows a bottom sheet
  /// 
  /// See also [showModalBottomSheet].
  void showBottomSheet({
    AFScreenID? screenId,
    AFRouteParam? param,
    AFNavigatePushAction? navigate,
    material.Color? backgroundColor,
    double? elevation,
    material.ShapeBorder? shape,
    material.Clip? clipBehavior,
  }) async {
    if(navigate != null) {
      assert(screenId == null);
      assert(param == null);
      screenId = navigate.param.id as AFScreenID;
      param = navigate.param;
    }

    if(screenId == null) throw AFException("You must either specify a screenId or a navigate containing one");
    _updateOptionalGlobalParam(screenId, param);

    final builder = AFibF.g.screenMap.findBy(screenId);
    if(builder == null) {
      throw AFException("The screen $screenId is not registered in the screen map");
    }

    final ctx = contextNullCheck;
    material.Scaffold.of(ctx).showBottomSheet<dynamic>(
      builder,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
    );
  }

  /// Open the drawer that you specified for your [Scaffold].
  /// 
  /// You may optionally specify the optional screenId (which must match the screen id of the drawer
  /// you specified to the scaffold) and param.   The route parameter for a drawer is stored in the global
  /// pool.    The first time your drawer is shown, it will use the [param] you pass to this function, or if you omit it,
  /// then your [AFConnectedDrawer.createDefaultRouteParam]
  /// method will be called to create it the very first time the drawer is shown.  Subsequently, it will
  /// use the param you pass to this function, or if you omit it, the value that is already in the global route pool.
  void openDrawer({
    required AFScreenID screenId,
    required AFRouteParam param,
  }) {
    _updateOptionalGlobalParam(screenId, param);
    final ctx = contextNullCheck;
    final scaffold = material.Scaffold.of(ctx);
    //if(scaffold == null) {
    //  throw AFException("Could not find a scaffold, you probably need to add an AFBuilder just under the scaffold but above the widget that calls this function");
    //}
    scaffold.openDrawer();
  }

  /// Open the end drawer that you specified for your [Scaffold].
  void openEndDrawer({
    required AFScreenID screenId,
    required AFRouteParam param,
  }) {
    _updateOptionalGlobalParam(screenId, param);
    final ctx = contextNullCheck;
    final scaffold = material.Scaffold.of(ctx);
    //if(scaffold == null) {
    //  throw AFException("Could not find a scaffold, you probably need to add an AFBuilder just under the scaffold but above the widget that calls this function");
    //}
    scaffold.openEndDrawer();
  }

  BuildContext get contextNullCheck {
    final ctx = context;
    if(ctx == null) { throw AFException("Missing build context"); }
    return ctx;
  }

  void _updateOptionalGlobalParam(AFScreenID screenId, AFRouteParam? param) {
    if(param == null)  {
      return;
    }
    dispatch(AFNavigateSetParamAction(
      param: param, route: AFNavigateRoute.routeGlobalPool
    ));
  }

  BuildContext? get context;
  void dispatch(dynamic action);

}

/// A utility that reduces the number of parameters passed in AF client code, and enhances flexibility
class AFStandardBuildContextData {
  AFScreenID? screenId;
  material.BuildContext? context;
  AFDispatcher dispatcher;
  AFScreenPrototype? screenTest;
  AFConnectedUIBase? container;
  AFThemeState themes;

  AFStandardBuildContextData({
    required this.screenId,
    required this.context,
    required this.dispatcher,
    this.screenTest,
    required this.container,
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

  Map<String, Object> createModelsByType(Iterable<Object> toIntegrate) {
    return AFFlexibleStateView.createModels(toIntegrate);
  }

}

/// A utility class which you can use when you have a complex screen which passes the dispatcher,
/// screen data and param to many functions, to make things more concise.  
/// 
/// The framework cannot pass you this itself because 
class AFBuildContext<TState extends AFFlexibleState, TStateView extends AFFlexibleStateView, TRouteParam extends AFRouteParam, TTheme extends AFFunctionalTheme> with AFContextDispatcherMixin, AFContextShowMixin {
  AFStandardBuildContextData standard;
  TStateView stateView;
  TRouteParam routeParam;
  TTheme theme;
  AFRouteSegmentChildren? children;
  bool compareChildren;

  AFBuildContext(this.standard, this.stateView, this.routeParam, this.children, this.theme, { this.compareChildren = true });

  /// Shorthand for accessing the route param.
  TRouteParam get p { return routeParam; }

  /// Shorthand for accessing data from the store
  TStateView get s { return stateView; }


  material.BuildContext get context { 
    // there is a brief time where we don't have a context internally, as the AFBuildContext is 
    // being constructed.   But, for the purposes of users of the framework, there will always
    // be a build context for any case where they have access to an AFBuildContext. 
    return standard.context!; 
  }  

  AFDispatcher get dispatcher { return standard.dispatcher; }
  AFScreenPrototype? get screenTest { return standard.screenTest; }
  AFConnectedUIBase? get container { return standard.container; }

  TFunctionalTheme findTheme<TFunctionalTheme extends AFFunctionalTheme>(AFThemeID themeId) {
    final themes = standard.themes;
    return themes.findById(themeId) as TFunctionalTheme;
  }

  /// Shorthand for accessing the theme
  TTheme get t { return theme; }

  /// Shorthand for accessing the dispatcher
  AFDispatcher get d { return standard.dispatcher; }

  /// Shorthand for accessing the flutter build context
  material.BuildContext get c { return context; }

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

  TChildRouteParam? findChild<TChildRouteParam extends AFRouteParam>(AFWidgetID wid) {
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

  Iterable<TChildRouteParam> childrenOfType<TChildRouteParam extends AFRouteParam>() {
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

  /// Update the parameter for the specified screen, but favor calling
  /// updateParam in your screen directly.
  /// 
  /// This method is here for discoverability, rather than calling 
  /// ```dart
  /// context.updateRouteParam(this, revisedParam)
  /// ```
  /// from within a screen/widget, I recommend calling 
  /// [AFConnectedUIBase.updateRouteParam] directly in your screen.
  /// 
  /// ```dart
  /// updateRouteParam(context, revisedParam);
  /// ```
  /// That said, there are other contexts, like when a query completes, 
  /// where you can call
  /// ```dart
  /// context.updateRouteParam(screenId, revisedParam)
  /// ```
  /// So, in a sense this is more consistent with that method.  They all function
  /// in the same way.
  void updateRouteParam(AFConnectedUIBase widget, TRouteParam revised, { AFID? id }) {
    widget.updateRouteParam(this, revised, id: id);
  }

  /// Adds a new connected child into the [AFRouteParamWithChildren] of this screen.
  /// 
  /// The parent screen will automatically re-render with the new child.
  void updateChildRouteParam<TChildRouteParam extends AFRouteParam>(AFConnectedUIBase widget, TChildRouteParam revised, { AFID? id }) {
    widget.updateChildRouteParam<TChildRouteParam>(this, revised, id: id);
  }


  /// Adds a new connected child into the [AFRouteParamWithChildren] of this screen.
  /// 
  /// The parent screen will automatically re-render with the new child.
  void updateAddChildParam(
    AFConnectedUIBase widget,
    AFRouteParam param
  ) {
    widget.updateAddChildParam(this, param);
  }

  /// Removes the connected child with the specified widget id from the [AFRouteParamWithChildren] of this screen.
  /// 
  /// The parent screen will automatically re-render.
  void updateRemoveChildParam(
    AFConnectedUIBase widget,
    AFWidgetID widgetId
  ) {
    widget.updateRemoveChildParam(this, widgetId);
  }

  /// Update one object at the root of the application state.
  /// 
  /// Note that you must specify your root application state type as a type parameter:
  /// ```dart
  /// context.updateAppStateOne<YourRootState>(oneObjectWithinYourRootState);
  /// ```
  void updateAppStateOne<TState extends AFFlexibleState>(Object toUpdate) {
    assert(TState != AFFlexibleState);
    dispatch(AFUpdateAppStateAction.updateOne(TState, toUpdate));
  }

  /// Update several objects at the root of the application state.
  /// 
  /// Note that you must specify your root application state type as a type parameter:
  /// ```dart
  /// context.updateAppStateMany<YourRootState>([oneObjectWithinYourRootState, anotherObjectWithinYourRootState]);
  /// ```
  void updateAppStateN<TState extends AFFlexibleState>(List<Object> toUpdate) {
    assert(TState != AFFlexibleState);
    dispatch(AFUpdateAppStateAction.updateMany(TState, toUpdate));
  } 

  /// A utility which dispatches an asynchronous query.
  void dispatchQuery(AFAsyncQuery query) {
    dispatch(query);
  }

  /// A utility which delays for the specified time, then updates the resulting code.   
  /// 
  /// This deferral is active in UIs, but is disabled during automated tests to speed results and avoid 
  /// complexity.
  void deferUpdate<TState extends AFFlexibleState>({ 
    required AFOnResponseDelegate<TState, AFUnused> onExecute, Duration duration = const Duration(milliseconds: 200)}) {
    dispatch(AFDeferredSuccessQuery(
      duration, onExecute,
    ));
  }

  bool get _isInWireframe {
    if(!AFibD.config.isTestContext) {
      return false;
    }
    return AFibF.g.storeInternalOnly!.state.private.testState.activeWireframe != null;
  }


  /// Called to close a drawer.
  /// 
  /// Important: If you call this method, and a drawer isn't open, it will
  /// pop the current screen and mess up the navigational state.   This method
  /// is usally called from within a drawer, in response to a user action that should
  /// close the drawer, and then do something else, like navigate to a new screen.
  void closeDrawer() {
    AFibF.g.doMiddlewareNavigation( (navState) {
      material.Navigator.pop(contextNullCheck);
    });
  }

  /// Closes the dialog, and returns the [returnValue] to the callback function that was
  /// passed to [showDialog].
  /// 
  /// This is intended to be called from within an AFConnectedDialog.  If you call it 
  /// and a dialog is not open, it will mess up the navigation state.
  void closeDialog(dynamic returnValue) {
    AFibF.g.doMiddlewareNavigation( (navState) {
      final ctx = contextNullCheck;
      material.Navigator.pop(ctx, returnValue); 
    });
  }

  /// Closes the dialog, and returns the [returnValue] to the callback function that was
  /// passed to [showDialog].
  /// 
  /// This is intended to be called from within an AFConnectedDialog.  If you call it 
  /// and a dialog is not open, it will mess up the navigation state.
  void closeBottomSheet(dynamic returnValue) {
    AFibF.g.doMiddlewareNavigation( (navState) {
      final ctx = contextNullCheck;
      material.Navigator.pop(ctx, returnValue); 
    });
  }

  /// Log to the appRender topic.  
  /// 
  /// The logger can be null, so you should
  /// use something like context.log?.d("my message");
  Logger? get log { 
    return AFibD.log(AFConfigEntryLogArea.ui);
  }

  bool operator==(dynamic o) {
    if(o is! AFBuildContext<TState, TStateView, TRouteParam, TTheme>) {
      return false;
    }
    var result = (routeParam == o.routeParam && stateView == o.stateView && theme == o.theme);
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

  /*
  /// Renders a list of connected children, one for reach child parameter in
  /// the parent's [AFRouteParamWithChildren] that also has the type [TChildRouteParam].
  List<material.Widget> childrenConnectedRender<TChildRouteParam extends AFRouteParam>({
    required AFScreenID screenParent,
    required AFRenderConnectedChildDelegate render
  }) {
    final result = <material.Widget>[];
    var childrenN = children;
    if(childrenN != null) {
      for(final childSeg in childrenN.values) {
        if(childSeg.param is TChildRouteParam) {
          final widChild = childSeg.param.id;
          final widget = render(screenParent, widChild as AFWidgetID);
          if(widget is! AFConnectedWidget) {
            throw AFException("When rendering children of a AFConnectedScreen, the children must be subclasses of AFConnectedWidget");
          }
          result.add(widget);
        }
      }    
    }
    return result;
  }
  */

  /// Returns the number of connected children that have a route parameter
  /// of the specified type.
  int childrenCountConnected<TChildRouteParam extends AFRouteParam>() {
    final childrenN = children;
    if(childrenN == null) {
      return 0;
    }
    return childrenN.countOfChildren<TChildRouteParam>();
  }

  /*
  /// Renders a single connected child.
  /// 
  /// If your [AFRouteParamWithChildren] contains exactly one value of type [TChildRouteParam], you can 
  /// render it using this method.
  material.Widget childConnectedRender<TChildRouteParam extends AFRouteParam>({
    required AFScreenID screenParent,
    required AFWidgetID widChild,
    required AFRenderConnectedChildDelegate render
  }) {
    final childrenN = children;
    if(childrenN == null) {
      throw AFException("No children exist");
    }

    final child = childrenN.findById(widChild);
    if(child == null) {
      throw AFException("Missing child with widget id $widChild");
    }
    assert(child is TChildRouteParam, "Expected child route param type $TChildRouteParam} but found ${child.runtimeType}");
    final widget = render(screenParent, widChild);
    assert(widget is AFConnectedWidget, "When rendering children of a AFConnectedScreen, the children must be subclasses of AFConnectedWidget");
    return widget;
  }

  material.Widget childConnectedRenderPassthrough<TChildRouteParam extends AFRouteParam>({
    required AFScreenID screenParent,
    required AFWidgetID widChild,
    required AFRenderConnectedChildDelegate render
  }) {
    assert(TChildRouteParam != dynamic);
    final param = this.routeParam;
    final widChildFull = screenParent.with2(widChild, AFUIWidgetID.afibPassthroughSuffix);
    assert(param is TChildRouteParam);
    final widget = render(screenParent, widChildFull);
    assert(widget is AFConnectedWidget);
    return widget;
  }
  */

  /// Meant to make the public state visible in the debugger, absolutely not for runtime use.
  AFPublicState? get debugOnlyPublicState {
    return dispatcher.debugOnlyPublicState;
  }

  TState? get debugOnlyAppState {
    final public = debugOnlyPublicState;
    if(public == null) {
      return null;
    }
    return public.componentState<TState>();
  }
}

