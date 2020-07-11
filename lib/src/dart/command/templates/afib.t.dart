

import 'package:afib/src/dart/command/af_template_source.dart';

class AFibT extends AFTemplateSource {

  AFibT(): super(AFTemplateSourceCreationRule.createAlways);

  @override
  String template() {
    return '''
AfibReplacementPoint(import_afib_command)
void configureAfib(AFConfig config) {
  AfibReplacementPoint(configuration_entries)
}
''';
  }
}
