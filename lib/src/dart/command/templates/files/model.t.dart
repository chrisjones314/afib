

import 'package:afib/src/dart/command/af_source_template.dart';

class AFModelT extends AFSourceTemplate {

  final String template = '''
import 'package:meta/meta.dart';

@immutable
class [!af_model_name] {
  [!af_model_name]();
}
''';
}
