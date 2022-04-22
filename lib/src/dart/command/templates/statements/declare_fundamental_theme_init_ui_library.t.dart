
import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareFundamentalThemeInitUILibraryT extends AFSourceTemplate {
  final String template = '''
  primary.setTranslations(AFUILocaleID.englishUS, {
    AFUITranslationID.appTitle: "hellolib"
  });
''';
}