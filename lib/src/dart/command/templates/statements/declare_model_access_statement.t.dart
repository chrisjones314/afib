import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareModelAccessStatementT extends AFSourceTemplate {
  final String template = '  [!af_model_name] get [!af_model_name(camel)] { return findType<[!af_model_name]>(); }';
}