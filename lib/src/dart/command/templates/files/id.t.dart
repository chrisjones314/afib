


import 'package:afib/src/dart/command/af_source_template.dart';

class IdentifierT extends AFSourceTemplate {

  final String template = '''
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

