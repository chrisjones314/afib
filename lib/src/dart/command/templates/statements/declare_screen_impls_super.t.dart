
import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareScreenImplsSuperT extends AFSourceTemplate {
  final String template = '''
    screenId: [!af_screen_id_type].[!af_screen_id], 
    uiConfig: config,
''';  
}
