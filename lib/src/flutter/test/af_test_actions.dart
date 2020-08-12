

import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';

/// Place a test context and a test state in the store, so that they can be referenced
/// by both the prototype screen and the debug drawer
class AFStartPrototypeScreenTestContextAction {
    final AFScreenTestContext context;
    AFStartPrototypeScreenTestContextAction(this.context);
}

class AFStartPrototypeScreenTestAction {
    final AFScreenPrototypeTest test;
    AFStartPrototypeScreenTestAction(this.test);
}


/// Update the 'store based' data for a prototype screen.
class AFUpdatePrototypeScreenTestDataAction {
  AFTestID testId;
  dynamic data;
  AFUpdatePrototypeScreenTestDataAction(this.testId, this.data);
}

class AFPrototypeScreenTestIncrementPassCount {
  AFTestID testId;
  AFPrototypeScreenTestIncrementPassCount(this.testId);
}

class AFPrototypeScreenTestAddError {
  AFTestID testId;
  String err;
  AFPrototypeScreenTestAddError(this.testId, this.err);
}