import 'package:afib/src/dart/command/af_source_template.dart';

/// Any class that ends in "T" is a source template used in code generation.
class StateModelAccessT extends AFCoreFileSourceTemplate {

  StateModelAccessT(): super(
    templateFileId: "state_model_access",
  );


  @override
  String get template => '''
// ignore_for_file: unused_import

import 'package:afib/afib_command.dart';
import 'package:afib/afib_flutter.dart';

mixin ${insertAppNamespaceUpper}StateModelAccess on AFStateModelAccess {
}

''';

}



