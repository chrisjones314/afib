import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:meta/meta.dart';


@immutable
class AFTestState {
  final Map<AFTestID, AFScreenTestContextSimulator> testContexts;

  AFTestState(this.testContexts);

  factory AFTestState.initial() {
    return AFTestState(Map<AFTestID, AFScreenTestContextSimulator>());
  }

  AFScreenTestContextSimulator findContext(AFTestID id) {
    return testContexts[id];
  }

  AFTestState addContext(AFScreenTestContextSimulator simulator) {
    final revised = Map<AFTestID, AFScreenTestContextSimulator>.from(testContexts);
    revised[simulator.test.id] = simulator;
    return AFTestState(revised);
  }
}