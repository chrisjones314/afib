import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:afib/src/flutter/utils/af_state_view.dart';
import 'package:meta/meta.dart';

@immutable 
class AFSingleScreenTestState {
  final int pass;
  final List<String> errors;
  final dynamic data;
  final dynamic param;
  final AFScreenID screen;

  AFSingleScreenTestState({this.pass, this.errors, this.data, this.param, this.screen});

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

  TStateView findViewStateFor<TStateView extends AFStateView>() {
    if(data is TStateView) {
      return data;
    }

    if(data is Iterable) {
      for(final testData in data) {
        if(testData is TStateView) {
          return testData;
        }
      }
    } 

    return null;    
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
  final AFTestID activeTestId;
  final Map<AFTestID, AFScreenTestContext> testContexts;
  final Map<AFTestID, AFSingleScreenTestState> testStates;

  AFTestState({
    @required this.activeTestId, 
    @required this.testContexts, 
    @required this.testStates});

  factory AFTestState.initial() {
    return AFTestState(
      activeTestId: null,
      testContexts: <AFTestID, AFScreenTestContext>{}, 
      testStates:<AFTestID, AFSingleScreenTestState>{}
    );
  }

  AFScreenTestContext findContext(AFTestID id) {
    return testContexts[id];
  }

  AFSingleScreenTestState findState(AFTestID id) {
    return testStates[id];
  }

  AFTestState navigateToTest(AFScreenPrototypeTest test, dynamic param, dynamic data, AFScreenID screen) {
    final revisedStates = _createTestState(test.id, param, data, screen);
    return copyWith(activeTestId: test.id, testStates: revisedStates);
  }

  Map<AFTestID, AFSingleScreenTestState> _createTestState(AFTestID testId, dynamic param, dynamic data, AFScreenID screen) {
    if(testStates.containsKey(testId)) {
      return testStates;
    }
    final revisedStates = Map<AFTestID, AFSingleScreenTestState>.from(testStates);
    revisedStates[testId] = AFSingleScreenTestState(pass: 0, errors: <String>[], data: data, param: param, screen: screen);
    return revisedStates;

  }

  AFTestState startTest(AFScreenTestContext simulator, dynamic param, dynamic data, AFScreenID screen) {
    final testId = simulator.testId;
    final revisedContexts = Map<AFTestID, AFScreenTestContext>.from(testContexts);
    revisedContexts[testId] = simulator;
    final revisedStates = _createTestState(testId, param, data, screen);
    return copyWith(
      activeTestId: simulator.testId,
      testContexts: revisedContexts,
      testStates: revisedStates
    );
  }

  AFTestState updateStateView(AFTestID testId, dynamic data) {
    final revisedStates = Map<AFTestID, AFSingleScreenTestState>.from(testStates);
    final currentState = revisedStates[testId];
    if(currentState == null) {
      revisedStates[testId] = AFSingleScreenTestState(data: data, errors: <String>[], pass: 0);    
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
    AFTestID activeTestId,
    Map<AFTestID, AFScreenTestContext> testContexts,
     Map<AFTestID, AFSingleScreenTestState> testStates
  }) {
    return AFTestState(
      activeTestId: activeTestId ?? this.activeTestId,
      testContexts: testContexts ?? this.testContexts,
      testStates: testStates ?? this.testStates
    );
  }
}