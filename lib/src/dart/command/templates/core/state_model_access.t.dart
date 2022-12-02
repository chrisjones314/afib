import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';

class StateModelAccessT extends AFFileSourceTemplate {

  StateModelAccessT(): super(
    templatePath: const <String>[AFProjectPaths.folderCore, "state_model_access"],
  );


  String get template => '''
import 'package:afib/afib_flutter.dart';

mixin ${insertAppNamespaceUpper}StateModelAccess on AFStateModelAccess {
}

''';

}



