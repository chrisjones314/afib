import 'package:afib/src/dart/command/af_source_template.dart';

/// Any class that ends in "T" is a source template used in code generation.
class SnippetCallFindTestDataT extends AFSourceTemplate {
  String get template => 'context.find(${insertAppNamespaceUpper}TestDataID.stateFullLogin$insertMainType),';
}
