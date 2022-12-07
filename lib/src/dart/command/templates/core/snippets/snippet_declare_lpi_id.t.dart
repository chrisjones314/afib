

import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_call_define_lpi.t.dart';

class SnippetDeclareLPIIDT extends AFSourceTemplate {
  String get template => '  static const ${SnippetCallDefineLPIT.insertLPIID} = ${insertAppNamespaceUpper}LibraryProgrammingInterfaceID("${SnippetCallDefineLPIT.insertLPIID}");';
}


