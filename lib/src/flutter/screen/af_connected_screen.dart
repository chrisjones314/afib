
import 'package:afib/src/dart/redux/actions/af_theme_actions.dart';
import 'package:afib/src/dart/utils/af_context_dispatcher_mixin.dart';
import 'package:afib/src/flutter/test/af_test_dispatchers.dart';
import 'package:afib/src/flutter/utils/af_dispatcher.dart';
import 'package:afib/src/flutter/utils/af_state_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:logger/logger.dart';
import 'package:quiver/core.dart';
import 'package:afib/afib_dart.dart';
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/redux/actions/af_route_actions.dart';
import 'package:afib/src/dart/redux/state/af_state.dart';
import 'package:afib/src/dart/redux/state/af_store.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/utils/af_bottom_popup_layout.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:afib/src/flutter/test/af_test_drawer.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_redux/flutter_redux.dart';


/// Base call for all screens, widgets, drawers, dialogs and bottom sheets
/// that connect to the store/state.
/// 
/// You should usually subclass on of its subclasses:
/// * [AFConnectedScreen]
/// * [AFConnectedWidget]
/// * [AFConnectedScreenWithConnectedChildren] - used for screens containing connected widgets
/// * [AFConnectedDrawer]
/// * [AFConnectedDialog]
/// * [AFConnectedBottomSheet]
abstract class AFConnectedUIBase<TState extends AFAppStateArea, TStateView extends AFStateView, TRouteParam extends AFRouteParam, TTheme extends AFConceptualTheme> extends material.StatelessWidget {
    
  //--------------------------------------------------------------------------------------
  AFConnectedUIBase({Key key}): super(key: key);

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

          var screenIdRegister = this.screenIdForTest;          
          if(screenIdRegister != null) {
            /*
            if(dataContext.p != null && dataContext.p is AFPrototypeSingleScreenRouteParam) {
              screenIdRegister = dataContext.p.effectiveScreenId;
            }
            */
            
            AFibF.g.registerTestScreen(screenIdRegister, buildContext, this);
            AFibD.logTest?.d("Rebuilding screen $runtimeType/$screenIdRegister with param ${dataContext.p}");
          }
          final withContext = createContext(buildContext, dataContext.d, dataContext.s, dataContext.p, dataContext.paramWithChildren, dataContext.theme);
          final widgetResult = buildWithContext(withContext);
          return widgetResult;
        }
    );
  }

  AFBuildContext createContext(material.BuildContext context, AFDispatcher dispatcher, TStateView data, TRouteParam param, AFRouteParamWithChildren paramWithChildren, TTheme theme) {
    return AFBuildContext<TStateView, TRouteParam, TTheme>(context, dispatcher, data, param, paramWithChildren, theme);
  }

  /// Screens that have their own element tree in testing must return their screen id here,
  /// otherwise return null.
  AFScreenID get screenIdForTest;
  bool get isPopupScreen { return false; }

  AFBuildContext<TStateView, TRouteParam, TTheme> _createNonBuildContext(AFStore store) {
    if(AFibD.config.isTestContext) {
      final testContext = _createTestContext(store);
      if(testContext != null) {
        return testContext;
      }
    }

    final data = createStateDataAF(store.state);
    final param = findParam(store.state);
    final paramWithChildren = findParamWithChildren(store.state);
    if(param == null && !routeEntryExists(store.state)) {
      return null;
    }
    final theme = findTheme(store.state.public.themes);

    final context = createContext(null, createDispatcher(store), data, param, paramWithChildren, theme);
    return context;
  }

  AFBuildContext<TStateView, TRouteParam, TTheme> _createTestContext(AFStore store) {
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
    if(!this.isPopupScreen && screen != this.screenIdForTest) {
      return null;
    }
    if(this.screenIdForTest == null) {
      return null;
    }
    if(this is AFTestDrawer) {
      return null;
    }

    final param = findParam(store.state);
    final paramWithChildren = findParamWithChildren(store.state);

    var data = activeState.findViewStateFor<TStateView>();

    if(data == null) {
      return null;
    }

    final mainDispatcher = AFStoreDispatcher(store);
    final dispatcher = AFSingleScreenTestDispatcher(activeTestId, mainDispatcher, testContext);
    final theme = findTheme(store.state.public.themes);

    /*
    if(paramChild is AFRouteParamWithChildren) {
      paramWithChildren = paramChild;
      paramChild = paramWithChildren.primary.param;
    }
    */
    

    return createContext(null, dispatcher, data, param, paramWithChildren, theme);
  }

  AFDispatcher createDispatcher(AFStore store) {
    return AFStoreDispatcher(store);
  }

  /// Find the route param for this screen. 
  AFRouteParam findParam(AFState state) { return null; }

  /// Find the route param for this screen. 
  AFRouteParamWithChildren findParamWithChildren(AFState state) { return null; }

  TTheme findTheme(AFThemeState themes) {
    return themes.findByType(TTheme);
  }

  bool routeEntryExists(AFState state) { return true; }

  TStateView createStateDataAF(AFState state) {
    return createStateDataPublic(state.public);
  }

  /// Override this instead of [createStateData] if you need access
  /// to the full route state. 
  /// 
  /// However, be aware that a full route state does not exist in single
  /// screen tests.
  TStateView createStateDataPublic(AFPublicState public) {
    final TState state = public.areaStateFor(TState);
    return createStateData(state);
  }


  /// Override this to create an [AFStateView] with the required data from the state.
  TStateView createStateData(TState state);

  /// Builds a Widget using the data extracted from the state.
  material.Widget buildWithContext(AFBuildContext<TStateView, TRouteParam, TTheme> context);

  /// Called to update the route parameter and re-render the screen.
  /// 
  /// It is strange to have a route-parameter method here (in a AFConnectedScreenWithoutRoute).
  /// However, subclasses of this like [AFPopupScreen] and [AFConnectedWidgetWithParam] have
  /// the ability to reference/update the AFRouteParam of their parent screen.
  /// This is here to create a single consistent mechanism for performing updates
  /// even in cases where that specific widget does not have its own route entry.
  void updateRouteParamD(AFDispatcher dispatcher, TRouteParam revised, { AFID id });

  /// Like [updateRouteParamD], but takes a build context
  /// rather than a dispatcher for convenience.
  void updateRouteParam(AFBuildContext context,TRouteParam revised, { AFID id }) {
    return updateRouteParamD(context.dispatcher, revised, id: id);
  }
}

