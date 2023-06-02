import 'dart:async';

import 'package:afib/afib_command.dart';
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/flutter/ui/dialog/afui_standard_notification.dart';
import 'package:afib/src/flutter/ui/screen/afui_demo_mode_transition_screen.dart';
import 'package:afib/src/flutter/ui/screen/afui_prototype_loading_screen.dart';
import 'package:afib/src/flutter/ui/stateviews/afui_default_state_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
import 'package:overlay_support/overlay_support.dart';

abstract class AFExecuteBeforeInterface {
  AFAsyncQuery? get executeBefore;
}

abstract class AFExecuteDuringInterface {
  AFAsyncQuery? get executeDuring;
}


mixin AFNonUIAPIContextMixin implements AFDispatcher {

  AFDispatcher get dispatcher;

  void dispatch(dynamic action) {
    dispatcher.dispatch(action);
  }

  /// Dispatches an action that updates the route parameter for the specified screen.
  void updateHierarchyRouteParam(AFRouteParam param) {
    dispatch(AFNavigateSetParamAction(param: param));
  }

  void updateGlobalRouteParam(AFRouteParam param) {
    dispatch(AFNavigateSetParamAction(param: param));
  }

  void executeStartTimeListenerQuery(AFTimeState baseTime) {
    dispatch(AFTimeUpdateListenerQuery(baseTime: baseTime));
  }

  /// Dispatches an action that updates the route parameter for the specified screen.
  void updateRouteParam(AFRouteParam param) {
    dispatch(AFNavigateSetParamAction(
      param: param, 
    ));
  }
}

mixin AFAccessStateSynchronouslyMixin {

  //-------------------------------------------------------------------------------------
  // access...
  //-------------------------------------------------------------------------------------
  AFPublicState get accessPublicState {
    return AFibF.g.internalOnlyActiveStore.state.public;
  }

  AFTimeState get accessCurrentTime {
    return accessPublicState.time;    
  }

  AFAppPlatformInfoState get accessPlatformInfo {
    return accessPublicState.appPlatformInfo;
  }

  TState accessComponentState<TState extends AFComponentState>() {
    final result = accessPublicState.components.findState<TState>();
    return result!;
  }

  AFRouteSegment? accessScreenRouteSegment(AFScreenID screen, {
    AFRouteLocation routeLocation = AFRouteLocation.screenHierarchy,
  }) {
    return accessPublicState.route.findRouteParamFull(
      screenId: screen,
      wid: AFUIWidgetID.useScreenParam,
      routeLocation: routeLocation
    );
  }

  AFRouteSegment? accessRouteParamSegment(AFRouteParamRef ref) {
    return accessPublicState.route.findRouteParamFull(
      screenId: ref.screenId,
      wid: ref.wid,
      routeLocation: ref.routeLocation
    );
  }

  TRouteParam? accessRouteParam<TRouteParam extends AFRouteParam>(AFRouteParamRef ref) {
    final seg = accessRouteParamSegment(ref);
    return seg?.param as TRouteParam?;
  }

  /*  
  TRouteParam? accessWidgetRouteParam<TRouteParam extends AFRouteParam>(AFScreenID screen, AFWidgetID child, {
    AFRouteLocation routeLocation = AFRouteLocation.screenHierarchy,
  }) {
    final seg = accessScreenRouteSegment(screen, routeLocation: routeLocation);
    final result = seg?.children?.findParamById(child);
    return result as TRouteParam?;
  }
  */

  /// Expectes to find exactly ione param of the specified type.
  /// 
  /// Searches the active screen in the hierarchy, the children of that screen, and any currently
  /// showing UIs (dialogs, etc)
  TRouteParam? accessActiveRouteParamOfType<TRouteParam extends AFRouteParam>({
    AFRouteLocation routeLocation = AFRouteLocation.screenHierarchy
  }) {
    final found = accessActiveRouteParamsOfType<TRouteParam>(routeLocation: routeLocation);
    assert(found.length < 2);
    if(found.isEmpty) {
      return null;
    }
    return found.first;
  }

  /// Find all route params that have the specified type.
  /// 
  /// Searches the active screen in the hierarchy, the children of that screen, and any currently
  /// showing UIs (dialogs, etc)
  List<TRouteParam> accessActiveRouteParamsOfType<TRouteParam extends AFRouteParam>({
    AFRouteLocation routeLocation = AFRouteLocation.screenHierarchy
  }) {
    final route = accessPublicState.route;
    final activeScreenId = route.activeScreenId;
    final routeSeg = route.findRouteParamFull(
      screenId: activeScreenId,
      routeLocation: routeLocation,
      wid: AFUIWidgetID.useScreenParam
    );
    final result = <TRouteParam>[];
    final screenParam = routeSeg?.param;
    if(screenParam is TRouteParam) {
      result.add(screenParam);
    }

    final children = routeSeg?.children;
    if(children != null) {
      for(final childSeg in children.values) {
        final childParam = childSeg.param;
        if(childParam is TRouteParam) {
          result.add(childParam);
        }
      }
    }

    for(final showingScreen in route.showingScreens.values) {
      final screenId = showingScreen.screenId;
      final screenSeg = route.findGlobalParam(screenId);
      final showParam = screenSeg?.param;
      if(showParam is TRouteParam) {
        result.add(showParam);
      }
    }

    return result;
  }


  TRouteParam? accessGlobalRouteParam<TRouteParam>(AFID id) {
    final seg = accessPublicState.route.findGlobalParam(id);
    final param = seg?.param as TRouteParam?;
    return param;
  }

}

