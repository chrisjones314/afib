import 'package:afib/src/dart/command/af_source_template.dart';

class SnippetStartupScreenCompleteProjectStyleT extends AFCoreSnippetSourceTemplate {

  SnippetStartupScreenCompleteProjectStyleT(): super(templateFileId: "snippet_startup_screen_complete_project_style");

  String get template => '''
final t = spi.t;
final rows = t.column();
rows.add(AFUICompleteProjectStyleWidget(
  projectStyle: '$insertProjectStyle',
));
return ListView(
  children: rows
);
''';
}

