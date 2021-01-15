
import 'package:afib/src/dart/redux/actions/af_theme_actions.dart';
import 'package:afib/src/dart/utils/af_context_dispatcher_mixin.dart';
import 'package:afib/src/flutter/test/af_test_dispatchers.dart';
import 'package:afib/src/flutter/utils/af_dispatcher.dart';
import 'package:afib/src/flutter/utils/af_state_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:quiver/core.dart';
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/redux/actions/af_route_actions.dart';
import 'package:afib/src/dart/redux/state/af_state.dart';
import 'package:afib/src/dart/redux/state/af_store.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:afib/src/flutter/ui/drawer/af_prototype_drawer.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_redux/flutter_redux.dart';

/// Base call for all screens, widgets, drawers, dialogs and bottom sheets
/// that connect to the store/state.
/// 
/// You should usually subclass on of its subclasses:
/// * [AFConnectedScreen]
/// * [AFConnectedWidget]
/// * [AFConnectedDrawer]
/// * [AFConnectedDialog]
/// * [AFConnectedBottomSheet]
abstract class AFConnectedUIBase<TState extends AFAppStateArea, TTheme extends AFConceptualTheme, TBuildContext extends AFBuildContext, TStateView extends AFStateView, TRouteParam extends AFRouteParam> extends material.StatelessWidget {
  final AFThemeID themeId;
    
  //--------------------------------------------------------------------------------------
  AFConnectedUIBase({Key key, @required this.themeId}): super(key: key);

  //--------------------------------------------------------------------------------------
  @override
  material.Widget build(material.BuildContext context) {
    return StoreConnector<AFState, AFBuildContext>(
        converter: (store) {
          final context = _createNonBuildContext(store);
          return context;
        },
        distinct: true,
        builder: (buildContext, dataContext) {
          if(dataContext == null) {
            return material.Container(child: material.Text("Loading..."));
          }

          var screenIdRegister = this.primaryScreenId;          
          if(screenIdRegister != null) {            
            AFibF.g.registerScreen(screenIdRegister, buildContext, this);
            AFibD.logTest?.d("Rebuilding screen $runtimeType/$screenIdRegister with param ${dataContext.p}");
          }



          final withContext = createContext(buildContext, dataContext.d, dataContext.s, dataContext.p, dataContext.paramWithChildren, dataContext.theme, this);
          final widgetResult = buildWithContext(withContext);
          return widgetResult;
        }
    );
  }

  TBuildContext createContext(material.BuildContext context, AFDispatcher dispatcher, TStateView stateView, TRouteParam param, AFRouteParamWithChildren paramWithChildren, TTheme theme, AFConnectedUIBase container);

  /// Screens that have their own element tree in testing must return their screen id here,
  /// otherwise return null.
  AFScreenID get primaryScreenId;

  /// Returns true if this is a screen that takes up the full screen, as opposed to a subclass like 
  /// drawer, dialog, bottom sheet, etc.
  bool get isPrimaryScreen { return false; }

  /// Uggg. In general, when looking up test data for a screen in prototype mode, you expect
  /// the screen id to match.  However, when we popup little screens on top of the main screen
  /// e.g. a dialog, bottomsheet, or drawer, that is not the case.
  bool get testOnlyRequireScreenIdMatchForTestContext { return false; }

  TBuildContext _createNonBuildContext(AFStore store) {
    if(AFibD.config.isTestContext) {
      final testContext = _createTestContext(store);
      if(testContext != null) {
        return testContext;
      }
    }

    final param = findRouteParam(store.state);
    final paramWithChildren = findParamWithChildren(store.state);
    final data = createStateViewAF(store.state, param, paramWithChildren);
    if(param == null && !routeEntryExists(store.state)) {
      return null;
    }
    final theme = findTheme(store.state.public.themes);

    final context = createContext(null, createDispatcher(store), data, param, paramWithChildren, theme, this);
    return context;
  }

