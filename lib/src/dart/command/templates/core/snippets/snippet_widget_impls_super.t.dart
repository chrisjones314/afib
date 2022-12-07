
import 'package:afib/src/dart/command/af_source_template.dart';

class SnippetWidgetImplsSuperT extends AFCoreSnippetSourceTemplate {
  String get template => '''
    uiConfig: config,
    widOverride: widOverride,
    launchParam: launchParam,
''';  
}
