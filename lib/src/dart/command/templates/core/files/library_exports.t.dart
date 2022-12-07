import 'package:afib/src/dart/command/af_source_template.dart';

class LibraryExportsT extends AFCoreFileSourceTemplate {
  LibraryExportsT(): super(
    templateFileId: "library_exports",
  );

  String get template => '''
library $insertPackageName;

''';

}





