import 'package:afib/src/dart/command/af_source_template.dart';

/// Any class that ends in "T" is a source template used in code generation.
class ConfigT extends AFCoreFileSourceTemplate {
  static const insertConfigEntries = AFSourceTemplateInsertion("config_entries");

  ConfigT(): super(
    templateFileId: "config",
  );

  @override
  String get template => '''
import 'package:afib/afib_command.dart';

void configureAfib(AFConfig config) {
  $insertConfigEntries
}

''';
}
