
import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareStateTestScreenShortcutT extends AFSourceTemplate {
  final String template = '''
  AFStateTestScreenShortcut<[!af_screen_name]SPI> create[!af_screen_name]Screen() {
    return testContext.create[!af_control_type_suffix]Shortcut<[!af_screen_name]SPI>([!af_screen_id_type].[!af_screen_id]);
  }
''';  
}
