import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareIncludeInstallTestsT extends AFSourceTemplate {
  final String template = "import 'package:[!af_package_path]/initialization/install/install_test.dart';";
}
