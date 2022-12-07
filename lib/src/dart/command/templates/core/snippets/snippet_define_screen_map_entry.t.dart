
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/screen.t.dart';

class SnippetDefineScreenMapEntryT extends AFCoreSnippetSourceTemplate {
  String get template => "  context.define${ScreenT.insertControlTypeSuffix}($insertAppNamespaceUpper${ScreenT.insertControlTypeSuffix}ID.${ScreenT.insertScreenID}, (_) => $insertMainType(), $insertMainType.config);";
}


