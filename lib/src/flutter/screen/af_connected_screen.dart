
import 'package:afib/src/dart/redux/actions/af_navigation_actions.dart';
import 'package:afib/src/dart/redux/state/af_route_state.dart';
import 'package:afib/src/dart/redux/state/af_state.dart';
import 'package:afib/src/dart/redux/state/af_store.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/dart/utils/af_unused.dart';
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
/// having a store in test scenarios.
@immutable
class AFStoreConnectorData<TRouteParam extends AFRouteParam, TV1, TV2, TV3, TV4> {
  final TRouteParam param;
  final TV1 first;
  final TV2 second;
  final TV3 third;
  final TV4 fourth;
  final AFDispatcher dispatcher;

  AFStoreConnectorData({@required this.dispatcher, @required this.param, this.first, this.second, this.third, this.fourth});

  /// Because store connector data is always recreated, it is 
  /// important to implement deep equality so that the screen won't be re-rendered
  /// each time if the data has not changed.
  bool operator==(o) {
    bool result = (o is AFStoreConnectorData<TRouteParam, TV1, TV2, TV3, TV4> && param == o.param && first == o.first && second == o.second && third == o.third && fourth == o.fourth);
    return result;
  }

  /// The testing-friendly way to dispatch actions to the store from within a screen.
  void dispatch(dynamic action) {
    dispatcher.dispatch(action);
  }
}

/// Use this version of [AFStoreConnectorData] if you only need one piece of data from the store.
@immutable 
class AFStoreConnectorData1<TRouteParam extends AFRouteParam, TV1> extends AFStoreConnectorData<TRouteParam, TV1, AFUnused, AFUnused, AFUnused> {
  AFStoreConnectorData1({AFDispatcher dispatcher, AFRouteParam param, TV1 first}): super(dispatcher: dispatcher, param: param, first: first);
}

/// Use this version of [AFStoreConnectorData] if you need two pieces of data from the store.
@immutable 
class AFStoreConnectorData2<TRouteParam extends AFRouteParam, TV1, TV2> extends AFStoreConnectorData<TRouteParam, TV1, TV2, AFUnused, AFUnused> {
  AFStoreConnectorData2({AFDispatcher dispatcher, AFRouteParam param, TV1 first, TV2 second}): super(dispatcher: dispatcher, param: param, first: first, second: second);
}

/// Use this version of [AFStoreConnectorData] if you need three pieces of data from the store.
@immutable 
class AFStoreConnectorData3<TRouteParam extends AFRouteParam, TV1, TV2, TV3> extends AFStoreConnectorData<TRouteParam, TV1, TV2, TV3, AFUnused> {
  AFStoreConnectorData3({AFDispatcher dispatcher, AFRouteParam param, TV1 first, TV2 second, TV3 third}): super(dispatcher: dispatcher, param: param, first: first, second: second, third: third);
}

/// Use this version of [AFStoreConnectorData] if you need four pieces of data from the store.
@immutable 
class AFStoreConnectorData4<TRouteParam extends AFRouteParam, TV1, TV2, TV3, TV4> extends AFStoreConnectorData<TRouteParam, TV1, TV2, TV3, TV4> {
  AFStoreConnectorData4({AFDispatcher dispatcher, AFRouteParam param, TV1 first, TV2 second, TV3 third, TV4 fourth}): super(dispatcher: dispatcher, param: param, first: first, second: second, third: third, fourth: fourth);
}

/// A screen that uses data from the store but not from the route.
abstract class AFConnectedScreenWithoutRoute<TState, TData> extends StatelessWidget {
  final String screen;
  final TData testData;

  //--------------------------------------------------------------------------------------
  AFConnectedScreenWithoutRoute({@required this.screen, @required this.testData});

  //--------------------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    if(testData != null) {
      onInit(testData);
      return buildWithData(context, this.testData);
    }

    return StoreConnector<AFState, TData>(
        converter: (store) => createData(AFStoreDispatcher(store), store.state),
        distinct: true,
        ignoreChange: (AFState state) {
          return shouldIgnoreChangeAF(state);
        },
        onInit: (store) {
          final data = createData(AFStoreDispatcher(store), store.state);
          onInit(data);
        },
        onDispose: (store) {
          onDispose(store.state.app);
        },
        builder: (context, obj) {
          if(obj == null) {
            return CircularProgressIndicator();
          }
          return buildWithData(context, obj);
        }
    );
  }

  /// Override this to create an [AFStoreConnectorData] with the required data from the state.
  TData createData(AFDispatcher dispatcher, AFState state);

  /// Builds a widget using the data extracted from the state.
  Widget buildWithData(BuildContext context, TData data);

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

