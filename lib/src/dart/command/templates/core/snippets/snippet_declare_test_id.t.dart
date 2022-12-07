import 'package:afib/src/dart/command/af_source_template.dart';

class SnippetDeclareStringTestIDT extends AFCoreSnippetSourceTemplate {
  static const insertTestId = AFSourceTemplateInsertion("test_id");

  String get template => '  static const $insertTestId = "$insertTestId";';
}


class SnippetDeclareClassTestIDT extends AFSourceTemplate {
  static const insertTestId = AFSourceTemplateInsertion("test_id");
  static const insertClassId = AFSourceTemplateInsertion("class_id");

  final String template = '  static const $insertTestId = $insertClassId("$insertTestId");';
}

