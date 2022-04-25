import 'package:afib/afib_flutter.dart';
import 'package:meta/meta.dart';

@immutable
class AFLibraryProgrammingInterface with AFNavigateMixin, AFUpdateAppStateMixin {
  final AFLibraryProgrammingInterfaceID id;
  
  @protected
  final AFPublicState state;

  @protected
  final AFDispatcher dispatcher;

  void dispatch(dynamic action) {
    dispatcher.dispatch(action);
  }

  AFLibraryProgrammingInterface(this.id, this.dispatcher, this.state);
}