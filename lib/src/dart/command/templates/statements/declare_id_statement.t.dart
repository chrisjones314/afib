

import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareIDStatementT extends AFSourceTemplate {
  final String template = '  static const [!af_screen_id] = [!af_app_namespace(upper)][!af_control_type_suffix]ID("[!af_screen_id]");';
}


