import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareScreenBuildWithSPIImplT extends AFSourceTemplate {
  final String template = '''
    final t = spi.t;
    final body = _buildBody(spi);
    return t.childScaffold(
      spi: spi,
      body: body,
      appBar: AppBar(
        title: t.childText(uiTitle),
        leading: t.childButtonStandardBack(spi, screen: screenId, shouldContinueCheck: () async {
          return AFShouldContinue.yesContinue; 
        })
      ),
    );
''';
}

