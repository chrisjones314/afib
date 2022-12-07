
import 'package:afib/src/dart/command/af_source_template.dart';

class SnippetExportStatementT extends AFSourceTemplate {
  static const insertPath = AFSourceTemplateInsertion("path");

  String get template => "export '$insertPath';";
}


