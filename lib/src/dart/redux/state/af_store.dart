import 'package:afib/src/dart/redux/state/af_state.dart';
import 'package:redux/redux.dart';

class AFStore extends Store<AFState> {
  AFStore(super.reducer, {
    required super.initialState,
    required super.middleware
  });
}
