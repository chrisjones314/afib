
import 'package:afib/src/dart/command/af_source_template.dart';

class SnippetFundamentalThemeInitUILibraryT extends AFSnippetSourceTemplate {
  String get template => '''
  primary.setTranslations(AFUILocaleID.englishUS, {
    AFUITranslationID.appTitle: "$insertPackageName"
  });
''';
}