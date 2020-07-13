


import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/utils/af_config_entries.dart';

class IdentifierT extends AFFileSourceTemplate {

  IdentifierT(): super(AFConfigEntries.afNamespace, AFProjectPaths.idFile, AFFileTemplateCreationRule.updateInPlace);

  @override
  String get template {
    return '''
AFRP(import_afib_dart)

// IDs will often be created for you as part of the generate command.
// If you need to generate additional ids, you can create them by hand, or by
// using the sub-command 'generate id widget myWidget', 
// 'generate id screen myScreen', etc.

class ScreenID {
  // AFibInsertionPoint(ScreenID)
}

class WidgetID {
  // AFibInsertionPoint(WidgetID)
}

class QueryID {
  // AFibInsertionPoint(QueryID)
}
''';
  }
}

