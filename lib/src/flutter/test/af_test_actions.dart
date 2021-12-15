import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:afib/src/flutter/test/af_test_data_registry.dart';
import 'package:afib/src/flutter/test/af_wireframe.dart';

/// Place a test context and a test state in the store, so that they can be referenced
/// by both the prototype screen and the debug drawer
class AFStartPrototypeScreenTestContextAction {
    final AFScreenTestContext context;
    final String? routeParamId;
    final dynamic models;
    final String? stateViewId;
    final AFNavigatePushAction navigate;
    AFStartPrototypeScreenTestContextAction(this.context, { 
      required this.navigate, 
      required this.models, 
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
    final dynamic models;
    final AFNavigatePushAction navigate;
    final String? modelsId;
    final String? routeParamId;

    AFStartPrototypeScreenTestAction(this.test, { 
      this.models, 
      required this.navigate, 
      required this.modelsId,
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
class AFUpdatePrototypeScreenTestModelsAction {
  AFBaseTestID testId;
  dynamic models;
  AFUpdatePrototypeScreenTestModelsAction(this.testId, this.models);
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