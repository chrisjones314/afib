  
  
import 'package:afib/src/dart/command/af_source_template.dart';

/// Any class that ends in "T" is a source template used in code generation.
class SnippetCallDefineThemeT extends AFSourceTemplate {
  static const insertThemeID = AFSourceTemplateInsertion("theme_id");
  static const insertThemeType = AFSourceTemplateInsertion("theme_type");

  @override
  String get template => '  context.defineTheme($insertThemeID, createTheme: $insertThemeType.create);';
}
