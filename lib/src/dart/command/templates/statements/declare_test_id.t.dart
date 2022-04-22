import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareTestIDT extends AFSourceTemplate {
  final String template = '  static const [!af_test_id] = "[!af_test_id(snake)]";';
}
