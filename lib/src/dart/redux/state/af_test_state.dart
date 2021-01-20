import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:afib/src/flutter/test/af_wireframe.dart';
import 'package:afib/src/flutter/utils/af_state_view.dart';
import 'package:meta/meta.dart';

@immutable 
class AFSingleScreenTestState {
  final int pass;
  final List<String> errors;
  final dynamic stateView;
  final dynamic param;
  final AFScreenID screen;

  AFSingleScreenTestState({
    @required this.pass, 
    @required this.errors, 
    @required this.stateView, 
    @required this.param, 
    @required this.screen
  });

  AFSingleScreenTestState reviseStateView(dynamic data) {
    return copyWith(stateView: data);
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
    if(stateView is TStateView) {
      return stateView;
    }

    if(stateView is Iterable) {
      for(final testData in stateView) {
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
    dynamic stateView
  }) {
    return AFSingleScreenTestState(
      stateView: stateView ?? this.stateView,
      errors: errors ?? this.errors,
      pass: pass ?? this.pass,
      param: this.param,
      screen: this.screen,
    );
  }
}


@immutable
class AFTestState {
  final AFTestID activeTestId;
  final AFWireframe activeWireframe;
  final Map<AFTestID, AFScreenTestContext> testContexts;
  final Map<AFTestID, AFSingleScreenTestState> testStates;

  AFTestState({
    @required this.activeTestId, 
    @required this.activeWireframe,
    @required this.testContexts, 
    @required this.testStates});

  factory AFTestState.initial() {
    return AFTestState(
      activeTestId: null,
      activeWireframe: null,
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

  AFTestState startWireframe(AFWireframe wireframe) {
    return copyWith(activeWireframe: wireframe);
  }

  Map<AFTestID, AFSingleScreenTestState> _createTestState(AFTestID testId, dynamic param, dynamic data, AFScreenID screen) {
    if(testStates.containsKey(testId)) {
      return testStates;
    }
    final revisedStates = Map<AFTestID, AFSingleScreenTestState>.from(testStates);
    revisedStates[testId] = AFSingleScreenTestState(pass: 0, errors: <String>[], stateView: data, param: param, screen: screen);
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

  AFTestState updateStateView(AFTestID testId, dynamic stateView) {
    final revisedStates = Map<AFTestID, AFSingleScreenTestState>.from(testStates);
    final currentState = revisedStates[testId];
    if(currentState == null) {
      throw AFException("Internal error, calling updateStateView when there is no test state for $testId");
    } else {
      revisedStates[testId] = currentState.reviseStateView(stateView);

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
    AFWireframe activeWireframe,
    Map<AFTestID, AFScreenTestContext> testContexts,
     Map<AFTestID, AFSingleScreenTestState> testStates
  }) {
    return AFTestState(
      activeTestId: activeTestId ?? this.activeTestId,
      testContexts: testContexts ?? this.testContexts,
      testStates: testStates ?? this.testStates,
      activeWireframe: activeWireframe ?? this.activeWireframe,
    );
  }
}