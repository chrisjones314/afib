import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareCallExtendT extends AFSourceTemplate {
  final String template = '  [!af_package_code]Extend[!af_extend_kind](context);';
}
