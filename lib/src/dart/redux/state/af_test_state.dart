import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:meta/meta.dart';

@immutable 
class AFSingleScreenTestState {
  final int pass;
  final List<String> errors;
  final dynamic data;

  AFSingleScreenTestState({this.pass, this.errors, this.data});

  AFSingleScreenTestState reviseData(dynamic data) {
    return copyWith(data: data);
  }

  AFSingleScreenTestState incrementPassCount() {
    final revisedPass = pass+1;
    return copyWith(pass: revisedPass);
  }

  AFSingleScreenTestState addError(String err) {
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

  AFSingleScreenTestState copyWith({
    int pass, 
    List<String> errors, 
    dynamic data
  }) {
    return AFSingleScreenTestState(
      data: data ?? this.data,
      errors: errors ?? this.errors,
      pass: pass ?? this.pass
    );
  }
}


@immutable
class AFTestState {
  final AFScreenPrototypeTest activeTest;
  final Map<AFTestID, AFScreenTestContext> testContexts;
  final Map<AFTestID, AFSingleScreenTestState> testStates;

  AFTestState({
    @required this.activeTest, 
    @required this.testContexts, 
    @required this.testStates});

  factory AFTestState.initial() {
    return AFTestState(
      activeTest: null,
      testContexts: Map<AFTestID, AFScreenTestContext>(), 
      testStates:Map<AFTestID, AFSingleScreenTestState>()
    );
  }

  AFScreenTestContext findContext(AFTestID id) {
    return testContexts[id];
  }

  AFSingleScreenTestState findState(AFTestID id) {
    return testStates[id];
  }

  AFTestState navigateToTest(AFScreenPrototypeTest test) {
    return copyWith(activeTest: test);
  }

  AFTestState startTest(AFScreenTestContext simulator) {
    final revisedContexts = Map<AFTestID, AFScreenTestContext>.from(testContexts);
    revisedContexts[simulator.test.id] = simulator;
    final revisedStates = Map<AFTestID, AFSingleScreenTestState>.from(testStates);
    revisedStates[simulator.test.id] = AFSingleScreenTestState(pass: 0, errors: List<String>(), data: null);
    
    return copyWith(
      activeTest: simulator.test,
      testContexts: revisedContexts,
      testStates: revisedStates
    );
  }

  AFTestState updateStateData(AFTestID testId, dynamic data) {
    final revisedStates = Map<AFTestID, AFSingleScreenTestState>.from(testStates);
    final currentState = revisedStates[testId];
    if(currentState == null) {
      revisedStates[testId] = AFSingleScreenTestState(data: data, errors: List<String>(), pass: 0);    
    } else {
      revisedStates[testId] = currentState.reviseData(data);

    }
    return copyWith(
      testStates: revisedStates
    );
  }

  AFTestState incrementPassCount(AFTestID testId) {
    final revisedStates = Map<AFTestID, AFSingleScreenTestState>.from(testStates);
    final currentState = revisedStates[testId];
    revisedStates[testId] = currentState?.incrementPassCount();
    return copyWith(
      testStates: revisedStates
    );
  }

  AFTestState addError(AFTestID testId, String err) {
    final revisedStates = Map<AFTestID, AFSingleScreenTestState>.from(testStates);
    final currentState = revisedStates[testId];
    revisedStates[testId] = currentState.addError(err);
    return copyWith(
      testStates: revisedStates
    );
  }

  AFTestState copyWith({
    AFScreenPrototypeTest activeTest,
    Map<AFTestID, AFScreenTestContext> testContexts,
     Map<AFTestID, AFSingleScreenTestState> testStates
  }) {
    return AFTestState(
      activeTest: activeTest ?? this.activeTest,
      testContexts: testContexts ?? this.testContexts,
      testStates: testStates ?? this.testStates
    );
  }
}