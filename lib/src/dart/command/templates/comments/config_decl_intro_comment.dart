
import 'package:afib/src/dart/command/af_source_template.dart';

class ConfigDeclIntroComment extends AFSourceTemplateComment {
  final String template = '''
  /// This declaration summarizes the 'essence' of the screen or widget, enabling the 
  /// state testing framework to simulate its existence without actually building the
  /// UI.
''';
}
