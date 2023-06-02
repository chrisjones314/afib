import 'package:afib/src/dart/command/af_source_template.dart';

/// Any class that ends in "T" is a source template used in code generation.
class SnippetEmptyScreenBuildBodyImplT extends AFCoreSnippetSourceTemplate {

  SnippetEmptyScreenBuildBodyImplT(): super(templateFileId: "empty_screen_build_body_impl");

  @override
  String get template => '''
final t = spi.t;
final rows = t.column();
rows.add(t.childCard(
  child: t.childMarginStandard(
    child: t.childText(text: "${AFSourceTemplate.insertMainTypeInsertion.spaces}", 
      textAlign: TextAlign.center, 
      style: t.styleOnCard.titleLarge
    )
  )
));
return ListView(
  children: rows
);
''';
}

