

import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';

class LibraryExportsT extends AFFileSourceTemplate {
  LibraryExportsT(): super(
    templatePath: const <String>[AFProjectPaths.folderCore, "library_exports"],
  );

  String get template => '''
library $insertPackageName;

''';

}