/// Superclass for a screen Widget, which combined data from the store with data from
/// the route in order to render itself.
abstract class AFConnectedScreen<TState extends AFAppStateArea, TStateView extends AFStateView, TRouteParam extends AFRouteParam, TTheme extends AFConceptualTheme> extends AFConnectedUIBase<TState, TStateView, TRouteParam, TTheme> {
  final AFScreenID screenId;
    final AFNavigateRoute route;

  AFConnectedScreen(this.screenId, { Key key, this.route = AFNavigateRoute.routeHierarchy }): super(key: key);

  AFScreenID get screenIdForTest {
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
  void updateRouteParamD(AFDispatcher dispatcher, TRouteParam revised, { AFID id }) {
    dispatcher.dispatch(AFNavigateSetParamAction(
      id: id,
      screen: this.screenId, 
      param: revised,
      route: route
    ));
  }

  /// Utility method which updates the parameter, but takes a build context
  /// rather than a dispatcher for convenience
  void updateRouteParam(AFBuildContext context,TRouteParam revised, { AFID id }) {
    return updateRouteParamD(context.dispatcher, revised, id: id);
  }

  /// Find the route parameter for the specified named screen
  AFRouteParam findParam(AFState state) {
    final route = state.public.route;
    TRouteParam p = route?.findParamFor(this.screenId, includePrior: true);
    if(p == null && this.screenId == AFibF.g.actualStartupScreenId) {
      p = route?.findParamFor(AFUIScreenID.screenStartupWrapper);
    }
    return p;
  }

  @override
  bool routeEntryExists(AFState state) {
    return state.public.route?.routeEntryExists(this.screenId, includePrior: true);
  }

  material.Widget createScaffold({
    Key key,
    @required AFBuildContext context,
    material.PreferredSizeWidget appBar,
    material.Widget drawer,
    material.Widget body,
    material.Widget bottomNavigationBar,
    material.Widget floatingActionButton,
    material.Color backgroundColor,
    material.FloatingActionButtonLocation floatingActionButtonLocation,
    material.FloatingActionButtonAnimator floatingActionButtonAnimator,
    List<material.Widget> persistentFooterButtons,
    material.Widget endDrawer,
    material.Widget bottomSheet,
    bool resizeToAvoidBottomPadding,
    bool resizeToAvoidBottomInset,
    bool primary = true,
    DragStartBehavior drawerDragStartBehavior = DragStartBehavior.start,
    bool extendBody = false,
    bool extendBodyBehindAppBar = false,
    material.Color drawerScrimColor, 
    double drawerEdgeDragWidth, 
    bool drawerEnableOpenDragGesture = true,
    bool endDrawerEnableOpenDragGesture = true
    
  }) {
      return material.Scaffold(
        key: key,
        drawer: context.createDebugDrawerBegin(drawer),
        body: body,
        appBar: appBar,
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
        floatingActionButtonAnimator: floatingActionButtonAnimator,
        backgroundColor: backgroundColor,
        persistentFooterButtons: persistentFooterButtons,
        bottomSheet: bottomSheet,
        resizeToAvoidBottomPadding: resizeToAvoidBottomPadding,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        primary: primary,
        drawerDragStartBehavior: drawerDragStartBehavior,
        extendBody: extendBody,
        extendBodyBehindAppBar: extendBodyBehindAppBar,
        drawerScrimColor: drawerScrimColor,
        drawerEdgeDragWidth: drawerEdgeDragWidth,
        drawerEnableOpenDragGesture: drawerEnableOpenDragGesture,
        endDrawer: context.createDebugDrawerEnd(endDrawer)
      );
  }
}

abstract class AFConnectedWidget<TState extends AFAppStateArea, TStateView extends AFStateView, TRouteParam extends AFRouteParam, TTheme extends AFConceptualTheme> extends AFConnectedUIBase<TState, TStateView, TRouteParam, TTheme> { 
  final AFScreenID parentScreen;
  final AFWidgetID widChild;
  
