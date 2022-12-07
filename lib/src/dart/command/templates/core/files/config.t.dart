import 'package:afib/src/dart/command/af_source_template.dart';

class ConfigT extends AFCoreFileSourceTemplate {
  static const insertConfigEntries = AFSourceTemplateInsertion("config_entries");

  ConfigT(): super(
    templateFileId: "config",
  );

  String get template => '''
import 'package:afib/afib_command.dart';

void configureAfib(AFConfig config) {
  $insertConfigEntries
}

''';
}
