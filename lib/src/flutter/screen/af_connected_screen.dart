
import 'package:quiver/core.dart';
import 'package:afib/afib_dart.dart';
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/redux/actions/af_navigation_actions.dart';
import 'package:afib/src/dart/redux/state/af_state.dart';
import 'package:afib/src/dart/redux/state/af_store.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/dart/utils/af_unused.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/test/af_prototype_single_screen_screen.dart';
import 'package:afib/src/flutter/test/af_test_actions.dart';
import 'package:afib/src/flutter/utils/af_bottom_popup_layout.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:afib/src/flutter/test/af_test_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

/// Used to dispatch actions to the store, with a level of indirection
/// for testing.
abstract class AFDispatcher {
  dynamic dispatch(dynamic action);

  bool isTestAction(dynamic action) {
    var shouldPop = false;
    if(action is AFNavigatePopAction) {
      shouldPop = action.worksInPrototypeMode;
    }

    return ( shouldPop ||
             action is AFNavigateExitTestAction || 
             action is AFNavigatePopNavigatorOnlyAction ||
             action is AFNavigatePushPopupAction ||
             action is AFNavigatePopPopupAction ||
             action is AFUpdatePrototypeScreenTestDataAction || 
             action is AFPrototypeScreenTestAddError ||
             action is AFPrototypeScreenTestIncrementPassCount ||
             action is AFStartPrototypeScreenTestContextAction );
  }
}

/// The production dispatcher which dispatches actions to the store.
class AFStoreDispatcher extends AFDispatcher {

  AFStore store;
  AFStoreDispatcher(this.store);

  dynamic dispatch(dynamic action) {  
    if(AFibD.config.requiresTestData && !isTestAction(action) && action is AFActionWithKey) {
      AFibF.testOnlyRegisterRegisterAction(action);
      AFibD.logTest?.d("Registered action: $action");
    }

    return store.dispatch(action);
  }

}

/// A test dispatcher which records actions for later inspection.
class AFTestDispatcher extends AFDispatcher {
  List<dynamic> actions = <dynamic>[];

  int get actionCount {
    return actions.length;
  }

  dynamic get first {
    return actions[0];
  }

  dynamic nth(int i ) {
    return actions[i];
  } 

  void clear() {
    actions.clear();
  }

  dynamic dispatch(dynamic action) {
    actions.add(action);
    return null;
  }

}

/// Used utility class used to capture pieces of data from the
/// store and expose them to a screen.  
/// 
/// This allows screens to be populated with data without ever
/// having a store in tests.
@immutable
class AFStoreConnectorData<TV1, TV2, TV3, TV4> {
  final TV1 first;
  final TV2 second;
  final TV3 third;
  final TV4 fourth;

  AFStoreConnectorData({this.first, this.second, this.third, this.fourth});

  /// Because store connector data is always recreated, it is 
  /// important to implement deep equality so that the screen won't be re-rendered
  /// each time if the data has not changed.
  bool operator==(dynamic o) {
    final result = (o is AFStoreConnectorData<TV1, TV2, TV3, TV4> && first == o.first && second == o.second && third == o.third && fourth == o.fourth);
    return result;
  }

  int get hashCode {
    return hash4(first.hashCode, second.hashCode, third.hashCode, fourth.hashCode);
  }

}

@immutable
class AFStoreConnectorDataExtended<TV1, TV2, TV3, TV4, TV5, TV6, TV7, TV8> extends AFStoreConnectorData<TV1, TV2, TV3, TV4> {
  final TV5 fifth;
  final TV6 sixth;
  final TV7 seventh;
  final TV8 eighth;

  AFStoreConnectorDataExtended({TV1 first, TV2 second, TV3 third, TV4 fourth, this.fifth, this.sixth, this.seventh, this.eighth}):
    super(first: first, second: second, third: third, fourth: fourth);

  bool operator==(dynamic o) {
    final result = (o is AFStoreConnectorDataExtended<TV1, TV2, TV3, TV4, TV5, TV6, TV7, TV8> 
      && first == o.first && second == o.second && third == o.third && fourth == o.fourth
      && fifth == o.fifth && sixth == o.sixth && seventh == o.seventh && eighth == o.eighth);
    return result;
  }

  int get hashCode {
    final start = super.hashCode;
    final next = hash4(fifth?.hashCode, sixth?.hashCode, seventh?.hashCode, eighth?.hashCode);
    return hash2(start, next);
  }
}

/// Use this if you don't use any data from the store to render your screen.
@immutable 
class AFStoreConnectorDataUnused extends AFStoreConnectorData<AFUnused, AFUnused, AFUnused, AFUnused> {
  AFStoreConnectorDataUnused({AFDispatcher dispatcher, AFRouteParam param}): super();
}

