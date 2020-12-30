
import 'package:afib/afib_dart.dart';
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/utils/af_object_with_key.dart';
import 'package:afib/src/flutter/test/af_prototype_widget_screen.dart';
import 'package:afib/src/flutter/utils/af_dispatcher.dart';

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
    } else if(action is AFNavigateSetParamAction || 
      action is AFNavigateSetChildParamAction ||
      action is AFNavigateAddConnectedChildAction ||
      action is AFNavigateRemoveConnectedChildAction ||
      action is AFNavigateSortConnectedChildrenAction) {
        main.dispatch(action);
    } 

    // if this is a test action, then remember it so that we can 
    if(!isTestAct && action is AFObjectWithKey) {
      AFibF.g.testOnlyRegisterRegisterAction(action);
      AFibD.logTest?.d("Registered action: $action");
    }
  }
}

class AFSingleScreenTestDispatcher extends AFScreenTestDispatcher {
  final AFTestID testId;
  
  
  AFSingleScreenTestDispatcher(
    this.testId, 
    AFDispatcher main, 
    AFScreenTestContext testContext): super(main, testContext);
}

class AFWidgetScreenTestDispatcher extends AFScreenTestDispatcher {
  AFPrototypeWidgetRouteParam originalParam;
  
  AFWidgetScreenTestDispatcher({
    AFScreenTestContext context,
    AFDispatcher main,
    this.originalParam
  }): super(main, context);

}