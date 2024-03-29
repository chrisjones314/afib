
import 'package:afib/src/dart/command/af_source_template.dart';

/// Any class that ends in "T" is a source template used in code generation.
class SnippetDrawerBuildBodyT extends AFCoreSnippetSourceTemplate {

  SnippetDrawerBuildBodyT(): super(templateFileId: "drawer_build_body");
  
  @override
  String get template => '''
    final t = spi.t;
    final rows = t.column();
    
    rows.add(UserAccountsDrawerHeader(
        accountEmail: t.childText(text: "example@email.com"),
        accountName: Text("Washington Irving"),
        decoration: BoxDecoration(
          color: t.colorSecondary,
        ),
      )
    );

    rows.add(ListTile(
      key: t.keyForWID(${insertAppNamespaceUpper}WidgetID.standardClose),
      leading: Icon(Icons.close),
      title: Text('Close'),
      onTap: spi.onCloseDrawer,
    ));

    return Drawer(
      key: null,
      child: ListView(
        padding: EdgeInsets.zero,
        children: rows,
      )
    );
''';
}