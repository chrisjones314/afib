import 'package:afib/src/dart/command/af_source_template.dart';

class SnippetEmptyScreenBuildBodyImplT extends AFCoreSnippetSourceTemplate {

  SnippetEmptyScreenBuildBodyImplT(): super(templateFileId: "empty_screen_build_body_impl");

  String get template => '''
final t = spi.t;
final rows = t.column();
rows.add(t.childCard(
  child: t.childMarginStandard(
    child: t.childText(text: "${AFSourceTemplate.insertMainTypeInsertion.spaces}", 
      textAlign: TextAlign.center, 
      style: t.styleOnCard.headline6
    )
  )
));
return ListView(
  children: rows
);
''';
}