/// Use this version of [AFStoreConnectorData] if you only need one piece of data from the store.
@immutable 
class AFStoreConnectorData1<TV1> extends AFStoreConnectorData<TV1, AFUnused, AFUnused, AFUnused> {
  AFStoreConnectorData1({AFDispatcher dispatcher, AFRouteParam param, TV1 first}): super(first: first);
}

/// Use this version of [AFStoreConnectorData] if you need two pieces of data from the store.
@immutable 
class AFStoreConnectorData2<TV1, TV2> extends AFStoreConnectorData<TV1, TV2, AFUnused, AFUnused> {
  AFStoreConnectorData2({AFDispatcher dispatcher, AFRouteParam param, TV1 first, TV2 second}): super(first: first, second: second);
}

/// Use this version of [AFStoreConnectorData] if you need three pieces of data from the store.
@immutable 
class AFStoreConnectorData3<TV1, TV2, TV3> extends AFStoreConnectorData<TV1, TV2, TV3, AFUnused> {
  AFStoreConnectorData3({AFDispatcher dispatcher, AFRouteParam param, TV1 first, TV2 second, TV3 third}): super(first: first, second: second, third: third);
}

/// Use this version of [AFStoreConnectorData] if you need four pieces of data from the store.
@immutable 
class AFStoreConnectorData4<TV1, TV2, TV3, TV4> extends AFStoreConnectorData<TV1, TV2, TV3, TV4> {
  AFStoreConnectorData4({TV1 first, TV2 second, TV3 third, TV4 fourth}): super(first: first, second: second, third: third, fourth: fourth);
}

/// User this version of [AFStoreConnectorDataExtended] if you need five pieces of data from the store.
class AFStoreConnectorData5<TV1, TV2, TV3, TV4, TV5> extends AFStoreConnectorDataExtended<TV1, TV2, TV3, TV4, TV5, AFUnused, AFUnused, AFUnused> {
  AFStoreConnectorData5({TV1 first, TV2 second, TV3 third, TV4 fourth, TV5 fifth}): super(first: first, second: second, third: third, fourth: fourth, fifth: fifth);

}

class AFStoreConnectorData6<TV1, TV2, TV3, TV4, TV5, TV6> extends AFStoreConnectorDataExtended<TV1, TV2, TV3, TV4, TV5, TV6, AFUnused, AFUnused> {
  AFStoreConnectorData6({TV1 first, TV2 second, TV3 third, TV4 fourth, TV5 fifth, TV6 sixth}): super(first: first, second: second, third: third, fourth: fourth, fifth: fifth, sixth: sixth);
}

class AFStoreConnectorData7<TV1, TV2, TV3, TV4, TV5, TV6, TV7> extends AFStoreConnectorDataExtended<TV1, TV2, TV3, TV4, TV5, TV6, TV7, AFUnused> {
  AFStoreConnectorData7({TV1 first, TV2 second, TV3 third, TV4 fourth, TV5 fifth, TV6 sixth, TV7 seventh}): super(first: first, second: second, third: third, fourth: fourth, fifth: fifth, sixth: sixth, seventh: seventh);
}

class AFStoreConnectorData8<TV1, TV2, TV3, TV4, TV5, TV6, TV7, TV8> extends AFStoreConnectorDataExtended<TV1, TV2, TV3, TV4, TV5, TV6, TV7, TV8> {
  AFStoreConnectorData8({TV1 first, TV2 second, TV3 third, TV4 fourth, TV5 fifth, TV6 sixth, TV7 seventh, TV8 eighth}): super(first: first, second: second, third: third, fourth: fourth, fifth: fifth, sixth: sixth, seventh: seventh, eighth: eighth);
}

/// This common superclass makes it possible to treat all afib Widgets/screens
/// similarly for testing and prototyping purposes.
abstract class AFBuildableWidget<TData extends AFStoreConnectorData, TRouteParam extends AFRouteParam> extends StatelessWidget {
  AFBuildableWidget({Key key}): super(key: key);


    /// Builds a Widget using the data extracted from the state.
  Widget buildWithContext(AFBuildContext<TData, TRouteParam> context);

  /// Wrap all four pieces of data needed during a build in a single utility object.
  AFBuildContext createContext(BuildContext context, AFDispatcher dispatcher, TData data, TRouteParam param) {
    return AFBuildContext<TData, TRouteParam>(context, dispatcher, data, param);
  }
}

/// A screen that uses data from the store but not from the route.
abstract class AFConnectedWidgetBase<TState, TData extends AFStoreConnectorData, TRouteParam extends AFRouteParam> extends AFBuildableWidget<TData, TRouteParam> {
  //--------------------------------------------------------------------------------------
  AFConnectedWidgetBase({Key key}): super(key: key);

