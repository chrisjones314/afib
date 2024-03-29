import 'package:afib/src/dart/redux/state/af_state.dart';
import 'package:redux/redux.dart';

class AFStore extends Store<AFState> {
  AFStore(Reducer<AFState> reducer, {
    required AFState initialState,
    required List<Middleware<AFState>> middleware
  }): super(reducer, initialState: initialState, middleware: middleware);
}
