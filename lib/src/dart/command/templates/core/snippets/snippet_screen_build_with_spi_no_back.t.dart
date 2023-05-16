import 'package:afib/src/dart/command/af_source_template.dart';

class SnippetScreenBuildWithSPINoBackImplT extends AFCoreSnippetSourceTemplate {
  String get template => '''
final t = spi.t;
final body = _buildBody(spi);
return t.childScaffold(
  spi: spi,
  body: body,
  appBar: AppBar(
    title: t.childText(text: "$insertMainType"),
  ),
);
''';
}

