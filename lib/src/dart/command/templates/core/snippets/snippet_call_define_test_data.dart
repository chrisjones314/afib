import 'package:afib/src/dart/command/af_source_template.dart';

/// Any class that ends in "T" is a source template used in code generation.
class SnippetCallDefineTestDataT extends AFCoreSnippetSourceTemplate {
  @override
  String get template => '  _define$insertMainType(context);';
}
