
import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareDrawerBuildBodyImplT extends AFSourceTemplate {
  final String template = '''
    final t = spi.t;
    final rows = t.column();
    
    rows.add(UserAccountsDrawerHeader(
        accountEmail: t.childText("example@email.com"),
        accountName: Text("Washington Irving"),
        decoration: BoxDecoration(
          color: t.colorSecondary,
        ),
      )
    );

    rows.add(ListTile(
      key: null,
      leading: Icon(Icons.close),
      title: Text('Close'),
      onTap: spi.onTapClose,
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