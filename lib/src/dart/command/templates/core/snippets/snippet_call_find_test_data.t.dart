import 'package:afib/src/dart/command/af_source_template.dart';

class SnippetCallFindTestDataT extends AFSourceTemplate {
  String get template => 'context.find(${insertAppNamespaceUpper}TestDataID.stateFullLogin$insertMainType),';
}
