import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';

class SnippetScreenBuildWithSPIImplT extends AFSnippetSourceTemplate {
  static const insertAppBarParams = AFSourceTemplateInsertion("app_bar_params");
  
  SnippetScreenBuildWithSPIImplT({
    String? templateFileId,
    required List<String> templateFolder,
    required AFSourceTemplateInsertions? embeddedInsertions,
  }): super(
    templateFileId: templateFileId ?? "screen_build_with_spi_impl",
    templateFolder: templateFolder,
    embeddedInsertions: embeddedInsertions
  );

  factory SnippetScreenBuildWithSPIImplT.core() {
    return SnippetScreenBuildWithSPIImplT(
      templateFolder: AFProjectPaths.pathGenerateCoreSnippets,
      embeddedInsertions: AFSourceTemplateInsertions(insertions: {
        insertAppBarParams: '''
leading: t.leadingButtonStandardBack(spi, screen: screenId),
'''
      })
    );
  }

  factory SnippetScreenBuildWithSPIImplT.coreNoBackButton() {
    return SnippetScreenBuildWithSPIImplT(
      templateFileId: "screen_build_with_spi_impl_no_back",
      templateFolder: AFProjectPaths.pathGenerateCoreSnippets,
      embeddedInsertions: AFSourceTemplateInsertions(insertions: {
        insertAppBarParams: AFSourceTemplate.empty,
      })
    );
  }


  String get template => '''
final t = spi.t;
final body = _buildBody(spi);
return t.childScaffold(
  spi: spi,
  body: body,
  appBar: AppBar(
    title: t.childText(text: "${insertMainType.spaces}"),
    $insertAppBarParams
    // IMPORTANT: Don't let Flutter automatically add its own back button, as that 
    // will get out of sync with AFib's route state.   Instead you must use
    // leading: t.leadingButtonStandardBack..., which is done by default for you 
    // in most cases.
    automaticallyImplyLeading: false,
  ),
);
''';
}