  TBuildContext _createTestContext(AFStore store) {
    // find the test state.
    final testState = store.state.testState;
    final activeTestId = testState.activeTestId;
    if(activeTestId == null) {
      return null;
    }

    
    final testContext = testState.findContext(activeTestId);
    final activeState = testState.findState(activeTestId);
    if(activeState == null) {
      return null;
    }

    final screen = activeState.screen;
    if(this.testOnlyRequireScreenIdMatchForTestContext && screen != this.primaryScreenId) {
      return null;
    }
    if(this is AFTestDrawer) {
      return null;
    }

    final param = findRouteParam(store.state);
    final paramWithChildren = findParamWithChildren(store.state);

    var data = activeState.findViewStateFor<TStateView>();

    if(data == null) {
      return null;
    }

    final mainDispatcher = AFStoreDispatcher(store);
    final dispatcher = AFSingleScreenTestDispatcher(activeTestId, mainDispatcher, testContext);
    final theme = findTheme(store.state.public.themes);    

    return createContext(null, dispatcher, data, param, paramWithChildren, theme, this);
  }

  AFDispatcher createDispatcher(AFStore store) {
    return AFStoreDispatcher(store);
  }

  /// Find the route param for this screen. 
  AFRouteParam findRouteParam(AFState state) { return null; }

  /// Find the route param for this screen. 
  AFRouteParamWithChildren findParamWithChildren(AFState state) { return null; }

  TTheme findTheme(AFThemeState themes) {
    return themes.findById(themeId);
  }

  bool routeEntryExists(AFState state) { return true; }

  TStateView createStateViewAF(AFState state, TRouteParam param, AFRouteParamWithChildren paramWithChildren) {
    return createStateViewPublic(state.public, param, paramWithChildren);
  }

  /// Override this instead of [createStateView] if you need access
  /// to the full route state. 
  /// 
  /// However, be aware that a full route state does not exist in single
  /// screen tests.
  TStateView createStateViewPublic(AFPublicState public, TRouteParam param, AFRouteParamWithChildren paramWithChildren) {
    final TState state = public.areaStateFor(TState);
    return createStateView(state, param);
  }

  /// Override this to create an [AFStateView] with the required data from the state.
  TStateView createStateView(TState state, TRouteParam param);

  /// Builds a Widget using the data extracted from the state.
  material.Widget buildWithContext(TBuildContext context);

  /// Update the route parameter for this screen, widget, etc.
  void updateRouteParam(AFBuildContext context,TRouteParam revised, { AFID id });
}

/// Superclass for a screen Widget, which combined data from the store with data from
/// the route in order to render itself.
abstract class AFConnectedScreen<TState extends AFAppStateArea, TTheme extends AFConceptualTheme, TBuildContext extends AFBuildContext, TStateView extends AFStateView, TRouteParam extends AFRouteParam> extends AFConnectedUIBase<TState, TTheme, TBuildContext, TStateView, TRouteParam> {
  final AFScreenID screenId;
    final AFNavigateRoute route;

  AFConnectedScreen(this.screenId, AFThemeID themeId, { Key key, this.route = AFNavigateRoute.routeHierarchy }): super(key: key, themeId: themeId);

  bool get testOnlyRequireScreenIdMatchForTestContext { return true; }
  bool get isPrimaryScreen { return true; }

  AFScreenID get primaryScreenId {
    return screenId;
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
  void updateRouteParam(AFBuildContext context, TRouteParam revised, { AFID id }) {
    if(context.paramWithChildren != null) {
      AFConnectedWidget.updateChildRouteParam(context, revised, this.screenId, this.screenId, id: id);
    } else {
      context.dispatch(AFNavigateSetParamAction(
        id: id,
        screen: this.screenId, 
        param: revised,
        route: route
      ));
    }
  }

  /// Utility method which updates the parameter, but takes a build context
  /// rather than a dispatcher for convenience
  void updateRouteParamWithChildren(AFBuildContext context, AFRouteParamWithChildren revised, { AFID id }) {
    context.dispatch(AFNavigateSetParamAction(
      screen: this.screenId,
      param: revised,
      route: this.route,
    ));  
  }

  /// Find the route parameter for the specified named screen
  AFRouteParam findRouteParam(AFState state) {
    final route = state.public.route;
    final pTest = route?.findParamFor(this.screenId, includePrior: true);
    if(pTest is AFRouteParamWithChildren) {
      return AFConnectedWidget.findChildParam<TRouteParam>(state, this.screenId, this.screenId);
    }

    TRouteParam p = pTest;
    if(p == null && this.screenId == AFibF.g.actualStartupScreenId) {
      p = route?.findParamFor(AFUIScreenID.screenStartupWrapper);
    }
    return p;
  }

  @override
  AFRouteParamWithChildren findParamWithChildren(AFState state) { 
    final route = state.public.route;
    final param = route?.findParamFor(this.screenId, includePrior: true);
    if(param is AFRouteParamWithChildren) {
      return param;
    }

    return null;   
  }

  @override
  bool routeEntryExists(AFState state) {
    return state.public.route?.routeEntryExists(this.screenId, includePrior: true);
  }

}

abstract class AFEmbeddedWidget<TState extends AFAppStateArea,  TTheme extends AFConceptualTheme, TBuildContext extends AFBuildContext, TStateView extends AFStateView, TRouteParam extends AFRouteParam> extends StatelessWidget { 
  final AFBuildContext parentContext;
  final TStateView stateViewOverride;
  final TRouteParam routeParamOverride;
  final TRouteParam paramWithChildren;
  final TTheme themeOverride;
  final AFUpdateRouteParamDelegate updateRouteParamDelegate;
  
