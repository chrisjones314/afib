

import 'package:afib/src/dart/command/af_source_template.dart';

class AFibT extends AFSourceTemplate {
  final String template = '''
// File last generated at [!af_timestamp] on [!af_machinestamp]
import 'package:afib/afib_command.dart';

void configureAfib(AFConfig config) {
  [!af_config_entries]
}

''';
}
