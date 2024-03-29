import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';

class SnippetMinimalScreenBuildBodyImplT extends AFSnippetSourceTemplate {

  SnippetMinimalScreenBuildBodyImplT(): super(
    templateFileId: "minimal_startup_screen_build_body_impl",
    templateFolder: AFProjectPaths.pathGenerateStarterMinimalSnippets
  );

  @override
  String get template => '''
final t = spi.t;
final rows = t.column();
rows.add(AFUIWelcomeWidget());
rows.add(t.childCard(
  child: t.childMarginStandard(
    child: t.childText(text: "Startup Screen", 
      textAlign: TextAlign.center, 
      style: t.styleOnCard.titleLarge)
  )
));

final currentTime = spi.context.accessPushTime();
rows.add(AFUIDebugTimeStateWidget(displayTime: currentTime));

return ListView(
  children: rows
);
''';
}

