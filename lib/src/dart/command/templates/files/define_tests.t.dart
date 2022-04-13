
import 'package:afib/src/dart/command/af_source_template.dart';

class AFDefineTestsT extends AFSourceTemplate {

  final String template = '''
import 'package:afib/afib_flutter.dart';

void define[!af_test_kind]s(AF[!af_test_kind]DefinitionContext definitions) {
}
''';
}
