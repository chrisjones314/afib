
import 'package:afib/afib_dart.dart';
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/utils/af_object_with_key.dart';
import 'package:afib/src/dart/utils/af_ui_id.dart';
import 'package:afib/src/flutter/test/af_simple_prototype_screen.dart';
import 'package:afib/src/flutter/test/af_test_actions.dart';

class AFPrototypeDispatcher extends AFDispatcher {
  AFID screenId;
  AFDispatcher main;
  AFScreenTestContext testContext;
  
  AFPrototypeDispatcher(this.screenId, this.main, this.testContext);

  void setContext(AFScreenTestContext context) {
    testContext = context;
  }

  @override
  void dispatch(action) {
    final isTestAction = action is AFNavigatePopInTestAction ||
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
        AFNavigateSetParamAction(screen: AFUIID.screenPrototypeInstance,
          param: AFScreenPrototypeScreenParam(id: screenId, param: action.param)
      ));      
    } else {
      // if this is an action that doesn't really dispatch, then bump the 
      // screen update count artificially to allow tests to continue (they
      // are waiting for a screen update.
      AFibF.testOnlyScreenUpdateCount++;
    }

    // if this is a test action, then remember it so that we can 
    if(!isTestAction && action is AFObjectWithKey) {
      testContext?.registerAction(action);
      AFibD.logInternal?.fine("Registered action: $action");
    }
  }

}