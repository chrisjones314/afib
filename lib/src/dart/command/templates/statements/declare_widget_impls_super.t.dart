
import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareWidgetImplsSuperT extends AFSourceTemplate {
  final String template = '''
    uiConfig: config,
    widOverride: widOverride,
    launchParam: launchParam,
''';  
}
