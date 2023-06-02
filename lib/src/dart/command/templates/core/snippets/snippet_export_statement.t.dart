
import 'package:afib/src/dart/command/af_source_template.dart';

/// Any class that ends in "T" is a source template used in code generation.
class SnippetExportStatementT extends AFSourceTemplate {
  static const insertPath = AFSourceTemplateInsertion("path");

  @override
  String get template => "export '$insertPath';";
}


