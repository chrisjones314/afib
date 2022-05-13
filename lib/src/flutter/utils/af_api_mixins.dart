import 'package:afib/afib_flutter.dart';
import 'package:afib/src/flutter/ui/dialog/afui_standard_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
import 'package:overlay_support/overlay_support.dart';

mixin AFNonUIAPIContextMixin implements AFDispatcher {

  AFDispatcher get dispatcher;

  void dispatch(dynamic action) {
    dispatcher.dispatch(action);
  }

  /// Dispatches an action that updates the route parameter for the specified screen.
  void updateHierarchyRouteParam(AFRouteParam param) {
    dispatch(AFNavigateSetParamAction(param: param, route: AFNavigateRoute.routeHierarchy));
  }

  void updateGlobalRouteParam(AFRouteParam param) {
    dispatch(AFNavigateSetParamAction(param: param, route: AFNavigateRoute.routeGlobalPool));
  }

  /// Dispatches an action that updates the route parameter for the specified screen.
  void updateChildRouteParam(AFScreenID screen, AFRouteParam param, { 
    AFWidgetParamSource paramSource = AFWidgetParamSource.child,
    AFNavigateRoute route = AFNavigateRoute.routeHierarchy
  }) {
    dispatch(AFNavigateSetChildParamAction(
      screen: screen,
      param: param, 
      route: route,
      paramSource: paramSource
    ));
  }
}

mixin AFAccessStateSynchronouslyMixin {

  //-------------------------------------------------------------------------------------
  // access...
  //-------------------------------------------------------------------------------------
  AFPublicState get accessPublicState {
    return AFibF.g.storeInternalOnly!.state.public;
  }

  AFTimeState get accessCurrentTime {
    return accessPublicState.time;    
  }

  TState accessComponentState<TState extends AFFlexibleState>() {
    final result = accessPublicState.components.findState<TState>();
    return result!;
  }

  AFRouteSegment? accessRouteSegment(AFScreenID screen) {
    return accessPublicState.route.findParamFor(screen);
  }

  TRouteParam? accessRouteParam<TRouteParam extends AFRouteParam>(AFScreenID screen) {
    final seg = accessRouteSegment(screen);
    return seg?.param as TRouteParam?;
  }
  TRouteParam? accessChildRouteParam<TRouteParam extends AFRouteParam>(AFScreenID screen, AFID child) {
    final seg = accessRouteSegment(screen);
    final result = seg?.children?.findParamById(child);
    return result as TRouteParam?;
  }

  TRouteParam? accessGlobalRouteParam<TRouteParam>(AFID id) {
    final seg = accessPublicState.route.findGlobalParam(id);
    final param = seg?.param as TRouteParam?;
    return param;
  }

}

