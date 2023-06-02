import 'package:afib/src/dart/command/af_source_template.dart';

/// Any class that ends in "T" is a source template used in code generation.
class LibraryExportsT extends AFCoreFileSourceTemplate {
  LibraryExportsT(): super(
    templateFileId: "library_exports",
  );

  @override
  String get template => '''
library $insertPackageName;

''';

}





