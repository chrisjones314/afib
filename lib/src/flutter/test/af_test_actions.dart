import 'package:afib/src/dart/redux/actions/af_route_actions.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:afib/src/flutter/test/af_wireframe.dart';

/// Place a test context and a test state in the store, so that they can be referenced
/// by both the prototype screen and the debug drawer
class AFStartPrototypeScreenTestContextAction {
    final AFScreenTestContext context;
    final dynamic models;
    final AFNavigatePushAction navigate;
    final AFTestTimeHandling timeHandling;
    AFStartPrototypeScreenTestContextAction(this.context, { 
      required this.navigate, 
      required this.models, 
      required this.timeHandling,
    });
}

class AFUpdateActivePrototypeAction {
  final AFPrototypeID prototypeId;
  AFUpdateActivePrototypeAction({
    required this.prototypeId
  });
}

class AFStartWireframePopTestAction {
  
}

class AFResetTestState {
  
}

class AFStartPrototypeScreenTestAction {
    final AFScreenPrototype test;
    final dynamic models;
    final AFNavigatePushAction navigate;

    AFStartPrototypeScreenTestAction(this.test, { 
      this.models, 
      required this.navigate, 
    });
}

class AFStartWireframeAction {
  final AFWireframe wireframe;

  AFStartWireframeAction({
    required this.wireframe
  });
}

/// Update the 'store based' data for a prototype screen.  Updates all the models.
class AFUpdatePrototypeScreenTestModelsAction {
  AFBaseTestID testId;
  dynamic models;
  AFUpdatePrototypeScreenTestModelsAction(this.testId, this.models);
}

/// Updates the state for a prototype screen.   
///
/// Integrates changes to the specified models, but does not replace all of them.
class AFUpdateTestStateAction {
  List<Object> toIntegrate;
  AFUpdateTestStateAction(this.toIntegrate);

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