  AFConnectedWidget({
    @required this.parentScreen,
    @required this.widChild,
  }): super(key: AFUI.keyForWID(widChild));


  AFScreenID get screenIdForTest {
    return null;
  }

  /// Find the route param for this child widget.
  /// 
  /// The parent screen must have a route param of type AFRouteParamWithChildren.
  /// Which this widget used to find its specific child route param in that screen's
  /// overall route param.
  AFRouteParam findParam(AFState state) { 
    return findChildParam(state, this.parentScreen, this.widChild);
  }

  static AFRouteParam findChildParam(AFState state, AFScreenID screen, AFID widChild) {
    final route = state.public.route;
    final paramParent = route?.findParamFor(screen);
    if(paramParent is! AFRouteParamWithChildren) {
      throw AFException("The parent screen must use AFRouteParamWithChildren as its route parameter");
    }
    final AFRouteParamWithChildren pp = paramParent;
    return pp.findByWidget(widChild);
  }  

  void updateRouteParamD(AFDispatcher dispatcher, TRouteParam revised, { AFID id }) {
    updateChildRouteParam(dispatcher, revised, this.parentScreen, this.widChild, id: id);
  }

  static void updateChildRouteParam(AFDispatcher dispatcher, AFRouteParam revised, AFScreenID parentScreen, AFID widChild, { AFID id } ) {
    dispatcher.dispatch(AFNavigateSetChildParamAction(
      id: id,
      screen: parentScreen, 
      param: revised,
      widget: widChild
    ));

  }

}


/// Use this, coupled with [AFRouteParamWithChildren] for screens which 
/// render connected widgets.  
/// 
/// See also:
/// * [AFBuildContext.childrenRenderConnected]
/// * various update... methods related to connected children on [AFBuildContext]
abstract class AFConnectedScreenWithConnectedChildren<TState extends AFAppStateArea, TStateView extends AFStateView, TRouteParam extends AFRouteParam, TTheme extends AFConceptualTheme> extends AFConnectedScreen<TState, TStateView, TRouteParam, TTheme> {

  AFConnectedScreenWithConnectedChildren({
    @required AFScreenID screenId,
    AFNavigateRoute route = AFNavigateRoute.routeHierarchy,
  }): super(screenId, route: route);