  //--------------------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AFState, AFBuildContext>(
        converter: (store) {
          final context = _createNonBuildContext(store);
          return context;
        },
        distinct: true,
        onInit: (store) {
          final context = _createNonBuildContext(store);
          onInit(context);
        },
        onDispose: (store) {
          final context = _createNonBuildContext(store);
          onDispose(context);
        },
        builder: (buildContext, dataContext) {
          if(dataContext == null) {
            return CircularProgressIndicator();
          }

          var screenIdRegister = this.screenIdForTest;          
          if(screenIdRegister != null) {
            if(dataContext.p != null && dataContext.p is AFPrototypeSingleScreenRouteParam) {
              screenIdRegister = dataContext.p.effectiveScreenId;
            }
            
            AFibF.registerTestScreen(screenIdRegister, buildContext);
            AFibD.logTest?.d("Rebuilding screen $runtimeType/$screenIdRegister with param ${dataContext.p}");
          }
          final withContext = createContext(buildContext, dataContext.d, dataContext.s, dataContext.p);
          return buildWithContext(withContext);
        }
    );
  }

  /// Screens that have their own element tree in testing must return their screen id here,
  /// otherwise return null.
  AFScreenID get screenIdForTest;

  AFBuildContext<TData, TRouteParam> _createNonBuildContext(AFStore store) {
    final data = createStateDataAF(store.state);
    final param = findParam(store.state);
    final context = createContext(null, createDispatcher(store), data, param);
    return context;
  }

  AFDispatcher createDispatcher(AFStore store) {
    return AFStoreDispatcher(store);
  }

  /// Find the route param for this screen. 
  AFRouteParam findParam(AFState state) { return null; }

  TData createStateDataAF(AFState state) {
    return createStateData(state.app);
  }

  /// Override this to create an [AFStoreConnectorData] with the required data from the state.
  TData createStateData(TState state);

  /// Builds a Widget using the data extracted from the state.
  Widget buildWithContext(AFBuildContext<TData, TRouteParam> context);

  /// Override this to perform screen specific initialization.
  void onInit(AFBuildContext<TData, TRouteParam> context) {}

  /// Override this to perform screen specific cleanup.
  void onDispose(AFBuildContext<TData, TRouteParam> context) {} 

  /// Called to update the route parameter and re-render the screen.
  /// 
  /// It is strange to have a route-parameter method here (in a AFConnectedScreenWithoutRoute).
  /// However, subclasses of this like [AFPopupScreen] and [AFConnectedWidgetWithParam] have
  /// the ability to reference/update the AFRouteParam of their parent screen.
  /// This is here to create a single consistent mechanism for performing updates
  /// even in cases where that specific widget does not have its own route entry.
  void updateParamD(AFDispatcher dispatcher, TRouteParam revised, { AFID id });

  /// Like [updateParamD], but takes a build context
  /// rather than a dispatcher for convenience.
  void updateParam(AFBuildContext context,TRouteParam revised, { AFID id }) {
    return updateParamD(context.dispatcher, revised, id: id);
  }

}

/// Superclass for a screen Widget, which combined data from the store with data from
/// the route in order to render itself.
abstract class AFConnectedScreen<TState, TData extends AFStoreConnectorData, TRouteParam extends AFRouteParam> extends AFConnectedWidgetBase<TState, TData, TRouteParam> {
  final AFScreenID screenId;
  AFConnectedScreen(this.screenId, { Key key }): super(key: key)
  ;

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
  ///   updateParam(screenData, revisedParam);
  void updateParamD(AFDispatcher dispatcher, TRouteParam revised, { AFID id }) {
    dispatcher.dispatch(AFNavigateSetParamAction(
      id: id,
      screen: this.screenId, 
      param: revised)
    );
  }

  /// Utility method which updates the parameter, but takes a build context
  /// rather than a dispatcher for convenience
  void updateParam(AFBuildContext context,TRouteParam revised, { AFID id }) {
    return updateParamD(context.dispatcher, revised, id: id);
  }

  /// Find the route parameter for the specified named screen
  AFRouteParam findParam(AFState state) {
    return state.route?.findParamFor(this.screenId, includePrior: true);
  }
}

