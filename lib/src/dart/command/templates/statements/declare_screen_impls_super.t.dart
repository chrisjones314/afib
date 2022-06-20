
import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareScreenImplsSuperT extends AFSourceTemplate {
  final bool usePlainConfig;

  DeclareScreenImplsSuperT({
    this.usePlainConfig = false
  });
  

  String get template {
    final superConfigName = usePlainConfig ? "config" : "uiConfig";
    return '''
    screenId: [!af_screen_id_type].[!af_screen_id], 
    $superConfigName: config,
''';  
  }
}