  AFRouteParam findParam(AFState state) { 
    return AFConnectedWidget.findChildParam(state, this.screenId, this.screenId);
  }
  
  void updateRouteParamD(AFDispatcher dispatcher, AFRouteParam revised, { AFID id }) {
    AFConnectedWidget.updateChildRouteParam(dispatcher, revised, this.screenId, this.screenId, id: id);
  }

  /// Find the route param for this screen. 
  AFRouteParamWithChildren findParamWithChildren(AFState state) { 
    final route = state.public.route;
    final param = route?.findParamFor(this.screenId);
    if(param is! AFRouteParamWithChildren) {
      throw AFException("When using AFConnectedScreenWithConnectedChildren, you must create an AFRouteParamWithChildren parameter and use that when you navigate to the screen");
    }

    return param;   
  }

  void updateRouteParamWithChildren(AFBuildContext context, AFRouteParamWithChildren revised, { AFID id }) {
    context.dispatcher.dispatch(AFNavigateSetParamAction(
      id: id,
      screen: this.screenId, 
      param: revised,
      route: route,
    ));
  }

}


abstract class AFConnectedScreenWithGlobalParam<TState extends AFAppStateArea, TStateView extends AFStateView, TRouteParam extends AFRouteParam, TTheme extends AFConceptualTheme> extends AFConnectedScreen<TState, TStateView, TRouteParam, TTheme> {
  AFConnectedScreenWithGlobalParam(
    AFScreenID screenId,
  ): super(screenId, route: AFNavigateRoute.routeGlobalPool);

  bool get isPopupScreen { return true; }

  /// Look for this screens route parameter in the global pool, 
  /// rather than in the navigational hierarchy
  @override
  TRouteParam findParam(AFState state) {
    var current = state.public.route.findGlobalParam(screenId);
    return current;
  }

