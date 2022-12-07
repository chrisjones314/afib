import 'package:afib/src/dart/command/af_source_template.dart';

class SnippetCallDefineLPIT extends AFSourceTemplate {
  static const insertLPIID = AFSourceTemplateInsertion("lpi_id");
  static const insertLPIType = AFSourceTemplateInsertion("lpi_type");

  String get template => '  context.defineLPI($insertLPIID, createLPI: $insertLPIType.create);';
}

