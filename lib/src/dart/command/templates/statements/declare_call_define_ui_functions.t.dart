import 'package:afib/src/dart/command/af_source_template.dart';

class CallUIFunctionsT extends AFSourceTemplate {
  final String template = '''
  defineFunctionalThemes(context);
  defineScreens(context);
''';
}
