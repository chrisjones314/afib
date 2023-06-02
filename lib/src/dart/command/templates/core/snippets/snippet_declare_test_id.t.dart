import 'package:afib/src/dart/command/af_source_template.dart';

/// Any class that ends in "T" is a source template used in code generation.
class SnippetDeclareStringTestIDT extends AFCoreSnippetSourceTemplate {
  static const insertTestId = AFSourceTemplateInsertion("test_id");

  @override
  String get template => '  static const $insertTestId = "$insertTestId";';
}

/// Any class that ends in "T" is a source template used in code generation.
class SnippetDeclareClassTestIDT extends AFSourceTemplate {
  static const insertTestId = AFSourceTemplateInsertion("test_id");
  static const insertClassId = AFSourceTemplateInsertion("class_id");

  @override
  final String template = '  static const $insertTestId = $insertClassId("$insertTestId");';
}