  /// Update this screens route parameter in the global pool, rather than in the
  /// route hiearchy.
  @override
  void updateRouteParamD(AFDispatcher dispatcher, TRouteParam revised, { AFID id }) {
    dispatcher.dispatch(AFNavigateSetParamAction(
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
abstract class AFConnectedDrawer<TState extends AFAppStateArea, TStateView extends AFStateView, TRouteParam extends AFRouteParam, TTheme extends AFConceptualTheme> extends AFConnectedScreenWithGlobalParam<TState, TStateView, TRouteParam, TTheme> {
  AFConnectedDrawer(
    AFScreenID screenId,
  ): super(screenId);

  /// Look for this screens route parameter in the global pool, 
  /// rather than in the navigational hierarchy.
  @override
  TRouteParam findParam(AFState state) {
    var current = super.findParam(state);
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
abstract class AFConnectedDialog<TState extends AFAppStateArea, TStateView extends AFStateView, TRouteParam extends AFRouteParam, TTheme extends AFConceptualTheme> extends AFConnectedScreenWithGlobalParam<TState, TStateView, TRouteParam, TTheme> {
  AFConnectedDialog(
    AFScreenID screenId,
  ): super(screenId);

  @override
  material.Widget buildWithContext(AFBuildContext<TStateView, TRouteParam, TTheme> context) {
    return buildDialogWithContext(context);
  }

  material.Widget buildDialogWithContext(AFBuildContext<TStateView, TRouteParam, TTheme> context);
}

/// Use this to connect a bottom sheet to the store.
/// 
/// You can open a bottom sheet with [AFBuildContext.showBottomSheet]
/// or [AFBuildContext.showModalBottomSheeet].
abstract class AFConnectedBottomSheet<TState extends AFAppStateArea, TStateView extends AFStateView, TRouteParam extends AFRouteParam, TTheme extends AFConceptualTheme> extends AFConnectedScreenWithGlobalParam<TState, TStateView, TRouteParam, TTheme> {
  AFConnectedBottomSheet(
    AFScreenID screenId,
  ): super(screenId);

  @override
  material.Widget buildWithContext(AFBuildContext<TStateView, TRouteParam, TTheme> context) {
    return buildBottomSheetWithContext(context);
  }

  material.Widget buildBottomSheetWithContext(AFBuildContext<TStateView, TRouteParam, TTheme> context);
}


/// A utility class which you can use when you have a complex screen which passes the dispatcher,
/// screen data and param to many functions, to make things more concise.  
/// 
/// The framework cannot pass you this itself because 
class AFBuildContext<TStateView extends AFStateView, TRouteParam extends AFRouteParam, TTheme extends AFConceptualTheme> with AFContextDispatcherMixin {
  material.BuildContext context;
  AFDispatcher dispatcher;
  TStateView stateView;
  TRouteParam param;
  AFRouteParamWithChildren paramWithChildren;
  AFScreenPrototypeTest screenTest;
  TTheme theme;

  AFBuildContext(this.context, this.dispatcher, this.stateView, this.param, this.paramWithChildren, this.theme,);

  /// Shorthand for accessing the route param.
  TRouteParam get p { return param; }

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
      context: c,
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
      context: c,
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

    material.Scaffold.of(c).showBottomSheet<AFRouteParam>(
      builder,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
    );
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
    final result = (o is AFBuildContext<TStateView, TRouteParam, TTheme> && param == o.param && paramWithChildren == o.paramWithChildren && stateView == o.stateView && theme == o.theme);
    return result;
  }

  int get hashCode {
    return hash2(param.hashCode, stateView.hashCode);
  }

  /// As long as you are calling [AFConnectedScreen.createScaffold], you don't need
  /// to worry about this, it will be done for you.
  material.Widget createDebugDrawerBegin(material.Widget beginDrawer) {
    return createDebugDrawer(beginDrawer, AFScreenPrototypeTest.testDrawerSideBegin);
  }

  /// As long as you are calling [AFConnectedScreen.createScaffold], you don't need
  /// to worry about this, it will be done for you.
  material.Widget createDebugDrawerEnd(material.Widget endDrawer) {
    return createDebugDrawer(endDrawer, AFScreenPrototypeTest.testDrawerSideEnd);
  }

  /// As long as you are calling [AFConnectedScreen.createScaffold], you don't need
  /// to worry about this, it will be done for you.
  material.Widget createDebugDrawer(material.Widget drawer, int testDrawerSide) {
    final store = AFibF.g.storeInternalOnly;
    final state = store.state;
    final testState = state.testState;
    if(testState.activeTestId != null) {
      final test = AFibF.g.findScreenTestById(testState.activeTestId);
      if(test != null && test.testDrawerSide == testDrawerSide) {
        return AFTestDrawer();
      }
    }
    return drawer;
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
  material.Widget childRenderConnected<TChildRouteParam extends AFRouteParam>({
    @required AFRenderChildByIDDelegate render
  }) {
    final children = paramWithChildren.children.where( (test) => test.param is TChildRouteParam);
    if(children.isEmpty || children.length > 1) {
      throw AFException("You can only use childRenderConnected if there is exactly one child route param of the specified type, there were ${children.length}");
    }

    final widChild = children.toList().first.widgetId;
    final widget = render(widChild);
    if(widget is! AFConnectedWidget) {
      throw AFException("When rendering children of a AFConnectedScreenWithConnectedChildren, the children must be subclasses of AFConnectedWidgetWithParent");
    }
    return widget;
  }


  /// Renders a list of connected children, one for reach child parameter in
  /// the parent's [AFRouteParamWithChildren] that also has the type [TChildRouteParam].
  List<material.Widget> childrenRenderConnected<TChildRouteParam extends AFRouteParam>({
    @required  AFRenderChildByIDDelegate render
  }) {
    final result = <material.Widget>[];
    if(paramWithChildren == null) {
      throw AFException("paramWithChildren was null while rendering connected children.   Most likely your parent screen did not derive from AFConnectedScreenWithChildren");
    }
    var children = paramWithChildren.children;
    for(final child in children) {
      if(child.param is TChildRouteParam) {
        final widChild = child.widgetId;
        final widget = render(widChild);
        if(widget == null) {
          continue;
        }
        if(widget is! AFConnectedWidget) {
          throw AFException("When rendering children of a AFConnectedScreenWithConnectedChildren, the children must be subclasses of AFConnectedWidgetWithParent");
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

/// Use this to connect a Widget to the store.  
/// 
/// The Widget can still have a route parameter, but it must be passed in
/// from the parent screen that the Widget is created by.
abstract class AFConnectedWidgetWithParam<TState extends AFAppStateArea, TStateView extends AFStateView, TRouteParam extends AFRouteParam, TTheme extends AFConceptualTheme> extends AFConnectedUIBase<TState, TStateView, TRouteParam, TTheme> {
  //final TRouteParam parentParam;
  final AFUpdateParamDelegate<TRouteParam> updateParamDelegate;
  final AFExtractParamDelegate extractParamDelegate;
  final AFCreateDataDelegate createDataDelegate;
  final AFFindParamDelegate findParamDelegate;
  final AFDispatcher dispatcher;

  AFConnectedWidgetWithParam({
    Key key,
    @required this.dispatcher,
    @required this.findParamDelegate,
    @required this.updateParamDelegate,
    @required this.extractParamDelegate,
    @required this.createDataDelegate
  }): super(key: key);

  AFScreenID get screenIdForTest {
    return null;
  }

  @override
  TStateView createStateData(TState state) {
    return this.createDataDelegate(state);
  }

  @override
  AFDispatcher createDispatcher(AFStore store) {
    return dispatcher;
  }

  /// Finds the parameter for the parent screen, since a popup screen had not route entry.
  TRouteParam findParam(AFState state) {
    AFRouteParam orig;
    if(findParamDelegate != null) {
       orig = this.findParamDelegate(state);
    }
    if(orig != null && this.extractParamDelegate != null) {
      orig = this.extractParamDelegate(orig);
    }
    return orig;
  }

  /// Updates the parameter for the parent screen, rather than updating a parameter for our screen (which has no route entry).
  void updateRouteParamD(AFDispatcher dispatcher, TRouteParam revised, { AFID id }) {
    updateParamDelegate(dispatcher, revised, id: id);
  }

}


/// Just like an [AFConnectedScreen], except it is typically displayed as 
/// a modal overlay on top of an existing screen, and launched using a custom 
/// AFPopupRoute
abstract class AFPopupScreen<TState extends AFAppStateArea, TStateView extends AFStateView, TRouteParam extends AFRouteParam, TTheme extends AFConceptualTheme> extends AFConnectedScreen<TState, TStateView, TRouteParam, TTheme> {
  final material.Animation<double> animation;
  final AFBottomPopupTheme theme;
  final AFCreateDataDelegate createDataDelegate;
  AFPopupScreen({
    AFScreenID screenId,
    @required this.animation, 
    @required this.theme,
    @required this.createDataDelegate
  }): super(screenId);

  AFScreenID get screenIdForTest {
    return screenId;
  }
  
  /// Find the route parameter for the specified named screen
  @override
  TRouteParam findParam(AFState state) {

    final route = state.public.route;
    TRouteParam p = route?.findPopupParamFor(this.screenId);
    return p;
  }

  TStateView createStateData(TState state) {
    return this.createDataDelegate(state);
  }

  void updateRouteParamD(AFDispatcher dispatcher, TRouteParam revised, { AFID id }) {
    dispatcher.dispatch(AFNavigateSetPopupParamAction(
      id: id,
      screen: this.screenId, 
      param: revised)
    );
  }

  @override
  material.Widget buildWithContext(AFBuildContext<TStateView, TRouteParam, TTheme> context) {
    return buildPopupAnimation(context);
  }

  material.Widget buildPopupAnimation(AFBuildContext<TStateView, TRouteParam, TTheme> context) {
    return material.GestureDetector(
      onTap: () {
        context.log?.d("OnTapGestureDetector");
      },
      child: material.AnimatedBuilder(
        animation: animation,
        builder: (ctx, child) {
          final local = AFBuildContext<TStateView, TRouteParam, TTheme>(ctx, context.d, context.s, context.p, context.paramWithChildren, context.t);
          final bottomPadding = material.MediaQuery.of(local.c).padding.bottom;
          return material.ClipRect(
            child: material.CustomSingleChildLayout(
              delegate: AFBottomPopupLayout(animation.value, theme, bottomPadding: bottomPadding),
              child: material.GestureDetector(
                child: material.Material(
                  color: theme.backgroundColor ?? material.Colors.white,
                  child: buildPopupContents(local, theme),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  material.Widget buildPopupContents(AFBuildContext<TStateView, TRouteParam, TTheme> context, AFBottomPopupTheme theme);
}
