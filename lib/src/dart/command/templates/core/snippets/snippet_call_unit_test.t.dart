import 'package:afib/src/dart/command/af_source_template.dart';

class SnippetCallUnitTestT extends AFSourceTemplate {
  static const insertTestName = AFSourceTemplateInsertion("test_name");
  static const insertTestSuffix = AFSourceTemplateInsertion("test_suffix");

  String get template => '  define$insertTestName$insertTestSuffix(context);';
}
