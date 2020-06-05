
import 'package:afib/afib_dart.dart';
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/redux/actions/af_action_with_key.dart';
import 'package:afib/src/dart/utils/af_ui_id.dart';
import 'package:afib/src/flutter/test/af_screen_test_screen.dart';

class AFPrototypeDispatcher extends AFDispatcher {
  AFID screenId;
  AFDispatcher main;
  AFScreenTestContextSimulator testContext;
  
  AFPrototypeDispatcher(this.screenId, this.main, this.testContext);

  @override
  void dispatch(action) {
    // if the action is a pop, then go ahead and do it.
    if(action is AFNavigatePopInTestAction) {
      main.dispatch(action);
    } else if(action is AFNavigateSetParamAction) {
      // change this into a set param action for the prototype.
      main.dispatch(
        AFNavigateSetParamAction(wid: action.wid, screen: AFUIID.screenPrototypeInstance,
          param: AFScreenTestScreenParam(id: screenId, param: action.param)
      ));
    } else {
      if(action is AFActionWithKey) {
        testContext?.registerAction(action);
        AF.debug("Action: $action");
      }
    }
  }

}