mixin AFStandardAPIContextMixin<TState extends AFFlexibleState> implements AFDispatcher {

  AFDispatcher get dispatcher;

  void dispatch(dynamic action) {
    dispatcher.dispatch(action);
  }

  //-------------------------------------------------------------------------------------
  // access...
  //-------------------------------------------------------------------------------------
  TTheme accessTheme<TTheme extends AFFunctionalTheme>(AFThemeID themeId) {
    final theme = _publicState.themes.findById(themeId);
    if(theme == null) {
      throw AFException("Unknown theme $themeId");
    }
    return theme as TTheme;
  }

  TLPI accessLPI<TLPI extends AFLibraryProgrammingInterface>(AFLibraryProgrammingInterfaceID id) {
    final lpi = AFibF.g.createLPI(id, dispatcher);
    return lpi as TLPI;
  } 

  Stream<AFPublicStateChange> get accessStreamPublicStateChanges {
    return AFibF.g.streamPublicStateChanges;
  }

  /// Synchronously accesses the current public state, providing it to a callback.
  /// 
  /// *Critical*: You cannot use this in UI rendering code to access state that is not in
  /// your state view.  Your UI will only rebuild when data in your state view (or route parameter)
  /// change.   So, if you use this method to try to access other state as part of your rendering code,
  /// then your UI won't update properly when that state changes.
  /// 
  /// However, you can use this in event handler code (usually within your SPI).  That said, you should
  /// not usually need to.   
  void accessCurrentState(AFAccessCurrentStateDelegate delegate) {
    final public = AFibF.g.storeInternalOnly?.state.public;
    if(public != null) {
      final context = AFCurrentStateContext(
        dispatcher: this,
      );
      delegate(context);
    }
  }

  AFPublicState get _publicState {
    return AFibF.g.storeInternalOnly!.state.public;
  }

  AFScreenID get accessActiveScreenId {
    return _publicState.route.activeScreenId;
  }

  //-------------------------------------------------------------------------------------
  // update...
  //-------------------------------------------------------------------------------------

  /// Dispatches an action that updates a single value in the app state area associated
  /// with the [TState] type parameter.
  void updateComponentStateOne<TState extends AFFlexibleState>(Object toIntegrate) {
    assert(TState != AFFlexibleState, "You must specify a state type as a type parameter");
    dispatch(AFUpdateAppStateAction(area: TState, toIntegrate: [toIntegrate]));
  }

  /// Dispatches an action that updates several blaues in the app state area associated
  /// with the [TState] type parameter.
  void updateComponentStateMany<TState extends AFFlexibleState>(List<Object> toIntegrate) {
    assert(TState != AFFlexibleState, "You must specify a state type as a type parameter");
    dispatch(AFUpdateAppStateAction(area: TState, toIntegrate: toIntegrate));
  }

  //-------------------------------------------------------------------------------------
  // navigate...
  //-------------------------------------------------------------------------------------

  void navigatePop({
    bool worksInSingleScreenTest = false,
  }) {
    dispatch(AFNavigatePopAction(worksInSingleScreenTest: worksInSingleScreenTest));
  }

  void navigatePush(
    AFNavigatePushAction action
  ) {
    dispatch(action);
  }

  void navigateReplaceCurrent(
    AFNavigateReplaceAction action,
  ) {
    dispatch(action);
  }

  void navigateReplaceAll(
    AFNavigateReplaceAllAction action
  ) {
    dispatch(action);
  }

  void navigateToUnimplementedScreen(String message) {
    dispatch(AFNavigateUnimplementedQuery(message));
  }

  void navigatePopN({ 
    required int popCount,
  }) {
    dispatch(AFNavigatePopNAction(popCount: popCount));
  }

  void navigatePopTo(
    AFNavigatePopToAction popTo
  )  {
    dispatch((popTo));
  }

  void navigatePopToAndPush({
    required AFScreenID popTo,
    required AFNavigatePushAction push
  }) {
    dispatch(AFNavigatePopToAction(popTo: popTo, push: push));
  }

  /// A utility which dispatches an asynchronous query.
  void executeQuery(AFAsyncQuery query) {
    dispatch(query);
  }

  /// Shuts down all existing listener and deferred queries.   Often called
  /// as part of a signout process.
  void executeShutdownAllActiveQueries() {
    dispatch(AFShutdownOngoingQueriesAction());
  }

  void executeDeferredCallback<TState extends AFFlexibleState>(Duration duration, AFOnResponseDelegate<TState, AFUnused> callback) {
    dispatch(AFDeferredSuccessQuery<TState>(duration, callback));
  }

  //-------------------------------------------------------------------------------------
  // execute...
  //-------------------------------------------------------------------------------------

  /// Resets your application state to it's initial state (see your static initialState method).
  /// This is often called as part of a signout process.
  /// 
  /// Note that you have to be a little careful with the ordering of this, as if you are navigating
  /// from a screen within your app that references state, back out to a signin screen, Flutter will
  /// usually re-render the screen within your app once more as part of the animation.  You may need
  /// to first do the navigation, then use context.executeDeferredCallback with a ~500 ms delay to 
  /// allow the animation to complete, then reset the state once you are fully on the signin screen.
  void executeResetToInitialState() {
    dispatch(AFResetToInitialStateAction());    
  }

  /// A utility which delays for the specified time, then updates the resulting code.   
  /// 
  /// This deferral is active in UIs, but is disabled during automated tests to speed results and reduce 
  /// complexity.
  void executeDeferredQuery(AFDeferredQuery query) {
    dispatch(query);
  }


  void executeConsolidatedQuery(AFConsolidatedQuery query) {
    dispatch(query);
  }

  /// Dispatch an [AFAsyncListenerQuery], which establishes a channel that
  /// recieves results on an ongoing basis (e.g. via a websocket).
  /// 
  /// This is just here for discoverability, it is no different from
  /// dispatch(query).
  void executeListenerQuery(AFAsyncListenerQuery query) {
    dispatch(query);
  }

}

