import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/utils/af_object_with_key.dart';
import 'package:afib/src/flutter/ui/screen/af_prototype_widget_screen.dart';
import 'package:afib/src/flutter/utils/af_dispatcher.dart';

abstract class AFTestDispatcher extends AFDispatcher {
  final AFDispatcher main;
  AFTestDispatcher(this.main);

  bool isNavigateAction(dynamic action) {
    return action is AFNavigateAction;
  }

  AFPublicState? get debugOnlyPublicState {
    return main.debugOnlyPublicState;
  }
}

class AFStateScreenTestDispatcher extends AFTestDispatcher {
  
  AFStateScreenTestDispatcher(
    AFDispatcher main
  ): super(main);

  @override
  void dispatch(dynamic action) {
    // don't do navigation actions when executed in a workflow context, instead,
    // let the workflow test itself establish the initial path.
    if(action is AFNavigateAction) {
      return;
    }
    main.dispatch(action);
  }
}

abstract class AFScreenTestDispatcher extends AFTestDispatcher {
  AFScreenTestContext? testContext;
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
      action is AFNavigateAddChildParamAction ||
      action is AFNavigateRemoveChildParamAction ||
      //action is AFNavigateSortConnectedChildrenAction ||
      action is AFNavigateWireframeAction) {
        main.dispatch(action);
    } 

    // if this is a test action, then remember it so that we can 
    if(!isTestAct && action is AFObjectWithKey) {
      AFibF.g.testOnlyRegisterRegisterAction(action as AFActionWithKey);
      AFibD.logTestAF?.d("Registered action: $action");
    }
  }
}

class AFSingleScreenTestDispatcher extends AFScreenTestDispatcher {
  final AFBaseTestID testId;
  
  
  AFSingleScreenTestDispatcher(
    this.testId, 
    AFDispatcher main, 
    AFScreenTestContext? testContext
  ): super(main, testContext);
}

class AFWidgetScreenTestDispatcher extends AFScreenTestDispatcher {
  AFPrototypeWidgetRouteParam originalParam;
  
  AFWidgetScreenTestDispatcher({
    required AFScreenTestContext? context,
    required AFDispatcher main,
    required this.originalParam
  }): super(main, context);

}