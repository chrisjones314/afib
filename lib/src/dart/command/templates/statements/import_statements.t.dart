
import 'package:afib/src/dart/command/af_source_template.dart';

class ImportAfibCommandT extends AFSourceTemplate {
  final template = "import 'package:afib/afib_command.dart';";
}

class ImportAfibDartT extends AFSourceTemplate {
  final template = "import 'package:afib/afib_command.dart';";
}

class ImportFromPackage extends AFSourceTemplate {
  final template = "import 'package:[!af_package_name]/[!af_package_path]';";
}