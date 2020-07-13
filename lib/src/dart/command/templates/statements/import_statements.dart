
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/utils/af_config_entries.dart';

class ImportAfibCommandT extends AFOneLineStatementSourceTemplate {
  ImportAfibCommandT(): super(AFConfigEntries.afNamespace, "import_afib_command", "import 'package:afib/afib_command.dart';");
}

class ImportAfibDartT extends AFOneLineStatementSourceTemplate {
  ImportAfibDartT(): super(AFConfigEntries.afNamespace, "import_afib_dart", "import 'package:afib/afib_command.dart';");
}
