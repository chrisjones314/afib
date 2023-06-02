

import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_call_define_lpi.t.dart';

/// Any class that ends in "T" is a source template used in code generation.
class SnippetDeclareLPIIDT extends AFSourceTemplate {
  @override
  String get template => '  static const ${SnippetCallDefineLPIT.insertLPIID} = ${insertAppNamespaceUpper}LibraryProgrammingInterfaceID("${SnippetCallDefineLPIT.insertLPIID}");';
}


