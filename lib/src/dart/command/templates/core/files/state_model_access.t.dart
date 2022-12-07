import 'package:afib/src/dart/command/af_source_template.dart';

class StateModelAccessT extends AFCoreFileSourceTemplate {

  StateModelAccessT(): super(
    templateFileId: "state_model_access",
  );


  String get template => '''
import 'package:afib/afib_flutter.dart';

mixin ${insertAppNamespaceUpper}StateModelAccess on AFStateModelAccess {
}

''';

}



