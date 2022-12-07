
import 'package:afib/src/dart/command/af_source_template.dart';

class SnippetFundamentalThemeInitUILibraryT extends AFCoreSnippetSourceTemplate {
  String get template => '''
  primary.setTranslations(AFUILocaleID.englishUS, {
    AFUITranslationID.appTitle: "$insertPackageName"
  });
''';
}