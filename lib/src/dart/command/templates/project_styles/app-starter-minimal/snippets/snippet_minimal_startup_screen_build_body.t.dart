import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';

class SnippetMinimalScreenBuildBodyImplT extends AFSnippetSourceTemplate {

  SnippetMinimalScreenBuildBodyImplT(): super(
    templateFileId: "minimal_startup_screen_build_body_impl",
    templateFolder: AFProjectPaths.pathGenerateStarterMinimalSnippets
  );

  String get template => '''
final t = spi.t;
final rows = t.column();
rows.add(AFUIWelcomeWidget());
rows.add(t.childCard(
  child: t.childMarginStandard(
    child: t.childText("Startup Screen", 
      textAlign: TextAlign.center, 
      style: t.styleOnCard.headline6)
  )
));
return ListView(
  children: rows
);
''';
}

