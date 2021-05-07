
import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareStateViewT extends AFSourceTemplate {
  final String template = '''
class [!af_screen_name]StateView extends AFStateView1<String> {
  [!af_screen_name]StateView(String exampleState):
    super(first: exampleState);

  String get exampleState { return first; }
}
''';  
}
