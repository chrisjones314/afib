

import 'package:afib/src/dart/command/af_source_template.dart';

class AFibT extends AFSourceTemplate {
  final String template = '''
import 'package:afib/afib_command.dart';

void configureAfib(AFConfig config) {
  [!af_config_entries]
}

''';
}
