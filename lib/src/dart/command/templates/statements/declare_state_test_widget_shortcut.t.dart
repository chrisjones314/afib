
import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareStateTestWidgetShortcutT extends AFSourceTemplate {
  final String template = '''
  AFStateTestWidgetShortcut<[!af_screen_name]SPI> create[!af_screen_name](AFStateTestScreenShortcut screen) {
    return screen.createWidgetShortcut<[!af_screen_name]SPI>([!af_screen_id_type].[!af_screen_id], [!af_screen_name].config);
  }
''';  
}
