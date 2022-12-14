import 'package:afib/src/dart/command/af_source_template.dart';

class SnippetScreenBuildWithSPIImplT extends AFCoreSnippetSourceTemplate {
  SnippetScreenBuildWithSPIImplT(): super(templateFileId: "screen_build_with_spi_impl");
  
  String get template => '''
    final t = spi.t;
    final body = _buildBody(spi);
    return t.childScaffold(
      spi: spi,
      body: body,
      appBar: AppBar(
        title: t.childText("${insertMainType.spaces}")
      ),
    );
''';
}
