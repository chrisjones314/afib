
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';

class SnippetStartupScreenBuildBodyT extends AFSnippetSourceTemplate {
  SnippetStartupScreenBuildBodyT(): super(
    templateFileId: "startup_screen_build_body",
    templateFolder: AFProjectPaths.pathGenerateExampleEvalDemoSnippets,
  );
  
  String get template => '''
final t = spi.t;
final rows = t.column();
rows.add(t.childMargin(
  margin: t.margin.v.biggest,  
  child: t.childText(text: "Startup Screen", style: t.styleOnCard.headline4)
));
rows.add(t.childCaptionSimulatedLatency());
return Center(
  child: Column(children: rows)
);
''';
}

class SnippetStartupScreenBuildWithSPIImplT extends AFSnippetSourceTemplate {
  SnippetStartupScreenBuildWithSPIImplT(): super(
    templateFileId: "startup_screen_build_with_spi",
    templateFolder: AFProjectPaths.pathGenerateExampleEvalDemoSnippets,
  );
  
  String get template => '''
final t = spi.t;
final body = _buildBody(spi);
return t.childScaffold(
  spi: spi,
  body: body,
  appBar: AppBar(
    title: t.childText(text: "${insertPackageName.spaces}"),
  ),
);
''';
}