  AFEmbeddedWidget({
    AFWidgetID wid,
    @required this.parentContext,
    this.stateViewOverride,
    this.routeParamOverride,
    this.paramWithChildren,
    this.themeOverride,
    this.updateRouteParamDelegate,

  }): super(key: AFConceptualTheme.keyForWIDStatic(wid));

  @override
  material.Widget build(material.BuildContext context) {
    final afContext = createContext(
      context, 
      parentContext.d, 
      stateViewOverride ?? parentContext.stateView,
      routeParamOverride ?? parentContext.routeParam,
      paramWithChildren ?? parentContext.paramWithChildren,
      themeOverride ?? parentContext.theme,
    );

    return buildWithContext(afContext);    
  }

  TBuildContext createContext(material.BuildContext context, AFDispatcher dispatcher, TStateView stateView, TRouteParam param, AFRouteParamWithChildren paramWithChildren, TTheme theme);

  material.Widget buildWithContext(TBuildContext context);

  
  void updateRouteParam(AFBuildContext context, TRouteParam revised, { AFID id }) {
    assert(updateRouteParamDelegate != null, "If you want to call updateRouteParam from an AFEmbeddedWidget, you need to pass an updateRouteParamDelegate to it's constructor, or us an AFConnectedWidget instead.");
    updateRouteParam(context, revised, id: id);
  }
}

abstract class AFConnectedWidget<TState extends AFAppStateArea, TTheme extends AFConceptualTheme, TBuildContext extends AFBuildContext, TStateView extends AFStateView, TRouteParam extends AFRouteParam> extends AFConnectedUIBase<TState, TTheme, TBuildContext, TStateView, TRouteParam> { 
  final AFScreenID screenParent;
  final AFWidgetID widChild;
  final AFNavigateRoute route;
  
  AFConnectedWidget({
    @required this.screenParent,
    @required this.widChild,
    @required AFThemeID themeId,
    this.route = AFNavigateRoute.routeHierarchy,
  }): super(key: AFConceptualTheme.keyForWIDStatic(widChild), themeId: themeId);

  AFScreenID get primaryScreenId {
    return null;
  }

  /// Find the route param for this child widget.
  /// 
  /// The parent screen must have a route param of type AFRouteParamWithChildren.
  /// Which this widget used to find its specific child route param in that screen's
  /// overall route param.
  AFRouteParam findRouteParam(AFState state) { 
    return findChildParam<TRouteParam>(state, this.screenParent, this.widChild);
  }

  static AFRouteParam findChildParam<TRouteParam extends AFRouteParam>(AFState state, AFScreenID screen, AFID widChild) {
    final route = state.public.route;
    final paramParent = route?.findParamFor(screen);
    final isPassthrough = widChild.endsWith(AFUIWidgetID.afibPassthroughSuffix);
    if(paramParent is! AFRouteParamWithChildren) {
      if(paramParent is TRouteParam && isPassthrough) {
        return paramParent;
      } 
      assert(false, "The parent screen must use AFRouteParamWithChildren as its route parameter");
    }
    final AFRouteParamWithChildren pp = paramParent;
    if(isPassthrough) {
      return pp.primary.param;
    }
    return pp.findByWidget(widChild);
  }  

