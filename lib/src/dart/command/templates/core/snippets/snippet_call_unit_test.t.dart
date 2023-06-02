import 'package:afib/src/dart/command/af_source_template.dart';

/// Any class that ends in "T" is a source template used in code generation.
class SnippetCallUnitTestT extends AFSourceTemplate {
  static const insertTestName = AFSourceTemplateInsertion("test_name");
  static const insertTestSuffix = AFSourceTemplateInsertion("test_suffix");

  @override
  String get template => '  define$insertTestName$insertTestSuffix(context);';
}
