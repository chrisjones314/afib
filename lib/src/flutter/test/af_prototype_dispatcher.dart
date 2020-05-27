
import 'package:afib/afib_dart.dart';
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/utils/af_ui_constants.dart';
import 'package:afib/src/flutter/test/af_scenario_instance_screen.dart';

class AFPrototypeDispatcher extends AFDispatcher {
  String screenId;
  AFDispatcher main;
  
  AFPrototypeDispatcher(this.screenId, this.main);

  @override
  void dispatch(action) {
    // if the action is a pop, then go ahead and do it.
    if(action is AFNavigatePopAction) {
      main.dispatch(action);
    } else if(action is AFNavigateSetParamAction) {
      // change this into a set param action for the prototype.
      main.dispatch(
        AFNavigateSetParamAction(screen: AFUIConstants.scenarioInstanceScreenId,
          param: AFScenarioInstanceScreenParam(id: screenId, param: action.param)
      ));
    } else {
      AF.logger.fine("Action: $action");
    }
  }

}