  
  
import 'package:afib/src/dart/command/af_source_template.dart';

class SnippetCallDefineThemeT extends AFSourceTemplate {
  static const insertThemeID = AFSourceTemplateInsertion("theme_id");
  static const insertThemeType = AFSourceTemplateInsertion("theme_type");

  String get template => '  context.defineTheme($insertThemeID, createTheme: $insertThemeType.create);';
}
