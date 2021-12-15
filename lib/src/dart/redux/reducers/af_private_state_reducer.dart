

import 'package:afib/src/dart/redux/reducers/af_test_contexts_reducer.dart';
import 'package:afib/src/dart/redux/state/af_state.dart';

AFPrivateState afPrivateStateReducer(AFPrivateState state, dynamic action) {

  return state.copyWith(
    testState: afTestStateReducer(state.testState, action)
  );
}