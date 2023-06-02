
import 'package:afib/src/dart/command/af_source_template.dart';

class SnippetImportFromPackageT extends AFCoreSnippetSourceTemplate {
  
  @override
  String get template => "import 'package:$insertPackageName/$insertPackagePath';";
}