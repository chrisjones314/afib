
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/screen.t.dart';

class SnippetStateTestWidgetShortcutT extends AFSourceTemplate {
  @override
  String get template => '''
  AFStateTestWidgetShortcut<${insertMainType}SPI> create$insertMainType(AFStateTestScreenShortcut screen) {
    return screen.createWidgetShortcut<${insertMainType}SPI>(${ScreenT.insertScreenIDType}.${ScreenT.insertScreenID}, $insertMainType.config);
  }
''';  
}
