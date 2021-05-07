

import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareIDStatementT extends AFSourceTemplate {
  final String template = '  static final [!af_screen_name(lower)] = AFScreenID("[!af_screen_name(snake)]", [!af_app_namespace(upper)]LibraryID.id);';
}


