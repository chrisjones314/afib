

import 'package:meta/meta.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';

/// Place a test context and a test state in the store, so that they can be referenced
/// by both the prototype screen and the debug drawer
class AFStartPrototypeScreenTestContextAction {
    final AFScreenTestContext context;
    final dynamic param;
    final dynamic stateView;
    final AFScreenID screen;
    AFStartPrototypeScreenTestContextAction(this.context, { 
      @required this.param, 
      @required this.stateView, 
      @required this.screen 
    });
}

class AFStartPrototypeScreenTestAction {
    final AFScreenPrototypeTest test;
    final dynamic param;
    final dynamic stateView;
    final AFScreenID screen;
    AFStartPrototypeScreenTestAction(this.test, { 
      this.param, 
      this.stateView, 
      @required this.screen });
}


/// Update the 'store based' data for a prototype screen.
class AFUpdatePrototypeScreenTestDataAction {
  AFTestID testId;
  dynamic stateView;
  AFUpdatePrototypeScreenTestDataAction(this.testId, this.stateView);
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