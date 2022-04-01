

import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareScreenIDStatementT extends AFSourceTemplate {
  final String template = '  static final [!af_screen_id] = [!af_app_namespace(upper)]ScreenID("[!af_screen_name(snake)]");';
}


