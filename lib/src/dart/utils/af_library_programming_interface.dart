import 'package:afib/afib_flutter.dart';
import 'package:afib/src/flutter/utils/af_api_mixins.dart';
import 'package:meta/meta.dart';

class AFCurrentStateContext<TState extends AFFlexibleState> with AFStandardAPIContextMixin, AFNonUIAPIContextMixin, AFAccessStateSynchronouslyMixin {
  @protected
  final AFDispatcher dispatcher;

  AFCurrentStateContext({
    required this.dispatcher,
  });

  void dispatch(dynamic action) {
    dispatcher.dispatch(action);
  }

  AFPublicState get publicState {
    return AFibF.g.internalOnlyActiveStore.state.public;
  }
}


class AFLibraryProgrammingInterfaceContext<TState extends AFFlexibleState> extends AFCurrentStateContext {
  AFLibraryProgrammingInterfaceContext({
    required AFDispatcher dispatcher,
  }): super(
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