// @dart=2.9
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:afib/src/flutter/test/af_test_data_registry.dart';
import 'package:afib/src/flutter/test/af_wireframe.dart';
import 'package:afib/src/flutter/utils/af_state_view.dart';
import 'package:meta/meta.dart';

@immutable 
class AFSingleScreenTestState {
  final AFBaseTestID testId;
  final int pass;
  final List<String> errors;
  final String stateViewId;
  final dynamic stateView;
  final dynamic param;
  final dynamic routeParamId;
  final AFScreenID screen;

  AFSingleScreenTestState({
    @required this.testId,
    @required this.pass, 
    @required this.errors, 
    @required this.stateViewId,
    @required this.stateView, 
    @required this.param, 
    @required this.routeParamId,
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
      testId: this.testId,
      stateViewId: this.stateViewId,
      routeParamId: this.routeParamId,
    );
  }
}


@immutable
class AFTestState {
  final List<AFBaseTestID> activeTestIds;
  final AFWireframe activeWireframe;
  final Map<AFBaseTestID, AFScreenTestContext> testContexts;
  final Map<AFBaseTestID, AFSingleScreenTestState> testStates;

  AFTestState({
    @required this.activeTestIds, 
    @required this.activeWireframe,
    @required this.testContexts, 
    @required this.testStates});

  factory AFTestState.initial() {
    return AFTestState(
      activeTestIds: <AFBaseTestID>[],
      activeWireframe: null,
      testContexts: <AFBaseTestID, AFScreenTestContext>{}, 
      testStates:<AFBaseTestID, AFSingleScreenTestState>{}
    );
  }

  AFBaseTestID findTestForScreen(AFScreenID screen) {
    for(final testState in testStates.values) {
      if(testState.screen == screen) {
        return testState.testId;
      }
    }

    // this catches the case where you have a dialog with a different
    // screen id.   The assumption is that this only occurs on the active screen.
    return activeTestId;
  }

  AFBaseTestID get activeTestId {
    if(activeTestIds.isEmpty) {
      return null;
    }
    return activeTestIds.last;
  }

  AFScreenTestContext findContext(AFBaseTestID id) {
    return testContexts[id];
  }

  AFSingleScreenTestState findState(AFBaseTestID id) {
    return testStates[id];
  }

  AFTestState navigateToTest(AFScreenPrototype test, dynamic param, dynamic data, AFScreenID screen, String stateViewId, String routeParamId) {
    final revisedStates = _createTestState(test.id, param, data, screen, stateViewId, routeParamId);
    final revisedActive = List<AFBaseTestID>.from(activeTestIds);
    revisedActive.add(test.id);
    return copyWith(activeTestIds: revisedActive, testStates: revisedStates);
  }

  AFTestState updateWireframeStateViews(AFCompositeTestDataRegistry registry) {
    final revisedStates = Map<AFBaseTestID, AFSingleScreenTestState>.from(this.testStates);
    for(final testState in testStates.values) {
      if(testState.stateViewId != null) { 
        final stateView = registry.f(testState.stateViewId);
        revisedStates[testState.testId] = testState.reviseStateView(stateView);
      }
    }
    return copyWith(testStates: revisedStates);
  }

  AFTestState popWireframeTest() {
    final revisedStates = Map<AFBaseTestID, AFSingleScreenTestState>.from(testStates);

    // the issue is that when we are navigating up, flutter continues to re-render the screen which we are in the process
    // of leaving, if we remove the test state, that render fails, as it loses its data.
    //revisedStates.remove(activeTestId);
    final revisedActive = List<AFBaseTestID>.from(activeTestIds);
    revisedActive.removeLast();
    var clearWireframe = false;
    if(revisedActive.isEmpty) {
      clearWireframe = true;
    }
    final result = copyWith(testStates: revisedStates, activeTestIds: revisedActive, clearActiveWireframe: clearWireframe);
    return result;
  }

  AFTestState reset() {
    return AFTestState.initial();
  }


  AFTestState startWireframe(AFWireframe wireframe) {
    return copyWith(activeWireframe: wireframe);
  }

  Map<AFBaseTestID, AFSingleScreenTestState> _createTestState(AFBaseTestID testId, dynamic param, dynamic data, AFScreenID screen, String stateViewId, String routeParamId) {
    final revisedStates = Map<AFBaseTestID, AFSingleScreenTestState>.from(testStates);
      final orig = testStates[testId];
    if(orig == null) {
      revisedStates[testId] = AFSingleScreenTestState(testId: testId, pass: 0, errors: <String>[], stateView: data, routeParamId: routeParamId, stateViewId: stateViewId, param: param, screen: screen);
    } else {
      revisedStates[testId] = orig.copyWith(pass: 0, errors: <String>[]);
    }
    return revisedStates;

  }

  AFTestState startTest(AFScreenTestContext simulator, dynamic param, dynamic data, AFScreenID screen, String stateViewId, String routeParamId) {
    final testId = simulator.testId;
    final revisedContexts = Map<AFBaseTestID, AFScreenTestContext>.from(testContexts);
    revisedContexts[testId] = simulator;
    final revisedStates = _createTestState(testId, param, data, screen, stateViewId, routeParamId);
    var revisedActive = activeTestIds;
    if(activeTestIds.isEmpty || activeTestIds.last != simulator.testId) {
      revisedActive = List<AFBaseTestID>.from(activeTestIds);
      revisedActive.add(simulator.testId);
    }
    return copyWith(
      activeTestIds: revisedActive,
      testContexts: revisedContexts,
      testStates: revisedStates
    );
  }

  AFTestState updateStateView(AFBaseTestID testId, dynamic stateView) {
    final revisedStates = Map<AFBaseTestID, AFSingleScreenTestState>.from(testStates);
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

  AFTestState incrementPassCount(AFBaseTestID testId) {
    final revisedStates = Map<AFBaseTestID, AFSingleScreenTestState>.from(testStates);
    final currentState = revisedStates[testId];
    revisedStates[testId] = currentState?.incrementPassCount();
    return copyWith(
      testStates: revisedStates
    );
  }

  AFTestState addError(AFBaseTestID testId, String err) {
    final revisedStates = Map<AFBaseTestID, AFSingleScreenTestState>.from(testStates);
    final currentState = revisedStates[testId];
    revisedStates[testId] = currentState.addError(err);
    return copyWith(
      testStates: revisedStates
    );
  }

  AFTestState copyWith({
    List<AFBaseTestID> activeTestIds,
    AFWireframe activeWireframe,
    bool clearActiveWireframe,
    Map<AFBaseTestID, AFScreenTestContext> testContexts,
     Map<AFBaseTestID, AFSingleScreenTestState> testStates
  }) {
    var wf = activeWireframe ?? this.activeWireframe;
    if(clearActiveWireframe != null && clearActiveWireframe) {
      wf = null;
    }
    return AFTestState(
      activeTestIds: activeTestIds ?? this.activeTestIds,
      testContexts: testContexts ?? this.testContexts,
      testStates: testStates ?? this.testStates,
      activeWireframe: wf,
    );
  }
}