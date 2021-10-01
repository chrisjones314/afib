import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:afib/src/flutter/test/af_test_data_registry.dart';
import 'package:afib/src/flutter/test/af_wireframe.dart';

/// Place a test context and a test state in the store, so that they can be referenced
/// by both the prototype screen and the debug drawer
class AFStartPrototypeScreenTestContextAction {
    final AFScreenTestContext context;
    final dynamic routeParam;
    final String? routeParamId;
    final dynamic stateViews;
    final String? stateViewId;
    final AFScreenID screen;
    AFStartPrototypeScreenTestContextAction(this.context, { 
      required this.routeParam, 
      required this.stateViews, 
      required this.screen, 
      required this.stateViewId,
      required this.routeParamId,
    });
}

class AFStartWireframePopTestAction {
  
}

class AFResetTestState {
  
}

class AFTestUpdateWireframeStateViews {
  final AFCompositeTestDataRegistry registry;

  AFTestUpdateWireframeStateViews(this.registry);  
}
class AFStartPrototypeScreenTestAction {
    final AFScreenPrototype test;
    final dynamic param;
    final dynamic stateView;
    final AFScreenID screen;
    final String? stateViewId;
    final String? routeParamId;

    AFStartPrototypeScreenTestAction(this.test, { 
      this.param, 
      this.stateView, 
      required this.screen, 
      required this.stateViewId,
      required this.routeParamId,
    });
}

class AFStartWireframeAction {
  final AFWireframe wireframe;

  AFStartWireframeAction({
    required this.wireframe
  });
}

/// Update the 'store based' data for a prototype screen.
class AFUpdatePrototypeScreenTestDataAction {
  AFBaseTestID testId;
  dynamic stateView;
  AFUpdatePrototypeScreenTestDataAction(this.testId, this.stateView);
}

class AFPrototypeScreenTestIncrementPassCount {
  AFBaseTestID testId;
  AFPrototypeScreenTestIncrementPassCount(this.testId);
}

class AFPrototypeScreenTestAddError {
  AFBaseTestID testId;
  String err;
  AFPrototypeScreenTestAddError(this.testId, this.err);
}