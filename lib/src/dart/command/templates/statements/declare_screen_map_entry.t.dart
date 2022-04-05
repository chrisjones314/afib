
import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareRegisterScreenMapT extends AFSourceTemplate {
  final String template = "  screens.register[!af_control_type_suffix]([!af_app_namespace(upper)][!af_control_type_suffix]ID.[!af_screen_id], (_) => [!af_screen_name]());";
}


