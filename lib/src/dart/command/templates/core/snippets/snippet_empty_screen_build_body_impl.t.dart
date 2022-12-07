import 'package:afib/src/dart/command/af_source_template.dart';

class SnippetMinimalScreenBuildBodyImplT extends AFCoreSnippetSourceTemplate {

  SnippetMinimalScreenBuildBodyImplT(): super(templateFileId: "minimal_screen_build_body_impl");

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

