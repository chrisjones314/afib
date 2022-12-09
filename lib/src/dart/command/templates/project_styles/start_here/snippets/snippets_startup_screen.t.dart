
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_declare_spi.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_extra_imports.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_navigate_push.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_standard_route_param.t.dart';



class SnippetStartupScreenBuildBodyT extends AFSnippetSourceTemplate {
  SnippetStartupScreenBuildBodyT(): super(
    templateFileId: "startup_screen_build_body",
    templateFolder: AFProjectPaths.pathGenerateExampleStartHereSnippets,
  );
  
  String get template => '''
final t = spi.t;
final rows = t.column();
rows.add(t.childMargin(
  margin: t.margin.v.biggest,  
  child: t.childText("Startup Screen", style: t.styleOnCard.headline4)
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
    templateFolder: AFProjectPaths.pathGenerateExampleStartHereSnippets,
  );
  
  String get template => '''
final t = spi.t;
final body = _buildBody(spi);
return t.childScaffold(
  spi: spi,
  body: body,
  appBar: AppBar(
    title: t.childText("${insertPackageName.spaces}"),
  ),
);
''';
}
