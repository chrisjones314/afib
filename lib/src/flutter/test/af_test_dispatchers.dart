
import 'package:afib/afib_dart.dart';
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/utils/af_object_with_key.dart';
import 'package:afib/src/dart/utils/af_ui_id.dart';
import 'package:afib/src/flutter/test/af_prototype_single_screen_screen.dart';
import 'package:afib/src/flutter/test/af_prototype_widget_screen.dart';

abstract class AFTestDispatcher extends AFDispatcher {
  final AFDispatcher main;
  AFTestDispatcher(this.main);

  bool isNavigateAction(dynamic action) {
    return action is AFNavigateAction;
  }

}

class AFStateScreenTestDispatcher extends AFTestDispatcher {
  
  AFStateScreenTestDispatcher(
    AFDispatcher main
  ): super(main);

  @override
  void dispatch(dynamic action) {
    // suppress navigation actions when we are in a state test, 
    // but note that this dispatcher also gets called during workflow
    // tests that are based on state tests, and we don't want to 
    // suppress navigation in that case.
    //if(AFibF.testOnlyShouldSuppressNavigation) {
    // return;
    //}
    if(isNavigateAction(action)) {
      if(AFibF.g.testOnlyShouldSuppressNavigation) {
        return;
      }
    } 

    main.dispatch(action);
  }


}

abstract class AFScreenTestDispatcher extends AFTestDispatcher {
  AFScreenTestContext testContext;
  AFScreenTestDispatcher(AFDispatcher main, this.testContext): super(main);

  void setContext(AFScreenTestContext context) {
    testContext = context;
  }

  @override
  void dispatch(dynamic action) {
    final isTestAct = isTestAction(action);

    // if the action is a pop, then go ahead and do it.
    if(isTestAct) {
      main.dispatch(action);
    } else if(action is AFNavigateSetParamAction) {
      if(action.route == AFNavigateRoute.routeHierarchy) {
        processSetParam(action);
      } else {
        main.dispatch(action);
      }
      // change this into a set param action for the prototype.
    } 

    // if this is a test action, then remember it so that we can 
    if(!isTestAct && action is AFObjectWithKey) {
      AFibF.g.testOnlyRegisterRegisterAction(action);
      AFibD.logTest?.d("Registered action: $action");
    }
  }

  void processSetParam(AFNavigateSetParamAction action);
}

class AFSingleScreenTestDispatcher extends AFScreenTestDispatcher {
  final AFTestID testId;
  
  
  AFSingleScreenTestDispatcher(
    this.testId, 
    AFDispatcher main, 
    AFScreenTestContext testContext): super(main, testContext);

  void processSetParam(AFNavigateSetParamAction action) {
    main.dispatch(
      AFNavigateSetParamAction(
        screen: AFUIScreenID.screenPrototypeSingleScreen,
        param: AFPrototypeSingleScreenRouteParam(id: testId, param: action.param),
        route: AFNavigateRoute.routeHierarchy,
    ));      
  }
}

class AFWidgetScreenTestDispatcher extends AFScreenTestDispatcher {
  AFPrototypeWidgetRouteParam originalParam;
  
  AFWidgetScreenTestDispatcher({
    AFScreenTestContext context,
    AFDispatcher main,
    this.originalParam
  }): super(main, context);

   void processSetParam(AFNavigateSetParamAction action) {
    main.dispatch(
      AFNavigateSetParamAction(
        screen: AFUIScreenID.screenPrototypeWidget,
        param: originalParam.copyWith(param: action.param),
        route: AFNavigateRoute.routeHierarchy,
    ));      
  }
}