
import 'package:afib/afib_dart.dart';
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/utils/af_object_with_key.dart';
import 'package:afib/src/dart/utils/af_ui_id.dart';
import 'package:afib/src/flutter/test/af_simple_prototype_screen.dart';
import 'package:afib/src/flutter/test/af_test_actions.dart';

abstract class AFTestDispatcher extends AFDispatcher {
  final AFDispatcher main;
  AFTestDispatcher(this.main);

  bool isNavigateAction(action) {
    return action is AFNavigateAction;
  }

}

class AFStateScreenTestDispatcher extends AFTestDispatcher {
  
  AFStateScreenTestDispatcher(
    AFDispatcher main
  ): super(main);

  @override
  void dispatch(action) {
    // suppress navigation actions.
    if(isNavigateAction(action)) {
      return;
    }

    main.dispatch(action);
  }


}

class AFSimpleScreenTestDispatcher extends AFTestDispatcher {
  final AFID screenId;
  AFScreenTestContext testContext;
  
  AFSimpleScreenTestDispatcher(
    this.screenId, 
    AFDispatcher main, this.testContext): super(main);

  void setContext(AFScreenTestContext context) {
    testContext = context;
  }

  @override
  void dispatch(action) {
    bool shouldPop = false;
    if(action is AFNavigatePopAction) {
      shouldPop = action.worksInPrototypeMode;
    }

    final isTestAction =  shouldPop ||
                          action is AFUpdatePrototypeScreenTestDataAction || 
                          action is AFPrototypeScreenTestAddError ||
                          action is AFPrototypeScreenTestIncrementPassCount ||
                          action is AFStartPrototypeScreenTestAction;
    // if the action is a pop, then go ahead and do it.
    if(isTestAction) {
      main.dispatch(action);
    } else if(action is AFNavigateSetParamAction) {
      // change this into a set param action for the prototype.
      main.dispatch(
        AFNavigateSetParamAction(screen: AFUIID.screenPrototypeSimple,
          param: AFScreenPrototypeScreenParam(id: screenId, param: action.param)
      ));      
    } else {
      // if this is an action that doesn't really dispatch, then bump the 
      // screen update count artificially to allow tests to continue (they
      // are waiting for a screen update.
      AFibF.testOnlyIncreaseAllUpdateCounts();
    }

    // if this is a test action, then remember it so that we can 
    if(!isTestAction && action is AFObjectWithKey) {
      testContext?.registerAction(action);
      AFibD.logInternal?.fine("Registered action: $action");
    }
  }

}