

import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';

class ConfigT extends AFFileSourceTemplate {
  static const insertConfigEntries = AFSourceTemplateInsertion("config_entries");

  ConfigT(): super(
    templatePath: const <String>[AFProjectPaths.folderCore, "config"],
  );

  String get template => '''
import 'package:afib/afib_command.dart';

void configureAfib(AFConfig config) {
  $insertConfigEntries
}

''';
}