  void updateRouteParam(AFBuildContext context, TRouteParam revised, { AFID id }) {
    updateChildRouteParam(context, revised, this.screenParent, this.widChild, id: id);
  }

  static void updateChildRouteParam(AFBuildContext context, AFRouteParam revised, AFScreenID parentScreen, AFID widChild, { AFID id } ) {
    context.dispatch(AFNavigateSetChildParamAction(
      id: id,
      screen: parentScreen, 
      param: revised,
      widget: widChild
    ));

  }

}

abstract class AFConnectedScreenWithGlobalParam<TState extends AFAppStateArea, TTheme extends AFConceptualTheme, TBuildContext extends AFBuildContext, TStateView extends AFStateView, TRouteParam extends AFRouteParam> extends AFConnectedScreen<TState, TTheme, TBuildContext, TStateView, TRouteParam> {
  AFConnectedScreenWithGlobalParam(
    AFScreenID screenId,
    AFThemeID themeId,
  ): super(screenId, themeId, route: AFNavigateRoute.routeGlobalPool);

  bool get testOnlyRequireScreenIdMatchForTestContext { return false; }
  bool get isPrimaryScreen { return false; }

  /// Look for this screens route parameter in the global pool, 
  /// rather than in the navigational hierarchy
  @override
  TRouteParam findRouteParam(AFState state) {
    var current = state.public.route.findGlobalParam(screenId);
    return current;
  }