/// Superclass for a screen widget, which combined data from the store with data from
/// the route in order to render itself.
abstract class AFConnectedScreen<TState, TData extends AFStoreConnectorData, TRouteParam extends AFRouteParam> extends AFConnectedScreenWithoutRoute<TState, TData> {

  AFConnectedScreen(String screen, {@required TData testData}): super(screen: screen, testData: testData);

  /// Utility for updating the route parameter for this screen.
  /// 
  /// Your route parameter should contain the data that your screen is editing.
  /// When a user action causes data on the screen, you will typically do 
  /// something like:
  /// 
  /// ### Example
  ///   final revisedParam = screenData.param.copyWith(someField: myRevisedValue);
  ///   updateParam(screenData, revisedParam);
  void updateParam(TData data, TRouteParam revised) {
    updateParamWithDispatcher(data.dispatcher, revised);
  }

  /// Override this method if you need access to the entire route, otherwise,
  /// override createDataWithParam
  TData createDataWithRoute(AFDispatcher dispatcher, AFRouteState route, TState state) {
    TRouteParam param = route.findParamFor(screen);
    return createDataWithParam(dispatcher, state, param);
  }


  /// Override this method to 
  TData createDataWithParam(AFDispatcher dispatcher, TState state, TRouteParam param);

  /// This exists because when navigating up from a child to a parent screen,
  /// flutter will re-render the child screen during the animation.   At that point,
  /// the state has already been updated to remove the data for the child screen,
  /// causing exceptions if it trys to render itself.   This method detects taht case
  /// and prevents the re-rendering gracefully.
  @override
  bool shouldIgnoreChangeAF(AFState state) { 
    final param = findParam(state);
    return (param == null);
   }

  /// Given a state, extracts the data that this specific screen needs to
  /// render itself.
  @override
  TData createData(AFDispatcher dispatcher, AFState state) {
    return createDataWithRoute(dispatcher, state.route, state.app);
  }

  /// Find the route parameter for the specified named screen
  AFRouteParam findParam(AFState state) {
    return state.route?.findParamFor(this.screen);
  }

  /// Modify the route parameter for this screens route element.
  void updateParamWithDispatcher(AFDispatcher dispatcher, dynamic param) {
    dispatcher.dispatch(AFNavigateSetParamAction(
      screen: this.screen, 
      param: param)
    );
  }
}

/// Use this to connect a widget to the store.  
/// 
/// The widget can still have a route parameter, but it must be passed in
/// from the parent screen that the widget is created by.
abstract class AFConnectedWidget<TState, TData extends AFStoreConnectorData, TRouteParam extends AFRouteParam> extends AFConnectedScreenWithoutRoute<TState, TData> {
  final TRouteParam parentParam;

  AFConnectedWidget(this.parentParam, {@required TData testData}): super(screen: null, testData: testData);


  @override
  TData createData(AFDispatcher dispatcher, AFState state) {
    return createDataWithParam(dispatcher, state.app, parentParam);
  }

  TData createDataWithParam(AFDispatcher dispatcher, TState state, TRouteParam param);
}

/// Use this for a widget that gets all of its data in its constructor, and does
/// not need to pull data from the store.
/// 
/// Use this instead of just passing individual parameters into the constructor for the 
/// following reasons:
/// * It is easy to promote the widget to a store connected widget later, because it
///   follows the same patterns.
/// * As you find you need to pass more data into the widget, you don't need to change
///   a bunch of method signatures within the widget.
/// * It integrates with the test framework (TODO)
@immutable
abstract class AFStandaloneWidget<TState, TData extends AFStoreConnectorData, TRouteParam extends AFRouteParam> extends StatelessWidget {
  final TData data;

  AFStandaloneWidget(this.data);

  /// To build your widget, implement [buildWithData]
  @override
  Widget build(BuildContext context) {
    return buildWithData(context, data);
  }

  /// Implement this method to build a widget from [data]
  Widget buildWithData(BuildContext context, TData data);

}

