

import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_fundamental_theme_init.t.dart';

class SnippetSigninStarterFundamentalThemeInitT {

  static SnippetFundamentalThemeInitT example() {
    return SnippetFundamentalThemeInitT.custom(
      templateFileId: "fundamental_theme_init",
      templateFolder: AFProjectPaths.pathGenerateStarterSigninSnippets,
      extraTranslations: '''
${AFSourceTemplate.insertAppNamespaceInsertion.upper}WidgetID.textFirstName: "First Name",
${AFSourceTemplate.insertAppNamespaceInsertion.upper}WidgetID.textLastName: "Last Name",
${AFSourceTemplate.insertAppNamespaceInsertion.upper}WidgetID.textZipCode: "Zip Code",
''',
    );
  }

}