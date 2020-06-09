import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:meta/meta.dart';

@immutable 
class AFScreenTestState {
  final int pass;
  final List<String> errors;
  final dynamic data;

  AFScreenTestState({this.pass, this.errors, this.data});

  AFScreenTestState reviseData(dynamic data) {
    return copyWith(data: data);
  }

  AFScreenTestState incrementPassCount() {
    final revisedPass = pass+1;
    return copyWith(pass: revisedPass);
  }

  AFScreenTestState addError(String err) {
    final revised = List<String>.from(errors);
    revised.add(err);
    return copyWith(errors: revised);
  }

  String get summaryText {
    final sb = StringBuffer();
    if(hasErrors) {
      sb.write(errors.length);
      sb.write(" failed");
      sb.write(", ");
    }    
    sb.write(pass);
    sb.write(" passed");
    return sb.toString();
  }

  bool get hasErrors {
    return errors.isNotEmpty;
  }

  AFScreenTestState copyWith({
    int pass, 
    List<String> errors, 
    dynamic data
  }) {
    return AFScreenTestState(
      data: data ?? this.data,
      errors: errors ?? this.errors,
      pass: pass ?? this.pass
    );
  }
}


@immutable
class AFTestState {
  final Map<AFTestID, AFScreenTestContextSimulator> testContexts;
  final Map<AFTestID, AFScreenTestState> testStates;

  AFTestState({this.testContexts, this.testStates});

  factory AFTestState.initial() {
    return AFTestState(
      testContexts: Map<AFTestID, AFScreenTestContextSimulator>(), 
      testStates:Map<AFTestID, AFScreenTestState>()
    );
  }

  AFScreenTestContextSimulator findContext(AFTestID id) {
    return testContexts[id];
  }

  AFScreenTestState findState(AFTestID id) {
    return testStates[id];
  }

  AFTestState startTest(AFScreenTestContextSimulator simulator) {
    final revisedContexts = Map<AFTestID, AFScreenTestContextSimulator>.from(testContexts);
    revisedContexts[simulator.test.id] = simulator;
    final revisedStates = Map<AFTestID, AFScreenTestState>.from(testStates);
    revisedStates[simulator.test.id] = AFScreenTestState(pass: 0, errors: List<String>(), data: null);
    return copyWith(
      testContexts: revisedContexts,
      testStates: revisedStates
    );
  }

  AFTestState updateStateData(AFTestID testId, dynamic data) {
    final revisedStates = Map<AFTestID, AFScreenTestState>.from(testStates);
    final currentState = revisedStates[testId];
    if(currentState == null) {
      revisedStates[testId] = AFScreenTestState(data: data, errors: List<String>(), pass: 0);    
    } else {
      revisedStates[testId] = currentState.reviseData(data);

    }
    return copyWith(
      testStates: revisedStates
    );
  }

  AFTestState incrementPassCount(AFTestID testId) {
    final revisedStates = Map<AFTestID, AFScreenTestState>.from(testStates);
    final currentState = revisedStates[testId];
    revisedStates[testId] = currentState.incrementPassCount();
    return copyWith(
      testStates: revisedStates
    );
  }

  AFTestState addError(AFTestID testId, String err) {
    final revisedStates = Map<AFTestID, AFScreenTestState>.from(testStates);
    final currentState = revisedStates[testId];
    revisedStates[testId] = currentState.addError(err);
    return copyWith(
      testStates: revisedStates
    );
  }

  AFTestState copyWith({
    Map<AFTestID, AFScreenTestContextSimulator> testContexts,
     Map<AFTestID, AFScreenTestState> testStates
  }) {
    return AFTestState(
      testContexts: testContexts ?? this.testContexts,
      testStates: testStates ?? this.testStates
    );
  }
}