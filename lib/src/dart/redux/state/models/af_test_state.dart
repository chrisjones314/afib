import 'package:afib/id.dart';
import 'package:afib/src/dart/redux/actions/af_route_actions.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:afib/src/flutter/test/af_wireframe.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:meta/meta.dart';

@immutable 
class AFSingleScreenTestState {
  final AFBaseTestID testId;
  final int pass;
  final List<String> errors;
  final Map<String, Object>? models;
  final AFNavigatePushAction navigate;
  final AFTestTimeHandling timeHandling;

  AFSingleScreenTestState({
    required this.testId,
    required this.navigate,
    required this.pass, 
    required this.errors, 
    required this.models, 
    required this.timeHandling,
  });

  AFSingleScreenTestState reviseModels(dynamic data) {
    return copyWith(models: data);
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
    int? pass, 
    List<String>? errors, 
    dynamic models
  }) {
    return AFSingleScreenTestState(
      models: models ?? this.models,
      errors: errors ?? this.errors,
      pass: pass ?? this.pass,
      navigate: this.navigate,
      testId: this.testId,
      timeHandling: this.timeHandling
    );
  }
}


@immutable
class AFTestState {
  final List<AFBaseTestID> activeTestIds;
  final AFWireframe? activeWireframe;
  final Map<AFBaseTestID, AFScreenTestContext> testContexts;
  final Map<AFBaseTestID, AFSingleScreenTestState> testStates;

  AFTestState({
    required this.activeTestIds, 
    required this.activeWireframe,
    required this.testContexts, 
    required this.testStates
  });

  factory AFTestState.initial() {
    return AFTestState(
      activeTestIds: <AFBaseTestID>[],
      activeWireframe: null,
      testContexts: <AFBaseTestID, AFScreenTestContext>{}, 
      testStates:<AFBaseTestID, AFSingleScreenTestState>{}
    );
  }

  AFBaseTestID? findTestForScreen(AFScreenID? screen) {
    for(final testState in testStates.values) {
      if(testState.navigate.screenId == screen) {
        return testState.testId;
      }
    }

    // this catches the case where you have a dialog with a different
    // screen id.   The assumption is that this only occurs on the active screen.
    return activeTestId;
  }

  AFBaseTestID? get activeTestId {
    if(activeTestIds.isEmpty) {
      return null;
    }
    return activeTestIds.last;
  }

  AFScreenTestContext? findContext(AFBaseTestID id) {
    return testContexts[id];
  }

  AFSingleScreenTestState? findState(AFBaseTestID id) {
    // if we are in an active wireframe, then use the test state for that wireframe.
    if(activeWireframe != null) {
      return testStates[AFUIReusableTestID.wireframe];
    }

    return testStates[id];
  }

  AFTestState navigateToTest(AFScreenPrototype test, AFNavigatePushAction navigate, dynamic models) {
    final revisedStates = _createTestState(test.id, test.navigate, models, timeHandling: test.timeHandling);
    final revisedActive = List<AFBaseTestID>.from(activeTestIds);
    revisedActive.add(test.id);
    return copyWith(activeTestIds: revisedActive, testStates: revisedStates);
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

    final revisedStates = Map<AFBaseTestID, AFSingleScreenTestState>.from(testStates);
    final testId = AFUIReusableTestID.wireframe;
    final models = AFibF.g.testData.resolveStateViewModels(wireframe.models);
    final currentState = revisedStates[testId] ?? AFSingleScreenTestState(
      testId: AFUIReusableTestID.wireframe,
      models: models,
      pass: 0, 
      errors: <String>[],
      navigate: AFNavigatePushAction(routeParam: AFRouteParamUnused.unused),
      timeHandling: AFTestTimeHandling.running,
    );
    revisedStates[testId] = currentState.reviseModels(models);
    return copyWith(
      activeWireframe: wireframe,
      testStates: revisedStates
    );
  }

  Map<AFBaseTestID, AFSingleScreenTestState> _createTestState(AFBaseTestID testId, AFNavigatePushAction navigate, dynamic models, { required AFTestTimeHandling timeHandling }) {
    final revisedStates = Map<AFBaseTestID, AFSingleScreenTestState>.from(testStates);
    final orig = testStates[testId];
    if(orig == null) {
      revisedStates[testId] = AFSingleScreenTestState(testId: testId, pass: 0, errors: <String>[], models: models, navigate: navigate, timeHandling: timeHandling);
    } else {
      revisedStates[testId] = orig.copyWith(pass: 0, errors: <String>[]);
    }
    return revisedStates;

  }

  AFTestState startTest(AFScreenTestContext simulator, AFNavigatePushAction navigate, dynamic data, { required AFTestTimeHandling timeHandling }) {
    final testId = simulator.testId;
    final revisedContexts = Map<AFBaseTestID, AFScreenTestContext>.from(testContexts);
    revisedContexts[testId] = simulator;
    final revisedStates = _createTestState(testId, navigate, data, timeHandling: timeHandling);
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

  AFTestState updateModels(AFBaseTestID testId, dynamic models) {
    final revisedStates = Map<AFBaseTestID, AFSingleScreenTestState>.from(testStates);
    final currentState = revisedStates[testId];
    if(currentState == null) {
      throw AFException("Internal error, calling updateStateView when there is no test state for $testId");
    } else {
      revisedStates[testId] = currentState.reviseModels(models);

    }
    return copyWith(
      testStates: revisedStates
    );
  }

  AFTestState incrementPassCount(AFBaseTestID testId) {
    final revisedStates = Map<AFBaseTestID, AFSingleScreenTestState>.from(testStates);
    final currentState = revisedStates[testId];
    if(currentState != null) {
      revisedStates[testId] = currentState.incrementPassCount();
    }
    return copyWith(
      testStates: revisedStates
    );
  }

  AFTestState addError(AFBaseTestID testId, String err) {
    final revisedStates = Map<AFBaseTestID, AFSingleScreenTestState>.from(testStates);
    final currentState = revisedStates[testId];
    if(currentState != null) {
      revisedStates[testId] = currentState.addError(err);
    }
    return copyWith(
      testStates: revisedStates
    );
  }

  AFTestState copyWith({
    List<AFBaseTestID>? activeTestIds,
    AFWireframe? activeWireframe,
    bool? clearActiveWireframe,
    Map<AFBaseTestID, AFScreenTestContext>? testContexts,
    Map<AFBaseTestID, AFSingleScreenTestState>? testStates
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