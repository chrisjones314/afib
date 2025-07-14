
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_fundamental_theme_init.t.dart';

/// Any class that ends in "T" is a source template used in code generation.
class SnippetFundamentalThemeInitUILibraryT extends AFSnippetSourceTemplate {

  SnippetFundamentalThemeInitUILibraryT({
    required super.templateFileId,
    required super.templateFolder,
    required super.embeddedInsertions,
  });

  factory SnippetFundamentalThemeInitUILibraryT.custom({
    required String templateFileId,
    required List<String> templateFolder,
    required Object extraTranslations,
  }) {
    return SnippetFundamentalThemeInitUILibraryT(
      templateFileId: templateFileId,
      templateFolder: templateFolder,
      embeddedInsertions: AFSourceTemplateInsertions(insertions: {
        SnippetFundamentalThemeInitT.insertExtraTranslations: extraTranslations,
      })
    );

  }

  factory SnippetFundamentalThemeInitUILibraryT.core() {
    return SnippetFundamentalThemeInitUILibraryT.custom(
      templateFileId: "fundamental_theme_ui_init",
      templateFolder: AFProjectPaths.pathGenerateCoreSnippets,
      extraTranslations: AFSourceTemplate.empty,
    );
  }
  
  @override
  String get template => '''
  primary.setTranslations(AFUILocaleID.englishUS, {
    AFUITranslationID.appTitle: "${insertPackageName.spaces}"
    ${SnippetFundamentalThemeInitT.insertExtraTranslations}
  });
''';
}