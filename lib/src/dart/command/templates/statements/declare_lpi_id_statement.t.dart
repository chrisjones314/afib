

import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareLPIIDStatementT extends AFSourceTemplate {
  final String template = '  static const [!af_lpi_id] = [!af_app_namespace(upper)]LibraryProgrammingInterfaceID("[!af_lpi_id]");';
}


