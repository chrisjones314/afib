

import 'package:afib/src/dart/command/af_template_source.dart';

class AFibT extends AFTemplateSource {

  @override
  String template() {
    return '''
[!import_afib_command!]
void configureAfib(AFConfig config) {
  [!configuration_entries!]
}
''';
  }
}
