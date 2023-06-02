

import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/screen.t.dart';

/// Any class that ends in "T" is a source template used in code generation.
class SnippetIDStatementT extends AFSourceTemplate {
  String get template => '  static const ${ScreenT.insertScreenID} = $insertAppNamespaceUpper${ScreenT.insertControlTypeSuffix}ID("${ScreenT.insertScreenID}");';
}


