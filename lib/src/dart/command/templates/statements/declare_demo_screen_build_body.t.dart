import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareDemoScreenBuildBodyT extends AFSourceTemplate {
  final String template = '''
    final t = spi.t;
    final rows = t.column();

    rows.add(AFUIWelcomeWidget(
      screenId: screenId,
    ));

    rows.add(_buildIncrementCard(spi));

    return ListView(
      children: rows
    );
''';  
}

