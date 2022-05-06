import 'package:afib/afib_flutter.dart';
import 'package:meta/meta.dart';

class AFLibraryProgrammingInterfaceContext with AFNavigateMixin, AFUpdateAppStateMixin {
  @protected
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

}

@immutable
class AFLibraryProgrammingInterface {
  final AFLibraryProgrammingInterfaceID id;

  @protected 
  final AFLibraryProgrammingInterfaceContext context;
  
  AFLibraryProgrammingInterface(this.id, this.context);
}