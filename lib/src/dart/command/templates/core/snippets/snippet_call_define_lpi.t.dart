import 'package:afib/src/dart/command/af_source_template.dart';

/// Any class that ends in "T" is a source template used in code generation.
class SnippetCallDefineLPIT extends AFSourceTemplate {
  static const insertLPIID = AFSourceTemplateInsertion("lpi_id");
  static const insertLPIType = AFSourceTemplateInsertion("lpi_type");

  @override
  String get template => '  context.defineLPI($insertLPIID, createLPI: $insertLPIType.create);';
}

