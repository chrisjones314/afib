

import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/utils/af_config_entries.dart';

class AFibT extends AFFileSourceTemplate {

  AFibT(): super(AFConfigEntries.afNamespace, AFProjectPaths.afibConfigFile, AFFileTemplateCreationRule.createAlways);

  @override
  String get template {
    return '''
AFRP(import_afib_command)
void configureAfib(AFConfig config) {
  AFRP(configuration_entries)
}
''';
  }
}
