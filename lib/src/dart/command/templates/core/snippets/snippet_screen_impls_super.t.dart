
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/screen.t.dart';

class SnippetScreenImplsSuperT extends AFCoreSnippetSourceTemplate {
  final bool usePlainConfig;

  SnippetScreenImplsSuperT({
    this.usePlainConfig = true
  });
  

  String get template {
    final superConfigName = usePlainConfig ? "config" : "uiConfig";
    return '''
    screenId: ${ScreenT.insertScreenIDType}.${ScreenT.insertScreenID}, 
    $superConfigName: config,
''';  
  }
}
