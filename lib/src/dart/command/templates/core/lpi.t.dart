



import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';

class LPIT extends AFFileSourceTemplate {

  LPIT(): super(
    templatePath: const <String>[AFProjectPaths.folderCore, "lpi"],
  );  

  String get template => '''
import 'package:afib/afib_flutter.dart';

class $insertMainType extends $insertMainParentType {

  $insertMainType(AFLibraryProgrammingInterfaceID id, AFLibraryProgrammingInterfaceContext context): super(id, context);

  factory $insertMainType.create(AFLibraryProgrammingInterfaceID id, AFLibraryProgrammingInterfaceContext context) {
    return $insertMainType(id, context);
  }
}
''';

}






