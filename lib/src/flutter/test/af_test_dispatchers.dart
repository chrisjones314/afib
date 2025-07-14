import 'package:afib/src/dart/redux/actions/af_action_with_key.dart';
import 'package:afib/src/dart/redux/actions/af_app_state_actions.dart';
import 'package:afib/src/dart/redux/actions/af_route_actions.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_object_with_key.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:afib/src/flutter/test/af_test_actions.dart';
import 'package:afib/src/flutter/ui/screen/afui_prototype_widget_screen.dart';
import 'package:afib/src/flutter/utils/af_dispatcher.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';

abstract class AFTestDispatcher extends AFDispatcher {
  final AFDispatcher main;
  AFTestDispatcher(this.main);

  bool isNavigateAction(dynamic action) {
    return action is AFNavigateAction;
  }

}

class AFStateScreenTestDispatcher extends AFTestDispatcher {
  
  AFStateScreenTestDispatcher(
    super.main
  );

  @override
  void dispatch(dynamic action) {
    // don't do navigation actions when executed in a workflow context, instead,
    // let the workflow test itself establish the initial path.
    /*
    if(action is AFNavigateAction) {
      return;
    }
    */
    main.dispatch(action);
  }
}

abstract class AFScreenTestDispatcher extends AFTestDispatcher {
  AFScreenTestContext? testContext;
  AFScreenTestDispatcher(super.main, this.testContext);

  void setContext(AFScreenTestContext context) {
    testContext = context;
  }

  @override
  void dispatch(dynamic action) {
    final isTestAct = AFStoreDispatcher.isTestAction(action);

    // if the action is a pop, then go ahead and do it.
    if(isTestAct) {
      main.dispatch(action);
    } else if(action is AFNavigateSetParamAction || 
      action is AFNavigateAddChildParamAction ||
      action is AFNavigateRemoveChildParamAction ||
      //action is AFNavigateSortConnectedChildrenAction ||
      action is AFWireframeEventAction ||
      action is AFNavigateShowScreenBeginAction || 
      action is AFNavigateShowScreenEndAction) {
        main.dispatch(action);
    } 

    if(action is AFUpdateAppStateAction) {
      // in this case, we need to update the test state for this test.
      main.dispatch(AFUpdateTestStateAction(action.toIntegrate));
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
  AFUIPrototypeWidgetRouteParam originalParam;
  
  AFWidgetScreenTestDispatcher({
    required AFScreenTestContext? context,
    required AFDispatcher main,
    required this.originalParam
  }): super(main, context);

}