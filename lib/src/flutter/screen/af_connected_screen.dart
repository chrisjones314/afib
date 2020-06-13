
import 'package:afib/src/dart/redux/actions/af_navigation_actions.dart';
import 'package:afib/src/dart/redux/state/af_state.dart';
import 'package:afib/src/dart/redux/state/af_store.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/dart/utils/af_unused.dart';
import 'package:afib/src/flutter/af.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:afib/src/flutter/test/af_test_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

/// Used to dispatch actions to the store, with a level of indirection
/// for testing.
abstract class AFDispatcher {
  dynamic dispatch(dynamic action);
}

/// The production dispatcher which dispatches actions to the store.
class AFStoreDispatcher extends AFDispatcher {

  AFStore store;
  AFStoreDispatcher(this.store);

  dynamic dispatch(dynamic action) {
    return store.dispatch(action);
  }
}

/// A test dispatcher which records actions for later inspection.
class AFTestDispatcher extends AFDispatcher {
  List<dynamic> actions = List<dynamic>();

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
  bool operator==(o) {
    bool result = (o is AFStoreConnectorData<TV1, TV2, TV3, TV4> && first == o.first && second == o.second && third == o.third && fourth == o.fourth);
    return result;
  }

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

/// This common superclass makes it possible to treat all afib Widgets/screens
/// similarly for testing and prototyping purposes.
abstract class AFBuildableWidget<TData extends AFStoreConnectorData, TRouteParam extends AFRouteParam> extends StatelessWidget {
    /// Builds a Widget using the data extracted from the state.
  Widget buildWithContext(AFBuildContext<TData, TRouteParam> context);

  /// Wrap all four pieces of data needed during a build in a single utility object.
  AFBuildContext createContext(BuildContext context, AFDispatcher dispatcher, TData data, TRouteParam param) {
    return AFBuildContext<TData, TRouteParam>(context, dispatcher, data, param);
  }
}

/// A screen that uses data from the store but not from the route.
abstract class AFConnectedScreenWithoutRoute<TState, TData extends AFStoreConnectorData, TRouteParam extends AFRouteParam> extends AFBuildableWidget<TData, TRouteParam> {
  final AFScreenID screen;

  //--------------------------------------------------------------------------------------
  AFConnectedScreenWithoutRoute(this.screen);

  //--------------------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AFState, AFBuildContext>(
        converter: (store) => createContext(null, AFStoreDispatcher(store), createDataAF(store.state), findParam(store.state)),
        distinct: true,
        ignoreChange: (AFState state) {
          return shouldIgnoreChangeAF(state);
        },
        onInit: (store) {
          final data = createDataAF(store.state);
          onInit(data);
        },
        onDispose: (store) {
          onDispose(store.state.app);
        },
        builder: (buildContext, dataContext) {
          if(dataContext == null) {
            return CircularProgressIndicator();
          }
          if(!(this is AFTestDrawer)) {
            AF.testOnlyScreenElement = buildContext;
            AF.testOnlyScreenUpdateCount++;
          }
          AF.internal?.fine("Rebuilding screen $screen with updateCount ${AF.testOnlyScreenUpdateCount}");
          final withContext = createContext(buildContext, dataContext.d, dataContext.s, dataContext.p);
          return buildWithContext(withContext);
        }
    );
  }

  /// Find the route param for this screen. 
  AFRouteParam findParam(AFState state) { return null; }

  TData createDataAF(AFState state) {
    return createData(state.app);
  }

  /// Override this to create an [AFStoreConnectorData] with the required data from the state.
  TData createData(TState state);

  /// Builds a Widget using the data extracted from the state.
  Widget buildWithContext(AFBuildContext<TData, TRouteParam> context);

  /// If you are looking to customize this behavior, override [shouldIngoreChange] instead.
  bool shouldIgnoreChangeAF(AFState state) { 
    return shouldIgnoreChange(state.app);
  }

  /// Override this method if you want to prevent re-rendering under certain states.
  bool shouldIgnoreChange(TState state) {
    return false;
  }

  /// Override this to perform screen specific initialization.
  void onInit(TData data) {}

  /// Override this to perform screen specific cleanup.
  void onDispose(TState state) {} 

}

/// Superclass for a screen Widget, which combined data from the store with data from
/// the route in order to render itself.
abstract class AFConnectedScreen<TState, TData extends AFStoreConnectorData, TRouteParam extends AFRouteParam> extends AFConnectedScreenWithoutRoute<TState, TData, TRouteParam> {
  AFConnectedScreen(AFScreenID screen): super(screen);

  /// Utility for updating the route parameter for this screen.
  /// 
  /// Your route parameter should contain the data that your screen is editing.
  /// When a user action causes data on the screen, you will typically do 
  /// something like:
  /// 
  /// ### Example
  ///   final revisedParam = screenData.param.copyWith(someField: myRevisedValue);
  ///   updateParam(screenData, revisedParam);
  void updateParam(AFDispatcher dispatcher, TRouteParam revised, { AFID id }) {
    dispatcher.dispatch(AFNavigateSetParamAction(
      id: id,
      screen: this.screen, 
      param: revised)
    );
  }

  /// Utility method which updates the parameter, but takes a build context
  /// rather than a dispatcher for convenience
  void updateParamC(AFBuildContext context,TRouteParam revised, { AFID id }) {
    return updateParam(context.dispatcher, revised, id: id);
  }

  /// This exists because when navigating up from a child to a parent screen,
  /// flutter will re-render the child screen during the animation.   At that point,
  /// the state has already been updated to remove the data for the child screen,
  /// causing exceptions if it trys to render itself.   This method detects taht case
  /// and prevents the re-rendering gracefully.
  @override
  bool shouldIgnoreChangeAF(AFState state) { 
    final param = findParam(state);
    if(param == null) {
      return true;
    }
    return shouldIgnoreChange(state.app);
   }

  /// Find the route parameter for the specified named screen
  AFRouteParam findParam(AFState state) {
    return state.route?.findParamFor(this.screen);
  }
}

/// Use this to connect a Widget to the store.  
/// 
/// The Widget can still have a route parameter, but it must be passed in
/// from the parent screen that the Widget is created by.
abstract class AFConnectedWidget<TState, TData extends AFStoreConnectorData, TRouteParam extends AFRouteParam> extends AFConnectedScreenWithoutRoute<TState, TData, TRouteParam> {
  final TRouteParam parentParam;

  AFConnectedWidget(this.parentParam): super(null);
}

/// Use this to connect a drawer to the store.
/// 
/// Drawers are special because the user can drag in from the left or right to open them.
/// You cannot trust that you used an [AFNavigatePush] action to open the drawer.  Consequently,
/// you should only rely on information in your [AFAppState] to render your drawers, and perhaps
/// the full state of the route ()
abstract class AFConnectedDrawer<TState, TData extends AFStoreConnectorData> extends AFConnectedScreenWithoutRoute<TState, TData, AFRouteParamUnused> {
  AFConnectedDrawer(): super(null);



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

  void enableTestContext(AFScreenPrototypeTest st) {
    screenTest = st;
  }

  Widget createDebugDrawer() {
    if(screenTest != null) {
      return AFTestDrawer(screenTest);
    };
    return null;
  }


}