/// Use this to connect a Widget to the store.  
/// 
/// The Widget can still have a route parameter, but it must be passed in
/// from the parent screen that the Widget is created by.
abstract class AFConnectedWidgetWithParam<TState, TData extends AFStoreConnectorData, TRouteParam extends AFRouteParam> extends AFConnectedWidgetBase<TState, TData, TRouteParam> {
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
  TData createStateData(TState state) {
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
  void updateParamD(AFDispatcher dispatcher, TRouteParam revised, { AFID id }) {
    updateParamDelegate(dispatcher, revised, id: id);
  }

}


/// Just like an [AFConnectedScreen], except it is typically displayed as 
/// a modal overlay on top of an existing screen, and launched using a custom 
/// AFPopupRoute
abstract class AFPopupScreen<TState, TData extends AFStoreConnectorData, TRouteParam extends AFRouteParam> extends AFConnectedScreen<TState, TData, TRouteParam> {
  final Animation<double> animation;
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
    return state.route?.findPopupParamFor(this.screenId);
  }

  TData createStateData(TState state) {
    return this.createDataDelegate(state);
  }

  void updateParamD(AFDispatcher dispatcher, TRouteParam revised, { AFID id }) {
    dispatcher.dispatch(AFNavigateSetPopupParamAction(
      id: id,
      screen: this.screenId, 
      param: revised)
    );
  }

  @override
  Widget buildWithContext(AFBuildContext<TData, TRouteParam> context) {
    return buildPopupAnimation(context);
  }

  Widget buildPopupAnimation(AFBuildContext<TData, TRouteParam> context) {
    return GestureDetector(
      onTap: () {
        AFibD.log?.d("OnTapGestureDetector");
      },
      child: AnimatedBuilder(
        animation: animation,
        builder: (ctx, child) {
          final local = AFBuildContext<TData, TRouteParam>(ctx, context.d, context.s, context.p);
          final bottomPadding = MediaQuery.of(local.c).padding.bottom;
          return ClipRect(
            child: CustomSingleChildLayout(
              delegate: AFBottomPopupLayout(animation.value, theme, bottomPadding: bottomPadding),
              child: GestureDetector(
                child: Material(
                  color: theme.backgroundColor ?? Colors.white,
                  child: buildPopupContents(local, theme),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildPopupContents(AFBuildContext<TData, TRouteParam> context, AFBottomPopupTheme theme);

}

/// Use this to connect a drawer to the store.
/// 
/// Drawers are special because the user can drag in from the left or right to open them.
/// You cannot trust that you used an [AFNavigatePush] action to open the drawer.  Consequently,
/// you should only rely on information in your [AFAppState] to render your drawers, and perhaps
/// the full state of the route ()
abstract class AFConnectedDrawer<TState, TData extends AFStoreConnectorData, TRouteParam extends AFRouteParam> extends AFConnectedWidgetWithParam<TState, TData, TRouteParam> {
  final AFScreenID screenId;

  AFConnectedDrawer({
    @required this.screenId,
    @required AFDispatcher dispatcher,
    @required AFUpdateParamDelegate<TRouteParam> updateParamDelegate,
    @required AFExtractParamDelegate extractParamDelegate,
    @required AFCreateDataDelegate createDataDelegate,
    @required AFFindParamDelegate findParamDelegate,
  }): super(
    dispatcher: dispatcher,
    updateParamDelegate: updateParamDelegate,
    extractParamDelegate: extractParamDelegate,
    createDataDelegate: createDataDelegate,
    findParamDelegate: findParamDelegate
  );

  AFScreenID get screenIdForTest {
    return screenId;
  }

}

/// A utility class which you can use when you have a complex screen which passes the dispatcher,
/// screen data and param to many functions, to make things more concise.  
/// 
/// The framework cannot pass you this itself because 
class AFBuildContext<TData extends AFStoreConnectorData, TRouteParam extends AFRouteParam> {
  BuildContext context;
  AFDispatcher dispatcher;
  TData storeData;
  TRouteParam param;
  AFScreenPrototypeTest screenTest;

  AFBuildContext(this.context, this.dispatcher, this.storeData, this.param);

  /// Shorthand for accessing the route param.
  TRouteParam get p { return param; }

  /// Shorthand for accessing data from the store
  TData get s { return storeData; }

  /// Shorthand for accessing the dispatcher
  AFDispatcher get d { return dispatcher; }

  /// Shorthand for accessing the flutter build context
  BuildContext get c { return context; }
  void dispatch(dynamic action) { dispatcher.dispatch(action); }

  bool operator==(dynamic o) {
    final result = (o is AFBuildContext<TData, TRouteParam> && param == o.param && storeData == o.storeData);
    return result;
  }

  int get hashCode {
    return hash2(param.hashCode, storeData.hashCode);
  }

  Widget createDebugDrawer() {
    final store = AFibF.testOnlyStore;
    final state = store.state;
    final testState = state.testState;
    if(testState.activeTestId != null) {
      return AFTestDrawer(
        dispatcher: dispatcher,
      );
    }
    return null;
  }


}

