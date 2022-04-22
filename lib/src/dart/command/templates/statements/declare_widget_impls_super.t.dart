
import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareWidgetImplsSuperT extends AFSourceTemplate {
  final String template = '''
    screenId: screenId, 
    uiConfig: config,
    wid: wid,
    paramSource: paramSource,
''';  
}