mixin AFContextShowMixin {
  
  AFDispatcher get dispatcher;

  BuildContext? get flutterContext;
  
  void dispatch(dynamic action) {
    dispatcher.dispatch(action);
  }

  //-------------------------------------------------------------------------------------
  // show...
  //-------------------------------------------------------------------------------------


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
  void showDialogAFib<TReturn extends Object?>({
    required AFNavigatePushAction navigate,
    AFReturnValueDelegate<TReturn>? onReturn,
    bool barrierDismissible = true,
    material.Color? barrierColor,
    bool useSafeArea = true,
    bool useRootNavigator = true,
    material.RouteSettings? routeSettings
  }) async {
    showDialogStatic<TReturn>(
      flutterContext: flutterContext,
      dispatch: this.dispatch,
      navigate: navigate,
      onReturn: onReturn,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      useSafeArea: useSafeArea,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
    );
  }

  static Future<void> showDialogStatic<TReturn>({
    required dynamic dispatch(dynamic action),
    required BuildContext? flutterContext,
    required AFNavigatePushAction navigate,
    AFReturnValueDelegate<TReturn>? onReturn,
    bool barrierDismissible = true,
    material.Color? barrierColor,
    bool useSafeArea = true,
    bool useRootNavigator = true,
    material.RouteSettings? routeSettings
  }) async {
    final screenId = navigate.param.id as AFScreenID;
    final verifiedScreenId = _nullCheckScreenId(screenId);
    updateOptionalGlobalParam(dispatch, navigate);

    final builder = AFibF.g.screenMap.findBy(verifiedScreenId);
    if(builder == null) {
      throw AFException("The screen $screenId is not registered in the screen map");
    }

    dispatch(AFNavigateShowScreenBeginAction(verifiedScreenId, AFUIType.dialog));

    final ctx = flutterContext;
    if(ctx != null) {
      // in the normal UI, we let the flutter navigation stuff handle returning 
      // the return value.
      final result = await material.showDialog<TReturn>(
        context: ctx,
        builder: builder,
        barrierDismissible: barrierDismissible,
        barrierColor: barrierColor,
        useSafeArea: useSafeArea,
        useRootNavigator: useRootNavigator,
        routeSettings: routeSettings
      );

      AFibF.g.testOnlyShowUIRegisterReturn(verifiedScreenId, result);
      if(onReturn != null) {
        onReturn(result);
      }
      dispatch(AFNavigateShowScreenEndAction(verifiedScreenId));

    } else {
      // this happens in state testing, where there is no BuildContext.  We still
      // need to handle calling onReturn when someone calls closeDialog.
       AFibF.g.testOnlySimulateShowDialogOrSheet<TReturn>(verifiedScreenId, (val) {
        if(onReturn != null) {
          onReturn(val);
        }
        dispatch(AFNavigateShowScreenEndAction(verifiedScreenId));
       });
    }
  }

  void showDialogInfoText({
    required Object themeOrId,
    required String title,
    String? body,
    List<String>? buttonTitles,   
    void Function(int)? onReturn
  }) {
    showDialogChoiceText(
      themeOrId: themeOrId,
      icon: AFUIStandardChoiceDialogIcon.info,
      title: title,
      body: body,
      buttonTitles: buttonTitles,
      onReturn: onReturn
    );
  }

  void showDialogWarningText({
    required Object themeOrId,
    required String title,
    String? body,
    List<String>? buttonTitles,   
    void Function(int)? onReturn
  }) {
    showDialogChoiceText(
      themeOrId: themeOrId,
      icon: AFUIStandardChoiceDialogIcon.warning,
      title: title,
      body: body,
      buttonTitles: buttonTitles,
      onReturn: onReturn
    );
  }

  void showDialogErrorText({
    required Object themeOrId,
    required String title,
    String? body,
    List<String>? buttonTitles,   
    void Function(int)? onReturn
  }) {
    showDialogChoiceText(
      themeOrId: themeOrId,
      icon: AFUIStandardChoiceDialogIcon.error,
      title: title,
      body: body,
      buttonTitles: buttonTitles,
      onReturn: onReturn
    );
  }

  AFFunctionalTheme _findTheme(Object themeOrId) {
    var theme;
    if(themeOrId is AFFunctionalTheme) {
      theme = themeOrId;
    }

    if(themeOrId is AFThemeID) {
      theme = AFibF.g.storeInternalOnly?.state.public.themes.findById(themeOrId);
    } 

    if(theme == null) {
      throw AFException("You must specify either an AFFunctionalTheme or an AFThemeID");
    }    
    return theme;
  }

  void showDialogChoiceText({
    required Object themeOrId,
    AFUIStandardChoiceDialogIcon icon = AFUIStandardChoiceDialogIcon.question,
    required String title,
    String? body,
    required List<String>? buttonTitles,   
    void Function(int)? onReturn
  }) {
    var richBody; 

    var themeActual = _findTheme(themeOrId);        
    final richTitle = themeActual.childRichTextBuilderOnCard();
    richTitle.writeBold(title);

    if(body != null) {
      richBody = themeActual.childRichTextBuilderOnCard();
      richBody.writeNormal(body);
    }

    if(buttonTitles == null) {
      buttonTitles = ["OK"];
    }
    showDialogAFib<int>(
       navigate: AFUIStandardChoiceDialog.navigatePush(
          icon: icon,
          title: richTitle, 
          body: richBody, 
          buttonTitles: buttonTitles,
      ),
      onReturn: (result) {
        if(result != null && onReturn != null) {
          onReturn(result);
        }
      },
    );
  }

  void showDialogChoice({
    AFUIStandardChoiceDialogIcon icon = AFUIStandardChoiceDialogIcon.question,
    required AFRichTextBuilder title,
    required AFRichTextBuilder? body,
    required List<String> buttonTitles,   
    required void Function(int?)? onReturn
  }) {
    showDialogAFib<int>(
       navigate: AFUIStandardChoiceDialog.navigatePush(
            icon: icon,
            title: title, 
            body: body, 
            buttonTitles: buttonTitles,
        ),
        onReturn: onReturn,
    );
  }

  void showInAppNotificationText({
    required Object themeOrId,
    VoidCallback? onAction,
    String? actionText,
    Color? colorBackground,
    Color? colorForeground,
    required String title,
    String? body,
    Duration? duration,
    NotificationPosition position = NotificationPosition.top,
  }) {
    var themeActual = _findTheme(themeOrId);        
    colorBackground = colorBackground ?? themeActual.colorSecondary;
    colorForeground = colorForeground ?? themeActual.colorOnSecondary;

    var richAction;
    if(actionText != null) {
      richAction = themeActual.childRichTextBuilder();
      richAction.writeNormal(actionText);
    }

    var richBody;
    if(body != null) {
      richBody = themeActual.childRichTextBuilder();
      richBody.writeNormal(body);
    }

    final richTitle = themeActual.childRichTextBuilder();
    richTitle.writeBold(title);

    // in testing, the notification library starts a timer, which doesn't get shut 
    // down, and causes error messages at the end of the test.
    if(AFibD.config.isWidgetTesterContext) {
      duration = Duration(seconds: 0);
    }

    showInAppNotification(
      colorBackground: colorBackground, 
      colorForeground: colorForeground, 
      title: richTitle,
      body: richBody,
      actionText: richAction,
      onAction: onAction,
      duration: duration,
      position: position,
    );
  }


  void showInAppNotification({
    VoidCallback? onAction,
    AFRichTextBuilder? actionText,
    required Color colorBackground,
    required Color colorForeground,
    required AFRichTextBuilder title,
    AFRichTextBuilder? body,
    Duration? duration,
    NotificationPosition position = NotificationPosition.top,
  }) {

    if(onAction != null || actionText != null) {
      if(onAction == null || actionText == null) {
        throw AFException("If you specify onAction or actionText, you must specify both of them.");
      }
    }
    showOverlayNotification( (context) {
      return AFUIStandardNotification(
        colorBackground: colorBackground,
        colorForeground: colorForeground,
        actionText: actionText,
        title: title,
        body: body,
        onAction: () {
          if(onAction != null) {
            onAction();
          }
          OverlaySupportEntry.of(context)?.dismiss();
        });
      },
      duration: duration,
      position: position,
    );
  }

  static AFScreenID _nullCheckScreenId(AFScreenID? screenId) {
    if(screenId == null) throw AFException("You must either specify a screenId, or the navigate param with a screen id");
    return screenId;
  }

  /// Show a snackbar.
  /// 
  /// Shows a snackbar containing the specified [text].   
  /// 
  /// See also [showSnackbarText]
  void showSnackbarText(String text, { Duration duration = const Duration(seconds: 2)}) {
    final ctx = flutterContext;
    if(ctx != null) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(text), duration: duration));
    }
  }

  bool get isUIEnabled {
    return flutterContext != null;
  }

  /// Show a snackbar.
  /// 
  /// Shows the specified snackbar.
  /// 
  /// See also [showSnackbarText]
  void showSnackbar(SnackBar snackbar) {
    final ctx = flutterContext;
    if(ctx != null) {
      ScaffoldMessenger.of(ctx).showSnackBar(snackbar);
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
  void showModalBottomSheetAFib<TReturn extends Object?>({
    required AFNavigatePushAction navigate,
    AFReturnValueDelegate<TReturn>? onReturn,
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

    showModalBottomSheetStatic<TReturn>(
      dispatch: dispatch, 
      navigate: navigate,
      onReturn: onReturn,
      flutterContext: flutterContext,
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
  }

  /// Shows a bottom sheet
  /// 
  /// See also [showModalBottomSheetAFib].
  void showBottomSheet({
    required AFNavigatePushAction navigate,
    material.Color? backgroundColor,
    double? elevation,
    material.ShapeBorder? shape,
    material.Clip? clipBehavior,
  }) async {
    final screenId = navigate.screenId;
    _updateOptionalGlobalParam(navigate);

    final builder = AFibF.g.screenMap.findBy(screenId);
    if(builder == null) {
      throw AFException("The screen $screenId is not registered in the screen map");
    }

    final ctx = flutterContext;
    if(ctx != null) {
      material.Scaffold.of(ctx).showBottomSheet<dynamic>(
        builder,
        backgroundColor: backgroundColor,
        elevation: elevation,
        shape: shape,
        clipBehavior: clipBehavior,
      );
    } 
  }

  static void showModalBottomSheetStatic<TReturn extends Object?>({
    required dynamic dispatch(dynamic action),
    BuildContext? flutterContext,    
    required AFNavigatePushAction navigate,
    AFReturnValueDelegate<TReturn>? onReturn,
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
    final screenId = navigate.param.id as AFScreenID;
    final verifiedScreenId = _nullCheckScreenId(screenId);
    updateOptionalGlobalParam(dispatch, navigate);

    final builder = AFibF.g.screenMap.findBy(verifiedScreenId);
    if(builder == null) {
      throw AFException("The screen $screenId is not registered in the screen map");
    }

    dispatch(AFNavigateShowScreenBeginAction(verifiedScreenId, AFUIType.bottomSheet));

    final ctx = flutterContext;
    if(ctx != null) {
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

      AFibF.g.testOnlyShowUIRegisterReturn(verifiedScreenId, result);

      if(onReturn != null) {
        onReturn(result);
      }
      dispatch(AFNavigateShowScreenEndAction(verifiedScreenId));

    } else {
      // this happens in state testing, where there is no BuildContext.  We still
      // need to handle calling onReturn when someone calls closeDialog.
      AFibF.g.testOnlySimulateShowDialogOrSheet(verifiedScreenId, (val) {
        if(onReturn != null) {
          onReturn(val);
        }
        dispatch(AFNavigateShowScreenEndAction(verifiedScreenId));
      });

    }
  }

  /// Open the drawer that you specified for your [Scaffold].
  /// 
  /// You may optionally specify the optional screenId (which must match the screen id of the drawer
  /// you specified to the scaffold) and param.   The route parameter for a drawer is stored in the global
  /// pool.    The first time your drawer is shown, it will use the [param] you pass to this function, or if you omit it,
  /// then your [AFConnectedDrawer.createDefaultRouteParam]
  /// method will be called to create it the very first time the drawer is shown.  Subsequently, it will
  /// use the param you pass to this function, or if you omit it, the value that is already in the global route pool.
  void showDrawer({
    required AFNavigatePushAction navigate
  }) {
    showDrawerStatic(
      dispatch: this.dispatch,
      flutterContext: flutterContext,
      navigate: navigate
    );
  }

  static void showDrawerStatic({
    required dynamic dispatch(dynamic action),
    BuildContext? flutterContext,    
    required AFNavigatePushAction navigate
  }) {
    updateOptionalGlobalParam(dispatch, navigate);
    final ctx = flutterContext;
    // this happens in state testing, where there is no BuildContext.
    if(ctx != null) {
      final scaffold = material.Scaffold.of(ctx);
      scaffold.openDrawer();
    }
  }

  /// Open the end drawer that you specified for your [Scaffold].
  void showEndDrawer({
    required AFNavigatePushAction navigate
  }) {
    _updateOptionalGlobalParam(navigate);
    // this happens in state testing, where there is no BuildContext.
    final ctx = flutterContext;
    if(ctx != null) {
      final scaffold = material.Scaffold.of(ctx);
      scaffold.openEndDrawer();
    }
  }

  BuildContext get contextNullCheck {
    final ctx = flutterContext;
    if(ctx == null) { throw AFException("Missing build context"); }
    return ctx;
  }

  void _updateOptionalGlobalParam(AFNavigatePushAction navigate) {
    updateOptionalGlobalParam(this.dispatch, navigate);
  }

  static updateOptionalGlobalParam(dynamic Function(dynamic action) dispatch, AFNavigatePushAction navigate) {
    dispatch(AFNavigateSetParamAction(
      param: navigate.param, route: AFNavigateRoute.routeGlobalPool
    ));    
  }
}
