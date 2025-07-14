import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';

class SnippetScreenBuildWithSPIImplT extends AFSnippetSourceTemplate {
  static const insertAppBarParams = AFSourceTemplateInsertion("app_bar_params");
  
  SnippetScreenBuildWithSPIImplT({
    String? templateFileId,
    required super.templateFolder,
    required super.embeddedInsertions,
  }): super(
    templateFileId: templateFileId ?? "screen_build_with_spi_impl"
  );

  factory SnippetScreenBuildWithSPIImplT.core() {
    return SnippetScreenBuildWithSPIImplT(
      templateFolder: AFProjectPaths.pathGenerateCoreSnippets,
      embeddedInsertions: const AFSourceTemplateInsertions(insertions: {
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
      embeddedInsertions: const AFSourceTemplateInsertions(insertions: {
        insertAppBarParams: AFSourceTemplate.empty,
      })
    );
  }


  @override
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