mixin AFStandardNavigateMixin implements AFDispatcher {
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
}

mixin AFStandardAPIContextMixin implements AFDispatcher {

  AFDispatcher get dispatcher;
  AFConceptualStore get targetStore;

  void dispatch(dynamic action) {
    dispatcher.dispatch(action);
  }

  TLPI accessLPI<TLPI extends AFLibraryProgrammingInterface>(AFLibraryProgrammingInterfaceID id) {
    final lpi = AFibF.g.createLPI(id, dispatcher, targetStore);
    return lpi as TLPI;
  } 

  Stream<AFPublicStateChange> get accessStreamPublicStateChanges {
    return AFibF.g.activeStageChangeStream;
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
    final context = AFCurrentStateContext(
      dispatcher: this,
      targetStore: targetStore,
    );
    delegate(context);
  }

  AFPublicState get _publicState {
    return AFibF.g.internalOnlyActiveStore.state.public;
  }

  AFScreenID get accessActiveScreenId {
    return _publicState.route.activeScreenId;
  }

  //-------------------------------------------------------------------------------------
  // update...
  //-------------------------------------------------------------------------------------

  /// Dispatches an action that updates a single value in the app state area associated
  /// with the [TState] type parameter.
  void updateComponentRootStateOne<TState extends AFComponentState>(Object toIntegrate) {
    assert(TState != AFComponentState, "You must specify a state type as a type parameter");
    dispatch(AFUpdateAppStateAction(area: TState, toIntegrate: [toIntegrate]));
  }

  /// Dispatches an action that updates several blaues in the app state area associated
  /// with the [TState] type parameter.
  void updateComponentRootStateMany<TState extends AFComponentState>(List<Object> toIntegrate) {
    assert(TState != AFComponentState, "You must specify a state type as a type parameter");
    dispatch(AFUpdateAppStateAction(area: TState, toIntegrate: toIntegrate));
  }

  //-------------------------------------------------------------------------------------
  // navigate...
  //-------------------------------------------------------------------------------------


  /// A utility which dispatches an asynchronous query.
  void executeQuery(AFAsyncQuery query) {
    dispatch(query);
  }

  /// Shuts down all existing listener and deferred queries.   Often called
  /// as part of a signout process.
  void executeShutdownAllActiveQueries() {
    dispatch(AFShutdownOngoingQueriesAction());
  }

  void executeShutdownListenerQuery<TQuery extends AFAsyncListenerQuery>({ AFID? id }) {
    assert(TQuery != AFAsyncListenerQuery);
    dispatch(AFShutdownListenerQueryAction(AFObjectWithKey.toKey(TQuery, id)));
  }


  void executeDeferredCallback(AFID uniqueQueryId, Duration duration, AFOnResponseDelegate<AFUnused> callback) {
    dispatch(AFDeferredSuccessQuery(uniqueQueryId, duration, callback));
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

  void executePeriodicQuery(AFPeriodicQuery query) {
    dispatch(query);
  }

  void executeCompositeQuery(AFCompositeQuery query) {
    dispatch(query);
  }

  void executeIsolateListenerQuery(AFIsolateListenerQuery query) {
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

  bool get isDemoMode {
    return AFibF.g.isDemoMode;
  }

  void executeExitDemoMode({
    required AFMergePublicStateDelegate mergePublicState,
  }) {
    // first, navigate to the entering/leaving demo model page.

    // NOTE: this query was started in standard app mode, and so is linked to the standard app store.
    // however, in this case, we need to manipualate the state in the demo app store.  So, we need to 
    // explicitly dispatch our nav into that store.
    final demoDispatcher = AFibF.g.internalOnlyDispatcher(AFConceptualStore.demoModeStore);
    demoDispatcher.dispatch(AFUIDemoModeExitScreen.navigatePush().castToReplaceAll());
    
    // wait for all navigation to complete, so that you don't have animations trying to 
    // reference screens that existed prior to demo-mode, then:
    
    // Note: you cannot use executeDeferredCallback here, because in prototype mode it doesn't actually delay, 
    // and we really need to delay and wait for the screen to render, even in prototype mode.
    Timer(Duration(seconds: 1), () { 
      AFibF.g.swapActiveAndBackgroundStores(
        mergePublicState: (source, dest) {
          var revised = mergePublicState(source, dest);
          var origRoute = AFibF.g.preDemoModeRoute;
          revised = revised.reviseRoute(origRoute!);
          return revised;
        }
      );

      AFibF.g.demoModeTest = null;        
      AFibF.g.setActiveStore(AFConceptualStore.appStore);

      assert(AFibF.g.internalOnlyActiveStore.state.public.conceptualStore == AFConceptualStore.appStore);


      final route = AFibF.g.internalOnlyActiveStore.state.public.route;
      AFibF.g.internalOnlyActiveDispatcher.dispatch(AFNavigateSyncNavigatorStateWithRoute(route));
    });    
  }

  void executeEnterDemoMode({
    required AFStateTestID stateTestId,
    required AFMergePublicStateDelegate mergePublicState,
  }) async {

    // save the route state prior to moving to the transition screen.
    final route = AFibF.g.internalOnlyActiveStore.state.public.route;
    AFibF.g.setPreDemoModeRoute(route);

    // first, navigate to the entering/leaving demo model page.
    AFibF.g.internalOnlyDispatcher(AFConceptualStore.appStore).dispatch(AFUIDemoModeEnterScreen.navigatePush().castToReplaceAll());
    
    // wait for all navigation to complete, so that you don't have animations trying to 
    // reference screens that existed prior to demo-mode, then:
    
    // Note: you cannot use executeDeferredCallback here, because in prototype mode it doesn't actually delay, 
    // and we really need to delay and wait for the screen to render, even in prototype mode.
    Timer(Duration(seconds: 1), () { 
      
      // restore the demo mode store to its initial state.
      final demoDispatcher = AFibF.g.internalOnlyDispatcher(AFConceptualStore.demoModeStore);
      demoDispatcher.dispatch(AFResetToInitialStateAction());
                  
      AFibF.g.setActiveStore(AFConceptualStore.demoModeStore);

      // build the test data.
      final globalState = AFibGlobalState(
        appContext: AFibF.context,
        activeConceptualStore: AFConceptualStore.demoModeStore
      );
      globalState.initializeForDemoMode();

      // find the desired state test.
      final test = globalState.stateTests.findById(stateTestId);

      // build that state test only.
      final testContext = AFStateTestContextForState(
        test as AFStateTest, 
        AFConceptualStore.demoModeStore,
        isTrueTestContext: true
      );

      // this both generates the state, and configures all the query overrides, 
      test.execute(testContext);

      // allow them to merge down any parts of the state that they wish to preserve from the real
      // app (for example, the help state.)
      AFibF.g.swapActiveAndBackgroundStores(
        mergePublicState: mergePublicState
      );

      assert(AFibF.g.internalOnlyActive.store!.state.public.conceptualStore == AFConceptualStore.demoModeStore);

      // this puts AFib into a mode where queries are routed through the state test's spoofed queries
      // instead of through the true query handling mechanism.
      //testContext.setTarget(AFTargetStore.uiStore);
      AFibF.g.demoModeTest = testContext;        
      
      // now, you have the desired state, but you don't want to install all of it, so
      // now, go ahead and synchronize 
      final route = AFibF.g.internalOnlyActiveStore.state.public.route;
      AFibF.g.internalOnlyActiveDispatcher.dispatch(AFNavigateSyncNavigatorStateWithRoute(route));
    });  
  }  

}

mixin AFContextShowMixin {
  
  AFDispatcher get dispatcher;

  BuildContext? get flutterContext {
    return AFibF.g.currentFlutterContext;
  }
  
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
    material.RouteSettings? routeSettings,
    AFAsyncQuery? executeBefore,
    AFAsyncQuery? executeDuring,
  }) async {
    showDialogStatic<TReturn>(
      flutterContext: flutterContext,
      dispatch: this.dispatch,
      navigate: navigate,
      onReturn: onReturn,
      executeBefore: executeBefore,
      executeDuring: executeDuring,
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
    required AFAsyncQuery? executeBefore,
    required AFAsyncQuery? executeDuring,
    AFReturnValueDelegate<TReturn>? onReturn,
    bool barrierDismissible = true,
    material.Color? barrierColor,
    bool useSafeArea = true,
    bool useRootNavigator = true,
    material.RouteSettings? routeSettings
  }) async {
    final screenId = navigate.param.screenId;
    final verifiedScreenId = _nullCheckScreenId(screenId);
    updateOptionalGlobalParam(dispatch, navigate);

    final builder = AFibF.g.screenMap.findBy(verifiedScreenId);
    if(builder == null) {
      throw AFException("The screen $screenId is not registered in the screen map");
    }

    dispatch(AFNavigateShowScreenBeginAction(verifiedScreenId, AFUIType.dialog, executeBefore, executeDuring));

    if(AFibD.config.isTestContext) {
       // Ugg, so the issue here is that flutter handles return values from a dialog,
       // but it does the processing asynchronously.   I couldn't figure out how to 
       // wait for the return value to be processed at the time you are closing the 
       // dialog with Flutter's navigator (see AFBuildContext.closeDialog).  So, 
       // in test contexts we always follow this path for handling return values
       // synchronously, and then below we need to ingore the result in the test context,
       // because we are handling it here.
       AFibF.g.testOnlySimulateShowDialogOrSheet<TReturn>(verifiedScreenId, (val) {
        AFibF.g.testOnlyShowUIRegisterReturn(verifiedScreenId, val);
        if(onReturn != null) {
          onReturn(val);
        }
        dispatch(AFNavigateShowScreenEndAction(verifiedScreenId));
       });
    }

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
      final notTestContext = !AFibD.config.isTestContext;
      if(onReturn != null && notTestContext) {
        onReturn(result);
      }

      if(notTestContext) {
        dispatch(AFNavigateShowScreenEndAction(verifiedScreenId));
      }
    } 

  }

  void showDialogInfoText({
    required Object themeOrId,
    required Object title,
    Object? body,
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
    required Object title,
    Object? body,
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
    required Object title,
    Object? body,
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
      final themes = AFibF.g.internalOnlyActiveStore.state.public.themes;
      final fundamentals = themes.fundamentals;
      final standard = AFStandardBuildContextData(
        screenId: AFUIScreenID.screenPrototypeLoading, 
        context: AFibF.g.currentFlutterContext, 
        dispatcher: dispatcher, 
        config: AFPrototypeLoadingScreen.config, 
        themes: themes);

      final context = AFBuildContext<AFFlexibleStateView, AFRouteParamUnused>(
        standard,
        AFUIDefaultStateView.create(<String, Object>{}),
        AFRouteParamUnused.unused,
        null,
      );
      theme = AFibF.g.coreDefinitions.createFunctionalTheme(themeOrId, fundamentals, context);
    } 

    if(theme == null) {
      throw AFException("You must specify either an AFFunctionalTheme or an AFThemeID");
    }    
    return theme;
  }

  void showDialogChoiceText({
    required Object themeOrId,
    AFUIStandardChoiceDialogIcon icon = AFUIStandardChoiceDialogIcon.question,
    required Object title,
    Object? body,
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
    Object? actionText,
    Color? colorBackground,
    Color? colorForeground,
    required Object title,
    Object? body,
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
  void showSnackbarText({ 
    required Object themeOrId,
    required Object text, 
    Duration duration = const Duration(seconds: 2)
  }) {
    var themeActual = _findTheme(themeOrId);        
    final ctx = flutterContext;
    if(ctx != null) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: themeActual.childText(text: text), 
        duration: duration
      ));
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
    AFAsyncQuery? executeBefore,
    AFAsyncQuery? executeDuring,
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
      executeBefore: executeBefore,
      executeDuring: executeDuring,
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
    required AFAsyncQuery? executeBefore,
    required AFAsyncQuery? executeDuring,
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
    final screenId = navigate.param.screenId;
    final verifiedScreenId = _nullCheckScreenId(screenId);
    updateOptionalGlobalParam(dispatch, navigate);

    final builder = AFibF.g.screenMap.findBy(verifiedScreenId);
    if(builder == null) {
      throw AFException("The screen $screenId is not registered in the screen map");
    }

    dispatch(AFNavigateShowScreenBeginAction(verifiedScreenId, AFUIType.bottomSheet, executeBefore, executeDuring));

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
  /// then your [AFDrawerConfig.createDefaultRouteParam]
  /// method will be called to create it the very first time the drawer is shown.  Subsequently, it will
  /// use the param you pass to this function, or if you omit it, the value that is already in the global route pool.  
  /// 
  void showLeftSideDrawer({
    AFNavigatePushAction? navigate
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
    AFNavigatePushAction? navigate
  }) {
    if(navigate != null) {
      updateOptionalGlobalParam(dispatch, navigate);
    }
    final ctx = flutterContext;
    // this happens in state testing, where there is no BuildContext.
    if(ctx != null) {
      final scaffold = material.Scaffold.of(ctx);
      scaffold.openDrawer();
    }
  }

  /// Open the end drawer that you specified for your [Scaffold].
  void showRightSideDrawer({
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

  static void updateOptionalGlobalParam(dynamic Function(dynamic action) dispatch, AFNavigatePushAction navigate) {
    dispatch(AFNavigateSetParamAction(
      param: navigate.param,
      children: navigate.children,
      createDefaultChildParam: navigate.createDefaultChildParam,
    ));    
  }
}