  /// Update this screens route parameter in the global pool, rather than in the
  /// route hiearchy.
  @override
  void updateRouteParam(AFBuildContext context, TRouteParam revised, { AFID id }) {
    context.dispatch(AFNavigateSetParamAction(
      id: id,
      screen: this.screenId, 
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
abstract class AFConnectedDrawer<TState extends AFAppStateArea, TTheme extends AFConceptualTheme, TBuildContext extends AFBuildContext, TStateView extends AFStateView, TRouteParam extends AFRouteParam> extends AFConnectedScreenWithGlobalParam<TState, TTheme, TBuildContext, TStateView, TRouteParam> {
  AFConnectedDrawer(
    AFScreenID screenId,
    AFThemeID themeId,
  ): super(screenId, themeId);

  /// Look for this screens route parameter in the global pool, 
  /// rather than in the navigational hierarchy.
  @override
  TRouteParam findRouteParam(AFState state) {
    var current = super.findRouteParam(state);
    // Note that because the user can slide a drawer on screen without the
    // application explictly opening it, we need to have the drawer create a default
    // route parameter if one does not already exist. 
    if(current == null) {
      current = createDefaultRouteParam(state);
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
abstract class AFConnectedDialog<TState extends AFAppStateArea, TTheme extends AFConceptualTheme, TBuildContext extends AFBuildContext, TStateView extends AFStateView, TRouteParam extends AFRouteParam> extends AFConnectedScreenWithGlobalParam<TState, TTheme, TBuildContext, TStateView, TRouteParam> {
  AFConnectedDialog(
    AFScreenID screenId,
    AFThemeID themeId,
  ): super(screenId, themeId);


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
abstract class AFConnectedBottomSheet<TState extends AFAppStateArea, TTheme extends AFConceptualTheme, TBuildContext extends AFBuildContext, TStateView extends AFStateView, TRouteParam extends AFRouteParam> extends AFConnectedScreenWithGlobalParam<TState, TTheme, TBuildContext, TStateView, TRouteParam> {
  AFConnectedBottomSheet(
    AFScreenID screenId,
    AFThemeID themeId,
  ): super(screenId, themeId);

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
  void showDialog({
    AFScreenID screenId,
    AFRouteParam param,
    AFNavigatePushAction navigate,
    AFReturnValueDelegate onReturn,
    bool barrierDismissible = true,
    material.Color barrierColor,
    bool useSafeArea = true,
    bool useRootNavigator = true,
    material.RouteSettings routeSettings
  }) async {
    if(navigate != null) {
      assert(screenId == null);
      assert(param == null);
      screenId = navigate.screen;
      param = navigate.param;
    }

    _updateOptionalGlobalParam(screenId, param);

    final builder = AFibF.g.screenMap.findBy(screenId);
    if(builder == null) {
      throw AFException("The screen $screenId is not registered in the screen map");
    }
    final result = await material.showDialog<AFRouteParam>(
      context: context,
      builder: builder,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      useSafeArea: useSafeArea,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings
    );

    AFibF.g.testOnlyDialogRegisterReturn(screenId, result);
    if(onReturn != null) {
      onReturn(result);
    }
  }

  /// Show a snackbar.
  /// 
  /// Shows a snackbar containing the specified [text].   
  /// 
  /// See also [showSnackbarText]
  void showSnackbarText(String text, { Duration duration = const Duration(seconds: 2)}) {
    if(text != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), duration: duration));
    }
  }

  /// Show a snackbar.
  /// 
  /// Shows the specified snackbar.
  /// 
  /// See also [showSnackbarText]
  void showSnackbar(SnackBar snackbar) {
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
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
    AFScreenID screenId,
    AFRouteParam param,
    AFNavigatePushAction navigate,
    AFReturnValueDelegate onReturn,
    material.Color backgroundColor,
    double elevation,
    material.ShapeBorder shape,
    material.Clip clipBehavior,
    material.Color barrierColor,
    bool isScrollControlled = false,
    bool useRootNavigator = false,
    bool isDismissible = true,
    bool enableDrag = true,
    material.RouteSettings routeSettings,  
  }) async {
    if(navigate != null) {
      assert(screenId == null);
      assert(param == null);
      screenId = navigate.screen;
      param = navigate.param;
    }

    _updateOptionalGlobalParam(screenId, param);

    final builder = AFibF.g.screenMap.findBy(screenId);
    if(builder == null) {
      throw AFException("The screen $screenId is not registered in the screen map");
    }

    final result = await material.showModalBottomSheet<AFRouteParam>(
      context: context,
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

    AFibF.g.testOnlyBottomSheetRegisterReturn(screenId, result);

    if(onReturn != null) {
      onReturn(result);
    }
  }

  /// Shows a bottom sheet
  /// 
  /// See also [showModalBottomSheet].
  void showBottomSheet({
    AFScreenID screenId,
    AFRouteParam param,
    AFNavigatePushAction navigate,
    material.Color backgroundColor,
    double elevation,
    material.ShapeBorder shape,
    material.Clip clipBehavior,
  }) async {
    if(navigate != null) {
      assert(screenId == null);
      assert(param == null);
      screenId = navigate.screen;
      param = navigate.param;
    }

    _updateOptionalGlobalParam(screenId, param);

    final builder = AFibF.g.screenMap.findBy(screenId);
    if(builder == null) {
      throw AFException("The screen $screenId is not registered in the screen map");
    }

    material.Scaffold.of(context).showBottomSheet<AFRouteParam>(
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
    AFScreenID screenId,
    AFRouteParam param,
  }) {
    _updateOptionalGlobalParam(screenId, param);
    final scaffold = material.Scaffold.of(context);
    if(scaffold == null) {
      throw AFException("Could not find a scaffold, you probably need to add an AFBuilder just under the scaffold but above the widget that calls this function");
    }
    scaffold.openDrawer();
  }

  /// Open the end drawer that you specified for your [Scaffold].
  void openEndDrawer({
    AFScreenID screenId,
    AFRouteParam param,
  }) {
    _updateOptionalGlobalParam(screenId, param);
    final scaffold = material.Scaffold.of(context);
    if(scaffold == null) {
      throw AFException("Could not find a scaffold, you probably need to add an AFBuilder just under the scaffold but above the widget that calls this function");
    }
    scaffold.openEndDrawer();
  }

  void _updateOptionalGlobalParam(AFScreenID screenId, AFRouteParam param) {
    if(param == null)  {
      return;
    }
    dispatch(AFNavigateSetParamAction(
      screen: screenId, 
      param: param, route: AFNavigateRoute.routeGlobalPool
    ));
  }

  BuildContext get context;
  void dispatch(dynamic action);

}

/// A utility class which you can use when you have a complex screen which passes the dispatcher,
/// screen data and param to many functions, to make things more concise.  
/// 
/// The framework cannot pass you this itself because 
class AFBuildContext<TStateView extends AFStateView, TRouteParam extends AFRouteParam, TTheme extends AFConceptualTheme> with AFContextDispatcherMixin, AFContextShowMixin {
  material.BuildContext context;
  AFDispatcher dispatcher;
  TStateView stateView;
  TRouteParam routeParam;
  AFRouteParamWithChildren paramWithChildren;
  AFScreenPrototypeTest screenTest;
  TTheme theme;
  AFConnectedUIBase container;

  AFBuildContext(this.context, this.dispatcher, this.stateView, this.routeParam, this.paramWithChildren, this.theme, this.container);

  /// Shorthand for accessing the route param.
  TRouteParam get p { return routeParam; }

  /// Shorthand for accessing data from the store
  TStateView get s { return stateView; }

  /// Shorthand for accessing the theme
  TTheme get t { return theme; }

  /// Shorthand for accessing the dispatcher
  AFDispatcher get d { return dispatcher; }

  /// Shorthand for accessing the flutter build context
  material.BuildContext get c { return context; }

  /// Dispatch an action or query.
  void dispatch(dynamic action) { dispatcher.dispatch(action); }

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
  void updateRouteParam(AFConnectedUIBase widget, TRouteParam revised, { AFID id }) {
    widget.updateRouteParam(this, revised, id: id);
  }

  /// Update one object at the root of the application state.
  /// 
  /// Note that you must specify your root application state type as a type parameter:
  /// ```dart
  /// context.updateAppStateOne<YourRootState>(oneObjectWithinYourRootState);
  /// ```
  void updateAppStateOne<TState extends AFAppStateArea>(Object toUpdate) {
    dispatcher.dispatch(AFUpdateAppStateAction.updateOne(TState, toUpdate));
  }

  /// Update several objects at the root of the application state.
  /// 
  /// Note that you must specify your root application state type as a type parameter:
  /// ```dart
  /// context.updateAppStateMany<YourRootState>([oneObjectWithinYourRootState, anotherObjectWithinYourRootState]);
  /// ```
  void updateAppStateMany<TState extends AFAppStateArea>(List<Object> toUpdate) {
    dispatcher.dispatch(AFUpdateAppStateAction.updateMany(TState, toUpdate));
  } 

  /// A utility which dispatches an asynchronous query.
  void updateRunQuery(AFAsyncQuery query) {
    dispatcher.dispatch(query);
  }


  /// Called to close a drawer.
  /// 
  /// Important: If you call this method, and a drawer isn't open, it will
  /// pop the current screen and mess up the navigational state.   This method
  /// is usally called from within a drawer, in response to a user action that should
  /// close the drawer, and then do something else, like navigate to a new screen.
  void closeDrawer() {
    AFibF.g.doMiddlewareNavigation( (navState) {
      material.Navigator.pop(c);
    });
  }

  /// Closes the dialog, and returns the [returnValue] to the callback function that was
  /// passed to [showDialog].
  /// 
  /// This is intended to be called from within an AFConnectedDialog.  If you call it 
  /// and a dialog is not open, it will mess up the navigation state.
  void closeDialog(dynamic returnValue) {
    AFibF.g.doMiddlewareNavigation( (navState) {
      material.Navigator.pop(context, returnValue); 
    });
  }

  /// Closes the dialog, and returns the [returnValue] to the callback function that was
  /// passed to [showDialog].
  /// 
  /// This is intended to be called from within an AFConnectedDialog.  If you call it 
  /// and a dialog is not open, it will mess up the navigation state.
  void closeBottomSheet(dynamic returnValue) {
    AFibF.g.doMiddlewareNavigation( (navState) {
      material.Navigator.pop(context, returnValue); 
    });
  }

  /// Log to the appRender topic.  
  /// 
  /// The logger can be null, so you should
  /// use something like context.log?.d("my message");
  Logger get log { 
    return AFibD.logAppRender;
  }

  bool operator==(dynamic o) {
    final result = (o is AFBuildContext<TStateView, TRouteParam, TTheme> && routeParam == o.routeParam && paramWithChildren == o.paramWithChildren && stateView == o.stateView && theme == o.theme);
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
  void updateRebuildThemeState() {
    dispatch(AFRebuildThemeState());
  }

  /// Renders a single connected child.
  /// 
  /// If your [AFRouteParamWithChildren] contains exactly one value of type [TChildRouteParam], you can 
  /// render it using this method.
  material.Widget childConnectedRender<TChildRouteParam extends AFRouteParam>({
    @required AFScreenID screenParent,
    @required AFWidgetID widChild,
    @required AFRenderConnectedChildDelegate render
  }) {
    final child = paramWithChildren.findByWidget(widChild);
    assert(child is TChildRouteParam, "Expected child route param type $TChildRouteParam} but found ${child.runtimeType}");
    final widget = render(screenParent, widChild);
    assert(widget is AFConnectedWidget, "When rendering children of a AFConnectedScreen, the children must be subclasses of AFConnectedWidget");
    return widget;
  }

  material.Widget childConnectedRenderPassthrough<TChildRouteParam extends AFRouteParam>({
    @required AFScreenID screenParent,
    @required AFWidgetID widChild,
    @required AFRenderConnectedChildDelegate render
  }) {
    assert(TChildRouteParam != dynamic);
    final param = this.routeParam;
    final widChildFull = screenParent.with2(widChild, AFUIWidgetID.afibPassthroughSuffix);
    assert(param is TChildRouteParam);
    final widget = render(screenParent, widChildFull);
    assert(widget is AFConnectedWidget);
    return widget;
  }


  /// Renders a list of connected children, one for reach child parameter in
  /// the parent's [AFRouteParamWithChildren] that also has the type [TChildRouteParam].
  List<material.Widget> childrenConnectedRender<TChildRouteParam extends AFRouteParam>({
    @required AFScreenID screenParent,
    @required AFRenderConnectedChildDelegate render
  }) {
    final result = <material.Widget>[];
    if(paramWithChildren == null) {
      throw AFException("paramWithChildren was null while rendering connected children.   Most likely your parent screen did not derive from AFConnectedScreenWithChildren");
    }
    var children = paramWithChildren.children;
    for(final child in children) {
      if(child.param is TChildRouteParam) {
        final widChild = child.widgetId;
        final widget = render(screenParent, widChild);
        if(widget == null) {
          continue;
        }
        if(widget is! AFConnectedWidget) {
          throw AFException("When rendering children of a AFConnectedScreen, the children must be subclasses of AFConnectedWidget");
        }
        result.add(widget);
      }
    }    
    return result;
  }

  /// Returns the number of connected children that have a route parameter
  /// of the specified type.
  int childrenCountConnected<TChildRouteParam extends AFRouteParam>() {
    return paramWithChildren.countOfChildren<TChildRouteParam>();
  }

  /// Adds a new connected child into the [AFRouteParamWithChildren] of this screen.
  /// 
  /// The parent screen will automatically re-render with the new child.
  void updateAddConnectedChild({
    @required AFScreenID screen,
    @required AFWidgetID widget, 
    @required AFRouteParam param
  }) {
    dispatch(AFNavigateAddConnectedChildAction(
      screen: screen,
      widget: widget,
      param: param
    ));
  }

  /// Removes the connected child with the specified widget id from the [AFRouteParamWithChildren] of this screen.
  /// 
  /// The parent screen will automatically re-render.
  void updateRemoveConnectedChild({
    @required AFScreenID screen,
    @required AFWidgetID widget
  }) {
    dispatch(AFNavigateRemoveConnectedChildAction(
      screen: screen,
      widget: widget,
    ));
  }

  /// Changes the sort order for connected children of thype [TChildRouteParam] in the [AFRouteParamWithChildren] of this screen.
  /// 
  /// Note that the sort order is stored in the state and is maintained dynamically.   If you add a new connected
  /// child later, the parent screen will automatically re-sort using the previously specified sort order.
  void updateSortConnectedChildren<TChildRouteParam extends AFRouteParam>({
    @required AFScreenID screen,
    @required AFTypedSortDelegate<TChildRouteParam> sort
  }) {
    dispatch(AFNavigateSortConnectedChildrenAction(
      screen: screen,
      sort: (l, r) {
        return sort(l, r);
      },
      typeToSort: TChildRouteParam,
    ));
  }
}

