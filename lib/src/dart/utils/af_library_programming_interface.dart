import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/command/af_standard_configs.dart';
import 'package:afib/src/flutter/utils/af_api_mixins.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';

class AFCurrentStateContext with AFStandardAPIContextMixin, AFStandardNavigateMixin, AFNonUIAPIContextMixin, AFAccessStateSynchronouslyMixin, AFContextShowMixin {
  final AFDispatcher dispatcher;
  final AFConceptualStore targetStore;

  AFCurrentStateContext({
    required this.dispatcher,
    required this.targetStore,
  });

  void dispatch(dynamic action) {
    dispatcher.dispatch(action);
  }

  AFPublicState get publicState {
    return AFibF.g.internalOnlyActiveStore.state.public;
  }
}

class AFLibraryProgrammingInterfaceContext extends AFCurrentStateContext {
  AFLibraryProgrammingInterfaceContext({
    required AFDispatcher dispatcher,
    required AFConceptualStore targetStore,
  }): super(
    dispatcher: dispatcher,
    targetStore: targetStore,
  );

  Logger? get log {
    return AFibD.log(AFConfigEntryLogArea.query);
  }
}


@immutable
class AFLibraryProgrammingInterface {
  final AFLibraryProgrammingInterfaceID id;

  @protected 
  final AFLibraryProgrammingInterfaceContext context;
  
  AFLibraryProgrammingInterface(this.id, this.context);


}