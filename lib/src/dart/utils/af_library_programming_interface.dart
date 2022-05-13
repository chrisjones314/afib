import 'package:afib/afib_flutter.dart';
import 'package:meta/meta.dart';

class AFLibraryProgrammingInterfaceContext<TState extends AFFlexibleState> with AFNavigateMixin, AFUpdateComponentStateMixin<TState>, AFStateAccessMixin {
  final AFPublicState state;

  @protected
  final AFDispatcher dispatcher;

  AFLibraryProgrammingInterfaceContext({
    required this.state,
    required this.dispatcher,
  });

  void dispatch(dynamic action) {
    dispatcher.dispatch(action);
  }

  AFPublicState get publicState {
    return state;
  }

  TOtherState findState<TOtherState extends AFFlexibleState>() {
    final result = state.components.findState<TOtherState>();
    return result!;
  }
}


class AFCurrentStateContext<TState extends AFFlexibleState> extends AFLibraryProgrammingInterfaceContext<TState> {

  AFCurrentStateContext({
    required AFPublicState state,
    required AFDispatcher dispatcher,
  }): super(
    state: state,
    dispatcher: dispatcher,
  );

}

@immutable
class AFLibraryProgrammingInterface<TState extends AFFlexibleState> {
  final AFLibraryProgrammingInterfaceID id;

  @protected 
  final AFLibraryProgrammingInterfaceContext context;
  
  AFLibraryProgrammingInterface(this.id, this.context);


}