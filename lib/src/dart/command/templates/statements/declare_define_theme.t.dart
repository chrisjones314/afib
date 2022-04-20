  
  
import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareDefineThemeT extends AFSourceTemplate {
  final String template = '  context.defineTheme([!af_theme_id], createTheme: [!af_theme_type].create);';
}
