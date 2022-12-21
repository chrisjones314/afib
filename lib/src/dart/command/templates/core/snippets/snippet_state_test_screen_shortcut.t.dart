
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/screen.t.dart';

class SnippetStateTestScreenShortcutT extends AFSourceTemplate {
  String get template => '''
  AFStateTest${ScreenT.insertControlTypeSuffix}Shortcut<${insertMainType}SPI> create$insertMainType() {
    return testContext.create${ScreenT.insertControlTypeSuffix}Shortcut<${insertMainType}SPI>(${ScreenT.insertScreenIDType}.${ScreenT.insertScreenID});
  }
''';  
}
