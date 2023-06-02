import 'package:afib/src/dart/command/af_source_template.dart';

class SnippetImportInstallTestsT extends AFCoreSnippetSourceTemplate {
  @override
  String get template => "import 'package:$insertPackagePath/initialization/install/install_test.dart';";
}
