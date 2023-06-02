import 'package:afib/src/dart/command/af_source_template.dart';

class SnippetNoScaffoldBuildWithSPIImplT extends AFCoreSnippetSourceTemplate {

  SnippetNoScaffoldBuildWithSPIImplT(): super(templateFileId: "no_scaffold_build_body");

  @override
  final String template = '''
    return _buildBody(spi);
''';
}

 